import 'package:isar_community/isar.dart';

import '../../../core/database/isar/collections/file_collection.dart';
import '../../../core/database/isar/collections/transfer_collection.dart';
import '../../../core/database/isar/collections/transfer_progress_collection.dart';
import '../../../domain/entities/file_status.dart';
import '../../../domain/entities/transfer_status.dart';
import '../../../transfer_engine/state/transfer_state_manager.dart';
import '../../models/transfer_task_model.dart';

abstract interface class TransferLocalDataSource {
  Future<void> saveTransferMetadata(TransferTaskModel task);
  Future<bool> transferExists(String transferId);
  Future<bool> fileHashExists(String hash);
  Future<void> upsertIncomingTransfer({
    required String transferId,
    required String senderId,
    required String receiverId,
    String? senderUsername,
    String? receiverUsername,
    required String fileId,
    required String fileName,
    required int fileSize,
    required String fileHash,
    required String storagePath,
    required DateTime createdAt,
    required TransferStatus status,
  });
  Future<void> updateTransferStatus(String transferId, TransferStatus status);
  Future<void> updateFileStatusByTransferId(
    String transferId,
    FileStatus status,
  );
  Future<bool> fileExistsByFileId(String fileId);
  Future<TransferResumeState?> getTransferProgress(String transferId);
  Future<void> upsertTransferProgress(TransferResumeState state);
  Future<void> clearTransferProgress(String transferId);
}

class TransferLocalDataSourceImpl implements TransferLocalDataSource {
  TransferLocalDataSourceImpl(this._isar);

  final Isar _isar;

  @override
  Future<void> saveTransferMetadata(TransferTaskModel task) async {
    await _isar.writeTxn(() async {
      final TransferCollection row = TransferCollection()
        ..transferId = task.id
        ..senderId = 'unknown'
        ..receiverId = 'unknown'
        ..status = TransferStatus.pending
        ..createdAt = DateTime.now()
        ..fileName = task.fileName
        ..fileSize = task.totalBytes
        ..storagePath = task.localPath;
      await _isar.transferCollections.put(row);
    });
  }

  @override
  Future<bool> transferExists(String transferId) async {
    final TransferCollection? row = await _isar.transferCollections
        .filter()
        .transferIdEqualTo(transferId)
        .findFirst();
    return row != null;
  }

  @override
  Future<bool> fileHashExists(String hash) async {
    final FileCollection? row = await _isar.fileCollections
        .filter()
        .hashEqualTo(hash)
        .findFirst();
    return row != null;
  }

  @override
  Future<void> upsertIncomingTransfer({
    required String transferId,
    required String senderId,
    required String receiverId,
    String? senderUsername,
    String? receiverUsername,
    required String fileId,
    required String fileName,
    required int fileSize,
    required String fileHash,
    required String storagePath,
    required DateTime createdAt,
    required TransferStatus status,
  }) async {
    await _isar.writeTxn(() async {
      final TransferCollection transfer = TransferCollection()
        ..transferId = transferId
        ..senderId = senderId
        ..receiverId = receiverId
        ..senderUsername = senderUsername
        ..receiverUsername = receiverUsername
        ..status = status
        ..createdAt = createdAt
        ..fileName = fileName
        ..fileSize = fileSize
        ..fileHash = fileHash
        ..storagePath = storagePath;
      await _isar.transferCollections.put(transfer);

      final FileCollection file = FileCollection()
        ..fileId = fileId
        ..transferId = transferId
        ..fileName = fileName
        ..size = fileSize
        ..hash = fileHash
        ..status = FileStatus.pending;
      await _isar.fileCollections.put(file);
    });
  }

  @override
  Future<void> updateTransferStatus(
    String transferId,
    TransferStatus status,
  ) async {
    await _isar.writeTxn(() async {
      final TransferCollection? transfer = await _isar.transferCollections
          .filter()
          .transferIdEqualTo(transferId)
          .findFirst();
      if (transfer == null) {
        return;
      }
      transfer.status = status;
      await _isar.transferCollections.put(transfer);
    });
  }

  @override
  Future<void> updateFileStatusByTransferId(
    String transferId,
    FileStatus status,
  ) async {
    await _isar.writeTxn(() async {
      final List<FileCollection> rows = await _isar.fileCollections
          .filter()
          .transferIdEqualTo(transferId)
          .findAll();
      for (final FileCollection row in rows) {
        row.status = status;
      }
      await _isar.fileCollections.putAll(rows);
    });
  }

  @override
  Future<bool> fileExistsByFileId(String fileId) async {
    final FileCollection? row = await _isar.fileCollections
        .filter()
        .fileIdEqualTo(fileId)
        .findFirst();
    return row != null;
  }

  @override
  Future<TransferResumeState?> getTransferProgress(String transferId) async {
    final TransferProgressCollection? row = await _isar
        .transferProgressCollections
        .getByTransferId(transferId);
    if (row == null) {
      return null;
    }
    return TransferResumeState(
      transferId: row.transferId,
      fileName: row.fileName,
      totalBytes: row.totalBytes,
      direction: TransferSessionDirection.values[row.direction],
      completedChunkIndexes: row.completedChunkIndexes.toSet(),
      updatedAt: row.updatedAt,
    );
  }

  @override
  Future<void> upsertTransferProgress(TransferResumeState state) async {
    final List<int> completed = state.completedChunkIndexes.toList(
      growable: false,
    )..sort();
    await _isar.writeTxn(() async {
      final TransferProgressCollection row = TransferProgressCollection()
        ..transferId = state.transferId
        ..fileName = state.fileName
        ..totalBytes = state.totalBytes
        ..direction = state.direction.index
        ..completedChunkIndexes = completed
        ..updatedAt = DateTime.now();
      await _isar.transferProgressCollections.putByTransferId(row);
    });
  }

  @override
  Future<void> clearTransferProgress(String transferId) async {
    await _isar.writeTxn(() async {
      await _isar.transferProgressCollections.deleteByTransferId(transferId);
    });
  }
}
