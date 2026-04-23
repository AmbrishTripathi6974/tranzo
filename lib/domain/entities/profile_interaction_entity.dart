import 'package:equatable/equatable.dart';

class ProfileInteractionEntity extends Equatable {
  const ProfileInteractionEntity({
    required this.userId,
    required this.displayLabel,
    required this.lastInteractionDate,
  });

  final String userId;
  final String displayLabel;
  final DateTime lastInteractionDate;

  @override
  List<Object?> get props => <Object?>[userId, displayLabel, lastInteractionDate];
}
