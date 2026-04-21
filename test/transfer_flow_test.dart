import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/core/constants/app_constants.dart';
import 'package:tranzo/core/errors/exceptions.dart';
import 'package:tranzo/domain/entities/file_entity.dart';
import 'package:tranzo/domain/entities/file_status.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/domain/entities/transfer_entity.dart';
import 'package:tranzo/domain/entities/transfer_status.dart' as domain;
import 'package:tranzo/domain/entities/transfer_task.dart';
import 'package:tranzo/domain/entities/user_entity.dart';
import 'package:tranzo/domain/repositories/transfer_repository.dart';
import 'package:tranzo/domain/usecases/retry_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/send_files_usecase.dart';
import 'package:tranzo/domain/usecases/start_download_usecase.dart';
import 'package:tranzo/domain/usecases/start_upload_usecase.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_event.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_state.dart';
import 'package:tranzo/transfer_engine/chunking/chunk_manager.dart';

void main() {
  group('ChunkManager', () {
    test('splits file into expected chunk boundaries', () {
      const ChunkManager manager = ChunkManager(chunkSizeBytes: 4);
      final chunks = manager.split(totalBytes: 10);

      expect(chunks.length, 3);
      expect(chunks[0].startByte, 0);
      expect(chunks[0].endByteExclusive, 4);
      expect(chunks[2].startByte, 8);
      expect(chunks[2].endByteExclusive, 10);
    });
  });

  group('TransferBloc batch upload', () {
    test('emits per-file progress for batch stream', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository();
      final TransferBloc bloc = TransferBloc(
        startUpload: StartUploadUseCase(repository),
        startDownload: StartDownloadUseCase(repository),
        retryTransfer: RetryTransferUseCase(repository),
        sendFiles: SendFiles(repository),
      );
      final List<TransferState> states = <TransferState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(
        TransferBatchUploadRequested(
          senderId: 'sender_1',
          recipientCode: 'ABC123',
          files: const <SelectedTransferFile>[
            SelectedTransferFile(
              id: 'f1',
              fileName: 'a.txt',
              localPath: '/tmp/a.txt',
              sizeBytes: 100,
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states.last.status, TransferStatus.success);
      expect(states.last.batchProgressByFileId['f1']?.progress, 1);

      await sub.cancel();
      await bloc.close();
    });

    test('rejects file larger than 1GB', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository();
      final TransferBloc bloc = TransferBloc(
        startUpload: StartUploadUseCase(repository),
        startDownload: StartDownloadUseCase(repository),
        retryTransfer: RetryTransferUseCase(repository),
        sendFiles: SendFiles(repository),
      );

      bloc.add(
        TransferBatchUploadRequested(
          senderId: 'sender_1',
          recipientCode: 'ABC123',
          files: const <SelectedTransferFile>[
            SelectedTransferFile(
              id: 'f1',
              fileName: 'large.bin',
              localPath: '/tmp/large.bin',
              sizeBytes: AppConstants.maxTransferFileSizeBytes + 1,
            ),
          ],
        ),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, TransferStatus.error);
      expect(bloc.state.errorMessage, contains('1GB'));

      await bloc.close();
    });
  });
}

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) async =>
      const <TransferEntity>[];

  @override
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
  }

  @override
  Future<void> retryTransfer(String transferId) async {}

  @override
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<TransferBatchProgress> sendFilesInBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) async* {
    if (recipientCode == 'INVALID') {
      throw const AppException('Invalid recipient code.');
    }
    yield TransferBatchProgress(
      sessionId: 'batch_1',
      files: files
          .map(
            (f) => TransferFileProgress(
              fileId: f.id,
              fileName: f.fileName,
              progress: 0.5,
              status: TransferFileProgressStatus.uploading,
            ),
          )
          .toList(growable: false),
    );
    yield TransferBatchProgress(
      sessionId: 'batch_1',
      files: files
          .map(
            (f) => TransferFileProgress(
              fileId: f.id,
              fileName: f.fileName,
              progress: 1,
              status: TransferFileProgressStatus.completed,
            ),
          )
          .toList(growable: false),
    );
  }

  @override
  Future<void> startDownload(TransferTask task) async {}

  @override
  Future<void> startUpload(TransferTask task) async {}
}
