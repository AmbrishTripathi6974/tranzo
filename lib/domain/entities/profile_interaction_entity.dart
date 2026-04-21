import 'package:equatable/equatable.dart';

class ProfileInteractionEntity extends Equatable {
  const ProfileInteractionEntity({
    required this.userId,
    required this.username,
    required this.lastInteractionDate,
  });

  final String userId;
  final String username;
  final DateTime lastInteractionDate;

  @override
  List<Object?> get props => <Object?>[userId, username, lastInteractionDate];
}
