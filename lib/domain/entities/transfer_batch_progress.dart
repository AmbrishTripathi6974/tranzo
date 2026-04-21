import 'package:equatable/equatable.dart';

enum TransferFileProgressStatus { pending, uploading, completed, failed }

class TransferFileProgress extends Equatable {
  const TransferFileProgress({
    required this.fileId,
    required this.fileName,
    required this.progress,
    required this.status,
    this.errorMessage,
  });

  final String fileId;
  final String fileName;
  final double progress;
  final TransferFileProgressStatus status;
  final String? errorMessage;

  @override
  List<Object?> get props => <Object?>[
    fileId,
    fileName,
    progress,
    status,
    errorMessage,
  ];
}

class TransferBatchProgress extends Equatable {
  const TransferBatchProgress({required this.sessionId, required this.files});

  final String sessionId;
  final List<TransferFileProgress> files;

  @override
  List<Object?> get props => <Object?>[sessionId, files];
}
