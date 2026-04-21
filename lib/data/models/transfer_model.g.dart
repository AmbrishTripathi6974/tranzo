// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TransferModel _$TransferModelFromJson(Map<String, dynamic> json) =>
    _TransferModel(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      senderUsername: json['senderUsername'] as String?,
      receiverUsername: json['receiverUsername'] as String?,
      fileName: json['fileName'] as String,
      fileSize: (json['fileSize'] as num).toInt(),
      status: _statusFromJson(json['status'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$TransferModelToJson(_TransferModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'receiverId': instance.receiverId,
      'senderUsername': instance.senderUsername,
      'receiverUsername': instance.receiverUsername,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'status': _statusToJson(instance.status),
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
