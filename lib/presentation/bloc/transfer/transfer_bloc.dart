import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/usecases/retry_transfer_usecase.dart';
import '../../../domain/usecases/send_files_usecase.dart';
import '../../../domain/usecases/start_download_usecase.dart';
import '../../../domain/usecases/start_upload_usecase.dart';
import '../../../domain/entities/transfer_batch_progress.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required StartUploadUseCase startUpload,
    required StartDownloadUseCase startDownload,
    required RetryTransferUseCase retryTransfer,
    required SendFiles sendFiles,
  }) : _startUpload = startUpload,
       _startDownload = startDownload,
       _retryTransfer = retryTransfer,
       _sendFiles = sendFiles,
       super(const TransferState()) {
    on<TransferUploadRequested>(_onUploadRequested);
    on<TransferDownloadRequested>(_onDownloadRequested);
    on<TransferRetryRequested>(_onRetryRequested);
    on<TransferBatchUploadRequested>(_onBatchUploadRequested);
  }

  final StartUploadUseCase _startUpload;
  final StartDownloadUseCase _startDownload;
  final RetryTransferUseCase _retryTransfer;
  final SendFiles _sendFiles;

  Future<void> _onUploadRequested(
    TransferUploadRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.task.id,
      action: () => _startUpload(event.task),
    );
  }

  Future<void> _onDownloadRequested(
    TransferDownloadRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.task.id,
      action: () => _startDownload(event.task),
    );
  }

  Future<void> _onRetryRequested(
    TransferRetryRequested event,
    Emitter<TransferState> emit,
  ) async {
    await _runTransferAction(
      emit: emit,
      transferId: event.transferId,
      action: () => _retryTransfer(event.transferId),
    );
  }

  Future<void> _runTransferAction({
    required Emitter<TransferState> emit,
    required String transferId,
    required Future<void> Function() action,
  }) async {
    emit(
      state.copyWith(
        status: TransferStatus.loading,
        progress: 0,
        activeTransferId: transferId,
        clearErrorMessage: true,
      ),
    );
    try {
      await action();
      emit(
        state.copyWith(
          status: TransferStatus.success,
          progress: 1,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(status: TransferStatus.error, errorMessage: '$error'),
      );
    }
  }

  Future<void> _onBatchUploadRequested(
    TransferBatchUploadRequested event,
    Emitter<TransferState> emit,
  ) async {
    final bool oversized = event.files.any(
      (file) => file.sizeBytes > AppConstants.maxTransferFileSizeBytes,
    );
    if (oversized) {
      emit(
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: 'File exceeds 1GB max size.',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: TransferStatus.loading,
        progress: 0,
        clearErrorMessage: true,
        clearBatchProgress: true,
      ),
    );

    try {
      await emit.forEach<TransferBatchProgress>(
        _sendFiles.sendBatch(
          senderId: event.senderId,
          recipientCode: event.recipientCode,
          files: event.files,
        ),
        onData: (TransferBatchProgress progress) {
          final Map<String, TransferFileProgress> byId =
              <String, TransferFileProgress>{
                for (final TransferFileProgress item in progress.files)
                  item.fileId: item,
              };
          final double total = progress.files.isEmpty
              ? 0
              : progress.files
                        .map((TransferFileProgress e) => e.progress)
                        .reduce((double a, double b) => a + b) /
                    progress.files.length;
          return state.copyWith(
            status: total >= 1
                ? TransferStatus.success
                : TransferStatus.loading,
            progress: total,
            batchSessionId: progress.sessionId,
            batchProgressByFileId: byId,
            clearErrorMessage: true,
          );
        },
      );
    } catch (error) {
      emit(
        state.copyWith(status: TransferStatus.error, errorMessage: '$error'),
      );
    }
  }
}
