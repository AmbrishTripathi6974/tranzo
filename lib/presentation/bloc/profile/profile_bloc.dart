import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_current_user_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required GetCurrentUser getCurrentUser})
    : _getCurrentUser = getCurrentUser,
      super(const ProfileState()) {
    on<ProfileRequested>(_onRequested);
  }

  final GetCurrentUser _getCurrentUser;

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearErrorMessage: true));
    try {
      final user = await _getCurrentUser();
      emit(state.copyWith(status: ProfileStatus.success, user: user));
    } catch (error) {
      emit(state.copyWith(status: ProfileStatus.error, errorMessage: '$error'));
    }
  }
}
