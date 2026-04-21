import 'package:equatable/equatable.dart';

enum TransferStatus { initial, loading, success, error }

class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.initial,
    this.progress = 0,
    this.activeTransferId,
    this.errorMessage,
  });

  final TransferStatus status;
  final double progress;
  final String? activeTransferId;
  final String? errorMessage;

  TransferState copyWith({
    TransferStatus? status,
    double? progress,
    String? activeTransferId,
    String? errorMessage,
    bool clearActiveTransferId = false,
    bool clearErrorMessage = false,
  }) {
    return TransferState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      activeTransferId: clearActiveTransferId
          ? null
          : (activeTransferId ?? this.activeTransferId),
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => <Object?>[
    status,
    progress,
    activeTransferId,
    errorMessage,
  ];
}
