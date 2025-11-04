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
  final bool useCache;
  final String? sessionCookie;
  FetchMoldCases({this.pageToken, this.useCache = true, this.sessionCookie});
  @override
  List<Object?> get props => [pageToken, useCache, sessionCookie];
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

  MoldCaseBloc({required this.repository, this.pageSize = 20}) : super(MoldCaseInitial()) {
    on<FetchMoldCases>(_onFetch);
    on<RefreshMoldCases>(_onRefresh);
  }

  Future<void> _onFetch(FetchMoldCases event, Emitter<MoldCaseState> emit) async {
    try {
      if (event.pageToken == null && !(event.useCache)) {
        emit(MoldCaseLoading());
      }

      await repository.fetchPage(pageToken: event.pageToken, useCache: event.useCache, sessionCookie: event.sessionCookie);

      final combined = repository.getCachedCases();
      final nextToken = repository.getNextPageToken(event.pageToken);
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      emit(MoldCaseLoaded(cases: combined, nextPageToken: nextToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }

  Future<void> _onRefresh(RefreshMoldCases event, Emitter<MoldCaseState> emit) async {
    try {
      emit(MoldCaseLoading());
      repository.clearCache();
      await repository.fetchPage(pageToken: null, useCache: false, sessionCookie: event.sessionCookie);
      final combined = repository.getCachedCases();
      final nextToken = repository.getNextPageToken(null);
      final hasMore = nextToken != null && nextToken.isNotEmpty;
      emit(MoldCaseLoaded(cases: combined, nextPageToken: nextToken, hasMore: hasMore));
    } catch (e) {
      emit(MoldCaseError(e.toString()));
    }
  }
}
