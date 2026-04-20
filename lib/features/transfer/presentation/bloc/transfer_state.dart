import 'package:equatable/equatable.dart';

enum TransferStatus { initial, idle, inProgress, success, failure }

class TransferState extends Equatable {
  const TransferState({
    this.status = TransferStatus.initial,
    this.message,
  });

  final TransferStatus status;
  final String? message;

  TransferState copyWith({
    TransferStatus? status,
    String? message,
  }) {
    return TransferState(
      status: status ?? this.status,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => <Object?>[status, message];
}
