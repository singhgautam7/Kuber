import 'package:flutter/services.dart';

/// Flutter side of the native home-screen widgets (the
/// `com.grs.kuber/widgets` channel in MainActivity). Providers live in
/// `com.grs.kuber.widgets.*`; [provider] is the simple class name.
/// Every call is a no-op (false) off Android or when the channel is missing.
class HomeWidgetBridge {
  const HomeWidgetBridge._();

  static const _channel = MethodChannel('com.grs.kuber/widgets');

  static Future<bool> _call(String method, [Map<String, Object?>? args]) async {
    try {
      return await _channel.invokeMethod<bool>(method, args) ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Stores [value] under [key] for the widget providers to read.
  static Future<bool> save(String key, String value) =>
      _call('save', {'key': key, 'value': value});

  /// Redraws every placed instance of [provider].
  static Future<bool> update(String provider) =>
      _call('update', {'provider': provider});

  /// True when at least one Kuber widget is on the home screen.
  static Future<bool> hasPlacedWidget() => _call('hasPlacedWidget');

  static Future<bool> isPinSupported() => _call('isPinSupported');

  /// Asks the launcher to pin [provider]. False if unsupported or the
  /// request could not be issued.
  static Future<bool> requestPin(String provider) =>
      _call('requestPin', {'provider': provider});
}
