import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:developer' as developer;

import '../../../domain/entities/profile_interaction_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/get_user_interactions_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required GetUserInteractions getUserInteractions,
  }) : _getCurrentUser = getCurrentUser,
       _getUserInteractions = getUserInteractions,
       super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final GetUserInteractions _getUserInteractions;
  static const Duration _profileLoadTimeout = Duration(seconds: 5);
  static const Duration _interactionLoadTimeout = Duration(seconds: 5);
  bool _isRequestInFlight = false;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    if (_isRequestInFlight) {
      return;
    }
    _isRequestInFlight = true;
    developer.log('profile_state_loading', name: 'profile');
    emit(
      state.copyWith(status: ProfileStatus.loading, clearErrorMessage: true),
    );
    try {
      final UserEntity user = await _getCurrentUser().timeout(_profileLoadTimeout);
      List<ProfileInteractionEntity> interactions =
          const <ProfileInteractionEntity>[];
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          user: user,
          interactions: interactions,
          clearErrorMessage: true,
        ),
      );
      developer.log(
        'profile_state_loaded',
        name: 'profile',
        error: <String, Object?>{'userId': user.id, 'shortCode': user.shortCode},
      );
      try {
        interactions = await _getUserInteractions(user.id).timeout(
          _interactionLoadTimeout,
        );
        emit(
          state.copyWith(
            status: ProfileStatus.success,
            user: user,
            interactions: interactions,
            clearErrorMessage: true,
          ),
        );
      } catch (_) {
        // Keep profile usable even if interactions fail or time out.
      }
    } catch (error) {
      developer.log('profile_state_error', name: 'profile', error: error);
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: '$error'));
    } finally {
      _isRequestInFlight = false;
    }
  }
}
