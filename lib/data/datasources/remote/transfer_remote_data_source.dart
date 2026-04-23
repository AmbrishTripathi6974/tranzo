import 'dart:typed_data';

import 'package:dio/dio.dart';

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
  Future<List<int>> downloadChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
  });

  Future<void> uploadTransfersV2Chunk({
    required String senderId,
    required String transferUuid,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  });

  Future<List<int>> downloadTransfersV2Chunk({
    required String senderId,
    required String transferUuid,
    required int chunkIndex,
  });

  /// Streams a signed Storage GET URL to [destinationPath] (e.g. temp `.part` file).
  Future<void> downloadFromSignedUrlToFile({
    required String signedUrl,
    required String destinationPath,
    void Function(int received, int total)? onReceiveProgress,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  TransferRemoteDataSourceImpl(this._transferService, this._dio);

  final TransferService _transferService;
  final Dio _dio;

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

  @override
  Future<List<int>> downloadChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
  }) async {
    return _transferService.downloadTransferChunk(
      sessionId: sessionId,
      fileId: fileId,
      chunkIndex: chunkIndex,
    );
  }

  @override
  Future<void> uploadTransfersV2Chunk({
    required String senderId,
    required String transferUuid,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  }) async {
    final List<int> chunkBytes = await byteStream.fold<List<int>>(
      <int>[],
      (List<int> acc, List<int> data) => acc..addAll(data),
    );
    await _transferService.uploadTransfersV2Chunk(
      senderId: senderId,
      transferUuid: transferUuid,
      chunkIndex: chunkIndex,
      chunkBytes: chunkBytes,
    );
  }

  @override
  Future<List<int>> downloadTransfersV2Chunk({
    required String senderId,
    required String transferUuid,
    required int chunkIndex,
  }) async {
    final Uint8List bytes = await _transferService.downloadTransfersV2Chunk(
      senderId: senderId,
      transferUuid: transferUuid,
      chunkIndex: chunkIndex,
    );
    return bytes.toList();
  }

  @override
  Future<void> downloadFromSignedUrlToFile({
    required String signedUrl,
    required String destinationPath,
    void Function(int received, int total)? onReceiveProgress,
  }) async {
    await _dio.download(
      signedUrl,
      destinationPath,
      deleteOnError: true,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
