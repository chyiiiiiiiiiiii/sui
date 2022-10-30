
import 'dart:convert';
import 'dart:typed_data';

import 'package:sui/cryptography/ed25519_publickey.dart';
import 'package:sui/cryptography/keypair.dart';
import 'package:sui/cryptography/mnemonics.dart';
import 'package:sui/cryptography/publickey.dart';
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed25519;
import 'package:sui/cryptography/secp256k1.dart';
import 'package:sui/serialization/base64_buffer.dart';
import 'package:sui/utils/ed25519_hd_key.dart' as ed25519HDKey;

const DEFAULT_ED25519_DERIVATION_PATH = "m/44'/784'/0'/0'/0'";


class Ed25519Keypair with Keypair {

  late ed25519.KeyPair _signingKeypair;

  /// Create a new Ed25519 keypair instance.
  /// Generate random keypair if no [Ed25519Keypair] is provided.
  Ed25519Keypair([Uint8List? secretKey]) {
    if (secretKey != null) {
      final privateKey = ed25519.PrivateKey(secretKey);
      final publicKey = ed25519.public(privateKey);
      _signingKeypair = ed25519.KeyPair(privateKey, publicKey);
    } else {
      _signingKeypair = ed25519.generateKey();
    }
  }

  @override
  SignatureScheme getKeyScheme() {
    return SignatureScheme.ED25519;
  }

  Uint8List secretKeyBytes() {
    return Uint8List.fromList(_signingKeypair.privateKey.bytes);
  }

  Uint8List publicKeyBytes() {
    return Uint8List.fromList(_signingKeypair.publicKey.bytes);
  }

  ed25519.KeyPair keyPair() {
    return _signingKeypair;
  }

  /// Create a Ed25519 keypair from a raw secret key byte array.
  ///
  /// throws error if the provided secret key is invalid and validation is not skipped.
  factory Ed25519Keypair.fromSecretKey(
    Uint8List secretKey,
    { bool? skipValidation }
  ) {
    final privateKey = ed25519.PrivateKey(secretKey);
    final publicKey = ed25519.public(privateKey);

    if (skipValidation != null && !skipValidation) {
      final msg =  Uint8List.fromList(utf8.encode('sui validation'));
      final signature = ed25519.sign(privateKey,msg);
      if (!ed25519.verify(publicKey, msg, signature)) {
        throw ArgumentError('provided secretKey is invalid');
      }
    }
    return Ed25519Keypair(secretKey);
  }

  /// Generate a Ed25519 keypair from a 32 byte seed.
  factory Ed25519Keypair.fromSeed(Uint8List seed) {
    final privateKey = ed25519.newKeyFromSeed(seed);
    return Ed25519Keypair(Uint8List.fromList(privateKey.bytes));
  }

  /// The public key for this Ed25519 keypair
  @override
  Ed25519PublicKey getPublicKey() {
    return Ed25519PublicKey(decodeBigIntToUnsigned(_signingKeypair.publicKey.bytes));
  }

  /// Return the signature for the provided data using Ed25519.
  @override
  Base64DataBuffer signData(Base64DataBuffer data) {
    Uint8List signature = ed25519.sign(_signingKeypair.privateKey, data.getData());
    return Base64DataBuffer(signature);
  }

  /// Derive Ed25519 keypair from mnemonics and path. The mnemonics must be normalized
  /// and validated against the english wordlist.
  ///
  /// If path is none, it will default to m/44'/784'/0'/0'/0', otherwise the path must
  /// be compliant to SLIP-0010 in form m/44'/784'/{account_index}'/{change_index}'/{address_index}'.
  static Ed25519Keypair deriveKeypair(String mnemonics, [String? path]) {
    path ??= DEFAULT_ED25519_DERIVATION_PATH;

    if (!isValidHardenedPath(path)) {
      throw ArgumentError('Invalid derivation path');
    }

    final normalizeMnemonics = mnemonics
      .trim()
      .split(r"\s+")
      .map((part) => part.toLowerCase())
      .join(" ");

    if(!isValidMnemonics(mnemonics)) {
      throw ArgumentError('Invalid mnemonics');
    }

    final key = ed25519HDKey.derivePath(path, mnemonicToSeedHex(normalizeMnemonics)).key!;    
    final pubkey = ed25519HDKey.getPublicKey(key, false);
    
    final fullPrivateKey = Uint8List(64);
    fullPrivateKey.setAll(0, key);
    fullPrivateKey.setAll(32, pubkey);

    return Ed25519Keypair(Uint8List.fromList(fullPrivateKey));
  }
}
