// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'file_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FileModel _$FileModelFromJson(Map<String, dynamic> json) => _FileModel(
  id: json['id'] as String,
  transferId: json['transferId'] as String,
  fileName: json['fileName'] as String,
  size: (json['size'] as num).toInt(),
  hash: json['hash'] as String,
  status: _statusFromJson(json['status'] as String),
);

Map<String, dynamic> _$FileModelToJson(_FileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'transferId': instance.transferId,
      'fileName': instance.fileName,
      'size': instance.size,
      'hash': instance.hash,
      'status': _statusToJson(instance.status),
    };
