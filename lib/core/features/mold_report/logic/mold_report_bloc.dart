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
  }

  Future<void> _onFetch(FetchMoldReports event, Emitter<MoldReportState> emit) async {
    try {
      if (event.pageToken == null) {
        emit(MoldReportLoading());
      }

      final pageReports = await repository.fetchPage(pageToken: event.pageToken, sessionCookie: event.sessionCookie);
      
      if (event.pageToken == null) {
        // First page - reset all reports
        _allReports.clear();
        _nextPageToken = null;
      }
      
      _allReports.addAll(pageReports);
      // In a real implementation, you'd extract nextPageToken from response
      // For now, assume if we got a full page, there might be more
      _nextPageToken = pageReports.length >= pageSize ? event.pageToken : null;
      
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
      
      final pageReports = await repository.fetchPage(pageToken: null, sessionCookie: event.sessionCookie);
      _allReports.addAll(pageReports);
      _nextPageToken = pageReports.length >= pageSize ? null : null; // First page, no token yet
      
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
      final pageReports = await repository.fetchPage(pageToken: null, sessionCookie: event.sessionCookie);
      _allReports.addAll(pageReports);
      final hasMore = _nextPageToken != null && _nextPageToken!.isNotEmpty;
      emit(MoldReportLoaded(reports: _allReports, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldReportError(e.toString()));
    }
  }
}
