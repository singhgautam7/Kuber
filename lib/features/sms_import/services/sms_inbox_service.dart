import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../engine/scan_progress.dart';

/// Bridges to the native Android SMS inbox reader. Reading happens on the root
/// isolate (platform channels require it); parsing is done elsewhere on a
/// worker isolate. On web / non-Android this is a no-op returning empty lists.
class SmsInboxService {
  static const _channel = MethodChannel('com.grs.kuber/sms');

  const SmsInboxService();

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Reads every inbox message from the last [days] days as plain data. Sender
  /// filtering and parsing happen later on the worker isolate. The READ_SMS
  /// permission must already be granted.
  Future<List<RawInboxSms>> readRawInbox({int days = 90}) async {
    if (!isSupported) return const [];

    final since = DateTime.now()
        .subtract(Duration(days: days))
        .millisecondsSinceEpoch;

    final raw = await _channel.invokeListMethod<Map<dynamic, dynamic>>(
      'getInboxMessages',
      {'sinceMillis': since},
    );
    if (raw == null || raw.isEmpty) return const [];

    final out = <RawInboxSms>[];
    for (final row in raw) {
      final body = (row['body'] as String?) ?? '';
      if (body.isEmpty) continue;
      out.add(
        RawInboxSms(
          address: (row['address'] as String?) ?? '',
          body: body,
          dateMillis: (row['date'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    return out;
  }
}
