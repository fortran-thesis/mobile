import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moldify/core/features/user/models/user_profile.dart';
import 'package:moldify/core/features/user/services/user_services.dart';
import 'package:equatable/equatable.dart';
import 'package:moldify/core/utils/cache_invalidation.dart';
import 'package:moldify/core/utils/logger.dart';

// Events
abstract class UserEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserProfile extends UserEvent {
  final String? sessionCookie;
  FetchUserProfile({this.sessionCookie});
  @override
  List<Object?> get props => [sessionCookie];
}

class ResetUserProfile extends UserEvent {}

// States
abstract class UserState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserState {}
class UserProfileLoading extends UserState {}
class UserProfileLoaded extends UserState {
  final UserProfile profile;
  UserProfileLoaded(this.profile);
  @override
  List<Object?> get props => [profile];
}
class UserProfileError extends UserState {
  final String message;
  UserProfileError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class UserBloc extends Bloc<UserEvent, UserState> {
  final UserService userService;
  String? _lastSessionCookie;
  late final StreamSubscription<CacheInvalidationEvent> _invalidationSub;

  UserBloc({required this.userService}) : super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<ResetUserProfile>(_onResetUserProfile);

    _invalidationSub = CacheInvalidationHub.instance.stream.listen((event) {
      if (event.entity == InvalidationEntity.authSession) {
        add(ResetUserProfile());
        return;
      }
      if (event.entity != InvalidationEntity.userProfile) return;
      add(FetchUserProfile(sessionCookie: _lastSessionCookie));
    });
  }

  void _onResetUserProfile(ResetUserProfile event, Emitter<UserState> emit) {
    _lastSessionCookie = null;
    emit(UserProfileInitial());
  }

  Future<void> _onFetchUserProfile(FetchUserProfile event, Emitter<UserState> emit) async {
    _lastSessionCookie = event.sessionCookie;
    AppLogger.d('UserBloc: FetchUserProfile with sessionCookie: ${event.sessionCookie}');
    emit(UserProfileLoading());
    try {
      final response = await userService.getUserProfile(event.sessionCookie);
      AppLogger.d('UserBloc: getUserProfile response: ${response.toString()}');
      if (response['success'] == true && response['data'] != null) {
        final profile = UserProfile.fromJson({'data': response['data']});
        AppLogger.d('UserBloc: UserProfile.fromJson: ${profile.toString()}');
        emit(UserProfileLoaded(profile));
      } else {
        emit(UserProfileError(response['error']?.toString() ?? 'Unknown error'));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  @override
  Future<void> close() async {
    await _invalidationSub.cancel();
    return super.close();
  }
}
