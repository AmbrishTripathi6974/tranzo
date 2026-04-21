import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/entities/transfer_entity.dart';
import '../../../domain/usecases/get_transfer_history_usecase.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  HistoryBloc({required GetTransferHistoryUseCase getTransferHistory})
    : _getTransferHistory = getTransferHistory,
      super(const HistoryState()) {
    on<LoadHistory>(_onLoadHistory);
    on<FilterChanged>(_onFilterChanged);
  }

  final GetTransferHistoryUseCase _getTransferHistory;

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(
      state.copyWith(status: HistoryStatus.loading, clearErrorMessage: true),
    );
    try {
      final List<TransferEntity> allItems = await _getTransferHistory(
        event.userId,
      );
      final List<TransferEntity> visibleItems = _applyFilter(
        allItems: allItems,
        currentUserId: event.userId,
        filterType: state.filterType,
      );
      final HistoryStatus status = visibleItems.isEmpty
          ? HistoryStatus.empty
          : HistoryStatus.loaded;
      emit(
        state.copyWith(
          status: status,
          allItems: allItems,
          items: visibleItems,
          userId: event.userId,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(status: HistoryStatus.error, errorMessage: '$error'));
    }
  }

  void _onFilterChanged(FilterChanged event, Emitter<HistoryState> emit) {
    final String? currentUserId = state.userId;
    if (currentUserId == null) {
      emit(state.copyWith(filterType: event.filterType));
      return;
    }

    final List<TransferEntity> visibleItems = _applyFilter(
      allItems: state.allItems,
      currentUserId: currentUserId,
      filterType: event.filterType,
    );

    emit(
      state.copyWith(
        status: visibleItems.isEmpty ? HistoryStatus.empty : HistoryStatus.loaded,
        filterType: event.filterType,
        items: visibleItems,
      ),
    );
  }

  List<TransferEntity> _applyFilter({
    required List<TransferEntity> allItems,
    required String currentUserId,
    required HistoryFilterType filterType,
  }) {
    return allItems.where((TransferEntity item) {
      switch (filterType) {
        case HistoryFilterType.all:
          return true;
        case HistoryFilterType.sent:
          return item.senderId == currentUserId;
        case HistoryFilterType.received:
          return item.receiverId == currentUserId;
      }
    }).toList(growable: false);
  }
}
