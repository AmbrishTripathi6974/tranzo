import '../../models/transfer_task_model.dart';

abstract interface class TransferRemoteDataSource {
  Future<void> upload(TransferTaskModel task);
  Future<void> download(TransferTaskModel task);
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  @override
  Future<void> upload(TransferTaskModel task) async {
    throw UnimplementedError('Upload API integration is not implemented yet.');
  }

  @override
  Future<void> download(TransferTaskModel task) async {
    throw UnimplementedError('Download API integration is not implemented yet.');
  }
}
