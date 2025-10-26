import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/mold_report/models/mold_report.dart';
import 'package:moldify/core/features/mold_report/repository/mold_report_repository.dart';

// Events
abstract class MoldReportEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMoldReports extends MoldReportEvent {
  final String? pageToken;
  final bool useCache;
  final String? sessionCookie;
  FetchMoldReports({this.pageToken, this.useCache = true, this.sessionCookie});
  @override
  List<Object?> get props => [pageToken, useCache, sessionCookie];
}

class RefreshMoldReports extends MoldReportEvent {
  final String? sessionCookie;
  RefreshMoldReports({this.sessionCookie});
  @override
  List<Object?> get props => [sessionCookie];
}

class CreateMoldReportEvent extends MoldReportEvent {
  final MoldReport report;
  final String? sessionCookie;
  CreateMoldReportEvent(this.report, {this.sessionCookie});
  @override
  List<Object?> get props => [report, sessionCookie];
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

  MoldReportBloc({required this.repository, this.pageSize = 20}) : super(MoldReportInitial()) {
    on<FetchMoldReports>(_onFetch);
    on<RefreshMoldReports>(_onRefresh);
    on<CreateMoldReportEvent>(_onCreate);
  }

  Future<void> _onFetch(FetchMoldReports event, Emitter<MoldReportState> emit) async {
    try {
      if (event.pageToken == null && !(event.useCache)) {
        emit(MoldReportLoading());
      }

  await repository.fetchPage(pageToken: event.pageToken, useCache: event.useCache, sessionCookie: event.sessionCookie);

  final combined = repository.getCachedReports();
      final nextToken = repository.getNextPageToken(event.pageToken);
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      emit(MoldReportLoaded(reports: combined, nextPageToken: nextToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshMoldReports event, Emitter<MoldReportState> emit) async {
    try {
      emit(MoldReportLoading());
  repository.clearCache();
  await repository.fetchPage(pageToken: null, useCache: false, sessionCookie: event.sessionCookie);
  final combined = repository.getCachedReports();
  final nextToken = repository.getNextPageToken(null);
  final hasMore = nextToken != null && nextToken.isNotEmpty;
  emit(MoldReportLoaded(reports: combined, nextPageToken: nextToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }

  Future<void> _onCreate(CreateMoldReportEvent event, Emitter<MoldReportState> emit) async {
    try {
      emit(MoldReportCreating());
      await repository.createReport(event.report, sessionCookie: event.sessionCookie);
  emit(MoldReportCreateSuccess());
  // refresh page 1 from cache
  final combined = repository.getCachedReports();
  final nextToken = repository.getNextPageToken(null);
  final hasMore = nextToken != null && nextToken.isNotEmpty;
  emit(MoldReportLoaded(reports: combined, nextPageToken: nextToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }
}
