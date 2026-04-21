import '../../models/transfer_task_model.dart';
import '../../../core/services/transfer_service.dart';

abstract interface class TransferRemoteDataSource {
  Future<void> upload(TransferTaskModel task);
  Future<void> download(TransferTaskModel task);
  Future<void> uploadChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  TransferRemoteDataSourceImpl(this._transferService);

  final TransferService _transferService;

  @override
  Future<void> upload(TransferTaskModel task) async {
    throw UnimplementedError('Upload API integration is not implemented yet.');
  }

  @override
  Future<void> download(TransferTaskModel task) async {
    throw UnimplementedError(
      'Download API integration is not implemented yet.',
    );
  }

  @override
  Future<void> uploadChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  }) {
    return _transferService.uploadTransferChunk(
      sessionId: sessionId,
      fileId: fileId,
      chunkIndex: chunkIndex,
      byteStream: byteStream,
    );
  }
}
