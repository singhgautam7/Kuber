import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/tools/bill_splitter/data/bill.dart';
import 'package:kuber/features/tools/bill_splitter/providers/bill_net_provider.dart';

Bill _bill({
  required String paidBy,
  required List<(String, double)> participants,
}) {
  return Bill()
    ..name = 'Dinner'
    ..totalAmount = participants.fold(0, (sum, item) => sum + item.$2)
    ..paidByPersonName = paidBy
    ..splitType = 'equal'
    ..participants = participants
        .map(
          (item) => BillParticipant()
            ..personName = item.$1
            ..share = item.$2,
        )
        .toList()
    ..createdAt = DateTime(2026, 5, 2);
}

void main() {
  group('debtsForYou', () {
    test('returns lent debts when You paid', () {
      final bill = _bill(
        paidBy: kYouName,
        participants: [(kYouName, 100), ('Amit', 250), ('Neha', 300)],
      );

      final debts = debtsForYou(bill);

      expect(debts, hasLength(2));
      expect(debts[0].personName, 'Amit');
      expect(debts[0].type, 'lent');
      expect(debts[0].amount, 250);
      expect(debts[1].personName, 'Neha');
      expect(debts[1].type, 'lent');
      expect(debts[1].amount, 300);
    });

    test(
      'returns borrowed debt when someone else paid and You participated',
      () {
        final bill = _bill(
          paidBy: 'Amit',
          participants: [('Amit', 400), (kYouName, 200), ('Neha', 300)],
        );

        final debts = debtsForYou(bill);

        expect(debts, hasLength(1));
        expect(debts.single.personName, 'Amit');
        expect(debts.single.type, 'borrowed');
        expect(debts.single.amount, 200);
      },
    );

    test('returns no debt when You are not involved', () {
      final bill = _bill(
        paidBy: 'Amit',
        participants: [('Amit', 400), ('Neha', 300)],
      );

      expect(debtsForYou(bill), isEmpty);
    });
  });
}
