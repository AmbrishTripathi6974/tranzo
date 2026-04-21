import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_transfer_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({required GetTransferHistory getTransferHistory})
    : _getTransferHistory = getTransferHistory,
      super(const HistoryState()) {
    on<HistoryRequested>(_onRequested);
  }

  final GetTransferHistory _getTransferHistory;

  Future<void> _onRequested(
    HistoryRequested event,
    Emitter<HistoryState> emit,
  ) async {
    emit(state.copyWith(status: HistoryStatus.loading, clearErrorMessage: true));
    try {
      final items = await _getTransferHistory(event.userId);
      emit(
        state.copyWith(
          status: HistoryStatus.success,
          items: items,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: HistoryStatus.error, errorMessage: '$error'));
    }
  }
}
