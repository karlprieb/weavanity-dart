import 'dart:convert';
import 'dart:typed_data';
// ignore: implementation_imports
import 'package:pointycastle/src/platform_check/platform_check.dart';
import "package:pointycastle/export.dart";
import 'package:cryptography/cryptography.dart';
import 'package:jwk/jwk.dart';

final BigInt _byteMask = BigInt.from(0xff);
Uint8List encodeBigIntToBytes(BigInt bigInt) {
  var size = (bigInt.bitLength + 7) >> 3;
  var result = Uint8List(size);
  for (var i = 0; i < size; i++) {
    result[size - i - 1] = (bigInt & _byteMask).toInt();
    bigInt = bigInt >> 8;
  }
  return result;
}

String encodeBytesToBase64(List<int> bytes) =>
    base64Url.encode(bytes).replaceAll('=', '');

Uint8List decodeBase64ToBytes(String base64) =>
    base64Url.decode(base64Url.normalize(base64));

final Sha256 sha256 = Sha256();

Future<String> ownerToAddress(String owner) async => encodeBytesToBase64(
    await sha256.hash(decodeBase64ToBytes(owner)).then((res) => res.bytes));

final BigInt publicExponent = BigInt.parse('65537');
const int keyLength = 4096;

// Based on Arweave Dart SDK
// https://github.com/CDDelta/arweave-dart
class Wallet {
  final RsaKeyPair _keyPair;

  Wallet({required RsaKeyPair keyPair}) : _keyPair = keyPair;

  static Future<Wallet> generate() async {
    final FortunaRandom secureRandom = FortunaRandom()
      ..seed(
          KeyParameter(Platform.instance.platformEntropySource().getBytes(32)));

    final RSAKeyGenerator keyGen = RSAKeyGenerator()
      ..init(
        ParametersWithRandom(
          RSAKeyGeneratorParameters(
            publicExponent,
            keyLength,
            12,
          ),
          secureRandom,
        ),
      );

    final AsymmetricKeyPair keyPair = keyGen.generateKeyPair();

    final RSAPrivateKey privateKey = keyPair.privateKey as RSAPrivateKey;

    return Wallet(
      keyPair: RsaKeyPairData(
        e: encodeBigIntToBytes(privateKey.publicExponent!),
        n: encodeBigIntToBytes(privateKey.modulus!),
        d: encodeBigIntToBytes(privateKey.privateExponent!),
        p: encodeBigIntToBytes(privateKey.p!),
        q: encodeBigIntToBytes(privateKey.q!),
      ),
    );
  }

  Future<String> getOwner() async => encodeBytesToBase64(
      await _keyPair.extractPublicKey().then((res) => res.n));

  Future<String> getAddress() async => ownerToAddress(await getOwner());

  String toJwkJson() => json.encode(Jwk.fromKeyPair(_keyPair).toJson());
}
