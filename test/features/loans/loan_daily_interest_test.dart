// Daily interest (actual days / 365, charged on the EMI date) for reducing
// loans. Expected values are worked out here from first principles, and the
// Federal Bank check uses the bank's own statement.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/money_math/loan_math.dart';
import 'package:kuber/core/schedule/schedule.dart';
import 'package:kuber/core/schedule/schedule_engine.dart';
import 'package:kuber/core/services/json_backup_service.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';
import 'package:kuber/features/loans/domain/loan_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';
import 'loan_pre_emi_test.dart' show federal;

int days(int a, int b) => DateTime.utc(b ~/ 10000, b ~/ 100 % 100, b % 100)
    .difference(DateTime.utc(a ~/ 10000, a ~/ 100 % 100, a % 100))
    .inDays;

List<int> monthly(int y, int m, int d, int n) => [
      for (var i = 0; i < n; i++)
        () {
          final mm = m + i, yy = y + (mm - 1) ~/ 12, m1 = (mm - 1) % 12 + 1;
          final last = DateTime.utc(yy, m1 + 1, 0).day;
          return yy * 10000 + m1 * 100 + (d > last ? last : d);
        }(),
    ];

void main() {
  group('Federal Bank on daily', () {
    // The outstanding before the first EMI matched to the statement, as a
    // user does by editing Interest added (59,591 gives 17,59,591 exactly).
    Loan matched() => federal()
      ..interestMethod = LoanInterestMethod.daily
      ..preEmiOverride = 59591
      ..preEmiCalculated = loanAmortization(federal())!.preEmi!.calculatedAdded;

    test('November balance within 3 rupees of the statement (17,57,561)', () {
      final a = loanAmortization(matched())!;
      expect(a.openingBalance, 1759591);
      final nov = a.rows.first;
      expect(nov.day, 20171113);
      // 13 Oct to 13 Nov: 31 days at 9.2% on 17,59,591, to the rupee.
      expect(nov.interest, (1759591 * 0.092 / 365 * 31).roundToDouble());
      expect((nov.balance - 1757561).abs(), lessThanOrEqualTo(3), reason: '${nov.balance}');
    });

    test('unedited, the first broken month keeps its 7 rupees', () {
      // The bank charged 3,915 for the first part-month; Kuber 3,908. That
      // gap is the whole difference here, not the daily split.
      final a = loanAmortization(federal()..interestMethod = LoanInterestMethod.daily)!;
      final gap = 1759591 - a.openingBalance;
      expect((a.rows.first.balance + gap - 1757561).abs(), lessThanOrEqualTo(3));
    });

    test('monthly stays exactly as before', () {
      final a = loanAmortization(federal())!;
      expect(federal().interestMethod, LoanInterestMethod.monthly);
      expect(a.rows.first.interest, closeTo(a.openingBalance * 9.2 / 1200, 1e-9));
    });

    test('the EMI stays the same, only the split moves', () {
      final m = loanAmortization(federal())!;
      final d = loanAmortization(federal()..interestMethod = LoanInterestMethod.daily)!;
      for (var i = 0; i < 24; i++) {
        expect(d.rows[i].payment, m.rows[i].payment);
      }
      expect(d.rows[0].interest, greaterThan(m.rows[0].interest)); // 31 days
      expect(d.rows[4].day, 20180313);
      expect(d.rows[4].interest, lessThan(m.rows[4].interest)); // 28 days of February
    });
  });

  group('days in the period', () {
    test('February in a leap year and not', () {
      // EMI on the 5th: 5 Feb to 5 Mar is 29 days in 2024, 28 in 2023.
      for (final (year, feb) in [(2024, 29), (2023, 28)]) {
        final emiDays = monthly(year, 1, 5, 12);
        final a = amortize(principal: 1000000, rate: 9, months: 12, emiDays: emiDays, dailyInterest: true);
        final marchRow = a.rows[2];
        expect(days(a.rows[1].day, marchRow.day), feb);
        expect(marchRow.interest, (a.rows[1].balance * 0.09 / 365 * feb).roundToDouble());
        // January's first period: 5 Dec to 5 Jan.
        expect(a.rows.first.interest, (1000000 * 0.09 / 365 * 31).roundToDouble());
      }
    });

    test('day counts agree with the calendar across leap years and centuries', () {
      // monthBefore + the amortization's own gaps against DateTime.
      for (final (a, b) in [(20240228, 20240301), (20230228, 20230301), (19000228, 19000301),
          (20000228, 20000301), (20171013, 20171113), (20271231, 20290228)]) {
        final emiDays = [a, b];
        final r = amortize(principal: 365000, rate: 100, months: 2, emiDays: emiDays,
            emi: 1, dailyInterest: true);
        expect(r.rows[1].interest, (365000 * days(a, b) / 365).roundToDouble(), reason: '$a $b');
      }
    });

    test('an EMI on the 31st clamps to the end of February', () {
      expect(monthBefore(20240331), 20240229);
      expect(monthBefore(20230331), 20230228);
      expect(monthBefore(20240115), 20231215);
      final a = amortize(
          principal: 500000, rate: 10, months: 6, emiDays: monthly(2024, 1, 31, 6), dailyInterest: true);
      expect(a.rows[1].day, 20240229);
      expect(a.rows[1].interest, (a.rows[0].balance * 0.10 / 365 * 29).roundToDouble());
      expect(a.rows[2].interest, (a.rows[1].balance * 0.10 / 365 * 31).roundToDouble());
    });

    test('a prepayment between EMIs splits the period at its date', () {
      final emiDays = monthly(2025, 1, 10, 24);
      final a = amortize(
          principal: 800000,
          rate: 8.5,
          months: 24,
          emiDays: emiDays,
          dailyInterest: true,
          events: const [AmortEvent(20250220, AmortEventKind.prepayment, amount: 100000)]);
      // 10 Feb to 20 Feb on the old balance, 20 Feb to 10 Mar (18 days) on
      // the new one.
      final before = a.rows[1].balance;
      final want = before * 0.085 / 365 * 10 + (before - 100000) * 0.085 / 365 * 18;
      expect(a.rows[2].interest, want.roundToDouble());
    });

    test('a year of daily interest is close to a year of monthly interest', () {
      final emiDays = monthly(2025, 4, 5, 240);
      final m = amortize(principal: 2000000, rate: 9, months: 240, emiDays: emiDays);
      final d = amortize(principal: 2000000, rate: 9, months: 240, emiDays: emiDays, dailyInterest: true);
      final mYear = m.rows.take(12).fold(0.0, (s, r) => s + r.interest);
      final dYear = d.rows.take(12).fold(0.0, (s, r) => s + r.interest);
      expect((mYear - dYear).abs() / mYear, lessThan(0.002));
    });

    test('flat rate and interest-only ignore it', () {
      final emiDays = monthly(2025, 1, 5, 24);
      for (final kind in [RateKind.flat, RateKind.interestOnlyFirst]) {
        final off = amortize(principal: 300000, rate: 12, months: 24, emiDays: emiDays, kind: kind, ioMonths: 3);
        final on = amortize(
            principal: 300000, rate: 12, months: 24, emiDays: emiDays, kind: kind, ioMonths: 3, dailyInterest: true);
        expect([for (final r in on.rows) r.interest], [for (final r in off.rows) r.interest]);
      }
    });
  });

  group('switching a running loan', () {
    final emiDays = monthly(2025, 1, 5, 60);
    final monthlyA = amortize(principal: 1500000, rate: 9.5, months: 60, emiDays: emiDays);
    // Three EMIs recorded as monthly worked them out, the third edited.
    final recorded = {
      for (final r in monthlyA.rows.take(3))
        r.day: () {
          final s = roundedSplit(r.payment, r.interest, 2);
          return RecordedEmi(r.payment, s.principal, s.interest, edited: r.index == 3);
        }(),
    };

    test('recorded EMIs never change; the projection does', () {
      final d = amortize(
          principal: 1500000, rate: 9.5, months: 60, emiDays: emiDays, recorded: recorded, dailyInterest: true);
      for (final r in d.rows.take(3)) {
        expect(r.principal, recorded[r.day]!.principal);
        expect(r.interest, recorded[r.day]!.interest);
      }
      expect(d.rows[2].edited, isTrue);
      // EMI 4 onwards: days since EMI 3 on what is owed after it.
      final after3 = d.rows[2].balance;
      expect(d.rows[3].interest, (after3 * 0.095 / 365 * days(d.rows[2].day, d.rows[3].day)).roundToDouble());
    });

    test('preview: the end date and total interest move', () {
      final m = amortize(principal: 1500000, rate: 9.5, months: 60, emiDays: emiDays, recorded: recorded);
      final d = amortize(
          principal: 1500000, rate: 9.5, months: 60, emiDays: emiDays, recorded: recorded, dailyInterest: true);
      final p = LoanService.interestMethodPreview(m, d);
      expect(p.interestNow, closeTo(m.totalInterest, 1e-6));
      expect(p.interestThen, closeTo(d.totalInterest, 1e-6));
      expect(p.endNow, m.rows.last.day);
      expect(p.endThen, d.rows.last.day);
    });
  });

  group('stored and restored', () {
    late Isar isar;
    setUpAll(() async {
      SharedPreferences.setMockInitialValues({});
      await initialiseIsarForTests();
      isar = await openTestIsar();
    });
    tearDownAll(() => closeAndCleanIsar(isar));

    test('a backup keeps the method; an older backup reads monthly', () async {
      final s = scheduleFrom(start: DateTime(2025, 1, 5), endType: ScheduleEnd.afterCount, endCount: 60);
      final l = federal()
        ..interestMethod = LoanInterestMethod.daily
        ..schedule = s;
      await LoanService(isar).save(l, s, isNew: true);
      final json = await JsonBackupService().exportJson(isar);
      expect((jsonDecode(json)['loans'] as List).single['interestMethod'], 'daily');
      await isar.writeTxn(() => isar.clear());
      await JsonBackupService().importJson(isar, json);
      expect((await isar.loans.where().findFirst())!.interestMethod, LoanInterestMethod.daily);

      final old = jsonDecode(json) as Map<String, dynamic>;
      ((old['loans'] as List).single as Map).remove('interestMethod');
      await isar.writeTxn(() => isar.clear());
      await JsonBackupService().importJson(isar, jsonEncode(old));
      expect((await isar.loans.where().findFirst())!.interestMethod, LoanInterestMethod.monthly);
    });
  });
}
