import '../../../l10n/app_localizations.dart';
import 'recurring_rule.dart';

/// Unit of a recurring rule's "every N units" schedule. Stored by [name] in
/// [RecurringRule.intervalUnit].
enum RecurrenceUnit { day, week, month, year }

/// A rule repeats every [count] [unit]s (count >= 1).
class RecurrenceInterval {
  final int count;
  final RecurrenceUnit unit;

  const RecurrenceInterval(int count, this.unit) : count = count < 1 ? 1 : count;

  /// The rule's interval. Rules saved by this version carry
  /// [RecurringRule.intervalUnit] + [RecurringRule.customDays] (the count);
  /// older rules and old JSON backups fall back to [legacy].
  factory RecurrenceInterval.of(RecurringRule rule) {
    final unit = RecurrenceUnit.values
        .where((u) => u.name == rule.intervalUnit)
        .firstOrNull;
    if (unit != null) return RecurrenceInterval(rule.customDays ?? 1, unit);
    return RecurrenceInterval.legacy(rule.frequency, rule.customDays);
  }

  /// Pre-interval `frequency` values, mapped so next dates are unchanged.
  factory RecurrenceInterval.legacy(String frequency, int? customDays) =>
      switch (frequency) {
        'daily' => const RecurrenceInterval(1, RecurrenceUnit.day),
        'weekly' => const RecurrenceInterval(1, RecurrenceUnit.week),
        'biweekly' => const RecurrenceInterval(2, RecurrenceUnit.week),
        'monthly' => const RecurrenceInterval(1, RecurrenceUnit.month),
        'quarterly' => const RecurrenceInterval(3, RecurrenceUnit.month),
        'half_yearly' => const RecurrenceInterval(6, RecurrenceUnit.month),
        'yearly' => const RecurrenceInterval(1, RecurrenceUnit.year),
        'custom' => RecurrenceInterval(customDays ?? 1, RecurrenceUnit.day),
        // The old computeNextDue default.
        _ => const RecurrenceInterval(1, RecurrenceUnit.day),
      };

  /// Preset chip key matching this interval, or 'custom'.
  String get presetKey =>
      kRecurrencePresets.entries
          .where((e) => e.value == this)
          .firstOrNull
          ?.key ??
      'custom';

  /// Multiplier from one occurrence to a monthly amount. A day-based month is
  /// 30 days (the old daily x30 / custom x30/N), a week-based month 52/12.
  double get monthlyFactor => switch (unit) {
    RecurrenceUnit.day => 30 / count,
    RecurrenceUnit.week => 52 / 12 / count,
    RecurrenceUnit.month => 1 / count,
    RecurrenceUnit.year => 1 / 12 / count,
  };

  /// "Daily", "Monthly" for a count of 1, else "Every 3 months".
  String describe(AppLocalizations l) {
    if (count == 1) {
      return switch (unit) {
        RecurrenceUnit.day => l.freqDaily,
        RecurrenceUnit.week => l.freqWeekly,
        RecurrenceUnit.month => l.freqMonthly,
        RecurrenceUnit.year => l.freqYearly,
      };
    }
    return switch (unit) {
      RecurrenceUnit.day => l.freqEveryNDays('$count'),
      RecurrenceUnit.week => l.freqEveryNWeeks('$count'),
      RecurrenceUnit.month => l.freqEveryNMonths('$count'),
      RecurrenceUnit.year => l.freqEveryNYears('$count'),
    };
  }

  @override
  bool operator ==(Object other) =>
      other is RecurrenceInterval && other.count == count && other.unit == unit;

  @override
  int get hashCode => Object.hash(count, unit);
}

/// Preset chips on the add/edit screen, in display order (Custom comes last).
const kRecurrencePresets = <String, RecurrenceInterval>{
  'daily': RecurrenceInterval(1, RecurrenceUnit.day),
  'weekly': RecurrenceInterval(1, RecurrenceUnit.week),
  'monthly': RecurrenceInterval(1, RecurrenceUnit.month),
  'quarterly': RecurrenceInterval(3, RecurrenceUnit.month),
  'half_yearly': RecurrenceInterval(6, RecurrenceUnit.month),
  'yearly': RecurrenceInterval(1, RecurrenceUnit.year),
};
