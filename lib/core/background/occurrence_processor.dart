// Posts due schedule occurrences for recurring rules, loan EMIs and SIP / RD
// installments. Each occurrence is one write transaction that inserts its
// processed-ledger row, the transaction and the advanced watermark together,
// so it is posted exactly once whatever runs, crashes or overlaps.
//
// Pure Dart over Isar: runs on the UI isolate (web, tests) or the
// background worker isolate.

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:isar_community/isar.dart';

import '../../features/investments/data/investment.dart';
import '../../features/loans/data/loan.dart';
import '../../features/loans/domain/loan_engine.dart';
import '../../features/loans/domain/loan_service.dart';
import '../../features/notifications/data/app_notification.dart';
import '../../features/notifications/data/notification_repository.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/services/suggestion_service.dart';
import '../../l10n/app_localizations.dart';
import '../money_math/investment_math.dart';
import '../schedule/processed_occurrence.dart';
import '../schedule/schedule.dart';
import '../schedule/schedule_engine.dart';

class ProcessSummary {
  int recurring = 0, emis = 0, sips = 0, failed = 0;
  final paidOffLoans = <String>[];
  final failedSources = <String>[];
  final log = <String>[];
  int get posted => recurring + emis + sips;
}

typedef ProgressCallback = void Function(int done, int total, Set<String> busy);

class OccurrenceProcessor {
  final Isar isar;

  /// The selected currency's minor units (EMI split and SIP rounding).
  final int decimals;
  final String? runId;
  final AppLocalizations l10n;

  OccurrenceProcessor(this.isar,
      {required this.decimals, required this.l10n, this.runId});

  /// Cheap check used before starting a run: is anything due today?
  static Future<int> countDue(Isar isar, {DateTime? now}) async {
    final today = todayKey(now);
    var n = 0;
    for (final r in await isar.recurringRules.filter().dataVersionEqualTo(1).findAll()) {
      if (r.schedule != null) n += dueOccurrences(r.schedule!, today).length;
    }
    for (final l in await _activeLoans(isar)) {
      n += dueOccurrences(l.schedule!, today).length;
    }
    for (final i in await _activeSips(isar)) {
      n += dueOccurrences(i.sip!, today).length;
    }
    return n;
  }

  static Future<List<Loan>> _activeLoans(Isar isar) async => (await isar.loans
          .filter()
          .dataVersionEqualTo(1)
          .isCompletedEqualTo(false)
          .closedAtIsNull()
          .findAll())
      .where((l) => l.schedule != null && l.schedule!.autoRecord)
      .toList();

  static Future<List<Investment>> _activeSips(Isar isar) async => (await isar
          .investments
          .filter()
          .dataVersionEqualTo(1)
          .statusEqualTo(InvestmentStatus.active)
          .findAll())
      .where((i) => i.sip != null && i.sip!.autoRecord)
      .toList();

  Future<ProcessSummary> run({DateTime? now, ProgressCallback? onProgress}) async {
    final at = now ?? DateTime.now();
    final today = dayKey(at);
    final summary = ProcessSummary();
    final rules = (await isar.recurringRules.filter().dataVersionEqualTo(1).findAll())
        .where((r) => r.schedule != null)
        .toList();
    final loans = await _activeLoans(isar);
    final sips = await _activeSips(isar);

    final work = <(String, String, List<Occurrence>)>[
      for (final r in rules)
        ('recurring', '${r.id}', dueOccurrences(r.schedule!, today)),
      for (final l in loans) ('loan', l.uid, dueOccurrences(l.schedule!, today)),
      for (final i in sips) ('investment', i.uid, dueOccurrences(i.sip!, today)),
    ].where((w) => w.$3.isNotEmpty).toList();
    final total = work.fold(0, (s, w) => s + w.$3.length);
    var done = 0;
    onProgress?.call(0, total, const {});

    final created = <Transaction>[];
    final perRule = <int, int>{};
    for (final (type, id, occurrences) in work) {
      final busy = {'$type:$id'};
      for (final o in occurrences) {
        onProgress?.call(done, total, busy);
        try {
          final t = await _postOne(type, id, o, at, summary);
          if (t != null) {
            created.add(t);
            if (type == 'recurring') {
              perRule[int.parse(id)] = (perRule[int.parse(id)] ?? 0) + 1;
            }
          }
        } catch (e) {
          // A failed occurrence never blocks the others: stop this source
          // (it retries next run from the same watermark), go on.
          summary.failed++;
          summary.failedSources.add('$type:$id');
          summary.log.add('Failed $type:$id ${dayOf(o.day)}: $e');
          debugPrint('Kuber: occurrence $type:$id ${o.day} failed: $e');
          done += occurrences.length - occurrences.indexOf(o);
          break;
        }
        done++;
      }
    }
    onProgress?.call(total, total, const {});

    final suggestions = SuggestionService(isar);
    for (final t in created) {
      suggestions.upsertSuggestion(t).ignore();
    }
    await _notify(perRule, created, summary);
    return summary;
  }

  /// Posts one occurrence. Returns the created transaction, or null when it
  /// was already processed (another run, a seeded legacy day) or skipped.
  Future<Transaction?> _postOne(
      String type, String id, Occurrence o, DateTime at, ProcessSummary summary) async {
    Transaction? out;
    final key = ProcessedOccurrence.keyOf(type, id, o.day);
    final stamp = DateTime(o.day ~/ 10000, o.day ~/ 100 % 100, o.day % 100,
        at.hour, at.minute, at.second, at.millisecond);
    await isar.writeTxn(() async {
      // Re-read inside the write transaction: writes are serialised across
      // isolates, so this sees anything another run committed.
      final (schedule, save) = await _load(type, id);
      if (schedule == null || o.day <= schedule.processedThrough) return;
      final existing = await isar.processedOccurrences.getByKey(key);
      if (existing != null) {
        // Already posted (seeded from a legacy transaction, or a run that
        // was killed after committing): just move past it.
        schedule.processedThrough = o.day;
        await save(schedule, null);
        return;
      }
      final row = ProcessedOccurrence()
        ..key = key
        ..sourceType = type
        ..sourceId = id
        ..occurrenceDate = o.day
        ..runId = runId
        ..createdAt = DateTime.now();
      if (o.skipped) {
        markSkipped(schedule, o.day);
        await isar.processedOccurrences.put(row..status = 'skipped');
        await save(schedule, null);
        return;
      }
      final t = await _build(type, id, o.day, stamp);
      if (t == null) return;
      final tid = await isar.transactions.put(t);
      await isar.processedOccurrences.put(row
        ..status = 'posted'
        ..transactionId = tid);
      markPosted(schedule, o.day);
      await save(schedule, t);
      out = t;
    });
    if (out != null) {
      switch (type) {
        case 'recurring':
          summary.recurring++;
        case 'loan':
          summary.emis++;
        case 'investment':
          summary.sips++;
      }
    }
    return out;
  }

  Future<(Schedule?, Future<void> Function(Schedule, Transaction?))> _load(
      String type, String id) async {
    switch (type) {
      case 'recurring':
        final r = await isar.recurringRules.get(int.parse(id));
        if (r == null || r.schedule == null) return (null, _noSave);
        return (
          r.schedule,
          (Schedule s, Transaction? _) async {
            r
              ..schedule = s
              ..executionCount = s.postedCount
              ..isPaused = s.paused
              ..nextDueAt = _mirrorNext(s)
              ..updatedAt = DateTime.now();
            if (isEnded(s)) r.endedAt ??= DateTime.now();
            await isar.recurringRules.put(r);
          }
        );
      case 'loan':
        final l = await isar.loans.filter().uidEqualTo(id).findFirst();
        if (l == null || l.schedule == null || l.isCompleted) return (null, _noSave);
        return (
          l.schedule,
          (Schedule s, Transaction? t) async {
            l
              ..schedule = s
              ..updatedAt = DateTime.now();
            if (t != null && paidOffAfter(l, t.occurrenceDate!)) {
              l
                ..isCompleted = true
                ..closedAt = DateTime.now();
              _paidOff.add(l.name);
            }
            await isar.loans.put(l);
          }
        );
      case 'investment':
        final i = await isar.investments.filter().uidEqualTo(id).findFirst();
        if (i == null || i.sip == null) return (null, _noSave);
        return (
          i.sip,
          (Schedule s, Transaction? t) async {
            i
              ..sip = s
              ..updatedAt = DateTime.now();
            // Approved fix S2: SIPs add to Invested like manual top-ups.
            if (t != null) i.investedAmount = (i.investedAmount ?? 0) + t.amount;
            await isar.investments.put(i);
          }
        );
    }
    return (null, _noSave);
  }

  final _paidOff = <String>[];

  static Future<void> _noSave(Schedule s, Transaction? t) async {}

  /// The old nextDueAt meaning, for pre-vNext readers: the next date of the
  /// rule after the watermark, ignoring the end (an ended rule's nextDueAt
  /// sat past its end date, and isExpired read that).
  static DateTime _mirrorNext(Schedule s) {
    for (final day in lattice(s)) {
      if (day > s.processedThrough) return dayOf(day);
    }
    return DateTime(9999, 12, 31);
  }

  double _round(double v) {
    var f = 1.0;
    for (var k = 0; k < decimals; k++) {
      f *= 10;
    }
    return (v * f).round() / f;
  }

  Future<Transaction?> _build(String type, String id, int day, DateTime stamp) async {
    final now = DateTime.now();
    Transaction base(String name) => Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..createdAt = stamp
      ..updatedAt = now
      ..occurrenceDate = day
      ..sourceType = type
      ..sourceId = id
      ..linkedRuleType = type
      ..linkedRuleId = id;
    switch (type) {
      case 'recurring':
        final r = (await isar.recurringRules.get(int.parse(id)))!;
        return base(r.name)
          ..amount = r.amount
          ..type = r.type
          ..categoryId = r.categoryId
          ..accountId = r.accountId
          ..notes = r.notes;
      case 'loan':
        final l = (await isar.loans.filter().uidEqualTo(id).findFirst())!;
        // Split from the outstanding after what was actually paid.
        final rec = await LoanService.records(isar, id);
        final emi = emiFor(l, day, decimals, linked: rec.linked, deletedDays: rec.deleted);
        final from = l.countOnlyInterestFrom;
        return base('EMI - ${l.name}')
          ..amount = emi.amount
          ..type = 'expense'
          ..categoryId = l.categoryId
          ..accountId = l.accountId
          ..subType = TxnSubType.loanRepayment
          ..principalPart = emi.principal
          ..interestPart = emi.interest
          ..spendInterestOnly = l.countOnlyInterest &&
              emi.interest != null &&
              (from == null || day >= dayKey(from));
      case 'investment':
        final i = (await isar.investments.filter().uidEqualTo(id).findFirst())!;
        final baseAmount = i.sipAmount ?? i.installment ?? 0;
        if (baseAmount <= 0 || i.accountId == null) return null;
        final amount = _round(stepUpAmount(
          base: baseAmount,
          start: i.sip!.startDate!,
          on: dayOf(day),
          percent: i.stepUpKind == StepUpKind.percent,
          value: i.stepUpValue,
        ));
        return base('Contribution - ${i.name}')
          ..amount = amount
          ..type = 'expense'
          ..categoryId = i.categoryId
          ..accountId = i.accountId!
          ..subType = TxnSubType.investment;
    }
    return null;
  }

  Future<void> _notify(
      Map<int, int> perRule, List<Transaction> created, ProcessSummary summary) async {
    final repo = NotificationRepository(isar);
    for (final e in perRule.entries) {
      final name = created
          .firstWhere((t) => t.sourceType == 'recurring' && t.sourceId == '${e.key}')
          .name;
      await repo.add(
        type: NotificationType.recurringTransaction,
        title: l10n.notifNewRecurring(e.value),
        body: l10n.notifRecurringBody(name),
        payload: 'recurring:${e.key}',
      );
    }
    for (final t in created.where((t) => t.sourceType == 'loan')) {
      await repo.add(
        type: NotificationType.loanEmi,
        title: l10n.notifLoanEmiTitle,
        body: l10n.notifLoanEmiBody(t.name.replaceFirst('EMI - ', '')),
        payload: 'loan:${t.sourceId}',
      );
    }
    for (final t in created.where((t) => t.sourceType == 'investment')) {
      await repo.add(
        type: NotificationType.recurringTransaction,
        title: l10n.notifInvestmentTitle,
        body: l10n.notifInvestmentBody(t.name.replaceFirst('Contribution - ', '')),
        payload: 'investment:${t.sourceId}',
      );
    }
    summary.paidOffLoans.addAll(_paidOff);
  }
}
