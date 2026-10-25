// Restoring a backup written by the build before vNext (6ce4f0e, backup
// version 1). The fixture was exported by that build from the legacy dataset
// (test/helpers/legacy_dataset.dart, 400 rows): rule, loan, SIP, transfers,
// linked rows. After import the first background run migrates it.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/task_runner.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/backups/services/scheduled_backup.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

import '../helpers/isar_test_helper.dart';

void main() {
  setUpAll(initialiseIsarForTests);
  late Isar isar;
  setUp(() async => isar = await openTestIsar());
  tearDown(() => closeAndCleanIsar(isar));

  final json = File('test/fixtures/backups/pre_vnext_6ce4f0e.json').readAsStringSync();
  final data = jsonDecode(json) as Map<String, dynamic>;
  final oldTxns = (data['transactions'] as List).cast<Map<String, dynamic>>();

  Map<String, double> totals(Iterable<(DateTime, String, double)> rows) {
    final m = <String, double>{};
    for (final (at, type, amount) in rows) {
      final k = '${at.year}-${at.month}-$type';
      m[k] = (m[k] ?? 0) + amount;
    }
    return m;
  }

  test('a version 1 backup restores, migrates once and keeps every total', () async {
    expect(data['version'], 1);
    final r = await JsonBackupService().importJson(isar, json);
    expect(r.error, isNull);
    expect(await isar.transactions.count(), oldTxns.length);

    // The first run after a restore migrates the old rows, then processes.
    final run = await TaskRunner(
      isar: isar,
      decimals: 2,
      l10n: AppLocalizationsEn(),
      backup: () async => (BackupOutcome.notDue, null),
    ).run(trigger: 'restore', now: DateTime(2026, 10, 21, 9));
    expect(run!.status, 'done');
    expect(run.postedRecurring + run.postedEmis + run.postedSips, 0,
        reason: 'nothing before the restore day is back-filled');

    final txns = await isar.transactions.where().findAll();
    expect(txns.length, oldTxns.length);
    expect(
      totals(txns.map((t) => (t.createdAt, t.type, t.spendAmount))),
      totals(oldTxns.map((m) => (
            DateTime.parse(m['createdAt'] as String),
            m['type'] as String,
            (m['amount'] as num).toDouble(),
          ))),
      reason: 'analytics totals of restored data are unchanged',
    );
    for (final t in txns) {
      // The migration backfills the sub type from the old link only.
      final expected = switch (t.linkedRuleType) {
        'loan' => TxnSubType.loanRepayment,
        'investment' => TxnSubType.investment,
        'lent' => TxnSubType.lent,
        'borrowed' => TxnSubType.borrowed,
        _ => null,
      };
      expect(t.subType, expected, reason: '${t.name} ${t.linkedRuleType}');
      expect(t.spendAmount, t.amount, reason: 'old rows count in full');
    }
    expect(txns.where((t) => t.isTransfer).length,
        oldTxns.where((m) => m['isTransfer'] == true).length);

    final rule = (await isar.recurringRules.where().findFirst())!;
    expect(rule.dataVersion, 1);
    expect(rule.schedule, isNotNull);
    expect(rule.nextDueAt, DateTime(2026, 11, 1));
    final loan = (await isar.loans.where().findFirst())!;
    expect(loan.dataVersion, 1);
    expect(loan.schedule, isNotNull);
    final inv = (await isar.investments.where().findFirst())!;
    expect(inv.dataVersion, 1);
    expect(inv.sip?.anchorDay, 10);
    expect(inv.investedAmount, 230000, reason: 'invested is not recomputed');

    // A second run (next launch) changes nothing.
    final again = await TaskRunner(
      isar: isar,
      decimals: 2,
      l10n: AppLocalizationsEn(),
      backup: () async => (BackupOutcome.notDue, null),
    ).run(trigger: 'coldStart', now: DateTime(2026, 10, 21, 18));
    expect(again!.postedRecurring + again.postedEmis + again.postedSips, 0);
    expect(await isar.transactions.count(), oldTxns.length);
  });

  test('restore then the next due dates post once each', () async {
    await JsonBackupService().importJson(isar, json);
    TaskRunner runner() => TaskRunner(
          isar: isar,
          decimals: 2,
          l10n: AppLocalizationsEn(),
          backup: () async => (BackupOutcome.notDue, null),
        );
    await runner().run(trigger: 'restore', now: DateTime(2026, 10, 21, 9));
    final r = await runner().run(trigger: 'coldStart', now: DateTime(2026, 11, 12, 9));
    // Rent 1 Nov, EMI 5 Nov, SIP 10 Nov.
    expect((r!.postedRecurring, r.postedEmis, r.postedSips), (1, 1, 1));
    final added = await isar.transactions.filter().occurrenceDateIsNotNull().findAll();
    expect(added.map((t) => t.occurrenceDate).toSet(), {20261101, 20261105, 20261110});
  });
}
