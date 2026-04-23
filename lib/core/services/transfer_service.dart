import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import '../errors/exceptions.dart';

/// Creates cloud-side transfer session rows.
///
/// Expects a `transfer_sessions` table aligned with your RLS policies.
class TransferService {
  TransferService(this._client);

  final SupabaseClient _client;

  static const String _transferSessionsTable = 'transfer_sessions';
  static const String _recipientCodesTable = 'recipient_codes';
  static const String _chunksBucket = 'transfer-chunks';
  static const String _insufficientRecipientCodePermissionCode = '42501';
  static const String _missingTransferSessionsHint =
      "Could not find the table 'public.transfer_sessions' in the schema cache";
  static const String _missingRecipientCodesHint =
      "Could not find the table 'public.recipient_codes' in the schema cache";
  static const String _storageObjectsRlsHint =
      'new row violates row-level security policy';
  static const String _postgrestRlsHint =
      'new row violates row-level security policy';

  /// Inserts a session row and returns the persisted record from PostgREST.
  Future<TransferSessionRecord> createTransferSession(
    TransferSessionPayload payload,
  ) async {
    await _ensureSenderMatchesAuthenticated(payload.senderId);
    try {
      final Map<String, dynamic> row = await _insertTransferSession(payload);
      return TransferSessionRecord.fromRow(row);
    } on PostgrestException catch (e) {
      if (_isRlsViolation(e.message) && await _tryRefreshSession()) {
        try {
          final Map<String, dynamic> row = await _insertTransferSession(
            payload,
          );
          return TransferSessionRecord.fromRow(row);
        } on PostgrestException catch (retryError) {
          throw _mapPostgrestException(
            retryError,
            fallbackMessage: 'Failed to create transfer session.',
          );
        }
      }
      throw _mapPostgrestException(
        e,
        fallbackMessage: 'Failed to create transfer session.',
      );
    }
  }

  Future<String?> resolveRecipientIdByCode(String rawCode) async {
    final String normalized = rawCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const AppException(
        'Recipient code is required.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    final RegExp allowed = RegExp(r'^[A-Z0-9]{4,12}$');
    if (!allowed.hasMatch(normalized)) {
      throw const AppException(
        'Recipient code format is invalid.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    try {
      final Map<String, dynamic>? row = await _client
          .from(_recipientCodesTable)
          .select('user_id')
          .eq('short_code', normalized)
          .maybeSingle();
      return row?['user_id'] as String?;
    } on PostgrestException catch (e) {
      if (e.code == _insufficientRecipientCodePermissionCode) {
        throw const AppException(
          'Cloud pairing is unavailable for this session. Reopen the app and try again.',
          code: AppErrorCode.invalidRecipientCode,
        );
      }
      throw _mapPostgrestException(
        e,
        fallbackMessage: 'Failed to resolve recipient code.',
      );
    }
  }

  Future<void> uploadTransferChunk({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required Stream<List<int>> byteStream,
  }) async {
    final List<int> chunkBytes = await byteStream.fold<List<int>>(
      <int>[],
      (List<int> acc, List<int> data) => acc..addAll(data),
    );
    try {
      await _uploadChunkBinary(
        sessionId: sessionId,
        fileId: fileId,
        chunkIndex: chunkIndex,
        chunkBytes: chunkBytes,
      );
    } on StorageException catch (e) {
      if (_isRlsViolation(e.message) && await _tryRefreshSession()) {
        try {
          await _uploadChunkBinary(
            sessionId: sessionId,
            fileId: fileId,
            chunkIndex: chunkIndex,
            chunkBytes: chunkBytes,
          );
          return;
        } on StorageException catch (retryError) {
          throw _mapStorageException(
            retryError,
            fallbackMessage: 'Failed to upload transfer chunk.',
          );
        }
      }
      throw _mapStorageException(
        e,
        fallbackMessage: 'Failed to upload transfer chunk.',
      );
    }
  }

  String? currentAuthenticatedUserId() {
    return _client.auth.currentUser?.id;
  }

  Future<String> requireAuthenticatedUserId() async {
    Session? session = _client.auth.currentSession;
    if (_sessionLikelyExpired(session)) {
      try {
        await _client.auth.refreshSession();
        session = _client.auth.currentSession;
      } catch (_) {
        // Fall through to validation below.
      }
    }
    String? userId = session?.user.id ?? _client.auth.currentUser?.id;
    if (userId == null || userId.trim().isEmpty) {
      userId = await _tryAnonymousReauth();
    }
    if (userId == null || userId.trim().isEmpty) {
      throw const AppException(
        'Cloud session expired. Sign in again before sending transfers.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    return userId;
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
      throw _mapPostgrestException(
        e,
        fallbackMessage: 'Failed to load incoming transfers.',
      );
    }
  }

  Future<List<TransferSessionRecord>> getParticipantTransfers(
    String userId,
  ) async {
    try {
      final List<dynamic> rows = await _client
          .from(_transferSessionsTable)
          .select()
          .or('receiver_id.eq.$userId,sender_id.eq.$userId')
          .order('created_at', ascending: false);
      return rows
          .map(
            (dynamic row) =>
                TransferSessionRecord.fromRow(row as Map<String, dynamic>),
          )
          .toList(growable: false);
    } on PostgrestException catch (e) {
      throw _mapPostgrestException(
        e,
        fallbackMessage: 'Failed to load transfer session updates.',
      );
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
      throw _mapPostgrestException(
        e,
        fallbackMessage: 'Failed to update transfer status.',
      );
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
      throw _mapStorageException(
        e,
        fallbackMessage: 'Failed to download transfer chunk.',
      );
    }
  }

  AppException _mapPostgrestException(
    PostgrestException exception, {
    required String fallbackMessage,
  }) {
    final String message = exception.message;
    if (message.contains(_missingTransferSessionsHint) ||
        message.contains(_missingRecipientCodesHint)) {
      return const AppException(
        'Cloud transfer tables are missing in Supabase. Apply latest migrations and restart the app.',
      );
    }
    if (_isRlsViolation(message)) {
      return const AppException(
        'Cloud session is not authorized for transfer writes. Re-authenticate and retry.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    return AppException(message.isEmpty ? fallbackMessage : message);
  }

  AppException _mapStorageException(
    StorageException exception, {
    required String fallbackMessage,
  }) {
    final String message = exception.message;
    final String normalized = message.toLowerCase();
    if (normalized.contains('jwt') ||
        normalized.contains('token') ||
        normalized.contains('unauthorized') ||
        normalized.contains('401')) {
      return const AppException(
        'Cloud auth session expired before upload. Sign in again and retry.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    if (message.toLowerCase().contains(_storageObjectsRlsHint)) {
      return const AppException(
        'Cloud storage policy blocked upload. Verify transfer storage policies and sender session, then retry.',
        code: AppErrorCode.invalidRecipientCode,
      );
    }
    return AppException(message.isEmpty ? fallbackMessage : message);
  }

  Future<Map<String, dynamic>> _insertTransferSession(
    TransferSessionPayload payload,
  ) {
    return _client
        .from(_transferSessionsTable)
        .insert(payload.toRow())
        .select()
        .single();
  }

  Future<void> _uploadChunkBinary({
    required String sessionId,
    required String fileId,
    required int chunkIndex,
    required List<int> chunkBytes,
  }) {
    final String objectPath = '$sessionId/$fileId/chunk_$chunkIndex.part';
    return _client.storage
        .from(_chunksBucket)
        .uploadBinary(
          objectPath,
          Uint8List.fromList(chunkBytes),
          fileOptions: const FileOptions(upsert: false),
        );
  }

  bool _isRlsViolation(String message) {
    final String normalized = message.toLowerCase();
    return normalized.contains(_postgrestRlsHint) ||
        normalized.contains(_storageObjectsRlsHint);
  }

  Future<bool> _tryRefreshSession() async {
    try {
      await _client.auth.refreshSession();
      return _client.auth.currentSession != null;
    } catch (_) {
      return false;
    }
  }

  Future<String?> _tryAnonymousReauth() async {
    try {
      final AuthResponse response = await _client.auth.signInAnonymously();
      return response.user?.id ?? response.session?.user.id;
    } catch (_) {
      return null;
    }
  }

  Future<void> _ensureSenderMatchesAuthenticated(String senderId) async {
    if (senderId.trim().isEmpty) {
      return;
    }
    final String? currentUserId = _client.auth.currentUser?.id;
    if (currentUserId == senderId) {
      return;
    }
    if (await _tryRefreshSession()) {
      final String? refreshedUserId = _client.auth.currentUser?.id;
      if (refreshedUserId == senderId) {
        return;
      }
    }
    throw const AppException(
      'Cloud session user does not match sender identity. Reauthenticate sender and retry.',
      code: AppErrorCode.invalidRecipientCode,
    );
  }

  bool _sessionLikelyExpired(Session? session) {
    if (session == null) {
      return true;
    }
    final dynamic rawExpiresAt = session.expiresAt;
    final int? expiresAtEpochSeconds = rawExpiresAt is int
        ? rawExpiresAt
        : (rawExpiresAt is String ? int.tryParse(rawExpiresAt) : null);
    if (expiresAtEpochSeconds == null) {
      return false;
    }
    final int nowEpochSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowEpochSeconds >= (expiresAtEpochSeconds - 30);
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
