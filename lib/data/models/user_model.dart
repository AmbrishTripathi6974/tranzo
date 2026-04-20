import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/user_entity.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
abstract class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String shortCode,
    required String username,
  }) = _UserModel;

  const UserModel._();

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  UserEntity toEntity() {
    return UserEntity(id: id, shortCode: shortCode, username: username);
  }

  static UserModel fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      shortCode: entity.shortCode,
      username: entity.username,
    );
  }
}
