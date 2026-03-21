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
  final String? sessionCookie;
  FetchMoldReports({this.pageToken, this.sessionCookie});
  @override
  List<Object?> get props => [pageToken, sessionCookie];
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

class SearchMoldReports extends MoldReportEvent {
  final String? searchQuery;
  final String? statusFilter;
  final String? sessionCookie;
  SearchMoldReports({
    this.searchQuery,
    this.statusFilter,
    this.sessionCookie,
  });
  @override
  List<Object?> get props => [searchQuery, statusFilter, sessionCookie];
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
  
  // Track pages ourselves now that repository is simplified
  final List<MoldReport> _allReports = [];
  String? _nextPageToken;

  MoldReportBloc({required this.repository, this.pageSize = 20}) : super(MoldReportInitial()) {
    on<FetchMoldReports>(_onFetch);
    on<RefreshMoldReports>(_onRefresh);
    on<CreateMoldReportEvent>(_onCreate);
    on<SearchMoldReports>(_onSearch);
  }

  Future<void> _onFetch(FetchMoldReports event, Emitter<MoldReportState> emit) async {
    try {
      if (event.pageToken == null) {
        emit(MoldReportLoading());
      }

      final page = await repository.fetchPageWithToken(
        pageToken: event.pageToken,
        sessionCookie: event.sessionCookie,
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
    try {
      emit(MoldReportLoading());
      _allReports.clear();
      _nextPageToken = null;
      
      final page = await repository.fetchPageWithToken(pageToken: null, sessionCookie: event.sessionCookie);
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
    try {
      emit(MoldReportCreating());
      // Call service directly to create report
      await repository.createMoldReport(event.report, sessionCookie: event.sessionCookie);
      emit(MoldReportCreateSuccess());
      // Refresh to get updated list
      _allReports.clear();
      _nextPageToken = null;
      final page = await repository.fetchPageWithToken(pageToken: null, sessionCookie: event.sessionCookie);
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
      );

      _allReports.addAll(searchResults);
      _nextPageToken = null;

      final hasMore = _nextPageToken != null && _nextPageToken!.isNotEmpty;
      emit(MoldReportLoaded(reports: _allReports, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }
}
