import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/retry_transfer_usecase.dart';
import '../../../domain/usecases/start_download_usecase.dart';
import '../../../domain/usecases/start_upload_usecase.dart';
import 'transfer_event.dart';
import 'transfer_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  TransferBloc({
    required StartUploadUseCase startUpload,
    required StartDownloadUseCase startDownload,
    required RetryTransferUseCase retryTransfer,
  }) : _startUpload = startUpload,
       _startDownload = startDownload,
       _retryTransfer = retryTransfer,
       super(const TransferState()) {
    on<TransferUploadRequested>(_onUploadRequested);
    on<TransferDownloadRequested>(_onDownloadRequested);
    on<TransferRetryRequested>(_onRetryRequested);
  }

  final StartUploadUseCase _startUpload;
  final StartDownloadUseCase _startDownload;
  final RetryTransferUseCase _retryTransfer;

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
        state.copyWith(
          status: TransferStatus.error,
          errorMessage: '$error',
        ),
      );
    }
  }
}
