import '../../models/transfer_task_model.dart';

abstract interface class TransferApiService {
  Future<void> upload(TransferTaskModel task);
  Future<void> download(TransferTaskModel task);
}

class TransferApiServiceImpl implements TransferApiService {
  @override
  Future<void> upload(TransferTaskModel task) async {
    throw UnimplementedError('Upload API integration is not implemented yet.');
  }

  @override
  Future<void> download(TransferTaskModel task) async {
    throw UnimplementedError('Download API integration is not implemented yet.');
  }
}
