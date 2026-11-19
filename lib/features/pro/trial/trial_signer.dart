import 'dart:convert';

import 'package:cryptography/cryptography.dart';

import 'trial_record.dart';

/// Signs and verifies trial records. A record that fails [verify] counts as
/// "trial used" wherever it came from.
abstract class TrialSigner {
  Future<String> sign(int v, String id, int startMs);
  Future<bool> verify(TrialRecord r);
}

// Dart half of the key, XOR-masked so it is not a literal in the binary
// (release builds also use --obfuscate). The other half comes from native code
// over the trial channel (`keyPart`). Key = SHA-256(dartHalf || nativeHalf).
const _kA = <int>[216, 176, 90, 49, 190, 165, 233, 228, 243, 12, 212, 135, 172, 203, 23, 85, 190, 120, 250, 134, 99, 224, 239, 245, 228, 236, 135, 175, 156, 50, 37, 81];
const _kB = <int>[163, 214, 196, 50, 205, 9, 149, 94, 117, 230, 106, 158, 149, 207, 6, 247, 200, 252, 9, 245, 197, 152, 48, 48, 180, 251, 170, 16, 121, 154, 104, 92];

List<int> _dartHalf() => [for (var i = 0; i < _kA.length; i++) _kA[i] ^ _kB[i]];

class HmacTrialSigner implements TrialSigner {
  /// Native half of the key, or null where unavailable (web, tests): then the
  /// Dart half alone is used.
  final Future<List<int>?> Function() nativeHalf;
  HmacTrialSigner(this.nativeHalf);

  SecretKey? _key;

  Future<SecretKey> _secret() async {
    final cached = _key;
    if (cached != null) return cached;
    final native = await nativeHalf();
    final hash = await Sha256().hash([..._dartHalf(), ...?native]);
    return _key = SecretKey(hash.bytes);
  }

  @override
  Future<String> sign(int v, String id, int startMs) async {
    final mac = await Hmac.sha256().calculateMac(utf8.encode('$v|$id|$startMs'), secretKey: await _secret());
    return base64Url.encode(mac.bytes).replaceAll('=', '');
  }

  @override
  Future<bool> verify(TrialRecord r) async {
    if (r.v != 1) return false;
    return r.sig == await sign(r.v, r.id, r.startMs);
  }
}

/// Test signer with a fixed key.
class FixedKeyTrialSigner extends HmacTrialSigner {
  FixedKeyTrialSigner([List<int> key = const [1, 2, 3]]) : super(() async => key);
}
