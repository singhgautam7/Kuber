import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Result of reading Block Store. [error] is true when Play services could
/// not answer (the caller then falls back to the local row only).
class BlockRead {
  final String? data;
  final bool error;
  const BlockRead(this.data, {this.error = false});
}

/// Google Play services Block Store behind `com.grs.kuber/trial`.
abstract class TrialBlockStore {
  Future<BlockRead> read();
  Future<bool> write(String data);

  /// Native half of the signing key, or null where unavailable.
  Future<List<int>?> keyPart();

  /// Milliseconds since boot (Android `SystemClock.elapsedRealtime`, which
  /// the user can't change), or null where unavailable.
  Future<int?> uptimeMs();
}

class ChannelTrialBlockStore implements TrialBlockStore {
  static const _channel = MethodChannel('com.grs.kuber/trial');
  bool get _supported => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  @override
  Future<BlockRead> read() async {
    if (!_supported) return const BlockRead(null, error: true);
    try {
      final m = await _channel.invokeMapMethod<String, dynamic>('read');
      return BlockRead(m?['data'] as String?, error: m?['error'] == true);
    } catch (e) {
      debugPrint('Kuber trial: Block Store read failed (local row only): $e');
      return const BlockRead(null, error: true);
    }
  }

  @override
  Future<bool> write(String data) async {
    if (!_supported) return false;
    try {
      return await _channel.invokeMethod<bool>('write', {'data': data}) ?? false;
    } catch (e) {
      debugPrint('Kuber trial: Block Store write failed (local row only): $e');
      return false;
    }
  }

  @override
  Future<int?> uptimeMs() async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<int>('uptime');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<int>?> keyPart() async {
    if (!_supported) return null;
    try {
      return await _channel.invokeMethod<List<int>>('keyPart');
    } catch (_) {
      return null;
    }
  }
}
