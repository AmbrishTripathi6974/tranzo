import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.shortCode,
    required this.username,
  });

  final String id;
  final String shortCode;
  final String username;

  @override
  List<Object?> get props => <Object?>[id, shortCode, username];
}
