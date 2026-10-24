import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/money_math/investment_math.dart';
import 'package:kuber/features/tools/engine/fd_rd_engine.dart';
import 'package:kuber/features/tools/engine/ppf_engine.dart';

void main() {
  group('XIRR', () {
    test('Excel reference example (37.34%)', () {
      final r = xirr([
        CashFlow(DateTime(2008, 1, 1), -10000),
        CashFlow(DateTime(2008, 3, 1), 2750),
        CashFlow(DateTime(2008, 10, 30), 4250),
        CashFlow(DateTime(2009, 2, 15), 3250),
        CashFlow(DateTime(2009, 4, 1), 2750),
      ]);
      expect(r, closeTo(0.373362535, 1e-8));
    });

    test('design: 5,000 a month for 3 years, worth 2,20,000 -> about 13.5%', () {
      final start = DateTime(2023, 10, 20);
      final flows = [
        for (var m = 0; m < 36; m++)
          CashFlow(DateTime(start.year, start.month + m, start.day), -5000),
        CashFlow(DateTime(2026, 10, 20), 220000),
      ];
      expect((xirr(flows)! * 100), closeTo(13.5, 0.3));
      expect(percentGain(220000, 180000), closeTo(22.2, 0.05));
    });

    test('lump sum doubling in a year is 100%', () {
      expect(
          xirr([
            CashFlow(DateTime(2025, 1, 1), -100),
            CashFlow(DateTime(2026, 1, 1), 200),
          ]),
          closeTo(1.0, 1e-9));
    });

    test('losses converge to a negative rate; one-sided flows give null', () {
      expect(
          xirr([
            CashFlow(DateTime(2025, 1, 1), -100),
            CashFlow(DateTime(2026, 1, 1), 50),
          ]),
          closeTo(-0.5, 1e-9));
      expect(xirr([CashFlow(DateTime(2025, 1, 1), -100)]), isNull);
      expect(
          xirr([
            CashFlow(DateTime(2025, 1, 1), -100),
            CashFlow(DateTime(2026, 1, 1), -50),
          ]),
          isNull);
    });
  });

  test('proportional withdrawal (design example)', () {
    final w = proportionalWithdrawal(invested: 80000, value: 100000, redeemed: 20000);
    expect(w.investedReduction, 16000);
    expect(w.realizedGain, 4000);
    expect(80000 - w.investedReduction, 64000);
    final n = proportionalWithdrawal(
        invested: 151600, value: 184000, redeemed: 20000, charges: 200);
    expect(n.realizedGain.round(), 3322);
    expect((151600 - n.investedReduction).round(), 135122);
  });

  test('step-up: 5,000 with 10% a year', () {
    expect(stepUpSeries(5000, true, 10, 4).map((v) => v.round()),
        [5000, 5500, 6050, 6655]);
    final start = DateTime(2026, 11, 10);
    expect(stepUpAmount(base: 3000, start: start, on: DateTime(2027, 11, 9), percent: true, value: 10), 3000);
    expect(stepUpAmount(base: 3000, start: start, on: DateTime(2027, 11, 10), percent: true, value: 10).round(), 3300);
    expect(stepUpAmount(base: 3000, start: start, on: DateTime(2028, 12, 1), percent: false, value: 500), 4000);
  });

  group('fixed return matches the calculators exactly', () {
    for (final f in CompoundingFrequency.values) {
      for (final y in [1, 2, 5, 10]) {
        test('FD ${f.name} $y y', () {
          expect(fdMaturity(100000, 7, y * 12, f),
              computeFd(100000, 7, y, f).maturity);
        });
      }
    }
    for (final y in [1, 3, 5]) {
      test('RD $y y', () {
        expect(rdMaturity(5000, 7.1, y * 12), computeRd(5000, 7.1, y).maturity);
      });
    }
    test('PPF 15 y', () {
      expect(ppfMaturity(150000, 7.1, 15), computePpf(150000, 15, ratePercent: 7.1).maturity);
    });
  });

  test('design: compounding examples (1L at 7% for 5 years)', () {
    expect(fdMaturity(100000, 7, 60, CompoundingFrequency.yearly).round(), 140255);
    expect(fdMaturity(100000, 7, 60, CompoundingFrequency.quarterly).round(), 141478);
    expect(fdMaturity(100000, 7, 60, CompoundingFrequency.monthly).round(), 141763);
  });

  test('design: value today and maturity of a 2L quarterly FD', () {
    final start = DateTime(2026, 3, 15);
    expect(
        fdValueOn(
                principal: 200000,
                rate: 7.25,
                freq: CompoundingFrequency.quarterly,
                start: start,
                tenureMonths: 24,
                at: DateTime(2026, 10, 20))
            .round(),
        208804);
    // The board shows 2,30,907 (it truncates); the exact value is 2,30,907.9.
    expect(fdMaturity(200000, 7.25, 24, CompoundingFrequency.quarterly),
        closeTo(230907.9, 0.1));
    expect(fdPayoutAmount(200000, 7.25, 4), 3625);
  });

  test('premature FD: rate after penalty applies to time held', () {
    final w = fdPrematureWithdrawal(
        principal: 100000,
        rate: 7,
        penaltyRate: 1,
        freq: CompoundingFrequency.quarterly,
        start: DateTime(2025, 1, 1),
        at: DateTime(2026, 1, 1));
    expect(w.rateAfterPenalty, 6);
    expect(w.received, greaterThan(100000));
    expect(w.received,
        lessThan(fdMaturity(100000, 7, 12, CompoundingFrequency.quarterly)));
  });
}
