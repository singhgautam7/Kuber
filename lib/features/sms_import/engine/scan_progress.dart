/// What kicked off a scan. Drives which loading surface is shown.
enum ScanTrigger {
  /// First ever scan (empty staging collection) — full-screen blocking screen.
  firstLoad,

  /// A subsequent refresh — non-blocking strip / widget State D.
  backgroundRefresh,
}

/// Live progress for an in-flight inbox scan. Plain data so it can cross the
/// isolate boundary. `totalMessages == 0` means the count is not known yet
/// (render the progress bar as indeterminate until it is).
class ScanProgress {
  final int totalMessages;
  final int scannedMessages;
  final int bankMessagesFound;
  final bool isComplete;
  final ScanTrigger trigger;

  const ScanProgress({
    required this.totalMessages,
    required this.scannedMessages,
    required this.bankMessagesFound,
    required this.isComplete,
    required this.trigger,
  });

  /// Determinate fraction once [totalMessages] is known, else null
  /// (indeterminate).
  double? get fraction {
    if (totalMessages <= 0) return null;
    return (scannedMessages / totalMessages).clamp(0.0, 1.0);
  }

  ScanProgress copyWith({
    int? totalMessages,
    int? scannedMessages,
    int? bankMessagesFound,
    bool? isComplete,
    ScanTrigger? trigger,
  }) {
    return ScanProgress(
      totalMessages: totalMessages ?? this.totalMessages,
      scannedMessages: scannedMessages ?? this.scannedMessages,
      bankMessagesFound: bankMessagesFound ?? this.bankMessagesFound,
      isComplete: isComplete ?? this.isComplete,
      trigger: trigger ?? this.trigger,
    );
  }
}

/// A raw inbox SMS as read from the platform channel. Plain, sendable data
/// handed to the worker isolate for parsing.
class RawInboxSms {
  final String address;
  final String body;
  final int dateMillis;

  const RawInboxSms({
    required this.address,
    required this.body,
    required this.dateMillis,
  });
}
