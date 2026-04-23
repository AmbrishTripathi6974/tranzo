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
    on<LoadMoreHistory>(_onLoadMoreHistory);
  }

  final GetTransferHistoryUseCase _getTransferHistory;
  static const int _pageSize = 20;

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    final bool hasWarmCache =
        state.userId == event.userId && state.allItems.isNotEmpty;
    if (!hasWarmCache) {
      emit(
        state.copyWith(
          status: HistoryStatus.loading,
          clearErrorMessage: true,
          isRefreshing: false,
          isLoadingMore: false,
        ),
      );
    } else {
      emit(
        state.copyWith(
          isRefreshing: true,
          isLoadingMore: false,
          clearErrorMessage: true,
        ),
      );
    }
    try {
      final List<TransferEntity> allItems = await _getTransferHistory(
        event.userId,
      );
      final List<TransferEntity> filteredItems = _applyFilter(
        allItems: allItems,
        currentUserId: event.userId,
        filterType: state.filterType,
      );
      final int firstPageCount = _firstPageCount(filteredItems.length);
      final List<TransferEntity> visibleItems = filteredItems
          .take(firstPageCount)
          .toList(growable: false);
      final HistoryStatus status = filteredItems.isEmpty
          ? HistoryStatus.empty
          : HistoryStatus.loaded;
      emit(
        state.copyWith(
          status: status,
          allItems: allItems,
          items: visibleItems,
          userId: event.userId,
          hasMore: filteredItems.length > firstPageCount,
          isLoadingMore: false,
          isRefreshing: false,
          clearErrorMessage: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: state.items.isNotEmpty ? HistoryStatus.loaded : HistoryStatus.error,
          errorMessage: '$error',
          isLoadingMore: false,
          isRefreshing: false,
        ),
      );
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
    final int firstPageCount = _firstPageCount(visibleItems.length);
    final List<TransferEntity> firstPage = visibleItems
        .take(firstPageCount)
        .toList(growable: false);

    emit(
      state.copyWith(
        status: visibleItems.isEmpty
            ? HistoryStatus.empty
            : HistoryStatus.loaded,
        filterType: event.filterType,
        items: firstPage,
        hasMore: visibleItems.length > firstPageCount,
        isLoadingMore: false,
      ),
    );
  }

  void _onLoadMoreHistory(
    LoadMoreHistory event,
    Emitter<HistoryState> emit,
  ) {
    if (state.status != HistoryStatus.loaded ||
        state.userId == null ||
        state.isLoadingMore ||
        !state.hasMore) {
      return;
    }

    final List<TransferEntity> filteredItems = _applyFilter(
      allItems: state.allItems,
      currentUserId: state.userId!,
      filterType: state.filterType,
    );

    final int currentCount = state.items.length;
    if (currentCount >= filteredItems.length) {
      emit(state.copyWith(hasMore: false, isLoadingMore: false));
      return;
    }

    emit(state.copyWith(isLoadingMore: true));
    final int nextCount = (currentCount + _pageSize).clamp(0, filteredItems.length);
    emit(
      state.copyWith(
        items: filteredItems.take(nextCount).toList(growable: false),
        hasMore: nextCount < filteredItems.length,
        isLoadingMore: false,
      ),
    );
  }

  int _firstPageCount(int total) {
    if (total <= 0) {
      return 0;
    }
    return total < _pageSize ? total : _pageSize;
  }

  List<TransferEntity> _applyFilter({
    required List<TransferEntity> allItems,
    required String currentUserId,
    required HistoryFilterType filterType,
  }) {
    return allItems
        .where((TransferEntity item) {
          switch (filterType) {
            case HistoryFilterType.all:
              return true;
            case HistoryFilterType.sent:
              return item.senderId == currentUserId;
            case HistoryFilterType.received:
              return item.receiverId == currentUserId;
          }
        })
        .toList(growable: false);
  }
}
