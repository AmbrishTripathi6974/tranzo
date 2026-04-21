import 'package:equatable/equatable.dart';

import '../../../domain/entities/transfer_entity.dart';

enum HistoryStatus { initial, loading, success, error }

class HistoryState extends Equatable {
  const HistoryState({
    this.status = HistoryStatus.initial,
    this.items = const <TransferEntity>[],
    this.errorMessage,
  });

  final HistoryStatus status;
  final List<TransferEntity> items;
  final String? errorMessage;

  HistoryState copyWith({
    HistoryStatus? status,
    List<TransferEntity>? items,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[status, items, errorMessage];
}
