import 'package:equatable/equatable.dart';

import '../../../domain/entities/profile_interaction_entity.dart';
import '../../../domain/entities/user_entity.dart';

enum ProfileStatus { initial, loading, success, error }

class ProfileState extends Equatable {
  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.interactions = const <ProfileInteractionEntity>[],
    this.errorMessage,
  });

  final ProfileStatus status;
  final UserEntity? user;
  final List<ProfileInteractionEntity> interactions;
  final String? errorMessage;

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    List<ProfileInteractionEntity>? interactions,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      interactions: interactions ?? this.interactions,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    user,
    interactions,
    errorMessage,
  ];
}
