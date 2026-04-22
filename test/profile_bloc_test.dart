import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/domain/entities/file_entity.dart';
import 'package:tranzo/domain/entities/incoming_transfer_offer.dart';
import 'package:tranzo/domain/entities/profile_interaction_entity.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/domain/entities/transfer_entity.dart';
import 'package:tranzo/domain/entities/transfer_lifecycle_signal.dart';
import 'package:tranzo/domain/entities/transfer_task.dart';
import 'package:tranzo/domain/entities/user_entity.dart';
import 'package:tranzo/domain/repositories/auth_repository.dart';
import 'package:tranzo/domain/repositories/transfer_repository.dart';
import 'package:tranzo/domain/usecases/get_current_user_usecase.dart';
import 'package:tranzo/domain/usecases/get_user_interactions_usecase.dart';
import 'package:tranzo/presentation/bloc/profile/profile_bloc.dart';
import 'package:tranzo/presentation/bloc/profile/profile_event.dart';
import 'package:tranzo/presentation/bloc/profile/profile_state.dart';

void main() {
  group('ProfileBloc', () {
    test('loads profile and interactions', () async {
      final _FakeAuthRepository authRepository = _FakeAuthRepository(
        user: const UserEntity(id: 'u1', shortCode: 'AB12', username: 'Alice'),
      );
      final _FakeTransferRepository transferRepository =
          _FakeTransferRepository(
            interactions: <ProfileInteractionEntity>[
              ProfileInteractionEntity(
                userId: 'u2',
                username: 'Bob',
                lastInteractionDate: DateTime(2026, 1, 5),
              ),
            ],
          );
      final ProfileBloc bloc = ProfileBloc(
        getCurrentUser: GetCurrentUserUseCase(authRepository),
        getUserInteractions: GetUserInteractions(transferRepository),
      );

      bloc.add(const ProfileRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, ProfileStatus.success);
      expect(bloc.state.user?.shortCode, 'AB12');
      expect(bloc.state.interactions.length, 1);
      await bloc.close();
    });

    test('second ProfileRequested can surface updated recipient short code', () async {
      final _SequentialAuthRepository authRepository =
          _SequentialAuthRepository(
            users: <UserEntity>[
              const UserEntity(id: 'u1', shortCode: '', username: 'Alice'),
              const UserEntity(id: 'u1', shortCode: 'XY12AB', username: 'Alice'),
            ],
          );
      final _FakeTransferRepository transferRepository =
          _FakeTransferRepository(interactions: <ProfileInteractionEntity>[]);

      final ProfileBloc bloc = ProfileBloc(
        getCurrentUser: GetCurrentUserUseCase(authRepository),
        getUserInteractions: GetUserInteractions(transferRepository),
      );

      bloc.add(const ProfileRequested());
      await bloc.stream.firstWhere(
        (ProfileState s) =>
            s.status == ProfileStatus.success && s.user?.shortCode == '',
      );

      bloc.add(const ProfileRequested());
      await bloc.stream.firstWhere(
        (ProfileState s) =>
            s.status == ProfileStatus.success && s.user?.shortCode == 'XY12AB',
      );

      expect(bloc.state.user?.shortCode, 'XY12AB');
      await bloc.close();
    });

    test('emits error when current-user initialization fails', () async {
      final _ThrowingAuthRepository authRepository = _ThrowingAuthRepository();
      final _FakeTransferRepository transferRepository =
          _FakeTransferRepository(interactions: <ProfileInteractionEntity>[]);
      final ProfileBloc bloc = ProfileBloc(
        getCurrentUser: GetCurrentUserUseCase(authRepository),
        getUserInteractions: GetUserInteractions(transferRepository),
      );

      bloc.add(const ProfileRequested());
      await bloc.stream.firstWhere(
        (ProfileState s) => s.status == ProfileStatus.error,
      );

      expect(bloc.state.errorMessage, isNotNull);
      await bloc.close();
    });

    test('ignores duplicate ProfileRequested while request is in flight', () async {
      final _CountingDelayedAuthRepository authRepository =
          _CountingDelayedAuthRepository(
            user: const UserEntity(id: 'u1', shortCode: 'AB12', username: 'Alice'),
          );
      final _FakeTransferRepository transferRepository =
          _FakeTransferRepository(interactions: <ProfileInteractionEntity>[]);
      final ProfileBloc bloc = ProfileBloc(
        getCurrentUser: GetCurrentUserUseCase(authRepository),
        getUserInteractions: GetUserInteractions(transferRepository),
      );

      bloc.add(const ProfileRequested());
      bloc.add(const ProfileRequested());
      await bloc.stream.firstWhere(
        (ProfileState s) => s.status == ProfileStatus.success,
      );

      expect(authRepository.callCount, 1);
      await bloc.close();
    });
  });
}

class _SequentialAuthRepository implements AuthRepository {
  _SequentialAuthRepository({required List<UserEntity> users}) : _users = users;

  final List<UserEntity> _users;
  int _call = 0;

  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    final int index = _call < _users.length ? _call : _users.length - 1;
    _call++;
    return _users[index];
  }
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.user});

  final UserEntity user;

  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getCurrentUser() async => user;
}

class _CountingDelayedAuthRepository implements AuthRepository {
  _CountingDelayedAuthRepository({required this.user});

  final UserEntity user;
  int callCount = 0;

  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    callCount++;
    await Future<void>.delayed(const Duration(milliseconds: 100));
    return user;
  }
}

class _ThrowingAuthRepository implements AuthRepository {
  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity> getCurrentUser() async {
    throw Exception('init failed');
  }
}

class _FakeTransferRepository implements TransferRepository {
  _FakeTransferRepository({required this.interactions});

  final List<ProfileInteractionEntity> interactions;

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
    bool persistPermanently = true,
    bool trustSender = false,
  }) async {}

  @override
  Future<List<TransferEntity>> getTransferHistory(String userId) {
    throw UnimplementedError();
  }

  @override
  Future<List<ProfileInteractionEntity>> getUserInteractions(
    String userId,
  ) async => interactions;

  @override
  Future<bool> hasAvailableStorage(int requiredBytes) async => true;

  @override
  Stream<IncomingTransferOffer> listenIncomingTransfers({
    required String receiverId,
  }) => const Stream<IncomingTransferOffer>.empty();

  @override
  Stream<TransferLifecycleSignalEntity> listenTransferSignals({
    required String userId,
  }) => const Stream<TransferLifecycleSignalEntity>.empty();

  @override
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {}

  @override
  Future<void> retryTransfer(String transferId) async {}

  @override
  Future<void> cancelTransfer(String transferId) async {}

  @override
  Future<void> resumeIncompleteTransfers({String? transferId}) async {}

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
