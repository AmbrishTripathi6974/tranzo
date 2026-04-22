import 'dart:async';
import 'dart:math';
import 'dart:developer' as developer;

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../errors/exceptions.dart';

/// Supabase-backed auth and recipient short-code allocation.
///
/// Expects tables/policies such as:
/// `recipient_codes (user_id uuid primary key references auth.users, short_code text unique not null)`.
final class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  static const String _recipientCodesTable = 'recipient_codes';
  static const int _shortCodeLength = 6;
  static const int _shortCodeMaxAttempts = 12;
  static const String _shortCodeAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const int _sessionRecoveryMaxAttempts = 4;
  static const Duration _sessionRecoveryDelay = Duration(milliseconds: 150);
  static const Duration _dbRequestTimeout = Duration(seconds: 5);
  static const Duration _authRequestTimeout = Duration(seconds: 5);
  static const String _deviceAuthEmailKey = 'tranzo.device_auth.email';
  static const String _deviceAuthPasswordKey = 'tranzo.device_auth.password';
  static const String _recipientCodeKey = 'tranzo.identity.recipient_code';

  /// Signs in anonymously and persists a human-facing [shortCode] for pairing.
  Future<AnonymousUserResult> createAnonymousUserWithShortCode() async {
    final AuthResponse response = await _signInOrCreateDeviceUser();
    final Session? session = response.session;
    final User? user = response.user ?? session?.user;
    final String? userId = user?.id;
    if (userId == null || session == null) {
      throw const AppException('Anonymous sign-in did not return a session.');
    }

    final Random random = Random.secure();
    final String? pinnedCode = await getPersistedRecipientCode();
    for (var attempt = 0; attempt < _shortCodeMaxAttempts; attempt++) {
      final String code = pinnedCode ?? _randomShortCode(random);
      try {
        await _client
            .from(_recipientCodesTable)
            .insert(<String, dynamic>{'user_id': userId, 'short_code': code})
            .timeout(_dbRequestTimeout);
        await persistRecipientCode(code);
        return AnonymousUserResult(
          userId: userId,
          shortCode: code,
          session: session,
        );
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          if (pinnedCode != null) {
            await clearPersistedRecipientCode();
          }
          continue;
        }
        await _client.auth.signOut();
        throw AppException(e.message);
      } on TimeoutException {
        await _client.auth.signOut();
        throw const AppException(
          'Authentication timed out. Check connection and retry.',
        );
      } catch (e) {
        await _client.auth.signOut();
        throw AppException('$e');
      }
    }

    await _client.auth.signOut();
    throw const AppException('Could not allocate a unique short code.');
  }

  Future<AuthResponse> _signInOrCreateDeviceUser() async {
    try {
      return await _client.auth.signInAnonymously().timeout(_authRequestTimeout);
    } on AuthApiException catch (e) {
      if (e.code != 'anonymous_provider_disabled') {
        rethrow;
      }
      developer.log(
        'anonymous_signin_disabled_fallback_to_signup',
        name: 'auth',
      );
      return _signInOrSignUpDeviceUser();
    }
  }

  Future<AuthResponse> _signInOrSignUpDeviceUser() async {
    final _DeviceAuthCredentials creds = await _loadOrCreateDeviceCredentials();
    try {
      return await _client.auth
          .signInWithPassword(email: creds.email, password: creds.password)
          .timeout(_authRequestTimeout);
    } on AuthApiException catch (e) {
      // Existing account might not exist yet; create it once.
      if (e.code == 'invalid_credentials' ||
          e.code == 'invalid_login_credentials') {
        return _signUpDeviceUser(creds);
      }
      if (e.code == 'email_not_confirmed') {
        // Credentials are valid but email confirmation is enforced.
        throw const AppException(
          'Email auth requires confirmation in Supabase. Enable anonymous auth '
          'or disable email confirmation for device bootstrap.',
        );
      }
      rethrow;
    }
  }

  Future<AuthResponse> _signUpDeviceUser(_DeviceAuthCredentials creds) async {
    try {
      final AuthResponse response = await _client.auth
          .signUp(email: creds.email, password: creds.password)
          .timeout(_authRequestTimeout);
      return response;
    } on AuthApiException catch (e) {
      if (e.code == 'over_email_send_rate_limit') {
        throw const AppException(
          'Supabase email rate limit exceeded. Wait a moment, then retry. '
          'For production, enable anonymous auth for device identity.',
        );
      }
      rethrow;
    }
  }

  Future<_DeviceAuthCredentials> _loadOrCreateDeviceCredentials() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? storedEmail = prefs.getString(_deviceAuthEmailKey);
    final String? storedPassword = prefs.getString(_deviceAuthPasswordKey);
    if (storedEmail != null &&
        storedEmail.isNotEmpty &&
        storedPassword != null &&
        storedPassword.isNotEmpty) {
      return _DeviceAuthCredentials(email: storedEmail, password: storedPassword);
    }

    final Random random = Random.secure();
    final int nonce = random.nextInt(1 << 31);
    final String localPart =
        'tranzo_${DateTime.now().microsecondsSinceEpoch}_$nonce';
    final String email = '$localPart@example.com';
    final String password =
        '${_randomShortCode(random)}${_randomShortCode(random)}!';
    await prefs.setString(_deviceAuthEmailKey, email);
    await prefs.setString(_deviceAuthPasswordKey, password);
    return _DeviceAuthCredentials(email: email, password: password);
  }

  /// When Supabase still has a session but local storage was cleared, loads
  /// [user_id] + [short_code] from [recipient_codes] so the app can repopulate
  /// the local user row. Returns null if there is no session or no row.
  Future<UserSessionSnapshot?> loadCurrentSessionProfile() async {
    final User? user = await _resolveCurrentUser();
    if (user == null) {
      return null;
    }

    String? code = await _readShortCodeForUser(user.id);
    if (code == null || code.isEmpty) {
      code = await _createMissingShortCodeForUser(user.id);
      if (code == null || code.isEmpty) {
        return null;
      }
    }
    await persistRecipientCode(code);

    final Object? metaName = user.userMetadata?['display_name'];
    final String username = metaName is String && metaName.isNotEmpty
        ? metaName
        : 'User';

    return UserSessionSnapshot(
      userId: user.id,
      shortCode: code,
      username: username,
    );
  }

  Future<User?> _resolveCurrentUser() async {
    for (var attempt = 0; attempt < _sessionRecoveryMaxAttempts; attempt++) {
      final User? user = _client.auth.currentUser;
      if (user != null) {
        return user;
      }
      if (attempt < _sessionRecoveryMaxAttempts - 1) {
        await Future<void>.delayed(_sessionRecoveryDelay);
      }
    }
    return null;
  }

  Future<String?> _readShortCodeForUser(String userId) async {
    final Map<String, dynamic>? row = await _client
        .from(_recipientCodesTable)
        .select('short_code')
        .eq('user_id', userId)
        .maybeSingle()
        .timeout(_dbRequestTimeout);
    final String? code = row?['short_code'] as String?;
    if (code == null || code.isEmpty) {
      return null;
    }
    return code;
  }

  Future<String?> _createMissingShortCodeForUser(String userId) async {
    final Random random = Random.secure();
    final String? pinnedCode = await getPersistedRecipientCode();
    for (var attempt = 0; attempt < _shortCodeMaxAttempts; attempt++) {
      final String code = pinnedCode ?? _randomShortCode(random);
      try {
        await _client
            .from(_recipientCodesTable)
            .insert(<String, dynamic>{'user_id': userId, 'short_code': code})
            .timeout(_dbRequestTimeout);
        await persistRecipientCode(code);
        return code;
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          if (pinnedCode != null) {
            await clearPersistedRecipientCode();
          }
          continue;
        }
        // If another client created the row first, read the latest value.
        if (e.code == '23503') {
          return _readShortCodeForUser(userId);
        }
        throw AppException(e.message);
      } on TimeoutException {
        throw const AppException(
          'Profile sync timed out. Check connection and retry.',
        );
      } catch (e) {
        throw AppException('$e');
      }
    }
    throw const AppException('Could not allocate a unique short code.');
  }

  /// Returns the peer [userId] when [rawCode] matches an active short code.
  Future<RecipientCodeValidation?> validateRecipientCode(String rawCode) async {
    final String normalized = rawCode.trim().toUpperCase();
    if (normalized.isEmpty) {
      throw const AppException('Recipient code is empty.');
    }

    final Map<String, dynamic>? row = await _client
        .from(_recipientCodesTable)
        .select('user_id, short_code')
        .eq('short_code', normalized)
        .maybeSingle();

    if (row == null) {
      return null;
    }

    final String? userId = row['user_id'] as String?;
    final String? code = row['short_code'] as String?;
    if (userId == null || code == null) {
      return null;
    }

    return RecipientCodeValidation(recipientUserId: userId, shortCode: code);
  }

  String _randomShortCode(Random random) {
    final StringBuffer buffer = StringBuffer();
    for (var i = 0; i < _shortCodeLength; i++) {
      buffer.write(
        _shortCodeAlphabet[random.nextInt(_shortCodeAlphabet.length)],
      );
    }
    return buffer.toString();
  }

  Future<String?> getPersistedRecipientCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_recipientCodeKey);
    if (code == null || code.isEmpty) {
      return null;
    }
    return code.toUpperCase();
  }

  Future<void> persistRecipientCode(String shortCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_recipientCodeKey, shortCode.toUpperCase());
  }

  Future<void> clearPersistedRecipientCode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recipientCodeKey);
  }
}

final class _DeviceAuthCredentials {
  const _DeviceAuthCredentials({required this.email, required this.password});

  final String email;
  final String password;
}

final class AnonymousUserResult {
  const AnonymousUserResult({
    required this.userId,
    required this.shortCode,
    required this.session,
  });

  final String userId;
  final String shortCode;
  final Session session;
}

final class RecipientCodeValidation {
  const RecipientCodeValidation({
    required this.recipientUserId,
    required this.shortCode,
  });

  final String recipientUserId;
  final String shortCode;
}

final class UserSessionSnapshot {
  const UserSessionSnapshot({
    required this.userId,
    required this.shortCode,
    required this.username,
  });

  final String userId;
  final String shortCode;
  final String username;
}
