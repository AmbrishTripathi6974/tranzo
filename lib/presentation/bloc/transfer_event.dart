import 'package:equatable/equatable.dart';

import '../../domain/entities/transfer_task.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class TransferStarted extends TransferEvent {
  const TransferStarted();
}

class UploadRequested extends TransferEvent {
  const UploadRequested(this.task);

  final TransferTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class DownloadRequested extends TransferEvent {
  const DownloadRequested(this.task);

  final TransferTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class RetryRequested extends TransferEvent {
  const RetryRequested(this.transferId);

  final String transferId;

  @override
  List<Object?> get props => <Object?>[transferId];
}
