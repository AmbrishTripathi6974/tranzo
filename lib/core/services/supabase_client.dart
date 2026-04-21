import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/exceptions.dart';

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
    validateSecureUrl(supabaseUrl);
    if (anonKey.trim().isEmpty) {
      throw const SecurityException('Missing Supabase anon key configuration.');
    }
    return Supabase.initialize(url: supabaseUrl, anonKey: anonKey);
  }

  static Future<void> initializeFromEnvironment() {
    const String url = String.fromEnvironment('SUPABASE_URL');
    const String key = String.fromEnvironment('SUPABASE_ANON_KEY');
    if (url.trim().isEmpty) {
      throw const SecurityException(
        'Missing SUPABASE_URL. Set a secure HTTPS endpoint.',
      );
    }
    return initialize(supabaseUrl: url, anonKey: key);
  }

  static Uri validateSecureUrl(String rawUrl) {
    final Uri uri = Uri.parse(rawUrl.trim());
    if (!uri.isAbsolute || uri.host.isEmpty) {
      throw const SecurityException('Supabase URL must be absolute.');
    }
    if (uri.scheme.toLowerCase() != 'https') {
      throw SecurityException(
        'Insecure endpoint rejected: ${uri.scheme.toLowerCase()}',
      );
    }
    return uri;
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
