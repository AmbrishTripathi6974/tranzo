import '../../models/transfer_task_model.dart';

abstract interface class TransferLocalDataSource {
  Future<void> saveTransferMetadata(TransferTaskModel task);
}

class TransferLocalDataSourceImpl implements TransferLocalDataSource {
  @override
  Future<void> saveTransferMetadata(TransferTaskModel task) async {
    throw UnimplementedError('Local storage integration is not implemented yet.');
  }
}
