import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tranzo/domain/entities/file_entity.dart';
import 'package:tranzo/domain/entities/incoming_transfer_offer.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/domain/entities/transfer_entity.dart';
import 'package:tranzo/domain/entities/transfer_task.dart';
import 'package:tranzo/domain/entities/user_entity.dart';
import 'package:tranzo/domain/repositories/transfer_repository.dart';
import 'package:tranzo/domain/usecases/retry_transfer_usecase.dart';
import 'package:tranzo/domain/usecases/send_files_usecase.dart';
import 'package:tranzo/domain/usecases/start_download_usecase.dart';
import 'package:tranzo/domain/usecases/start_upload_usecase.dart';
import 'package:tranzo/presentation/bloc/transfer/transfer_bloc.dart';
import 'package:tranzo/presentation/pages/transfer_home_page.dart';

void main() {
  testWidgets('Transfer home scaffold renders', (WidgetTester tester) async {
    final _FakeTransferRepository repository = _FakeTransferRepository();
    final TransferBloc bloc = TransferBloc(
      startUpload: StartUploadUseCase(repository),
      startDownload: StartDownloadUseCase(repository),
      retryTransfer: RetryTransferUseCase(repository),
      sendFiles: SendFiles(repository),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TransferBloc>.value(
          value: bloc,
          child: const TransferHomePage(),
        ),
      ),
    );

    expect(find.text('Tranzo Transfer Home'), findsOneWidget);
  });
}

class _FakeTransferRepository implements TransferRepository {
  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
  }) async {}

  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) async =>
      const <TransferEntity>[];

  @override
  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  }) => const Stream<IncomingTransferOffer>.empty();

  @override
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
  }

  @override
  Future<void> retryTransfer(String transferId) async {}

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {}

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
    yield const TransferBatchProgress(
      sessionId: 'session',
      files: <TransferFileProgress>[],
    );
  }

  @override
  Future<void> startDownload(TransferTask task) async {}

  @override
  Future<void> startUpload(TransferTask task) async {}
}
