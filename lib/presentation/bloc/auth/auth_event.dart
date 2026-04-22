import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthEmailOtpRequested extends AuthEvent {
  const AuthEmailOtpRequested({required this.email});

  final String email;

  @override
  List<Object?> get props => <Object?>[email];
}

class AuthEmailOtpVerified extends AuthEvent {
  const AuthEmailOtpVerified({required this.email, required this.otpCode});

  final String email;
  final String otpCode;

  @override
  List<Object?> get props => <Object?>[email, otpCode];
}

class AuthSignedOut extends AuthEvent {
  const AuthSignedOut();
}
