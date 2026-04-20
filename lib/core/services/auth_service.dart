import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';

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
  static const String _shortCodeAlphabet =
      'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  /// Signs in anonymously and persists a human-facing [shortCode] for pairing.
  Future<AnonymousUserResult> createAnonymousUserWithShortCode() async {
    final AuthResponse response = await _client.auth.signInAnonymously();
    final Session? session = response.session;
    final User? user = response.user ?? session?.user;
    final String? userId = user?.id;
    if (userId == null || session == null) {
      throw const AppException('Anonymous sign-in did not return a session.');
    }

    final Random random = Random.secure();
    for (var attempt = 0; attempt < _shortCodeMaxAttempts; attempt++) {
      final String code = _randomShortCode(random);
      try {
        await _client.from(_recipientCodesTable).insert(<String, dynamic>{
          'user_id': userId,
          'short_code': code,
        });
        return AnonymousUserResult(
          userId: userId,
          shortCode: code,
          session: session,
        );
      } on PostgrestException catch (e) {
        if (e.code == '23505') {
          continue;
        }
        await _client.auth.signOut();
        throw AppException(e.message);
      } catch (e) {
        await _client.auth.signOut();
        throw AppException('$e');
      }
    }

    await _client.auth.signOut();
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
