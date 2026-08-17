import 'dart:async';
import 'dart:io' show Platform;

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Single structured diagnostic entry for Play Billing events.
class BillingLogEntry {
  final DateTime timestamp;
  final String tag;
  final String message;
  final Map<String, dynamic>? details;

  BillingLogEntry({
    required this.tag,
    required this.message,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final timeStr = timestamp.toIso8601String().split('T').last;
    final detailsStr = details != null && details!.isNotEmpty ? ' | $details' : '';
    return '[$timeStr] [$tag] $message$detailsStr';
  }
}

/// In-memory bounded recorder for Google Play Billing diagnostics.
///
/// Keeps the last 30 log entries in memory so users or developers can
/// inspect or share them on demand (e.g. from Dev Tools or when reporting a
/// billing issue). Gated so it never introduces disk I/O, heavy memory use,
/// or release log spam.
class BillingDiagnostics {
  BillingDiagnostics._();
  static final BillingDiagnostics instance = BillingDiagnostics._();

  static const int _maxEntries = 30;
  final List<BillingLogEntry> _logs = [];

  List<BillingLogEntry> get logs => List.unmodifiable(_logs);

  void log(String tag, String message, [Map<String, dynamic>? details]) {
    final entry = BillingLogEntry(tag: tag, message: message, details: details);
    if (_logs.length >= _maxEntries) {
      _logs.removeAt(0);
    }
    _logs.add(entry);

    if (kDebugMode) {
      debugPrint('[BILLING] $entry');
    }
  }

  void recordQueryStart(String operation, {String? source}) {
    log('QUERY_START', 'Operation started: $operation', {
      ...?source == null ? null : {'source': source},
    });
  }

  void recordQueryEnd(
    String operation, {
    required bool success,
    required Duration duration,
    String? error,
  }) {
    log(
      success ? 'QUERY_SUCCESS' : 'QUERY_ERROR',
      '$operation finished in ${duration.inMilliseconds}ms',
      {
        'success': success,
        'duration_ms': duration.inMilliseconds,
        ...?error == null ? null : {'error': error},
      },
    );
  }

  void recordStreamPurchases(List<PurchaseDetails> purchases) {
    final purchaseSummaries = purchases.map((p) {
      final token = p.verificationData.serverVerificationData;
      final maskedToken = token.length > 10
          ? '${token.substring(0, 4)}...${token.substring(token.length - 4)}'
          : (token.isEmpty ? 'empty' : 'present');
      return {
        'productId': p.productID,
        'status': p.status.name,
        'transactionDate': p.transactionDate,
        'pendingComplete': p.pendingCompletePurchase,
        'hasError': p.error != null,
        if (p.error != null) 'errorCode': p.error?.code,
        if (p.error != null) 'errorMessage': p.error?.message,
        'token': maskedToken,
      };
    }).toList();

    log('STREAM_RECEIVED', 'Received ${purchases.length} purchase event(s)', {
      'count': purchases.length,
      'purchases': purchaseSummaries,
    });
  }

  void recordError(String context, Object error, [StackTrace? stack]) {
    log('ERROR', 'Error in $context: $error', {
      'context': context,
      'error': error.toString(),
    });
  }

  /// Generates a comprehensive plain-text diagnostics report containing device
  /// metadata, app version, and timestamped billing traces.
  Future<String> generateDiagnosticsReport() async {
    String appVersion = 'Unknown';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
    } catch (_) {}

    String deviceModel = 'Unknown';
    String osVersion = 'Unknown';
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model} (${android.brand})';
        osVersion = 'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceModel = ios.model;
        osVersion = 'iOS ${ios.systemVersion}';
      }
    } catch (_) {}

    final buffer = StringBuffer();
    buffer.writeln('=== KUBER PLAY BILLING DIAGNOSTICS ===');
    buffer.writeln('App Version : $appVersion');
    buffer.writeln('Device      : $deviceModel');
    buffer.writeln('OS Version  : $osVersion');
    buffer.writeln('Timestamp   : ${DateTime.now().toIso8601String()}');
    buffer.writeln('---------------------------------------');
    buffer.writeln('Recent Billing Logs (${_logs.length} entries):');

    if (_logs.isEmpty) {
      buffer.writeln('No billing events recorded in this session.');
    } else {
      for (final entry in _logs) {
        buffer.writeln(entry.toString());
      }
    }
    buffer.writeln('=======================================');
    return buffer.toString();
  }
}
