import '../../models/transfer_task_model.dart';

abstract interface class FileStorageService {
  Future<void> saveTransferMetadata(TransferTaskModel task);
}

class FileStorageServiceImpl implements FileStorageService {
  @override
  Future<void> saveTransferMetadata(TransferTaskModel task) async {
    throw UnimplementedError(
      'Local storage integration is not implemented yet.',
    );
  }
}
