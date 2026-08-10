import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Biometric-convenience secret store, backed by the Android Keystore (native
/// `com.grs.kuber/cards_keystore` in `MainActivity.kt`).
///
/// SECURITY: we store the **derived 32-byte key**, never the PIN. The PIN itself
/// is never persisted anywhere (not here, not in SharedPreferences, Isar, logs,
/// or backups). The stored key is encrypted at rest under a hardware Keystore
/// key; callers gate [retrieveKey] behind a successful `local_auth` biometric
/// check. Unlock verification uses the Argon2id-derived verifier, not a hash of
/// the PIN (a short PIN's hash would be trivially brute-forced).
/// See `specs/plans/kuber-cards.md` §2.5.
class CardKeystore {
  CardKeystore._();

  static const _channel = MethodChannel('com.grs.kuber/cards_keystore');

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Persist the derived key for biometric unlock. Called only after the user
  /// opts in (following a successful biometric check).
  static Future<bool> storeKey(List<int> key) async {
    if (!_supported) return false;
    try {
      await _channel.invokeMethod('store', {'secret': base64Encode(key)});
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Retrieve the raw stored secret string (caller must have just passed a
  /// biometric check). Normally a base64 key; may be a legacy plaintext PIN from
  /// an older build, which the caller migrates on unlock.
  static Future<String?> retrieveSecret() async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<String>('retrieve');
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod('clear');
    } catch (_) {}
  }
}
