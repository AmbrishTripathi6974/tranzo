import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/transfer_entity.dart';
import '../../domain/entities/transfer_status.dart';

part 'transfer_model.freezed.dart';
part 'transfer_model.g.dart';

@freezed
abstract class TransferModel with _$TransferModel {
  const factory TransferModel({
    required String id,
    required String senderId,
    required String receiverId,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required TransferStatus status,
    required DateTime createdAt,
    DateTime? expiresAt,
  }) = _TransferModel;

  const TransferModel._();

  factory TransferModel.fromJson(Map<String, dynamic> json) =>
      _$TransferModelFromJson(json);

  TransferEntity toEntity() {
    return TransferEntity(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      status: status,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  static TransferModel fromEntity(TransferEntity entity) {
    return TransferModel(
      id: entity.id,
      senderId: entity.senderId,
      receiverId: entity.receiverId,
      status: entity.status,
      createdAt: entity.createdAt,
      expiresAt: entity.expiresAt,
    );
  }
}

TransferStatus _statusFromJson(String value) {
  for (final TransferStatus status in TransferStatus.values) {
    if (status.name == value) {
      return status;
    }
  }

  throw ArgumentError.value(value, 'status', 'Unknown transfer status');
}

String _statusToJson(TransferStatus value) => value.name;
