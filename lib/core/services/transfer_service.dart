import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import '../errors/exceptions.dart';

/// Creates cloud-side transfer session rows.
///
/// Expects a `transfer_sessions` table aligned with your RLS policies.
final class TransferService {
  TransferService(this._client);

  final SupabaseClient _client;

  static const String _transferSessionsTable = 'transfer_sessions';
  static const String _recipientCodesTable = 'recipient_codes';
  static const String _chunksBucket = 'transfer-chunks';

  /// Inserts a session row and returns the persisted record from PostgREST.
  Future<TransferSessionRecord> createTransferSession(
    TransferSessionPayload payload,
  ) async {
    try {
      final Map<String, dynamic> row = await _client
          .from(_transferSessionsTable)
          .insert(payload.toRow())
          .select()
          .single();
      return TransferSessionRecord.fromRow(row);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<String?> resolveRecipientIdByCode(String rawCode) async {
    final String normalized = rawCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const AppException('Recipient code is required.');
    }
    try {
      final Map<String, dynamic>? row = await _client
          .from(_recipientCodesTable)
          .select('user_id')
          .eq('short_code', normalized)
          .maybeSingle();
      return row?['user_id'] as String?;
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<void> uploadTransferChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  }) async {
    try {
      final List<int> chunkBytes = await byteStream.fold<List<int>>(
        <int>[],
        (List<int> acc, List<int> data) => acc..addAll(data),
      );
      final String objectPath = '$sessionId/$fileId/chunk_$chunkIndex.part';
      await _client.storage
          .from(_chunksBucket)
          .uploadBinary(
            objectPath,
            Uint8List.fromList(chunkBytes),
            fileOptions: const FileOptions(upsert: true),
          );
    } on StorageException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<List<TransferSessionRecord>> getIncomingTransfers(
    String receiverId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from(_transferSessionsTable)
          .select()
          .eq('receiver_id', receiverId)
          .order('created_at', ascending: false);
      return rows
          .map(
            (dynamic row) =>
                TransferSessionRecord.fromRow(row as Map<String, dynamic>),
          )
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<void> updateTransferStatus({
    required String transferId,
    required String status,
  }) async {
    try {
      await _client
          .from(_transferSessionsTable)
          .update(<String, dynamic>{'status': status})
          .eq('transfer_id', transferId);
    } on PostgrestException catch (e) {
      throw AppException(e.message);
    }
  }

  Future<Uint8List> downloadTransferChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
  }) async {
    final String objectPath = '$sessionId/$fileId/chunk_$chunkIndex.part';
    try {
      return await _client.storage.from(_chunksBucket).download(objectPath);
    } on StorageException catch (e) {
      throw AppException(e.message);
    }
  }
}

final class TransferSessionPayload {
  const TransferSessionPayload({
    required this.transferId,
    required this.senderId,
    required this.receiverId,
    required this.fileName,
    required this.fileSize,
    required this.fileHash,
    required this.status,
    required this.storagePath,
    required this.createdAt,
    this.expiresAt,
    this.intentExpiry,
    this.intentScore,
  });

  final String transferId;
  final String senderId;
  final String receiverId;
  final String fileName;
  final int fileSize;
  final String fileHash;
  final String status;
  final String storagePath;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final DateTime? intentExpiry;
  final double? intentScore;

  Map<String, dynamic> toRow() {
    return <String, dynamic>{
      'transfer_id': transferId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'file_name': fileName,
      'file_size': fileSize,
      'file_hash': fileHash,
      'status': status,
      'storage_path': storagePath,
      'created_at': createdAt.toUtc().toIso8601String(),
      if (expiresAt != null) 'expires_at': expiresAt!.toUtc().toIso8601String(),
      if (intentExpiry != null)
        'intent_expiry': intentExpiry!.toUtc().toIso8601String(),
      if (intentScore != null) 'intent_score': intentScore,
    };
  }
}

final class TransferSessionRecord {
  const TransferSessionRecord({
    required this.id,
    required this.transferId,
    required this.senderId,
    required this.receiverId,
    required this.row,
  });

  final String id;
  final String transferId;
  final String senderId;
  final String receiverId;
  final Map<String, dynamic> row;

  factory TransferSessionRecord.fromRow(Map<String, dynamic> row) {
    final String? id = row['id'] as String?;
    final String? transferId = row['transfer_id'] as String?;
    final String? senderId = row['sender_id'] as String?;
    final String? receiverId = row['receiver_id'] as String?;
    if (id == null ||
        transferId == null ||
        senderId == null ||
        receiverId == null) {
      throw const AppException('Malformed transfer_sessions response.');
    }
    return TransferSessionRecord(
      id: id,
      transferId: transferId,
      senderId: senderId,
      receiverId: receiverId,
      row: Map<String, dynamic>.from(row),
    );
  }
}
