import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../errors/exceptions.dart';

enum TransferLifecycleEvent {
  transferStarted('transfer_started'),
  transferAccepted('transfer_accepted'),
  transferCompleted('transfer_completed'),
  transferFailed('transfer_failed'),
  transferRejected('transfer_rejected');

  const TransferLifecycleEvent(this.wireName);
  final String wireName;

  static TransferLifecycleEvent? fromWireName(String value) {
    for (final TransferLifecycleEvent event in TransferLifecycleEvent.values) {
      if (event.wireName == value) {
        return event;
      }
    }
    return null;
  }
}

final class TransferLifecycleSignal {
  const TransferLifecycleSignal({
    required this.transferId,
    required this.senderId,
    required this.receiverId,
    required this.event,
    required this.emittedAt,
    this.fileId,
    this.fileName,
    this.fileSize,
    this.fileHash,
    this.storagePath,
  });

  final String transferId;
  final String senderId;
  final String receiverId;
  final TransferLifecycleEvent event;
  final DateTime emittedAt;
  final String? fileId;
  final String? fileName;
  final int? fileSize;
  final String? fileHash;
  final String? storagePath;

  Map<String, dynamic> toPayload() {
    return <String, dynamic>{
      'transfer_id': transferId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'event_name': event.wireName,
      'emitted_at': emittedAt.toUtc().toIso8601String(),
      if (fileId != null) 'file_id': fileId,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (fileHash != null) 'file_hash': fileHash,
      if (storagePath != null) 'storage_path': storagePath,
    };
  }

  static TransferLifecycleSignal? fromPayload(Map<String, dynamic> payload) {
    final String? transferId = payload['transfer_id'] as String?;
    final String? senderId = payload['sender_id'] as String?;
    final String? receiverId = payload['receiver_id'] as String?;
    final String? eventRaw = payload['event_name'] as String?;
    final TransferLifecycleEvent? event = eventRaw == null
        ? null
        : TransferLifecycleEvent.fromWireName(eventRaw);
    if (transferId == null ||
        senderId == null ||
        receiverId == null ||
        event == null) {
      return null;
    }
    final String emittedAtRaw =
        payload['emitted_at'] as String? ?? DateTime.now().toIso8601String();
    return TransferLifecycleSignal(
      transferId: transferId,
      senderId: senderId,
      receiverId: receiverId,
      event: event,
      emittedAt: DateTime.tryParse(emittedAtRaw) ?? DateTime.now(),
      fileId: payload['file_id'] as String?,
      fileName: payload['file_name'] as String?,
      fileSize: payload['file_size'] as int?,
      fileHash: payload['file_hash'] as String?,
      storagePath: payload['storage_path'] as String?,
    );
  }
}

/// Realtime broadcast helper (no UI subscriptions here).
class RealtimeService {
  RealtimeService(this._client);

  final SupabaseClient _client;
  final Map<String, RealtimeChannel> _channels = <String, RealtimeChannel>{};

  /// Sends a broadcast on [channelName] using the Realtime REST endpoint.
  ///
  /// Configure matching Realtime authorization for the channel in Supabase.
  Future<void> sendRealtimeEvent({
    required String channelName,
    required String event,
    required Map<String, dynamic> payload,
  }) async {
    if (channelName.trim().isEmpty) {
      throw const AppException('Channel name is empty.');
    }
    if (event.trim().isEmpty) {
      throw const AppException('Event name is empty.');
    }

    final RealtimeChannel channel = _client.channel(
      channelName,
      opts: const RealtimeChannelConfig(),
    );

    try {
      await channel.httpSend(event: event, payload: payload);
    } catch (e) {
      throw AppException('Realtime broadcast unavailable: $e');
    }
  }

  Future<void> sendTransferSignal({
    required TransferLifecycleSignal signal,
    String channelPrefix = 'transfer-signals',
  }) {
    return sendRealtimeEvent(
      channelName: '$channelPrefix:${signal.receiverId}',
      event: signal.event.wireName,
      payload: signal.toPayload(),
    );
  }

  Stream<TransferLifecycleSignal> listenTransferSignals({
    required String receiverId,
    String channelPrefix = 'transfer-signals',
  }) {
    if (receiverId.trim().isEmpty) {
      throw const AppException('Receiver id is empty.');
    }
    final String channelName = '$channelPrefix:$receiverId';
    final StreamController<TransferLifecycleSignal> controller =
        StreamController<TransferLifecycleSignal>();
    final RealtimeChannel channel = _client.channel(
      channelName,
      opts: const RealtimeChannelConfig(),
    );
    _channels[channelName] = channel;

    for (final TransferLifecycleEvent event in TransferLifecycleEvent.values) {
      channel.onBroadcast(
        event: event.wireName,
        callback: (dynamic message) {
          final dynamic rawPayload = message is Map<String, dynamic>
              ? message['payload'] ?? message
              : <String, dynamic>{};
          final Map<String, dynamic> payload = Map<String, dynamic>.from(
            rawPayload as Map,
          );
          final TransferLifecycleSignal? parsed =
              TransferLifecycleSignal.fromPayload(payload);
          if (parsed == null || parsed.receiverId != receiverId) {
            return;
          }
          controller.add(parsed);
        },
      );
    }
    try {
      channel.subscribe();
    } catch (_) {
      controller.addError(
        const AppException('Realtime lifecycle subscription unavailable.'),
      );
    }

    controller.onCancel = () async {
      await channel.unsubscribe();
      _channels.remove(channelName);
    };
    return controller.stream;
  }

  Stream<Map<String, dynamic>> listenIncomingTransfers({
    required String receiverId,
    String channelName = 'incoming-transfers',
    String event = 'incoming_transfer',
  }) {
    if (receiverId.trim().isEmpty) {
      throw const AppException('Receiver id is empty.');
    }
    final StreamController<Map<String, dynamic>> controller =
        StreamController<Map<String, dynamic>>();
    final RealtimeChannel channel = _client.channel(
      channelName,
      opts: const RealtimeChannelConfig(),
    );
    _channels[channelName] = channel;

    channel.onBroadcast(
      event: event,
      callback: (dynamic message) {
        final dynamic rawPayload = message is Map<String, dynamic>
            ? message['payload'] ?? message
            : <String, dynamic>{};
        final Map<String, dynamic> payload = Map<String, dynamic>.from(
          rawPayload as Map,
        );
        if (payload['receiver_id'] == receiverId) {
          controller.add(payload);
        }
      },
    );
    try {
      channel.subscribe();
    } catch (_) {
      controller.addError(
        const AppException('Realtime incoming subscription unavailable.'),
      );
    }

    controller.onCancel = () async {
      await channel.unsubscribe();
      _channels.remove(channelName);
    };

    return controller.stream;
  }
}
