import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/domain/entities/file_entity.dart';
import 'package:tranzo/domain/entities/incoming_transfer_offer.dart';
import 'package:tranzo/domain/entities/profile_interaction_entity.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/domain/entities/transfer_entity.dart';
import 'package:tranzo/domain/entities/transfer_status.dart';
import 'package:tranzo/domain/entities/transfer_task.dart';
import 'package:tranzo/domain/entities/user_entity.dart';
import 'package:tranzo/domain/repositories/transfer_repository.dart';
import 'package:tranzo/domain/usecases/get_transfer_history_usecase.dart';
import 'package:tranzo/presentation/bloc/history/history_bloc.dart';
import 'package:tranzo/presentation/bloc/history/history_event.dart';
import 'package:tranzo/presentation/bloc/history/history_state.dart';

void main() {
  group('HistoryBloc', () {
    test('loads history and emits loaded state', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository(
        historyItems: _demoItems,
      );
      final HistoryBloc bloc = HistoryBloc(
        getTransferHistory: GetTransferHistoryUseCase(repository),
      );
      final List<HistoryState> states = <HistoryState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const LoadHistory('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(states.first.status, HistoryStatus.loading);
      expect(states.last.status, HistoryStatus.loaded);
      expect(states.last.items.length, 3);
      expect(states.last.filterType, HistoryFilterType.all);

      await sub.cancel();
      await bloc.close();
    });

    test('applies sent and received filters after load', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository(
        historyItems: _demoItems,
      );
      final HistoryBloc bloc = HistoryBloc(
        getTransferHistory: GetTransferHistoryUseCase(repository),
      );

      bloc.add(const LoadHistory('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.items.length, 3);

      bloc.add(const FilterChanged(HistoryFilterType.sent));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.status, HistoryStatus.loaded);
      expect(bloc.state.items.length, 2);
      expect(
        bloc.state.items.every((TransferEntity item) => item.senderId == 'u1'),
        isTrue,
      );

      bloc.add(const FilterChanged(HistoryFilterType.received));
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(bloc.state.status, HistoryStatus.loaded);
      expect(bloc.state.items.length, 1);
      expect(bloc.state.items.first.receiverId, 'u1');

      await bloc.close();
    });

    test('emits empty when loaded list is empty', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository(
        historyItems: const <TransferEntity>[],
      );
      final HistoryBloc bloc = HistoryBloc(
        getTransferHistory: GetTransferHistoryUseCase(repository),
      );

      bloc.add(const LoadHistory('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, HistoryStatus.empty);
      expect(bloc.state.items, isEmpty);

      await bloc.close();
    });

    test('emits error when usecase throws', () async {
      final _FakeTransferRepository repository = _FakeTransferRepository(
        throwOnGetHistory: true,
      );
      final HistoryBloc bloc = HistoryBloc(
        getTransferHistory: GetTransferHistoryUseCase(repository),
      );

      bloc.add(const LoadHistory('u1'));
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, HistoryStatus.error);
      expect(bloc.state.errorMessage, contains('history failed'));

      await bloc.close();
    });
  });
}

final List<TransferEntity> _demoItems = <TransferEntity>[
  TransferEntity(
    id: 't1',
    senderId: 'u1',
    receiverId: 'u2',
    status: TransferStatus.completed,
    createdAt: DateTime(2026, 1, 1),
    fileName: 'report.pdf',
    fileSize: 1024,
    senderUsername: 'alice',
    receiverUsername: 'bob',
  ),
  TransferEntity(
    id: 't2',
    senderId: 'u3',
    receiverId: 'u1',
    status: TransferStatus.failed,
    createdAt: DateTime(2026, 1, 2),
    fileName: 'image.png',
    fileSize: 2048,
    senderUsername: 'charlie',
    receiverUsername: 'alice',
  ),
  TransferEntity(
    id: 't3',
    senderId: 'u1',
    receiverId: 'u4',
    status: TransferStatus.cancelled,
    createdAt: DateTime(2026, 1, 3),
    fileName: 'video.mp4',
    fileSize: 4096,
    senderUsername: 'alice',
    receiverUsername: 'diana',
  ),
];

class _FakeTransferRepository implements TransferRepository {
  _FakeTransferRepository({
    this.historyItems = const <TransferEntity>[],
    this.throwOnGetHistory = false,
  });

  final List<TransferEntity> historyItems;
  final bool throwOnGetHistory;

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
  }) async {}

  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) async {
    if (throwOnGetHistory) {
      throw Exception('history failed');
    }
    return historyItems;
  }

  @override
  Future<List<ProfileInteractionEntity>> getUserInteractions(
    String userId,
  ) async => const <ProfileInteractionEntity>[];

  @override
  Future<bool> hasAvailableStorage(int requiredBytes) async => true;

  @override
  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  }) => const Stream<IncomingTransferOffer>.empty();

  @override
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
  }

  @override
  Future<void> retryTransfer(String transferId) async {}

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {}

  @override
  Future<TransferEntity> sendFiles({
    required UserEntity sender,
    required UserEntity receiver,
    required List<FileEntity> files,
  }) {
    throw UnimplementedError();
  }

  @override
  Stream<TransferBatchProgress> sendFilesInBatch({
    required String senderId,
    required String recipientCode,
    required List<SelectedTransferFile> files,
  }) => const Stream<TransferBatchProgress>.empty();

  @override
  Future<void> startDownload(TransferTask task) async {}

  @override
  Future<void> startUpload(TransferTask task) async {}
}
