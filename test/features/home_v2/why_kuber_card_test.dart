import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/widget_editor/providers/widget_editor_provider.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/home_v2/data/home_v2_state.dart';
import 'package:kuber/features/home_v2/data/tracking_choices.dart';
import 'package:kuber/features/home_v2/engine/suggestion_engine.dart';
import 'package:kuber/features/home_v2/engine/suggestion_scheduler.dart';
import 'package:kuber/features/home_v2/providers/home_suggestion_provider.dart';
import 'package:kuber/features/home_v2/providers/home_v2_provider.dart';
import 'package:kuber/features/pro/promo/home_promo_banner.dart';
import 'package:kuber/features/why_kuber/why_kuber_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  group('Why Kuber card eligibility', () {
    bool e({
      bool v2 = true,
      bool graduated = true,
      bool setting = true,
      bool promo = false,
      bool locked = false,
      bool seen = false,
      bool dismissed = false,
    }) => SgScheduler.whyKuberEligible(
      isV2: v2,
      gsGraduated: graduated,
      setting: setting,
      promoVisible: promo,
      sessionLocked: locked,
      tourSeen: seen,
      cardDismissed: dismissed,
    );

    test('every install on the widget model once Get started graduated', () {
      expect(e(), isTrue);
      expect(e(graduated: false), isFalse); // never alongside Get started
      expect(e(v2: false), isFalse); // migration not run (yet)
    });
    test('until the tour is seen or the card is closed', () {
      expect(e(seen: true), isFalse);
      expect(e(dismissed: true), isFalse);
    });
    test('respects the Suggestions switch, promo banner and Not now', () {
      expect(e(setting: false), isFalse);
      expect(e(promo: true), isFalse);
      expect(e(locked: true), isFalse);
    });
  });

  group('Why Kuber card priority (resolver)', () {
    late Isar isar;
    setUpAll(() async => initialiseIsarForTests());
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => closeAndCleanIsar(isar));

    final graduated = HomeV2Snapshot(
      cohort: HomeCohort.v2,
      gsGraduatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      gsGraduationReason: GsGraduation.migrated,
    );

    ProviderContainer container(HomeV2Snapshot s) => ProviderContainer(
      overrides: [
        homeV2BootProvider.overrideWithValue(s),
        homePromoVisibleProvider.overrideWithValue(false),
        isarProvider.overrideWithValue(isar),
      ],
    );

    test('shown first, without the 24 h wait or the daily allowance', () async {
      // Today's new-suggestion allowance is already used: a normal
      // suggestion could not show, the card still does.
      SharedPreferences.setMockInitialValues({
        PrefsKeys.sgLastNewShownDay: SgScheduler.dayStamp(DateTime.now()),
      });
      final c = container(graduated);
      addTearDown(c.dispose);
      await c.read(homeSuggestionProvider.notifier).resolve();
      expect(c.read(homeSuggestionProvider).card?.type, SgType.whyKuber);
      // The allowance was not touched.
      final p = await SharedPreferences.getInstance();
      expect(p.getInt(PrefsKeys.sgLastNewShownDay), SgScheduler.dayStamp(DateTime.now()));
    });

    test('gone once the tour is seen; Not now hides it for the session', () async {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.sgLastNewShownDay: SgScheduler.dayStamp(DateTime.now()),
      });
      final c = container(graduated);
      addTearDown(c.dispose);
      final n = c.read(homeSuggestionProvider.notifier);
      await n.resolve();
      await n.notNow(kWhyKuberCard);
      expect(c.read(homeSuggestionProvider).card, isNull);
      await n.resolve(force: true); // same session: still hidden
      expect(c.read(homeSuggestionProvider).card, isNull);

      await WhyKuberStore.markSeen();
      await n.runNow();
      expect(c.read(homeSuggestionProvider).card, isNull);
    });

    test('close is permanent; Undo brings it back', () async {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.sgLastNewShownDay: SgScheduler.dayStamp(DateTime.now()),
      });
      final c = container(graduated);
      addTearDown(c.dispose);
      final n = c.read(homeSuggestionProvider.notifier);
      await n.resolve();
      await n.dismiss(kWhyKuberCard);
      expect(await WhyKuberStore.cardDismissed(), isTrue);
      await n.undoDismiss(kWhyKuberCard);
      expect(c.read(homeSuggestionProvider).card?.type, SgType.whyKuber);
      await n.dismiss(kWhyKuberCard);
      await n.runNow();
      expect(c.read(homeSuggestionProvider).card, isNull);
    });

    test('Quick Add intro from 2 transactions, after Why Kuber', () async {
      SharedPreferences.setMockInitialValues({
        PrefsKeys.sgLastNewShownDay: SgScheduler.dayStamp(DateTime.now()),
        PrefsKeys.tourSeenAt: DateTime.now().toIso8601String(),
      });
      Transaction t() => Transaction()
        ..name = 'x'
        ..nameLower = 'x'
        ..amount = 10
        ..type = 'expense'
        ..categoryId = ''
        ..accountId = '1'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();
      await isar.writeTxn(() => isar.transactions.put(t()));
      final c = container(graduated);
      addTearDown(c.dispose);
      await c.read(homeWidgetsProvider.future); // Quick Add is on Home
      final n = c.read(homeSuggestionProvider.notifier);
      await n.resolve();
      expect(c.read(homeSuggestionProvider).card, isNull); // 1 transaction
      await isar.writeTxn(() => isar.transactions.put(t()));
      await n.runNow();
      expect(c.read(homeSuggestionProvider).card?.type, SgType.quickAddIntro);
      await n.dismiss(kQuickAddIntroCard);
      await n.runNow();
      expect(c.read(homeSuggestionProvider).card, isNull);
    });

    test('not while Get started is still on Home', () async {
      SharedPreferences.setMockInitialValues({});
      final c = container(const HomeV2Snapshot(cohort: HomeCohort.v2));
      addTearDown(c.dispose);
      await c.read(homeSuggestionProvider.notifier).resolve();
      expect(c.read(homeSuggestionProvider).card, isNull);
    });
  });

  test('tracking choices move matching suggestions back, before discovery', () {
    const loans = SgCandidate(type: SgType.loans, key: 'loans');
    const budget = SgCandidate(type: SgType.budget, key: 'budget:a');
    const ask = SgCandidate(type: SgType.askKuber, key: 'ask_kuber');
    final day = DateTime(2026, 10, 14);
    expect(
      SgScheduler.select(const SgStore(), [loans, budget, ask], day).shown!.key,
      'loans',
    );
    expect(
      SgScheduler.select(
        const SgStore(),
        [loans, budget, ask],
        day,
        movedBack: {SgType.loans},
      ).shown!.key,
      'budget:a',
    );
    expect(
      SgScheduler.select(
        const SgStore(),
        [loans, ask],
        day,
        movedBack: {SgType.loans},
      ).shown!.key,
      'loans',
    );
  });

  test('tracking choices map to their widgets', () {
    expect(trackingWidgetsFor({'budgets'}), {'budget_snapshot'});
    expect(trackingWidgetsFor({'loans', 'subscriptions'}), {'upcoming_events_widget'});
    expect(trackingWidgetsFor(const {}), isEmpty);
  });
}
