import 'dart:async';
import 'dart:math';

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
  static const int _sessionRecoveryMaxAttempts = 12;
  static const Duration _sessionRecoveryDelay = Duration(milliseconds: 250);
  static const Duration _dbRequestTimeout = Duration(seconds: 5);
  static const Duration _authRequestTimeout = Duration(seconds: 5);
  static const String _insufficientRecipientCodePermissionCode = '42501';
  static const String _recipientCodeKeyPrefix =
      'tranzo.identity.recipient_code';

  Future<void> sendEmailOtp({required String email}) async {
    final String normalized = email.trim().toLowerCase();
    if (normalized.isEmpty || !normalized.contains('@')) {
      throw const AppException('Enter a valid email address.');
    }
    try {
      await _client.auth
          .signInWithOtp(email: normalized, shouldCreateUser: true)
          .timeout(_authRequestTimeout);
    } on AuthApiException catch (e) {
      throw AppException(e.message);
    } on TimeoutException {
      throw const AppException('OTP request timed out. Please try again.');
    }
  }

  Future<UserSessionSnapshot> verifyEmailOtp({
    required String email,
    required String otpCode,
  }) async {
    final String normalizedEmail = email.trim().toLowerCase();
    final String normalizedCode = otpCode.trim();
    if (normalizedEmail.isEmpty || !normalizedEmail.contains('@')) {
      throw const AppException('Enter a valid email address.');
    }
    if (normalizedCode.length < 6) {
      throw const AppException('Enter the 6-digit code from your email.');
    }
    try {
      await _client.auth
          .verifyOTP(
            email: normalizedEmail,
            token: normalizedCode,
            type: OtpType.email,
          )
          .timeout(_authRequestTimeout);
    } on AuthApiException catch (e) {
      throw AppException(e.message);
    } on TimeoutException {
      throw const AppException('OTP verification timed out. Please try again.');
    }
    final UserSessionSnapshot? profile = await loadCurrentSessionProfile();
    if (profile == null) {
      throw const AppException(
        'Authenticated session unavailable after verification.',
      );
    }
    return profile;
  }

  Future<void> signOut() => _client.auth.signOut();

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
    await persistRecipientCode(user.id, code);

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
    final String? pinnedCode = await getPersistedRecipientCode(userId);
    for (var attempt = 0; attempt < _shortCodeMaxAttempts; attempt++) {
      final String code = pinnedCode ?? _randomShortCode(random);
      try {
        await _client
            .from(_recipientCodesTable)
            .insert(<String, dynamic>{'user_id': userId, 'short_code': code})
            .timeout(_dbRequestTimeout);
        await persistRecipientCode(userId, code);
        return code;
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          if (pinnedCode != null) {
            await clearPersistedRecipientCode(userId);
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
    final Map<String, dynamic>? row;
    try {
      row = await _client
          .from(_recipientCodesTable)
          .select('user_id, short_code')
          .eq('short_code', normalized)
          .maybeSingle();
    } on PostgrestException catch (e) {
      if (e.code == _insufficientRecipientCodePermissionCode) {
        throw const AppException(
          'Cloud pairing is unavailable for this session. Reopen the app and try again.',
          code: AppErrorCode.invalidRecipientCode,
        );
      }
      throw AppException(e.message);
    }

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

  String _recipientCodeKeyForUser(String userId) =>
      '$_recipientCodeKeyPrefix.$userId';

  Future<String?> getPersistedRecipientCode(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_recipientCodeKeyForUser(userId));
    if (code == null || code.isEmpty) {
      return null;
    }
    return code.toUpperCase();
  }

  Future<void> persistRecipientCode(String userId, String shortCode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _recipientCodeKeyForUser(userId),
      shortCode.toUpperCase(),
    );
  }

  Future<void> clearPersistedRecipientCode(String userId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recipientCodeKeyForUser(userId));
  }
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
