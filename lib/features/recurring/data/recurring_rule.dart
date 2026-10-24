import 'package:isar_community/isar.dart';

import '../../../core/schedule/schedule.dart';

part 'recurring_rule.g.dart';

/// A rule's terms before an "edit future only" change. The rule's own fields
/// always hold the current version.
@embedded
class RuleVersion {
  DateTime? effectiveFrom;
  double amount = 0;
  String? categoryId;
  String? accountId;
  int intervalCount = 1;

  @Enumerated(EnumType.name)
  ScheduleUnit intervalUnit = ScheduleUnit.month;

  int? anchorDay;

  RuleVersion();

  Map<String, dynamic> toMap() => {
    'effectiveFrom': effectiveFrom?.toIso8601String(),
    'amount': amount,
    'categoryId': categoryId,
    'accountId': accountId,
    'intervalCount': intervalCount,
    'intervalUnit': intervalUnit.name,
    'anchorDay': anchorDay,
  };

  static RuleVersion fromMap(Map<String, dynamic> m) => RuleVersion()
    ..effectiveFrom = m['effectiveFrom'] == null
        ? null
        : DateTime.parse(m['effectiveFrom'] as String)
    ..amount = (m['amount'] as num?)?.toDouble() ?? 0
    ..categoryId = m['categoryId'] as String?
    ..accountId = m['accountId'] as String?
    ..intervalCount = (m['intervalCount'] as int?) ?? 1
    ..intervalUnit = ScheduleUnit.values.firstWhere(
        (u) => u.name == m['intervalUnit'],
        orElse: () => ScheduleUnit.month)
    ..anchorDay = m['anchorDay'] as int?;
}

@collection
class RecurringRule {
  Id id = Isar.autoIncrement;

  late String name;
  late double amount;
  late String type; // 'income' | 'expense'

  late String categoryId;
  late String accountId;

  String? notes;

  // Preset key, kept for CSV / backups: 'daily' | 'weekly' | 'monthly' |
  // 'quarterly' | 'half_yearly' | 'yearly' | 'custom' (legacy: 'biweekly').
  // The schedule comes from RecurrenceInterval.of(rule), not this string.
  late String frequency;

  /// Interval count ("every N units"). Legacy rules (intervalUnit == null)
  /// only set it for frequency == 'custom', where the unit was days. The
  /// field keeps its original name so old databases and backups read as-is.
  int? customDays;

  /// 'day' | 'week' | 'month' | 'year'. Null on rules saved before intervals
  /// existed; RecurrenceInterval.legacy maps those (migration 10 backfills).
  String? intervalUnit;

  late DateTime startDate;

  @Index()
  late DateTime nextDueAt;

  int executionCount = 0;

  late String endType; // 'never' | 'occurrences' | 'date'
  int? endAfter; // number of occurrences (when endType == 'occurrences')
  DateTime? endDate; // end date (when endType == 'date')

  bool isPaused = false;

  late DateTime createdAt;
  late DateTime updatedAt;

  // ── vNext. The schedule fields above (frequency .. isPaused) stay as they
  // were at migration and are read only from here on. ──────────────────

  Schedule? schedule;

  /// Earlier versions, oldest first (edit future only).
  List<RuleVersion> versions = [];

  DateTime? endedAt;

  /// 0 = not migrated to vNext yet.
  int dataVersion = 0;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'amount': amount,
    'type': type,
    'categoryId': categoryId,
    'accountId': accountId,
    'notes': notes,
    'frequency': frequency,
    'customDays': customDays,
    'intervalUnit': intervalUnit,
    'startDate': startDate.toIso8601String(),
    'nextDueAt': nextDueAt.toIso8601String(),
    'executionCount': executionCount,
    'endType': endType,
    'endAfter': endAfter,
    'endDate': endDate?.toIso8601String(),
    'isPaused': isPaused,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'schedule': schedule?.toMap(),
    'versions': versions.map((v) => v.toMap()).toList(),
    'endedAt': endedAt?.toIso8601String(),
    'dataVersion': dataVersion,
  };
}
