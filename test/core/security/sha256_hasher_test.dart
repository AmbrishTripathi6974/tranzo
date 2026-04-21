import 'package:flutter_test/flutter_test.dart';
import 'package:tranzo/core/security/sha256_hasher.dart';

void main() {
  group('Sha256Hasher', () {
    const Sha256Hasher hasher = Sha256Hasher();

    test('hashBytes returns deterministic SHA-256 digest', () {
      final String digest = hasher.hashBytes('tranzo'.codeUnits);
      expect(
        digest,
        'b29a72422c0b2f475d8edec056496de656f8102ac5130eba3e1b190f20078c5b',
      );
    });
  });
}
