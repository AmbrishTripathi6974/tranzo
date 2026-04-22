import 'package:flutter_bloc/flutter_bloc.dart';

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
  static const Duration _profileLoadTimeout = Duration(seconds: 10);
  static const Duration _interactionLoadTimeout = Duration(seconds: 10);

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(status: ProfileStatus.loading, clearErrorMessage: true),
    );
    try {
      final user = await _getUserProfile().timeout(_profileLoadTimeout);
      if (user == null) {
        emit(
          state.copyWith(
            status: ProfileStatus.error,
            errorMessage:
                'User profile is not ready yet. Check your connection, wait for '
                'sign-in to finish, then tap Retry. If it keeps failing, confirm '
                'your Supabase project has a recipient_codes row for this user '
                'and RLS allows reads.',
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: ProfileStatus.success,
          user: user,
          interactions: const <ProfileInteractionEntity>[],
          clearErrorMessage: true,
        ),
      );
      try {
        final List<ProfileInteractionEntity> interactions = await _getUserInteractions(
          user.id,
        ).timeout(_interactionLoadTimeout);
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
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: '$error'));
    }
  }
}
