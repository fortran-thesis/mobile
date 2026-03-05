import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/repository/mold_case_repository.dart';
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
  
  // Track pages ourselves now that repository is simplified
  final List<MoldCase> _allCases = [];
  String? _nextPageToken;

  MoldCaseBloc({required this.repository, this.pageSize = 20}) : super(MoldCaseInitial()) {
    on<FetchMoldCases>(_onFetch);
    on<RefreshMoldCases>(_onRefresh);
    on<SearchMoldCases>(_onSearch);
  }

  Future<void> _onFetch(FetchMoldCases event, Emitter<MoldCaseState> emit) async {
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
      
      // Deduplicate: only add cases with IDs we haven't seen yet
      final existingIds = _allCases.map((c) => c.id).toSet();
      final newCases = pageCases.where((c) => !existingIds.contains(c.id)).toList();
      
      AppLogger.d('MoldCaseBloc: fetched ${pageCases.length} cases, adding ${newCases.length} new unique cases (filtered ${pageCases.length - newCases.length} duplicates)');
      
      _allCases.addAll(newCases);
      _nextPageToken = nextToken;
      
      // hasMore is true if we have a nextPageToken from the server
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      
      emit(MoldCaseLoaded(cases: List.from(_allCases), nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshMoldCases event, Emitter<MoldCaseState> emit) async {
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
      
      _allCases.addAll(pageCases);
      _nextPageToken = nextToken;
      
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      
      emit(MoldCaseLoaded(cases: _allCases, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }

  Future<void> _onSearch(SearchMoldCases event, Emitter<MoldCaseState> emit) async {
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
      
      _allCases.addAll(searchCases);
      _nextPageToken = nextToken;
      
      final hasMore = nextToken != null && nextToken.isNotEmpty;

      emit(MoldCaseLoaded(cases: List.from(_allCases), nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }
}
