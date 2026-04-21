import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class AuthUserCreated extends AuthEvent {
  const AuthUserCreated({required this.shortCode, required this.username});

  final String shortCode;
  final String username;

  @override
  List<Object?> get props => <Object?>[shortCode, username];
}
