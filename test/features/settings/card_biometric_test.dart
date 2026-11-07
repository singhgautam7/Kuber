// November release D1: the app lock and the Kuber Cards biometric are two
// settings. All 4 combinations, plus no biometrics and the PIN alone.
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/services/biometric_service.dart';
import 'package:kuber/features/kuber_cards/data/card_biometric.dart';
import 'package:kuber/features/kuber_cards/data/card_vault_meta.dart';
import 'package:kuber/features/kuber_cards/providers/kuber_cards_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

class FakeBiometric extends BiometricService {
  final bool available, passes;
  FakeBiometric({this.available = true, this.passes = true});
  @override
  Future<bool> canAuthenticate() async => available;
  @override
  Future<bool> authenticate() async => passes;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;
  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
    // The Keystore channel: stores and clears, nothing else.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('com.grs.kuber/cards_keystore'), (_) async => null);
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
  });
  tearDownAll(() async {
    debugDefaultTargetPlatformOverride = null;
    await closeAndCleanIsar(isar);
  });
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await isar.writeTxn(() async {
      await isar.clear();
      await isar.cardVaultMetas.put(CardVaultMeta());
    });
  });

  Future<void> run(WidgetTester t, Future<void> Function(WidgetRef ref) body,
      {bool unlocked = true}) async {
    late WidgetRef captured;
    await t.pumpWidget(ProviderScope(
      overrides: [isarProvider.overrideWithValue(isar)],
      child: MaterialApp(home: Consumer(builder: (_, ref, _) {
        captured = ref;
        return const SizedBox();
      })),
    ));
    if (unlocked) {
      captured.read(cardSessionProvider.notifier).unlock(utf8.encode('k' * 32));
    }
    await t.runAsync(() => body(captured));
    await t.pumpWidget(const SizedBox());
    await drainIsarWrites(t, isar);
  }

  Future<bool> cardsOn() async => (await isar.cardVaultMetas.get(0))!.biometricEnabled;

  for (final (app, cards) in [(false, false), (false, true), (true, false), (true, true)]) {
    testWidgets('app lock $app, cards $cards: each keeps its own value', (t) async {
      await run(t, (ref) async {
        final settings = ref.read(settingsProvider.notifier);
        await ref.read(settingsProvider.future);
        await settings.setBiometricsEnabled(app);
        await setCardBiometric(ref, cards, biometric: FakeBiometric());
        expect(ref.read(settingsProvider).valueOrNull?.biometricsEnabled, app);
        expect(await cardsOn(), cards);
        // Flip the app lock: cards don't move.
        await settings.setBiometricsEnabled(!app);
        expect(await cardsOn(), cards);
        // Flip the cards: the app lock doesn't move.
        await setCardBiometric(ref, !cards, biometric: FakeBiometric());
        expect(ref.read(settingsProvider).valueOrNull?.biometricsEnabled, !app);
        expect(await cardsOn(), !cards);
      });
    });
  }

  testWidgets('no biometrics on the phone: a clear result, the PIN still works', (t) async {
    await run(t, (ref) async {
      final r = await setCardBiometric(ref, true, biometric: FakeBiometric(available: false));
      expect(r, CardBiometricResult.unavailable);
      expect(await cardsOn(), isFalse);
    });
  });

  testWidgets('a locked vault has no key yet: asks to unlock with the PIN first', (t) async {
    await run(t, (ref) async {
      final r = await setCardBiometric(ref, true, biometric: FakeBiometric());
      expect(r, CardBiometricResult.needsUnlock);
      expect(await cardsOn(), isFalse);
    }, unlocked: false);
  });

  testWidgets('a cancelled check changes nothing', (t) async {
    await run(t, (ref) async {
      final r = await setCardBiometric(ref, true, biometric: FakeBiometric(passes: false));
      expect(r, CardBiometricResult.cancelled);
      expect(await cardsOn(), isFalse);
    });
  });

  testWidgets('turning off works with the vault locked and no biometrics left', (t) async {
    await run(t, (ref) async {
      await ref.read(cardVaultServiceProvider).setBiometricEnabled(true);
      final r = await setCardBiometric(ref, false, biometric: FakeBiometric(available: false));
      expect(r, CardBiometricResult.disabled);
      expect(await cardsOn(), isFalse);
    }, unlocked: false);
  });
}
