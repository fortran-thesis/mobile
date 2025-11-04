import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/mold_case/models/mold_case.dart';
import 'package:moldify/core/features/mold_case/repository/mold_case_repository.dart';

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
  }

  Future<void> _onFetch(FetchMoldCases event, Emitter<MoldCaseState> emit) async {
    try {
      if (event.pageToken == null) {
        emit(MoldCaseLoading());
        // First page - reset all cases
        _allCases.clear();
        _nextPageToken = null;
      }

      final pageCases = await repository.fetchPage(pageToken: event.pageToken, sessionCookie: event.sessionCookie);
      
      // Deduplicate: only add cases with IDs we haven't seen yet
      final existingIds = _allCases.map((c) => c.id).toSet();
      final newCases = pageCases.where((c) => !existingIds.contains(c.id)).toList();
      
      print('MoldCaseBloc: fetched ${pageCases.length} cases, adding ${newCases.length} new unique cases (filtered ${pageCases.length - newCases.length} duplicates)');
      
      _allCases.addAll(newCases);
      // If we got fewer items than pageSize, there's no more data
      // hasMore is determined by: did we get a full page? If so, assume there could be more
      final hasMore = pageCases.length >= pageSize;
      _nextPageToken = hasMore ? (pageCases.isNotEmpty ? 'next_token_placeholder' : null) : null;
      
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
      
      final pageCases = await repository.fetchPage(pageToken: null, sessionCookie: event.sessionCookie);
      _allCases.addAll(pageCases);
      
      // If we got fewer items than pageSize, there's no more data
      final hasMore = pageCases.length >= pageSize;
      _nextPageToken = hasMore ? (pageCases.isNotEmpty ? 'next_token_placeholder' : null) : null;
      
      emit(MoldCaseLoaded(cases: _allCases, nextPageToken: _nextPageToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }
}
