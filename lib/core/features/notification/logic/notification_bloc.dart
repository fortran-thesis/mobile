import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/notification/models/notification.dart';
import 'package:moldify/core/features/notification/repository/notification_repository.dart';
import 'package:moldify/core/utils/logger.dart';

// ── Events ──────────────────────────────────────────────────────────────────

abstract class NotificationEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationEvent {
  final String? pageToken;
  final String? sessionCookie;
  FetchNotifications({this.pageToken, this.sessionCookie});
  @override
  List<Object?> get props => [pageToken, sessionCookie];
}

class RefreshNotifications extends NotificationEvent {
  final String? sessionCookie;
  RefreshNotifications({this.sessionCookie});
  @override
  List<Object?> get props => [sessionCookie];
}

class FetchUnreadCount extends NotificationEvent {
  final String? sessionCookie;
  FetchUnreadCount({this.sessionCookie});
  @override
  List<Object?> get props => [sessionCookie];
}

class MarkNotificationRead extends NotificationEvent {
  final String notificationId;
  final String? sessionCookie;
  MarkNotificationRead({required this.notificationId, this.sessionCookie});
  @override
  List<Object?> get props => [notificationId, sessionCookie];
}

class MarkAllNotificationsRead extends NotificationEvent {
  final String? sessionCookie;
  MarkAllNotificationsRead({this.sessionCookie});
  @override
  List<Object?> get props => [sessionCookie];
}

class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;
  final String? sessionCookie;
  DeleteNotificationEvent({required this.notificationId, this.sessionCookie});
  @override
  List<Object?> get props => [notificationId, sessionCookie];
}

// ── States ──────────────────────────────────────────────────────────────────

abstract class NotificationState extends Equatable {
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;
  final int unreadCount;
  final String? nextPageToken;
  final bool hasMore;

  NotificationLoaded({
    required this.notifications,
    required this.unreadCount,
    this.nextPageToken,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, nextPageToken, hasMore];
}

class NotificationError extends NotificationState {
  final String message;
  NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Bloc ────────────────────────────────────────────────────────────────────

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository repository;
  final int pageSize;

  final List<AppNotification> _allNotifications = [];
  String? _nextPageToken;
  int _unreadCount = 0;

  NotificationBloc({required this.repository, this.pageSize = 20})
      : super(NotificationInitial()) {
    on<FetchNotifications>(_onFetch);
    on<RefreshNotifications>(_onRefresh);
    on<FetchUnreadCount>(_onFetchUnreadCount);
    on<MarkNotificationRead>(_onMarkRead);
    on<MarkAllNotificationsRead>(_onMarkAllRead);
    on<DeleteNotificationEvent>(_onDelete);
  }

  Future<void> _onFetch(FetchNotifications event, Emitter<NotificationState> emit) async {
    try {
      if (_allNotifications.isEmpty) emit(NotificationLoading());

      final page = await repository.fetchPage(
        pageToken: event.pageToken ?? _nextPageToken,
        sessionCookie: event.sessionCookie,
      );

      _allNotifications.addAll(page);
      _nextPageToken = page.length >= pageSize ? page.last.id : null;

      // Also refresh unread count
      _unreadCount = await repository.fetchUnreadCount(sessionCookie: event.sessionCookie);

      emit(NotificationLoaded(
        notifications: List.unmodifiable(_allNotifications),
        unreadCount: _unreadCount,
        nextPageToken: _nextPageToken,
        hasMore: page.length >= pageSize,
      ));
    } catch (e) {
      AppLogger.e('NotificationBloc._onFetch error: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshNotifications event, Emitter<NotificationState> emit) async {
    try {
      _allNotifications.clear();
      _nextPageToken = null;
      emit(NotificationLoading());

      final page = await repository.fetchPage(
        sessionCookie: event.sessionCookie,
      );

      _allNotifications.addAll(page);
      _nextPageToken = page.length >= pageSize ? page.last.id : null;

      _unreadCount = await repository.fetchUnreadCount(sessionCookie: event.sessionCookie);

      emit(NotificationLoaded(
        notifications: List.unmodifiable(_allNotifications),
        unreadCount: _unreadCount,
        nextPageToken: _nextPageToken,
        hasMore: page.length >= pageSize,
      ));
    } catch (e) {
      AppLogger.e('NotificationBloc._onRefresh error: $e');
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onFetchUnreadCount(FetchUnreadCount event, Emitter<NotificationState> emit) async {
    try {
      _unreadCount = await repository.fetchUnreadCount(sessionCookie: event.sessionCookie);

      if (state is NotificationLoaded) {
        final current = state as NotificationLoaded;
        emit(NotificationLoaded(
          notifications: current.notifications,
          unreadCount: _unreadCount,
          nextPageToken: current.nextPageToken,
          hasMore: current.hasMore,
        ));
      }
    } catch (e) {
      AppLogger.e('NotificationBloc._onFetchUnreadCount error: $e');
    }
  }

  Future<void> _onMarkRead(MarkNotificationRead event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAsRead(event.notificationId, sessionCookie: event.sessionCookie);

      // Optimistic update
      final idx = _allNotifications.indexWhere((n) => n.id == event.notificationId);
      if (idx != -1) {
        _allNotifications[idx] = _allNotifications[idx].copyWithRead();
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }

      emit(NotificationLoaded(
        notifications: List.unmodifiable(_allNotifications),
        unreadCount: _unreadCount,
        nextPageToken: _nextPageToken,
        hasMore: _allNotifications.length >= pageSize,
      ));
    } catch (e) {
      AppLogger.e('NotificationBloc._onMarkRead error: $e');
    }
  }

  Future<void> _onMarkAllRead(MarkAllNotificationsRead event, Emitter<NotificationState> emit) async {
    try {
      await repository.markAllAsRead(sessionCookie: event.sessionCookie);

      for (var i = 0; i < _allNotifications.length; i++) {
        if (!_allNotifications[i].isRead) {
          _allNotifications[i] = _allNotifications[i].copyWithRead();
        }
      }
      _unreadCount = 0;

      emit(NotificationLoaded(
        notifications: List.unmodifiable(_allNotifications),
        unreadCount: 0,
        nextPageToken: _nextPageToken,
        hasMore: _allNotifications.length >= pageSize,
      ));
    } catch (e) {
      AppLogger.e('NotificationBloc._onMarkAllRead error: $e');
    }
  }

  Future<void> _onDelete(DeleteNotificationEvent event, Emitter<NotificationState> emit) async {
    try {
      await repository.deleteNotification(event.notificationId, sessionCookie: event.sessionCookie);

      final removed = _allNotifications.firstWhere(
        (n) => n.id == event.notificationId,
        orElse: () => AppNotification(id: '', recipientId: '', type: '', title: '', body: '', isRead: true),
      );
      if (!removed.isRead) {
        _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
      }
      _allNotifications.removeWhere((n) => n.id == event.notificationId);

      emit(NotificationLoaded(
        notifications: List.unmodifiable(_allNotifications),
        unreadCount: _unreadCount,
        nextPageToken: _nextPageToken,
        hasMore: _allNotifications.length >= pageSize,
      ));
    } catch (e) {
      AppLogger.e('NotificationBloc._onDelete error: $e');
    }
  }
}
