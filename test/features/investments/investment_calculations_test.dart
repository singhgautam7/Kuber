import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/investments/utils/investment_calculations.dart';

import '../../helpers/test_factories.dart';

void main() {
  group('computeTotalInvested', () {
    test('returns investedAmount from the investment', () {
      final inv = makeInvestment(uid: 'uid1', investedAmount: 15000);
      expect(computeTotalInvested(inv), 15000);
    });

    test('returns 0.0 when investedAmount is null', () {
      final inv = makeInvestment(uid: 'uid1', investedAmount: null);
      expect(computeTotalInvested(inv), 0.0);
    });
  });

  group('computeGainLoss', () {
    test('positive when currentValue > investedAmount', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 135000, investedAmount: 100000);
      expect(computeGainLoss(inv), 35000);
    });

    test('negative when currentValue < investedAmount', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 80000, investedAmount: 100000);
      expect(computeGainLoss(inv), -20000);
    });

    test('returns 0.0 when currentValue is null', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: null, investedAmount: 100000);
      expect(computeGainLoss(inv), 0.0);
    });

    test('returns 0.0 when investedAmount is null', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 100000, investedAmount: null);
      expect(computeGainLoss(inv), 0.0);
    });
  });

  group('computeGainLossPercent', () {
    test('35% when invested 1,00,000 current 1,35,000', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 135000, investedAmount: 100000);
      expect(computeGainLossPercent(inv), 35.0);
    });

    test('returns 0.0 when investedAmount is 0', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 1000, investedAmount: 0);
      expect(computeGainLossPercent(inv), 0.0);
    });

    test('returns 0.0 when investedAmount is null', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 1000, investedAmount: null);
      expect(computeGainLossPercent(inv), 0.0);
    });

    test('negative for loss', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 80000, investedAmount: 100000);
      expect(computeGainLossPercent(inv), -20.0);
    });
  });

  group('totalInvestedAll', () {
    test('sums investedAmount across all investments', () {
      final inv1 = makeInvestment(uid: 'uid1', investedAmount: 50000);
      final inv2 = makeInvestment(uid: 'uid2', investedAmount: 30000);
      expect(totalInvestedAll([inv1, inv2]), 80000);
    });

    test('treats null investedAmount as 0', () {
      final inv1 = makeInvestment(uid: 'uid1', investedAmount: 50000);
      final inv2 = makeInvestment(uid: 'uid2', investedAmount: null);
      expect(totalInvestedAll([inv1, inv2]), 50000);
    });
  });

  group('totalCurrentValueAll', () {
    test('sums currentValue, treating null as 0', () {
      final inv1 = makeInvestment(uid: 'uid1', currentValue: 60000);
      final inv2 = makeInvestment(uid: 'uid2', currentValue: null);
      final inv3 = makeInvestment(uid: 'uid3', currentValue: 40000);
      expect(totalCurrentValueAll([inv1, inv2, inv3]), 100000);
    });
  });

  group('totalGainLossAll', () {
    test('aggregate gain/loss across portfolio', () {
      final inv1 = makeInvestment(uid: 'uid1', currentValue: 60000, investedAmount: 50000);
      final inv2 = makeInvestment(uid: 'uid2', currentValue: 25000, investedAmount: 30000);
      // currentValue total: 85000, invested total: 80000, gain: 5000
      expect(totalGainLossAll([inv1, inv2]), 5000);
    });
  });

  group('totalAssetCount', () {
    test('returns count of investments list', () {
      final investments = [
        makeInvestment(uid: 'uid1'),
        makeInvestment(uid: 'uid2'),
        makeInvestment(uid: 'uid3'),
      ];
      expect(totalAssetCount(investments), 3);
    });
  });
}
