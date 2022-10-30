import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

final sha3Hash = SHA3Digest(256);

Uint8List sha256(List<int> data) {
  sha3Hash.reset();
  return sha3Hash.process(Uint8List.fromList(data));
}

Uint8List sha256FromString(String str) {
  sha3Hash.reset();
  final data = Uint8List.fromList(utf8.encode(str));
  return sha3Hash.process(data);
}

Uint8List hmacSha256Sync(Uint8List hmacKey, Uint8List data) {
  final hmac = HMac(SHA256Digest(), 64) 
    ..init(KeyParameter(hmacKey));

  return hmac.process(data);
}