import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Applies Android `FLAG_SECURE` while any Kuber Cards screen is on screen:
/// blocks screenshots and screen recording, and blanks the app-switcher preview
/// (so no card content leaks to the OS thumbnail). Ref-counted so nested pushes
/// (home -> add -> detail) keep it on until the last cards screen is gone.
///
/// Native handler: `com.grs.kuber/secure_screen` in `MainActivity.kt`.
/// See `specs/plans/kuber-cards.md` §8.
class CardSecureScreen {
  CardSecureScreen._();

  static const _channel = MethodChannel('com.grs.kuber/secure_screen');
  static int _count = 0;

  static bool get _supported =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// Register one active cards screen; enables FLAG_SECURE on the first.
  static Future<void> acquire() async {
    _count++;
    if (_count == 1) await _set(true);
  }

  /// Release one cards screen; disables FLAG_SECURE when none remain.
  static Future<void> release() async {
    _count--;
    if (_count <= 0) {
      _count = 0;
      await _set(false);
    }
  }

  static Future<void> _set(bool enabled) async {
    if (!_supported) return;
    try {
      await _channel.invokeMethod(enabled ? 'enable' : 'disable');
    } catch (_) {
      // Best-effort: never crash a screen if the native side is unavailable.
    }
  }
}
