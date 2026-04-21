import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/errors/exceptions.dart';
import '../../../domain/entities/profile_interaction_entity.dart';
import '../../../domain/usecases/get_user_interactions_usecase.dart';
import '../../../domain/usecases/get_user_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required GetUserProfile getUserProfile,
    required GetUserInteractions getUserInteractions,
  }) : _getUserProfile = getUserProfile,
       _getUserInteractions = getUserInteractions,
       super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
  }

  final GetUserProfile _getUserProfile;
  final GetUserInteractions _getUserInteractions;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(status: ProfileStatus.loading, clearErrorMessage: true),
    );
    try {
      final user = await _getUserProfile();
      if (user == null) {
        throw const AppException('User profile not available.');
      }
      final List<ProfileInteractionEntity> interactions =
          await _getUserInteractions(user.id);
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          user: user,
          interactions: interactions,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: '$error'));
    }
  }
}
