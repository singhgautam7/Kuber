import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/investments/utils/investment_calculations.dart';

import '../../helpers/test_factories.dart';

void main() {
  /// Helper to build a contribution transaction.
  makeContribution({
    required String investmentUid,
    required double amount,
  }) {
    return makeTransaction(
      name: 'Contribution — Test',
      amount: amount,
      type: 'expense',
      linkedRuleId: investmentUid,
      linkedRuleType: 'investment',
    );
  }

  group('computeTotalInvested', () {
    test('sums all expense txns linked to investment', () {
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 10000),
        makeContribution(investmentUid: 'uid1', amount: 5000),
      ];
      expect(computeTotalInvested('uid1', txns), 15000);
    });

    test('returns 0.0 when no contributions', () {
      expect(computeTotalInvested('uid1', []), 0.0);
    });

    test('ignores transactions for other investments', () {
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 10000),
        makeContribution(investmentUid: 'uid2', amount: 20000),
      ];
      expect(computeTotalInvested('uid1', txns), 10000);
    });
  });

  group('computeGainLoss', () {
    test('positive when currentValue > totalInvested', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 135000);
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 100000),
      ];
      expect(computeGainLoss(inv, txns), 35000);
    });

    test('negative when currentValue < totalInvested', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 80000);
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 100000),
      ];
      expect(computeGainLoss(inv, txns), -20000);
    });

    test('returns 0.0 when currentValue is null', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: null);
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 100000),
      ];
      expect(computeGainLoss(inv, txns), 0.0);
    });
  });

  group('computeGainLossPercent', () {
    test('35% when invested 1,00,000 current 1,35,000', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 135000);
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 100000),
      ];
      expect(computeGainLossPercent(inv, txns), 35.0);
    });

    test('returns 0.0 when totalInvested is 0', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 1000);
      expect(computeGainLossPercent(inv, []), 0.0);
    });

    test('negative for loss', () {
      final inv = makeInvestment(uid: 'uid1', currentValue: 80000);
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 100000),
      ];
      expect(computeGainLossPercent(inv, txns), -20.0);
    });
  });

  group('totalInvestedAll', () {
    test('sums across all investments', () {
      final inv1 = makeInvestment(uid: 'uid1');
      final inv2 = makeInvestment(uid: 'uid2');
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 50000),
        makeContribution(investmentUid: 'uid2', amount: 30000),
      ];
      expect(totalInvestedAll([inv1, inv2], txns), 80000);
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
      final inv1 = makeInvestment(uid: 'uid1', currentValue: 60000);
      final inv2 = makeInvestment(uid: 'uid2', currentValue: 25000);
      final txns = [
        makeContribution(investmentUid: 'uid1', amount: 50000),
        makeContribution(investmentUid: 'uid2', amount: 30000),
      ];
      // currentValue total: 85000, invested total: 80000, gain: 5000
      expect(totalGainLossAll([inv1, inv2], txns), 5000);
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
