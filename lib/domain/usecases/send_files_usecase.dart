import '../entities/file_entity.dart';
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
}
