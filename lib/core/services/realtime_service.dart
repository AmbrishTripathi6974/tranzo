import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/exceptions.dart';

/// Realtime broadcast helper (no UI subscriptions here).
final class RealtimeService {
  RealtimeService(this._client);

  final SupabaseClient _client;

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
}
