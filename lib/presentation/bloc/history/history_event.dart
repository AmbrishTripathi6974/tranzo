import 'package:equatable/equatable.dart';

import 'history_state.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadHistory extends HistoryEvent {
  const LoadHistory(this.userId);

  final String userId;

  @override
  List<Object?> get props => <Object?>[userId];
}

class FilterChanged extends HistoryEvent {
  const FilterChanged(this.filterType);

  final HistoryFilterType filterType;

  @override
  List<Object?> get props => <Object?>[filterType];
}

class LoadMoreHistory extends HistoryEvent {
  const LoadMoreHistory();
}
