// vNext data migration (specs/vnext/migration.md). Additive and idempotent:
// every step is per record (dataVersion 0 -> 1) or keyed (ledger rows), so a
// crash mid-way resumes cleanly and a second run changes nothing. Old fields
// are never deleted or overwritten. Runs on first launch of the new build
// and again after every JSON restore (older backups carry dataVersion 0).

import 'dart:io';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:isar_community/isar.dart';

import '../../features/investments/data/investment.dart';
import '../../features/loans/data/loan.dart';
import '../../features/recurring/data/recurring_interval.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../schedule/legacy_schedules.dart';
import '../schedule/processed_occurrence.dart';
import '../schedule/schedule.dart';
import '../schedule/schedule_engine.dart';

class VNextMigrationReport {
  int rules = 0, loans = 0, investments = 0;
  int flagged = 0, kept = 0;
  int seeded = 0, backfilled = 0;
  int elapsedMs = 0;
  bool snapshotTaken = false;

  @override
  String toString() =>
      'rules $rules, loans $loans, investments $investments, flagged $flagged '
      '(kept old dates $kept), ledger seeded $seeded, transactions '
      'backfilled $backfilled, ${elapsedMs}ms';
}

class VNextMigration {
  static const snapshotName = 'pre_vnext.isar';

  static Future<VNextMigrationReport> run(Isar isar, {DateTime? now}) async {
    final sw = Stopwatch()..start();
    final report = VNextMigrationReport();
    final n = now ?? DateTime.now();

    // dataVersionLessThan(1), not EqualTo(0): Isar 3 reads a field that an
    // old row never stored as its null sentinel (Int64 min for int, NaN for
    // double), not as the Dart default.
    final rules = await isar.recurringRules.filter().dataVersionLessThan(1).findAll();
    final loans = await isar.loans.filter().dataVersionLessThan(1).findAll();
    final invs = await isar.investments.filter().dataVersionLessThan(1).findAll();
    final linked = await isar.transactions
        .filter()
        .linkedRuleTypeIsNotNull()
        .sourceTypeIsNull()
        .subTypeIsNull()
        .findAll();
    if (rules.isEmpty && loans.isEmpty && invs.isEmpty && linked.isEmpty) {
      return report..elapsedMs = sw.elapsedMilliseconds;
    }

    report.snapshotTaken = await _snapshot(isar);

    // Linked transactions per source, for watermarks and seeding.
    final allLinked = await isar.transactions
        .filter()
        .anyOf(['recurring', 'loan', 'investment'],
            (q, t) => q.linkedRuleTypeEqualTo(t))
        .findAll();
    final bySource = <String, List<Transaction>>{};
    for (final t in allLinked) {
      bySource.putIfAbsent('${t.linkedRuleType}:${t.linkedRuleId}', () => []).add(t);
    }

    await isar.writeTxn(() async {
      for (final r in rules) {
        migrateRule(r, n);
        report.rules++;
        if (r.schedule!.migrationNote?.contains('Flagged') ?? false) report.flagged++;
        if (r.schedule!.compat != null) report.kept++;
      }
      await isar.recurringRules.putAll(rules);

      for (final l in loans) {
        migrateLoan(l, bySource['loan:${l.uid}'] ?? const [], n);
        report.loans++;
      }
      await isar.loans.putAll(loans);

      for (final i in invs) {
        migrateInvestment(i, bySource['investment:${i.uid}'] ?? const [], n);
        report.investments++;
      }
      await isar.investments.putAll(invs);

      // Ledger: one 'seeded' row per day that already has a linked
      // transaction, so nothing already posted can post again.
      final keys = <String, ProcessedOccurrence>{};
      for (final t in allLinked) {
        final key = ProcessedOccurrence.keyOf(
            t.linkedRuleType!, t.linkedRuleId!, dayKey(t.createdAt));
        keys.putIfAbsent(
            key,
            () => ProcessedOccurrence()
              ..key = key
              ..sourceType = t.linkedRuleType!
              ..sourceId = t.linkedRuleId!
              ..occurrenceDate = dayKey(t.createdAt)
              ..status = 'seeded'
              ..transactionId = t.id
              ..createdAt = n);
      }
      final existing = await isar.processedOccurrences.getAllByKey(keys.keys.toList());
      final fresh = <ProcessedOccurrence>[
        for (final (i, k) in keys.keys.indexed)
          if (existing[i] == null) keys[k]!
      ];
      await isar.processedOccurrences.putAll(fresh);
      report.seeded = fresh.length;

      // Transactions: sub type + source link only where the link is certain.
      for (final t in linked) {
        switch (t.linkedRuleType) {
          case 'recurring':
            t.sourceType = 'recurring';
            t.sourceId = t.linkedRuleId;
          case 'loan':
            t.sourceType = 'loan';
            t.sourceId = t.linkedRuleId;
            t.subType = TxnSubType.loanRepayment;
          case 'investment':
            t.sourceType = 'investment';
            t.sourceId = t.linkedRuleId;
            t.subType = TxnSubType.investment;
          case 'lent':
            t.subType = TxnSubType.lent;
          case 'borrowed':
            t.subType = TxnSubType.borrowed;
          default:
            continue;
        }
        report.backfilled++;
      }
      await isar.transactions.putAll(linked);
    });

    report.elapsedMs = sw.elapsedMilliseconds;
    debugPrint('Kuber: vNext migration: $report');
    return report;
  }

  static Future<bool> _snapshot(Isar isar) async {
    final dir = isar.directory;
    if (dir == null) return false;
    final file = File('$dir/$snapshotName');
    if (file.existsSync()) return false;
    try {
      await isar.copyToFile(file.path);
      return true;
    } catch (e) {
      debugPrint('Kuber: pre-vNext snapshot failed (non-fatal): $e');
      return false;
    }
  }

  // ── Recurring ──────────────────────────────────────────────────────────

  @visibleForTesting
  static void migrateRule(RecurringRule r, DateTime now) {
    final interval = RecurrenceInterval.of(r);
    final unit = ScheduleUnit.values.byName(interval.unit.name);
    final s = scheduleFrom(
      start: r.startDate,
      count: interval.count,
      unit: unit,
      endType: switch (r.endType) {
        'occurrences' => ScheduleEnd.afterCount,
        'date' => ScheduleEnd.onDate,
        _ => ScheduleEnd.never,
      },
      endCount: r.endType == 'occurrences' ? r.endAfter : null,
      endDate: r.endType == 'date' ? r.endDate : null,
    )
      ..paused = r.isPaused
      ..pausedOn = r.isPaused
          ? DateTime(r.updatedAt.year, r.updatedAt.month, r.updatedAt.day)
          : null
      ..postedCount = r.executionCount
      ..processedThrough = addDays(dayKey(r.nextDueAt), -1);

    // Verification: next 24 dates from the old rule vs the engine.
    final legacy = _legacyNext(r, interval.count, LegacyUnit.values.byName(interval.unit.name));
    final engine = upcomingOccurrences(s, limit: 24).map((o) => o.day).toList();
    final notes = <String>[];
    if (r.frequency != 'custom' && r.frequency != interval.presetKey) {
      notes.add('Migrated · legacy "${r.frequency}" read as ${_sentence(interval.count, unit)}');
    } else if (r.frequency != 'custom') {
      notes.add('Migrated · "${r.frequency}" → ${_sentence(interval.count, unit)}');
    }
    if (!_sameDays(legacy, engine)) {
      s
        ..compat = 'legacyRecurring'
        ..legacyNextDue = r.nextDueAt;
      final i = _firstDiff(legacy, engine);
      notes.add('Flagged · kept the old dates (old ${_fmt(i < legacy.length ? legacy[i] : null)}, '
          'new ${_fmt(i < engine.length ? engine[i] : null)})');
    } else if ((unit == ScheduleUnit.month || unit == ScheduleUnit.year) &&
        (s.anchorDay ?? 0) >= 29) {
      final c = s.copy()
        ..paused = false;
      final next12 = upcomingOccurrences(c, limit: 12);
      final clamped = next12.where((o) => o.day % 100 != s.anchorDay).length;
      if (clamped > 0) {
        notes.add('Flagged · day ${s.anchorDay} falls on the last day in $clamped of 12');
      }
    }
    if (r.isPaused && notes.isNotEmpty) notes.last = '${notes.last}; paused';
    s.migrationNote = notes.isEmpty ? 'OK' : notes.join(' · ');
    r
      ..schedule = s
      ..dataVersion = 1;
  }

  static List<int> _legacyNext(RecurringRule r, int count, LegacyUnit unit) {
    final out = <int>[];
    var due = r.nextDueAt;
    var exec = r.executionCount;
    while (out.length < 24) {
      if (legacyRecurringExpired(
          endType: r.endType,
          endAfter: r.endAfter,
          endDate: r.endDate,
          executionCount: exec,
          dueDate: due)) {
        break;
      }
      out.add(dayKey(due));
      exec++;
      due = legacyRecurringNext(count: count, unit: unit, startDate: r.startDate, from: due);
    }
    return out;
  }

  static bool _sameDays(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static int _firstDiff(List<int> a, List<int> b) {
    var i = 0;
    while (i < a.length && i < b.length && a[i] == b[i]) {
      i++;
    }
    return i;
  }

  static String _fmt(int? day) => day == null ? 'none' : '$day';

  static String _sentence(int count, ScheduleUnit unit) =>
      '$count ${unit.name}${count == 1 ? '' : 's'}';

  // ── Loans ──────────────────────────────────────────────────────────────

  /// New non-nullable numbers on rows written before vNext read as Isar's
  /// null sentinels; give them their real defaults.
  static double _d(double v) => v.isNaN ? 0 : v;
  static int _i(int v) => v < 0 ? 0 : v;

  @visibleForTesting
  static void migrateLoan(Loan l, List<Transaction> linked, DateTime now) {
    l
      ..interestOnlyMonths = _i(l.interestOnlyMonths)
      ..principalPaidBefore = _d(l.principalPaidBefore)
      ..interestPaidBefore = _d(l.interestPaidBefore)
      ..emisPaidBefore = _i(l.emisPaidBefore)
      ..adjustment = _d(l.adjustment);
    final day = l.billDate.clamp(1, 31);
    final first = firstMonthlyOnOrAfter(l.startDate, day);
    final s = scheduleFrom(
      start: first,
      unit: ScheduleUnit.month,
      anchorDay: day,
      endType: l.endDate != null ? ScheduleEnd.onDate : ScheduleEnd.never,
      endDate: l.endDate,
    )
      ..autoRecord = l.autoAddTransaction
      ..processedThrough = _watermark(linked, now);
    s.postedCount = linked.where((t) => t.name.startsWith('EMI - ')).length;

    final tenure = l.endDate == null
        ? null
        : (s.copy()..processedThrough = 0..postedCount = 0).let(totalOccurrences);
    l
      ..mode = LoanMode.simple
      ..schedule = s
      ..annualRate = l.interestRate
      ..alreadyRunning = first.isBefore(DateTime(l.createdAt.year, l.createdAt.month, l.createdAt.day));
    // L3: loans with all the numbers get a computed outstanding; the rest
    // track the EMI only (no outstanding shown instead of a wrong one).
    final hasNumbers = l.principalAmount > 0 &&
        l.interestRate != null &&
        tenure != null &&
        tenure > 0 &&
        l.emiAmount > 0;
    if (hasNumbers) {
      l
        ..startingPoint = LoanStartingPoint.originalDetails
        ..interestType = LoanInterestType.reducingBalance
        ..tenureMonths = tenure;
      s.migrationNote = 'Migrated · billDate $day → When · original loan details';
    } else {
      l.startingPoint = LoanStartingPoint.trackEmiOnly;
      l.tenureMonths = tenure;
      s.migrationNote = 'Migrated · billDate $day → When · tracking the EMI only';
    }
    if (l.isCompleted) l.closedAt ??= l.updatedAt;
    l.dataVersion = 1;
  }

  /// Nothing before the update is back-filled (approved fix L1 applies from
  /// the migration on): today counts as processed when something linked was
  /// already posted today.
  static int _watermark(List<Transaction> linked, DateTime now) {
    final today = dayKey(now);
    final postedToday = linked.any((t) => dayKey(t.createdAt) == today);
    return postedToday ? today : addDays(today, -1);
  }

  // ── Investments ────────────────────────────────────────────────────────

  @visibleForTesting
  static InvestmentBehaviour behaviourFor(String type) => switch (type) {
        'sip' || 'mutual_fund' || 'stocks' || 'etf' || 'gold' || 'crypto' =>
          InvestmentBehaviour.market,
        'ppf' => InvestmentBehaviour.fixedReturn,
        _ => InvestmentBehaviour.other,
      };

  @visibleForTesting
  static void migrateInvestment(Investment i, List<Transaction> linked, DateTime now) {
    i
      ..stepUpValue = _d(i.stepUpValue)
      ..openingInvested = _d(i.openingInvested);
    // Existing FD / RD / bonds have no terms, so they keep their typed value
    // (behaviour "other") until terms are added through Edit.
    i.behaviour = behaviourFor(i.investmentType);
    if (i.currentValue != null && i.snapshots.isEmpty) {
      i.snapshots = [
        ValueSnapshot()
          ..date = i.updatedAt
          ..value = i.currentValue!
      ];
    }
    final contributed = linked.fold(0.0, (s, t) => s + t.amount);
    final opening = (i.investedAmount ?? 0) - contributed;
    if (opening > 0) {
      i
        ..openingInvested = opening
        ..openingDate = i.createdAt;
    }
    if (i.autoDebit && i.sipDate != null && (i.sipAmount ?? 0) > 0) {
      final day = i.sipDate!.clamp(1, 31);
      i.sip = scheduleFrom(
        start: firstMonthlyOnOrAfter(i.createdAt, day),
        unit: ScheduleUnit.month,
        anchorDay: day,
      )
        ..processedThrough = _watermark(linked, now)
        ..postedCount = linked.where((t) => t.name.startsWith('Contribution - ')).length
        ..migrationNote = 'Migrated · sipDate $day → When';
    }
    i.status = InvestmentStatus.active;
    i.dataVersion = 1;
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) f) => f(this);
}
