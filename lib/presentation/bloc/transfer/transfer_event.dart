import 'package:equatable/equatable.dart';

import '../../../domain/entities/transfer_task.dart';

sealed class TransferEvent extends Equatable {
  const TransferEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class TransferUploadRequested extends TransferEvent {
  const TransferUploadRequested(this.task);

  final TransferTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class TransferDownloadRequested extends TransferEvent {
  const TransferDownloadRequested(this.task);

  final TransferTask task;

  @override
  List<Object?> get props => <Object?>[task];
}

class TransferRetryRequested extends TransferEvent {
  const TransferRetryRequested(this.transferId);

  final String transferId;

  @override
  List<Object?> get props => <Object?>[transferId];
}
