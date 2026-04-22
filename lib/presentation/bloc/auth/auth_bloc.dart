import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/user_entity.dart';
import '../../../domain/usecases/get_current_user_usecase.dart';
import '../../../domain/usecases/send_email_otp_usecase.dart';
import '../../../domain/usecases/sign_out_usecase.dart';
import '../../../domain/usecases/verify_email_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required GetCurrentUserUseCase getCurrentUser,
    required SendEmailOtpUseCase sendEmailOtp,
    required VerifyEmailOtpUseCase verifyEmailOtp,
    required SignOutUseCase signOut,
  }) : _getCurrentUser = getCurrentUser,
       _sendEmailOtp = sendEmailOtp,
       _verifyEmailOtp = verifyEmailOtp,
       _signOut = signOut,
       super(const AuthState()) {
    on<AuthStarted>(_onStarted);
    on<AuthEmailOtpRequested>(_onEmailOtpRequested);
    on<AuthEmailOtpVerified>(_onEmailOtpVerified);
    on<AuthSignedOut>(_onSignedOut);
  }

  final GetCurrentUserUseCase _getCurrentUser;
  final SendEmailOtpUseCase _sendEmailOtp;
  final VerifyEmailOtpUseCase _verifyEmailOtp;
  final SignOutUseCase _signOut;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    if (state.activeAction == AuthAction.bootstrap) {
      return;
    }
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        activeAction: AuthAction.bootstrap,
        clearErrorMessage: true,
      ),
    );
    try {
      final UserEntity user = await _getCurrentUser();
      if (user.id.trim().isEmpty) {
        emit(
          state.copyWith(
            status: AuthStatus.initial,
            flowStep: AuthFlowStep.emailEntry,
            activeAction: AuthAction.none,
            clearUser: true,
            clearPendingEmail: true,
            clearErrorMessage: true,
          ),
        );
        return;
      }
      emit(
        state.copyWith(
          status: AuthStatus.success,
          flowStep: AuthFlowStep.emailEntry,
          activeAction: AuthAction.none,
          user: user,
          clearPendingEmail: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          activeAction: AuthAction.none,
          errorMessage: '$error',
        ),
      );
    }
  }

  Future<void> _onEmailOtpRequested(
    AuthEmailOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.activeAction == AuthAction.sendOtp) {
      return;
    }
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        activeAction: AuthAction.sendOtp,
        clearErrorMessage: true,
      ),
    );
    try {
      final String normalizedEmail = event.email.trim().toLowerCase();
      await _sendEmailOtp(email: event.email);
      emit(
        state.copyWith(
          status: AuthStatus.otpSent,
          flowStep: AuthFlowStep.otpEntry,
          activeAction: AuthAction.none,
          pendingEmail: normalizedEmail,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          activeAction: AuthAction.none,
          errorMessage: '$error',
        ),
      );
    }
  }

  Future<void> _onEmailOtpVerified(
    AuthEmailOtpVerified event,
    Emitter<AuthState> emit,
  ) async {
    if (state.activeAction == AuthAction.verifyOtp) {
      return;
    }
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        flowStep: AuthFlowStep.otpEntry,
        activeAction: AuthAction.verifyOtp,
        clearErrorMessage: true,
      ),
    );
    try {
      final UserEntity user = await _verifyEmailOtp(
        email: event.email,
        otpCode: event.otpCode,
      );
      emit(
        state.copyWith(
          status: AuthStatus.success,
          flowStep: AuthFlowStep.emailEntry,
          activeAction: AuthAction.none,
          user: user,
          clearErrorMessage: true,
          clearPendingEmail: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          flowStep: AuthFlowStep.otpEntry,
          activeAction: AuthAction.none,
          errorMessage: '$error',
        ),
      );
    }
  }

  Future<void> _onSignedOut(
    AuthSignedOut event,
    Emitter<AuthState> emit,
  ) async {
    if (state.activeAction == AuthAction.signOut) {
      return;
    }
    emit(
      state.copyWith(
        status: AuthStatus.loading,
        activeAction: AuthAction.signOut,
        clearErrorMessage: true,
      ),
    );
    try {
      await _signOut();
      emit(
        state.copyWith(
          status: AuthStatus.initial,
          flowStep: AuthFlowStep.emailEntry,
          activeAction: AuthAction.none,
          clearUser: true,
          clearPendingEmail: true,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          activeAction: AuthAction.none,
          errorMessage: '$error',
        ),
      );
    }
  }
}
