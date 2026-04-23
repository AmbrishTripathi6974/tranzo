import 'package:equatable/equatable.dart';

import '../../../domain/entities/transfer_entity.dart';

enum HistoryFilterType { all, sent, received }

enum HistoryStatus { initial, loading, loaded, empty, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.allItems = const <TransferEntity>[],
    this.items = const <TransferEntity>[],
    this.filterType = HistoryFilterType.all,
    this.userId,
    this.errorMessage,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  final HistoryStatus status;
  final List<TransferEntity> allItems;
  final List<TransferEntity> items;
  final HistoryFilterType filterType;
  final String? userId;
  final String? errorMessage;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;

  HistoryState copyWith({
    HistoryStatus? status,
    List<TransferEntity>? allItems,
    List<TransferEntity>? items,
    HistoryFilterType? filterType,
    String? userId,
    String? errorMessage,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    bool clearErrorMessage = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      allItems: allItems ?? this.allItems,
      items: items ?? this.items,
      filterType: filterType ?? this.filterType,
      userId: userId ?? this.userId,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    allItems,
    items,
    filterType,
    userId,
    errorMessage,
    hasMore,
    isLoadingMore,
    isRefreshing,
  ];
}
