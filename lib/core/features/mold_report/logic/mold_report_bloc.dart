import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/mold_report/models/mold_report.dart';
import 'package:moldify/core/features/mold_report/repository/mold_report_repository.dart';
import 'package:moldify/core/utils/cache_invalidation.dart';

// Events
abstract class MoldReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMoldReports extends MoldReportEvent {
  final String? pageToken;
  final String? sessionCookie;
  final String scope;
  FetchMoldReports({this.pageToken, this.sessionCookie, this.scope = 'own'});
  @override
  List<Object?> get props => [pageToken, sessionCookie, scope];
}

class RefreshMoldReports extends MoldReportEvent {
  final String? sessionCookie;
  final String scope;
  RefreshMoldReports({this.sessionCookie, this.scope = 'own'});
  @override
  List<Object?> get props => [sessionCookie, scope];
}

class CreateMoldReportEvent extends MoldReportEvent {
  final MoldReport report;
  final String? sessionCookie;
  CreateMoldReportEvent(this.report, {this.sessionCookie});
  @override
  List<Object?> get props => [report, sessionCookie];
}

class SearchMoldReports extends MoldReportEvent {
  final String? searchQuery;
  final String? statusFilter;
  final String? sessionCookie;
  final String scope;
  SearchMoldReports({
    this.searchQuery,
    this.statusFilter,
    this.sessionCookie,
    this.scope = 'own',
  });
  @override
  List<Object?> get props => [searchQuery, statusFilter, sessionCookie, scope];
}

// States
abstract class MoldReportState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MoldReportInitial extends MoldReportState {}

class MoldReportLoading extends MoldReportState {}

class MoldReportLoaded extends MoldReportState {
  final List<MoldReport> reports;
  final String? nextPageToken;
  final bool hasMore;
  MoldReportLoaded({required this.reports, this.nextPageToken, required this.hasMore});
  @override
  List<Object?> get props => [reports, nextPageToken, hasMore];
}

class MoldReportError extends MoldReportState {
  final String message;
  MoldReportError(this.message);
  @override
  List<Object?> get props => [message];
}

class MoldReportCreating extends MoldReportState {}

class MoldReportCreateSuccess extends MoldReportState {}

// Bloc
class MoldReportBloc extends Bloc<MoldReportEvent, MoldReportState> {
  final MoldReportRepository repository;
  final int pageSize;
  static const Duration _invalidationCooldown = Duration(milliseconds: 500);
  
  // Track pages ourselves now that repository is simplified
  final List<MoldReport> _allReports = [];
  String? _nextPageToken;
  String? _lastSessionCookie;
  String _lastScope = 'own';
  DateTime _lastInvalidationAt = DateTime.fromMillisecondsSinceEpoch(0);
  late final StreamSubscription<CacheInvalidationEvent> _invalidationSub;

  MoldReportBloc({required this.repository, this.pageSize = 20}) : super(MoldReportInitial()) {
    on<FetchMoldReports>(_onFetch);
    on<RefreshMoldReports>(_onRefresh);
    on<CreateMoldReportEvent>(_onCreate);
    on<SearchMoldReports>(_onSearch);

    _invalidationSub = CacheInvalidationHub.instance.stream.listen((event) {
      final shouldRefresh =
          event.entity == InvalidationEntity.moldReport ||
          event.entity == InvalidationEntity.moldCase;
      if (!shouldRefresh) return;

      final now = DateTime.now().toUtc();
      if (now.difference(_lastInvalidationAt) < _invalidationCooldown) return;
      _lastInvalidationAt = now;

      add(
        RefreshMoldReports(
          sessionCookie: _lastSessionCookie,
          scope: _lastScope,
        ),
      );
    });
  }

  Future<void> _onFetch(FetchMoldReports event, Emitter<MoldReportState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    _lastScope = event.scope;
    try {
      if (event.pageToken == null) {
        emit(MoldReportLoading());
      }

      final page = await repository.fetchPageWithToken(
        pageToken: event.pageToken,
        sessionCookie: event.sessionCookie,
        scope: event.scope,
      );
      final pageReports = page['reports'] as List<MoldReport>;
      final incomingNextPageToken = page['nextPageToken'] as String?;
      
      if (event.pageToken == null) {
        // First page - reset all reports
        _allReports.clear();
        _nextPageToken = null;
      }
      
      _allReports.addAll(pageReports);
      // Loop guard: if backend echoes the same token, stop paginating to avoid infinite fetch.
      if (event.pageToken != null && incomingNextPageToken == event.pageToken) {
        _nextPageToken = null;
      } else {
        _nextPageToken = incomingNextPageToken;
      }
      
      final hasMore = _nextPageToken != null && _nextPageToken!.isNotEmpty;
      emit(MoldReportLoaded(reports: _allReports, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshMoldReports event, Emitter<MoldReportState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    _lastScope = event.scope;
    try {
      emit(MoldReportLoading());
      _allReports.clear();
      _nextPageToken = null;
      
      final page = await repository.fetchPageWithToken(pageToken: null, sessionCookie: event.sessionCookie, scope: event.scope);
      final pageReports = page['reports'] as List<MoldReport>;
      final incomingNextPageToken = page['nextPageToken'] as String?;
      _allReports.addAll(pageReports);
      _nextPageToken = incomingNextPageToken;
      
      final hasMore = _nextPageToken != null && _nextPageToken!.isNotEmpty;
      emit(MoldReportLoaded(reports: _allReports, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateMoldReportEvent event, Emitter<MoldReportState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    try {
      emit(MoldReportCreating());
      // Call service directly to create report
      await repository.createMoldReport(event.report, sessionCookie: event.sessionCookie);
      emit(MoldReportCreateSuccess());
      // Refresh to get updated list
      _allReports.clear();
      _nextPageToken = null;
      final page = await repository.fetchPageWithToken(pageToken: null, sessionCookie: event.sessionCookie, scope: 'own');
      final pageReports = page['reports'] as List<MoldReport>;
      final incomingNextPageToken = page['nextPageToken'] as String?;
      _allReports.addAll(pageReports);
      _nextPageToken = incomingNextPageToken;
      final hasMore = _nextPageToken != null && _nextPageToken!.isNotEmpty;
      emit(MoldReportLoaded(reports: _allReports, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchMoldReports event, Emitter<MoldReportState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    _lastScope = event.scope;
    try {
      emit(MoldReportLoading());
      _allReports.clear();
      _nextPageToken = null;

      // Normalize status filter to lowercase
      String? normalizedStatus = event.statusFilter;
      if (normalizedStatus != null) {
        if (normalizedStatus.toLowerCase() == 'all') {
          normalizedStatus = null; // No filter for "All"
        } else {
          // Convert "In Progress" -> "in progress", etc.
          normalizedStatus = normalizedStatus.toLowerCase().replaceAll(' ', ' ');
        }
      }

      final searchResults = await repository.searchReports(
        search: event.searchQuery,
        status: normalizedStatus,
        pageToken: null,
        sessionCookie: event.sessionCookie,
        scope: event.scope,
      );

      _allReports.addAll(searchResults);
      _nextPageToken = null;

      final hasMore = _nextPageToken != null && _nextPageToken!.isNotEmpty;
      emit(MoldReportLoaded(reports: _allReports, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _invalidationSub.cancel();
    return super.close();
  }
}
