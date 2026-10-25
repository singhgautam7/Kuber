// Upgrade check (specs/vnext/test-report.md): compares the database from the
// base build 6ce4f0e (pre) with the same database after this build's upgrade
// (post). By default it upgrades in process: the committed fixture
// (test/fixtures/upgrade, pulled from the emulator after the base build ran
// on the full schedule set + 6k ledger) is opened with this build's schemas
// and the first background run (migration + processing) runs on it.
// Emulator mode compares two pulled databases instead:
//   KUBER_PRE_DB=<dir with pre.isar> KUBER_POST_DB=<dir with post.isar> \
//   KUBER_TODAY=2026-10-21 flutter test test/upgrade/upgrade_compare_test.dart
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/task_runner.dart';
import 'package:kuber/features/backups/services/scheduled_backup.dart';
import 'package:kuber/l10n/app_localizations_en.dart';
import 'package:kuber/core/schedule/legacy_schedules.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/transactions/data/transaction.dart';

import '../helpers/isar_test_helper.dart';

void main() {
  final preDir = Platform.environment['KUBER_PRE_DB'];
  final postDir = Platform.environment['KUBER_POST_DB'];
  late Isar pre, post;
  late DateTime today;

  setUpAll(() async {
    await initialiseIsarForTests();
    if (preDir != null && postDir != null) {
      pre = await openTestIsar(directory: preDir, name: 'pre');
      post = await openTestIsar(directory: postDir, name: 'post');
      today = DateTime.parse(Platform.environment['KUBER_TODAY']!);
      return;
    }
    final bytes = gzip.decode(
        File('test/fixtures/upgrade/pre_6ce4f0e.isar.gz').readAsBytesSync());
    Directory dir(String name) {
      final d = Directory.systemTemp.createTempSync('upgrade_');
      File('${d.path}/$name.isar').writeAsBytesSync(bytes);
      return d;
    }

    pre = await openTestIsar(directory: dir('pre').path, name: 'pre');
    post = await openTestIsar(directory: dir('post').path, name: 'post');
    final now = DateTime.now();
    today = DateTime(now.year, now.month, now.day);
    final run = await TaskRunner(
      isar: post,
      decimals: 2,
      l10n: AppLocalizationsEn(),
      backup: () async => (BackupOutcome.notDue, null),
    ).run(trigger: 'coldStart', now: now);
    expect(run!.status, 'done');
  });

  tearDownAll(() async {
    await pre.close();
    await post.close();
  });

  int day(DateTime d) => dayKey(d);
  int todayK() => dayKey(today);

  group('upgrade', () {
    test(
      'recurring: next dates match the old rule, nothing posted twice',
      () async {
        final before = {
          for (final r in await pre.recurringRules.where().findAll()) r.id: r,
        };
        final after = {
          for (final r in await post.recurringRules.where().findAll()) r.id: r,
        };
        expect(after.keys.toSet(), before.keys.toSet());
        for (final r in before.values) {
          final a = after[r.id]!;
          final s = a.schedule!;
          final (
            count,
            unit,
          ) = r.frequency == 'custom' && r.intervalUnit != null
              ? (r.customDays ?? 1, LegacyUnit.values.byName(r.intervalUnit!))
              : legacyFrequency(r.frequency, r.customDays);
          expect(s.paused, r.isPaused, reason: r.name);
          // Expected: walk the old rule past today (occurrences due today are
          // posted by the new run, date-only per fix R1).
          var d = r.nextDueAt;
          var executed = r.executionCount;
          var ended = false;
          while (!r.isPaused && day(d) <= todayK()) {
            if (legacyRecurringExpired(
              endType: r.endType,
              endAfter: r.endAfter,
              endDate: r.endDate,
              executionCount: executed,
              dueDate: d,
            )) {
              ended = true;
              break;
            }
            executed++;
            d = legacyRecurringNext(
              count: count,
              unit: unit,
              startDate: r.startDate,
              from: d,
            );
          }
          if (!ended &&
              legacyRecurringExpired(
                endType: r.endType,
                endAfter: r.endAfter,
                endDate: r.endDate,
                executionCount: executed,
                dueDate: d,
              )) {
            ended = true;
          }
          final next = nextDate(s, fromKey: addDays(todayK(), 1));
          // ignore: avoid_print
          print(
            '${r.name.padRight(18)} old next ${day(r.nextDueAt)}  expected ${ended ? 'ended' : day(d)}  '
            'new ${next ?? 'none'}  ${s.migrationNote ?? ''}',
          );
          if (r.isPaused) continue;
          if (ended) {
            expect(next == null || isEnded(s), isTrue, reason: r.name);
          } else {
            expect(next, day(d), reason: r.name);
          }
        }
      },
    );

    test(
      'transactions: old rows untouched, new ones only for due days, no duplicates',
      () async {
        final before = {
          for (final t in await pre.transactions.where().findAll()) t.id: t,
        };
        final after = await post.transactions.where().findAll();
        final byId = {for (final t in after) t.id: t};
        for (final t in before.values) {
          final a = byId[t.id];
          expect(a, isNotNull, reason: 'txn ${t.id} missing');
          expect(
            (a!.amount, a.type, a.createdAt, a.accountId),
            (t.amount, t.type, t.createdAt, t.accountId),
          );
          expect(a.spendAmount, a.amount);
        }
        final added = after.where((t) => !before.containsKey(t.id)).toList();
        // ignore: avoid_print
        print(
          'added ${added.length}: ${added.map((t) => '${t.name}@${t.occurrenceDate}').join(', ')}',
        );
        for (final t in added) {
          expect(t.occurrenceDate, isNotNull, reason: t.name);
          expect(t.occurrenceDate! <= todayK(), isTrue, reason: t.name);
          // Not already recorded by the old build on that day.
          final dup = before.values.where(
            (o) =>
                o.linkedRuleId == t.linkedRuleId &&
                o.linkedRuleId != null &&
                day(o.createdAt) == t.occurrenceDate,
          );
          expect(dup, isEmpty, reason: '${t.name} duplicated');
        }
        final keys = <String>{};
        for (final t in after.where((t) => t.occurrenceDate != null)) {
          expect(
            keys.add('${t.sourceType}:${t.sourceId}:${t.occurrenceDate}'),
            isTrue,
            reason: t.name,
          );
        }
      },
    );

    test('analytics totals for existing data are identical', () async {
      Map<String, double> totals(Iterable<Transaction> ts) {
        final m = <String, double>{};
        for (final t in ts) {
          final k = '${t.createdAt.year}-${t.createdAt.month}-${t.type}';
          m[k] = (m[k] ?? 0) + t.spendAmount;
        }
        return m;
      }

      final before = await pre.transactions.where().findAll();
      final ids = before.map((t) => t.id).toSet();
      final after = (await post.transactions.where().findAll()).where(
        (t) => ids.contains(t.id),
      );
      expect(totals(after), totals(before));
      final all = totals(await post.transactions.where().findAll());
      final k = '${today.year}-${today.month}-expense';
      // ignore: avoid_print
      print('this month expense: before ${totals(before)[k]} after ${all[k]}');
    });

    test('loans and investments carried over', () async {
      final loans = await post.loans.where().findAll();
      final txns = await post.transactions.where().findAll();
      for (final l in loans) {
        final st = loanStatus(
          l,
          txns.where((t) => t.linkedRuleId == l.uid).toList(),
          now: today,
        );
        // ignore: avoid_print
        print(
          'loan ${l.name}: v${l.dataVersion} ${l.startingPoint.name} next ${st.nextDay} '
          'outstanding ${st.outstanding?.round()} emis ${st.emisPaid}/${st.totalEmis} '
          'auto ${l.schedule?.autoRecord} ${l.schedule?.migrationNote ?? ''}',
        );
        expect(l.dataVersion, 1);
        expect(l.schedule, isNotNull);
      }
      for (final i in await post.investments.where().findAll()) {
        // ignore: avoid_print
        print(
          'inv ${i.name}: ${i.behaviour.name} invested ${i.investedAmount} value ${i.currentValue} '
          'snapshots ${i.snapshots.length} opening ${i.openingInvested} sip ${i.sip?.anchorDay}',
        );
        expect(i.dataVersion, 1);
        expect(i.snapshots, isNotEmpty);
      }
    });
  });
}
