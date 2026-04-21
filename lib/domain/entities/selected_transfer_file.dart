import 'package:equatable/equatable.dart';

class SelectedTransferFile extends Equatable {
  const SelectedTransferFile({
    required this.id,
    required this.fileName,
    required this.localPath,
    required this.sizeBytes,
  });

  final String id;
  final String fileName;
  final String localPath;
  final int sizeBytes;

  @override
  List<Object?> get props => <Object?>[id, fileName, localPath, sizeBytes];
}
