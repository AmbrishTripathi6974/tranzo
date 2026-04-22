import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/create_user_usecase.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required CreateUser createUser,
  }) : _getCurrentUser = getCurrentUser,
       _createUser = createUser,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthUserCreated>(_onUserCreated);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final CreateUser _createUser;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));
    try {
      final UserEntity user = await _getCurrentUser();
      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: user,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: '$error'));
    }
  }

  Future<void> _onUserCreated(
    AuthUserCreated event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading, clearErrorMessage: true));
    try {
      final user = await _createUser(
        shortCode: event.shortCode,
        username: event.username,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          user: user,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: AuthStatus.error, errorMessage: '$error'));
    }
  }
}
