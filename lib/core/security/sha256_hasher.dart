import 'dart:io';
import 'package:crypto/crypto.dart';

final class Sha256Hasher {
  const Sha256Hasher();

  Future<String> hashFile(String filePath) async {
    final Digest digest = await sha256.bind(File(filePath).openRead()).first;
    return digest.toString();
  }

  String hashBytes(List<int> bytes) {
    return sha256.convert(bytes).toString();
  }
}
