import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

import '../errors/exceptions.dart';

/// Realtime broadcast helper (no UI subscriptions here).
final class RealtimeService {
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
      throw AppException('Realtime broadcast failed: $e');
    }
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

    channel.subscribe();

    controller.onCancel = () async {
      await channel.unsubscribe();
      _channels.remove(channelName);
    };

    return controller.stream;
  }
}
