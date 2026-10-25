import 'package:isar_community/isar.dart';

part 'schedule.g.dart';

/// Unit of a schedule's "every N units" interval. Stored by name.
enum ScheduleUnit { day, week, month, year }

/// How a schedule ends. Stored by name.
enum ScheduleEnd { never, onDate, afterCount }

/// The shared "when" of a recurring rule, a loan EMI and a SIP / RD
/// installment. Occurrences are calendar days (no time of day), handled by
/// `schedule_engine.dart`. Embedded in RecurringRule, Loan and Investment.
@embedded
class Schedule {
  /// First occurrence, date only (local midnight).
  DateTime? startDate;

  int intervalCount = 1;

  @Enumerated(EnumType.name)
  ScheduleUnit intervalUnit = ScheduleUnit.month;

  /// Month / year: day of month 1..31 (clamped to short months).
  /// Week: weekday 1 (Mon) .. 7 (Sun). Day: unused.
  int? anchorDay;

  /// Year unit only: month 1..12.
  int? anchorMonth;

  @Enumerated(EnumType.name)
  ScheduleEnd endType = ScheduleEnd.never;

  DateTime? endDate;
  int? endCount;

  bool paused = false;
  DateTime? pausedOn;

  /// Always true this release (no confirm flow). Stored so one can be added
  /// later without a migration.
  bool autoRecord = true;

  /// yyyymmdd keys of occurrences the user skipped.
  List<int> skippedDates = [];

  /// yyyymmdd watermark: no occurrence on or before it is ever posted.
  int processedThrough = 0;

  /// Occurrences posted so far (the afterCount end counts these).
  int postedCount = 0;

  /// null, or 'legacyRecurring' when migration found that the new rules
  /// would move this record's dates outside an approved fix; the engine then
  /// keeps chaining the old algorithm from [legacyNextDue].
  String? compat;
  DateTime? legacyNextDue;

  /// Shown in Dev tools > Schedule debug.
  String? migrationNote;

  Schedule();

  Schedule copy() => Schedule()
    ..startDate = startDate
    ..intervalCount = intervalCount
    ..intervalUnit = intervalUnit
    ..anchorDay = anchorDay
    ..anchorMonth = anchorMonth
    ..endType = endType
    ..endDate = endDate
    ..endCount = endCount
    ..paused = paused
    ..pausedOn = pausedOn
    ..autoRecord = autoRecord
    ..skippedDates = [...skippedDates]
    ..processedThrough = processedThrough
    ..postedCount = postedCount
    ..compat = compat
    ..legacyNextDue = legacyNextDue
    ..migrationNote = migrationNote;

  Map<String, dynamic> toMap() => {
    'startDate': startDate?.toIso8601String(),
    'intervalCount': intervalCount,
    'intervalUnit': intervalUnit.name,
    'anchorDay': anchorDay,
    'anchorMonth': anchorMonth,
    'endType': endType.name,
    'endDate': endDate?.toIso8601String(),
    'endCount': endCount,
    'paused': paused,
    'pausedOn': pausedOn?.toIso8601String(),
    'autoRecord': autoRecord,
    'skippedDates': skippedDates,
    'processedThrough': processedThrough,
    'postedCount': postedCount,
    'compat': compat,
    'legacyNextDue': legacyNextDue?.toIso8601String(),
    'migrationNote': migrationNote,
  };

  static Schedule? fromMap(Object? raw) {
    if (raw is! Map) return null;
    final m = raw.cast<String, dynamic>();
    DateTime? d(String k) => m[k] == null ? null : DateTime.parse(m[k] as String);
    return Schedule()
      ..startDate = d('startDate')
      ..intervalCount = (m['intervalCount'] as int?) ?? 1
      ..intervalUnit = ScheduleUnit.values.firstWhere(
          (u) => u.name == m['intervalUnit'],
          orElse: () => ScheduleUnit.month)
      ..anchorDay = m['anchorDay'] as int?
      ..anchorMonth = m['anchorMonth'] as int?
      ..endType = ScheduleEnd.values.firstWhere((e) => e.name == m['endType'],
          orElse: () => ScheduleEnd.never)
      ..endDate = d('endDate')
      ..endCount = m['endCount'] as int?
      ..paused = (m['paused'] as bool?) ?? false
      ..pausedOn = d('pausedOn')
      ..autoRecord = (m['autoRecord'] as bool?) ?? true
      ..skippedDates = (m['skippedDates'] as List?)?.cast<int>() ?? []
      ..processedThrough = (m['processedThrough'] as int?) ?? 0
      ..postedCount = (m['postedCount'] as int?) ?? 0
      ..compat = m['compat'] as String?
      ..legacyNextDue = d('legacyNextDue')
      ..migrationNote = m['migrationNote'] as String?;
  }
}
