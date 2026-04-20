import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/retry_transfer_usecase.dart';
import '../../domain/usecases/start_download_usecase.dart';
import '../../domain/usecases/start_upload_usecase.dart';
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
    on<TransferStarted>(_onStarted);
    on<UploadRequested>(_onUploadRequested);
    on<DownloadRequested>(_onDownloadRequested);
    on<RetryRequested>(_onRetryRequested);
  }

  final StartUploadUseCase _startUpload;
  final StartDownloadUseCase _startDownload;
  final RetryTransferUseCase _retryTransfer;

  Future<void> _onStarted(
    TransferStarted event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.idle, message: null));
  }

  Future<void> _onUploadRequested(
    UploadRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.inProgress));
    await _startUpload(event.task);
    emit(state.copyWith(status: TransferStatus.success));
  }

  Future<void> _onDownloadRequested(
    DownloadRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.inProgress));
    await _startDownload(event.task);
    emit(state.copyWith(status: TransferStatus.success));
  }

  Future<void> _onRetryRequested(
    RetryRequested event,
    Emitter<TransferState> emit,
  ) async {
    emit(state.copyWith(status: TransferStatus.inProgress));
    await _retryTransfer(event.transferId);
    emit(state.copyWith(status: TransferStatus.success));
  }
}
