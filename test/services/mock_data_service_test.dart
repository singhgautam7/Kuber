import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/services/mock_data_service.dart';
import 'package:kuber/core/utils/card_palette.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_service.dart';
import 'package:kuber/features/kuber_cards/data/stored_card.dart';

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
}
