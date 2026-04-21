import 'package:equatable/equatable.dart';

sealed class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class HistoryRequested extends HistoryEvent {
  const HistoryRequested(this.userId);

  final String userId;

  @override
  List<Object?> get props => <Object?>[userId];
}
