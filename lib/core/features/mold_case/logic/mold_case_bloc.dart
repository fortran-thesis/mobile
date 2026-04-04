import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/repository/mold_case_repository.dart';
import 'package:moldify/core/utils/cache_invalidation.dart';
import 'package:moldify/core/utils/logger.dart';

// Events
abstract class MoldCaseEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMoldCases extends MoldCaseEvent {
  final String? pageToken;
  final String? sessionCookie;
  FetchMoldCases({this.pageToken, this.sessionCookie});
  @override
  List<Object?> get props => [pageToken, sessionCookie];
}

class RefreshMoldCases extends MoldCaseEvent {
  final String? sessionCookie;
  RefreshMoldCases({this.sessionCookie});
  @override
  List<Object?> get props => [sessionCookie];
}

class SearchMoldCases extends MoldCaseEvent {
  final String? searchQuery;
  final String? priorityFilter;
  final String? sessionCookie;
  SearchMoldCases({this.searchQuery, this.priorityFilter, this.sessionCookie});
  @override
  List<Object?> get props => [searchQuery, priorityFilter, sessionCookie];
}

// States
abstract class MoldCaseState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MoldCaseInitial extends MoldCaseState {}

class MoldCaseLoading extends MoldCaseState {}

class MoldCaseLoaded extends MoldCaseState {
  final List<MoldCase> cases;
  final String? nextPageToken;
  final bool hasMore;
  MoldCaseLoaded({required this.cases, this.nextPageToken, required this.hasMore});
  @override
  List<Object?> get props => [cases, nextPageToken, hasMore];
}

class MoldCaseError extends MoldCaseState {
  final String message;
  MoldCaseError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class MoldCaseBloc extends Bloc<MoldCaseEvent, MoldCaseState> {
  final MoldCaseRepository repository;
  final int pageSize;
  static const Duration _invalidationCooldown = Duration(milliseconds: 500);
  
  // Track pages ourselves now that repository is simplified
  final List<MoldCase> _allCases = [];
  String? _nextPageToken;
  String? _lastSessionCookie;
  DateTime _lastInvalidationAt = DateTime.fromMillisecondsSinceEpoch(0);
  late final StreamSubscription<CacheInvalidationEvent> _invalidationSub;

  MoldCaseBloc({required this.repository, this.pageSize = 20}) : super(MoldCaseInitial()) {
    on<FetchMoldCases>(_onFetch);
    on<RefreshMoldCases>(_onRefresh);
    on<SearchMoldCases>(_onSearch);

    _invalidationSub = CacheInvalidationHub.instance.stream.listen((event) {
      final shouldRefresh =
          event.entity == InvalidationEntity.moldCase ||
          event.entity == InvalidationEntity.moldReport;
      if (!shouldRefresh) return;

      final now = DateTime.now().toUtc();
      if (now.difference(_lastInvalidationAt) < _invalidationCooldown) return;
      _lastInvalidationAt = now;

      add(RefreshMoldCases(sessionCookie: _lastSessionCookie));
    });
  }

  List<MoldCase> _dedupeByReportIdPreferHigherPriority(List<MoldCase> cases) {
    final priorityOrder = {'low': 1, 'medium': 2, 'high': 3};
    final Map<String, MoldCase> byReport = {};

    for (final moldCase in cases) {
      final key = moldCase.moldReportId.trim().isNotEmpty
          ? moldCase.moldReportId
          : moldCase.id;
      final existing = byReport[key];
      if (existing == null) {
        byReport[key] = moldCase;
        continue;
      }

      final existingRank = priorityOrder[existing.priority.toLowerCase()] ?? 0;
      final currentRank = priorityOrder[moldCase.priority.toLowerCase()] ?? 0;
      if (currentRank > existingRank) {
        byReport[key] = moldCase;
      }
    }

    return byReport.values.toList();
  }

  Future<void> _onFetch(FetchMoldCases event, Emitter<MoldCaseState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    try {
      if (event.pageToken == null) {
        emit(MoldCaseLoading());
        // First page - reset all cases
        _allCases.clear();
        _nextPageToken = null;
      }

      final result = await repository.fetchPageWithToken(
        pageToken: event.pageToken, 
        sessionCookie: event.sessionCookie,
      );
      
      final pageCases = result['cases'] as List<MoldCase>;
      final nextToken = result['nextPageToken'] as String?;

      final merged = <MoldCase>[..._allCases, ...pageCases];
      final deduped = _dedupeByReportIdPreferHigherPriority(merged);
      AppLogger.d('MoldCaseBloc: fetched ${pageCases.length} cases, merged ${merged.length}, deduped to ${deduped.length} by mold_report_id');

      _allCases
        ..clear()
        ..addAll(deduped);
      _nextPageToken = nextToken;
      
      // hasMore is true if we have a nextPageToken from the server
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      
      emit(MoldCaseLoaded(cases: List.from(_allCases), nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshMoldCases event, Emitter<MoldCaseState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    try {
      emit(MoldCaseLoading());
      _allCases.clear();
      _nextPageToken = null;
      
      final result = await repository.fetchPageWithToken(
        pageToken: null, 
        sessionCookie: event.sessionCookie,
      );
      
      final pageCases = result['cases'] as List<MoldCase>;
      final nextToken = result['nextPageToken'] as String?;

      final deduped = _dedupeByReportIdPreferHigherPriority(pageCases);
      _allCases.addAll(deduped);
      _nextPageToken = nextToken;
      
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      
      emit(MoldCaseLoaded(cases: _allCases, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchMoldCases event, Emitter<MoldCaseState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    try {
      emit(MoldCaseLoading());
      _allCases.clear();
      _nextPageToken = null;

      final result = await repository.searchCasesWithToken(
        search: event.searchQuery,
        priority: event.priorityFilter,
        sessionCookie: event.sessionCookie,
      );

      final searchCases = result['cases'] as List<MoldCase>;
      final nextToken = result['nextPageToken'] as String?;

      final deduped = _dedupeByReportIdPreferHigherPriority(searchCases);
      _allCases.addAll(deduped);
      _nextPageToken = nextToken;
      
      final hasMore = nextToken != null && nextToken.isNotEmpty;

      emit(MoldCaseLoaded(cases: List.from(_allCases), nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _invalidationSub.cancel();
    return super.close();
  }
}
