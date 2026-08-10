import 'dart:async';

import 'package:flutter/services.dart';

/// Copies a value to the clipboard and schedules an auto-clear 30 seconds later.
/// A new copy within the window cancels and reschedules the clear (brief §10).
/// The value itself is never logged.
class CardClipboardService {
  CardClipboardService._();

  static Timer? _timer;
  static const _clearAfter = Duration(seconds: 30);

  static Future<void> copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    _timer?.cancel();
    _timer = Timer(_clearAfter, () async {
      await Clipboard.setData(const ClipboardData(text: ''));
    });
  }
}
