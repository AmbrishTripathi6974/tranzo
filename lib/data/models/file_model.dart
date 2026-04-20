import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/file_entity.dart';
import '../../domain/entities/file_status.dart';

part 'file_model.freezed.dart';
part 'file_model.g.dart';

@freezed
abstract class FileModel with _$FileModel {
  const factory FileModel({
    required String id,
    required String transferId,
    required String fileName,
    required int size,
    required String hash,
    @JsonKey(fromJson: _statusFromJson, toJson: _statusToJson)
    required FileStatus status,
  }) = _FileModel;

  const FileModel._();

  factory FileModel.fromJson(Map<String, dynamic> json) =>
      _$FileModelFromJson(json);

  FileEntity toEntity() {
    return FileEntity(
      id: id,
      transferId: transferId,
      fileName: fileName,
      size: size,
      hash: hash,
      status: status,
    );
  }

  static FileModel fromEntity(FileEntity entity) {
    return FileModel(
      id: entity.id,
      transferId: entity.transferId,
      fileName: entity.fileName,
      size: entity.size,
      hash: entity.hash,
      status: entity.status,
    );
  }
}

FileStatus _statusFromJson(String value) {
  for (final FileStatus status in FileStatus.values) {
    if (status.name == value) {
      return status;
    }
  }

  throw ArgumentError.value(value, 'status', 'Unknown file status');
}

String _statusToJson(FileStatus value) => value.name;
