import 'package:equatable/equatable.dart';

import 'file_status.dart';

class FileEntity extends Equatable {
  const FileEntity({
    required this.id,
    required this.transferId,
    required this.fileName,
    required this.size,
    required this.hash,
    required this.status,
  });

  final String id;
  final String transferId;
  final String fileName;
  final int size;
  final String hash;
  final FileStatus status;

  @override
  List<Object?> get props => <Object?>[
    id,
    transferId,
    fileName,
    size,
    hash,
    status,
  ];
}
