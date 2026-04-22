import 'package:equatable/equatable.dart';

import '../../../domain/entities/user_entity.dart';

enum AuthStatus { initial, loading, otpSent, success, error }

enum AuthFlowStep { emailEntry, otpEntry }

enum AuthAction { none, bootstrap, sendOtp, verifyOtp, signOut }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.pendingEmail,
    this.flowStep = AuthFlowStep.emailEntry,
    this.activeAction = AuthAction.none,
  });

  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final String? pendingEmail;
  final AuthFlowStep flowStep;
  final AuthAction activeAction;

  bool get isBusy => activeAction != AuthAction.none;

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    String? pendingEmail,
    AuthFlowStep? flowStep,
    AuthAction? activeAction,
    bool clearUser = false,
    bool clearErrorMessage = false,
    bool clearPendingEmail = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      pendingEmail: clearPendingEmail
          ? null
          : (pendingEmail ?? this.pendingEmail),
      flowStep: flowStep ?? this.flowStep,
      activeAction: activeAction ?? this.activeAction,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    user,
    errorMessage,
    pendingEmail,
    flowStep,
    activeAction,
  ];
}
