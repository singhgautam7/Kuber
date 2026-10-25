import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/services/data_service.dart';
import 'package:kuber/core/services/mock_data_service.dart';
import 'package:kuber/core/utils/card_palette.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_service.dart';
import 'package:kuber/features/kuber_cards/data/stored_card.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/domain/loan_engine.dart';

import '../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async => isar = await openTestIsar());
  tearDown(() async => closeAndCleanIsar(isar));

  test('mock cards unlock with PIN 0000 and have renderable colours', () async {
    await MockDataService.generate(isar);
    final outcome = await CardVaultService(
      isar,
    ).attemptUnlock(MockDataService.mockCardsPin);
    expect(outcome.status, UnlockStatus.success);

    final cards = await isar.storedCards.where().findAll();
    expect(cards, hasLength(4));
    for (final c in cards) {
      // Gradient cards store a palette index; an ARGB there crashes the card.
      if (c.isGradient) {
        expect(c.colorValue, inInclusiveRange(0, CardPalette.gradients.length - 1));
      }
    }
  });

  // Regression: demo loans had no schedule, so View EMI schedule crashed.
  test('Generate Mock Data gives every loan a schedule', () async {
    await DataService(isar).generateMockData();
    final loans = await isar.loans.where().findAll();
    expect(loans, isNotEmpty);
    for (final l in loans) {
      expect(l.schedule, isNotNull, reason: l.name);
    }
  });

  test('mock data includes one loan with full details (Advanced options)', () async {
    await MockDataService.generate(isar);
    final car = (await isar.loans.filter().nameEqualTo('Creta Car Loan').findFirst())!;
    expect(car.mode, LoanMode.advanced);
    expect(hasLoanNumbers(car), isTrue);
    expect(car.schedule!.autoRecord, isTrue);
    final st = loanStatus(car, const []);
    expect(st.emisPaid, inInclusiveRange(13, 15), reason: 'running 14 months before Kuber');
    expect(st.principalPaid! + st.outstanding!, closeTo(900000, 1));
    expect(st.closed, isFalse);
  });
}
