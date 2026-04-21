import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/domain/entities/file_entity.dart';
import 'package:tranzo/domain/entities/incoming_transfer_offer.dart';
import 'package:tranzo/domain/entities/profile_interaction_entity.dart';
import 'package:tranzo/domain/entities/selected_transfer_file.dart';
import 'package:tranzo/domain/entities/transfer_batch_progress.dart';
import 'package:tranzo/domain/entities/transfer_entity.dart';
import 'package:tranzo/domain/entities/transfer_task.dart';
import 'package:tranzo/domain/entities/user_entity.dart';
import 'package:tranzo/domain/repositories/auth_repository.dart';
import 'package:tranzo/domain/repositories/transfer_repository.dart';
import 'package:tranzo/domain/usecases/get_user_interactions_usecase.dart';
import 'package:tranzo/domain/usecases/get_user_profile_usecase.dart';
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
        getUserProfile: GetUserProfile(authRepository),
        getUserInteractions: GetUserInteractions(transferRepository),
      );

      bloc.add(const ProfileRequested());
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(bloc.state.status, ProfileStatus.success);
      expect(bloc.state.user?.shortCode, 'AB12');
      expect(bloc.state.interactions.length, 1);
      await bloc.close();
    });
  });
}

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({required this.user});

  final UserEntity? user;

  @override
  Future<UserEntity> createUser({
    required String shortCode,
    required String username,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<UserEntity?> getCurrentUser() async => user;
}

class _FakeTransferRepository implements TransferRepository {
  _FakeTransferRepository({required this.interactions});

  final List<ProfileInteractionEntity> interactions;

  @override
  Future<void> acceptIncomingTransfer({
    required IncomingTransferOffer transfer,
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
  Future<TransferEntity> receiveFiles(String transferId) {
    throw UnimplementedError();
  }

  @override
  Future<void> rejectIncomingTransfer({required String transferId}) async {}

  @override
  Future<void> retryTransfer(String transferId) async {}

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
