import 'dart:io';

import 'package:crypto/crypto.dart';
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

    test('hashFile matches hashBytes for same file content', () async {
      final Directory dir = await Directory.systemTemp.createTemp('tranzo_sha256');
      addTearDown(() async {
        if (await dir.exists()) {
          await dir.delete(recursive: true);
        }
      });
      final File file = File('${dir.path}/content.bin');
      await file.writeAsBytes('tranzo'.codeUnits, flush: true);

      final String fromFile = await hasher.hashFile(file.path);
      final String fromBytes = hasher.hashBytes('tranzo'.codeUnits);
      expect(fromFile, fromBytes);
    });

    test('hashBytesAsync matches sha256.convert for isolate-sized buffer', () async {
      const int length = 512 * 1024;
      final List<int> bytes = List<int>.filled(length, 7);
      final String expected = sha256.convert(bytes).toString();

      final String actual = await hasher.hashBytesAsync(bytes);
      expect(actual, expected);
    });
  });
}
