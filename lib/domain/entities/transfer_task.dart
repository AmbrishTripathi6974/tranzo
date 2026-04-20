import 'package:equatable/equatable.dart';

class TransferTask extends Equatable {
  const TransferTask({
    required this.id,
    required this.fileName,
    required this.totalBytes,
  });

  final String id;
  final String fileName;
  final int totalBytes;

  @override
  List<Object?> get props => <Object?>[id, fileName, totalBytes];
}
