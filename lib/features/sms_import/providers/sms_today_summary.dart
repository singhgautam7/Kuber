import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/sms_transaction.dart';
import 'sms_import_provider.dart';

/// Which "Untracked today" state to show (board 3.9d).
enum SmsTodayState {
  /// At least one SMS from today is still in Unreviewed.
  untracked,

  /// Nothing left today, and at least one SMS from today was imported or
  /// dismissed.
  caughtUp,

  /// No bank SMS today at all.
  none,
}

/// Today's unreviewed bank SMS, summed by kind. Debits and credits are never
/// added together. Value class: two summaries with the same numbers are equal,
/// so listeners only rebuild when something visible changes.
class SmsTodaySummary {
  /// Local midnight this summary was computed for.
  final DateTime day;
  final double spent;
  final double received;

  /// Every unreviewed SMS since midnight, including ones with no amount.
  final int count;

  /// Of [count], those the parser found no amount for.
  final int noAmount;
  final bool reviewedToday;

  const SmsTodaySummary({
    required this.day,
    this.spent = 0,
    this.received = 0,
    this.count = 0,
    this.noAmount = 0,
    this.reviewedToday = false,
  });

  SmsTodayState get state => count > 0
      ? SmsTodayState.untracked
      : (reviewedToday ? SmsTodayState.caughtUp : SmsTodayState.none);

  @override
  bool operator ==(Object other) =>
      other is SmsTodaySummary &&
      other.day == day &&
      other.spent == spent &&
      other.received == received &&
      other.count == count &&
      other.noAmount == noAmount &&
      other.reviewedToday == reviewedToday;

  @override
  int get hashCode =>
      Object.hash(day, spent, received, count, noAmount, reviewedToday);
}

/// Pure summary over the lists the SMS page already holds. "Today" starts at
/// local midnight of [now]. The parser only reads INR amounts, so there is no
/// other currency to keep apart.
SmsTodaySummary computeSmsTodaySummary({
  required List<SmsTransaction> unreviewed,
  required List<SmsTransaction> imported,
  required List<SmsTransaction> dismissed,
  required DateTime now,
}) {
  final day = DateTime(now.year, now.month, now.day);
  bool isToday(SmsTransaction s) => !s.smsDate.isBefore(day);

  var spent = 0.0, received = 0.0;
  var count = 0, noAmount = 0;
  for (final s in unreviewed) {
    if (!isToday(s)) continue;
    count++;
    if (s.parsedAmount <= 0) {
      noAmount++;
    } else if (s.parsedType == 'income') {
      received += s.parsedAmount;
    } else {
      spent += s.parsedAmount;
    }
  }
  return SmsTodaySummary(
    day: day,
    spent: spent,
    received: received,
    count: count,
    noAmount: noAmount,
    reviewedToday:
        count == 0 && (imported.any(isToday) || dismissed.any(isToday)),
  );
}

/// The one "today" summary, shared by the Unreviewed card and the Home widget
/// so their numbers always match. Derived from the already-loaded lists: no
/// Isar query, no inbox read. Scan-progress emissions keep the same list
/// instances, so they never recompute it. Null until the lists are loaded.
///
/// The SMS page invalidates it on open, so a summary computed before midnight
/// is not shown as "today" after it; every refresh replaces the lists, which
/// recomputes it too.
final smsTodaySummaryProvider = Provider<SmsTodaySummary?>((ref) {
  final lists = ref.watch(
    smsImportProvider.select(
      (s) => s.valueOrNull == null
          ? null
          : (s.value!.unreviewed, s.value!.imported, s.value!.dismissed),
    ),
  );
  if (lists == null) return null;
  return computeSmsTodaySummary(
    unreviewed: lists.$1,
    imported: lists.$2,
    dismissed: lists.$3,
    now: DateTime.now(),
  );
});
