import '../entities/file_entity.dart';
import '../entities/selected_transfer_file.dart';
import '../entities/transfer_batch_progress.dart';
import '../entities/transfer_entity.dart';
import '../entities/user_entity.dart';
import '../repositories/transfer_repository.dart';

class SendFiles {
  const SendFiles(this._repository);

  final TransferRepository _repository;

  Future<TransferEntity> call({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) {
    return _repository.sendFiles(
      sender: sender,
      receiver: receiver,
      files: files,
    );
  }

  Stream<TransferBatchProgress> sendBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) {
    return _repository.sendFilesInBatch(
      senderId: senderId,
      recipientCode: recipientCode,
      files: files,
    );
  }
}
