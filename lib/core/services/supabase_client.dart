import 'package:supabase_flutter/supabase_flutter.dart';

/// One-time Supabase bootstrap and access to the shared [SupabaseClient].
///
/// Call [initialize] from your composition root (for example `main`) before
/// constructing [AuthService], [TransferService], or [RealtimeService].
final class TranzoSupabase {
  TranzoSupabase._();

  /// Initializes the global Supabase instance. Must run at most once.
  static Future<void> initialize({
    required String supabaseUrl,
    required String anonKey,
  }) {
    return Supabase.initialize(url: supabaseUrl, anonKey: anonKey);
  }

  /// Live client after [initialize] completes.
  static SupabaseClient get client => Supabase.instance.client;
}

/// Injectable wrapper around [SupabaseClient] for tests and explicit DI.
final class SupabaseClientHandle {
  SupabaseClientHandle(this._client);

  factory SupabaseClientHandle.fromEnvironment() =>
      SupabaseClientHandle(TranzoSupabase.client);

  final SupabaseClient _client;

  SupabaseClient get client => _client;
}
