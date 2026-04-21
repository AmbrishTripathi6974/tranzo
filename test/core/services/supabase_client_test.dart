import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/core/errors/exceptions.dart';
import 'package:tranzo/core/services/supabase_client.dart';

void main() {
  group('TranzoSupabase.validateSecureUrl', () {
    test('accepts valid https URL', () {
      final Uri uri = TranzoSupabase.validateSecureUrl(
        'https://abc.supabase.co',
      );
      expect(uri.scheme, 'https');
      expect(uri.host, 'abc.supabase.co');
    });

    test('rejects non-https URL', () {
      expect(
        () => TranzoSupabase.validateSecureUrl('http://abc.supabase.co'),
        throwsA(
          isA<SecurityException>().having(
            (e) => e.code,
            'code',
            AppErrorCode.insecureEndpoint,
          ),
        ),
      );
    });
  });
}
