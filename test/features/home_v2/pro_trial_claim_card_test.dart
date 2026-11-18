import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/home_v2/data/home_v2_state.dart';
import 'package:kuber/features/home_v2/engine/suggestion_engine.dart';
import 'package:kuber/features/home_v2/engine/suggestion_scheduler.dart';
import 'package:kuber/features/home_v2/providers/home_suggestion_provider.dart';
import 'package:kuber/features/home_v2/providers/home_v2_provider.dart';
import 'package:kuber/features/home_v2/widgets/suggestion_card.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/promo/home_promo_banner.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/features/pro/trial/trial_suggestions.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';
import '../pro/trial_ui_harness.dart';

final _promo = StateProvider<bool>((_) => false);

void main() {
  late Isar isar;
  setUpAll(() async => initialiseIsarForTests());
  setUp(() async {
    isar = await openTestIsar();
    TrialSession.sheetShown = false;
    SharedPreferences.setMockInitialValues({
      PrefsKeys.sgLastNewShownDay: SgScheduler.dayStamp(DateTime.now()),
    });
  });
  tearDown(() async {
    TrialSession.sheetShown = false;
    await closeAndCleanIsar(isar);
  });

  final graduated = HomeV2Snapshot(
    cohort: HomeCohort.v2,
    gsGraduatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    gsGraduationReason: GsGraduation.migrated,
  );

  Future<ProviderContainer> make({
    TrialInfo? trial,
    FakeTrial? fake,
    KuberProState pro = const KuberProState(),
  }) async {
    final c = ProviderContainer(
      overrides: [
        homeV2BootProvider.overrideWithValue(graduated),
        homePromoVisibleProvider.overrideWith((ref) => ref.watch(_promo)),
        isarProvider.overrideWithValue(isar),
        proTrialProvider.overrideWith(() => fake ?? FakeTrial(trial ?? eligibleTrial())),
        kuberProStateProvider.overrideWith(() => FakePro(pro)),
      ],
    );
    addTearDown(c.dispose);
    c.read(trialSuggestionsProvider);
    await Future<void>.delayed(Duration.zero); // prefs load
    await Future<void>.delayed(Duration.zero);
    return c;
  }

  SgType? shown(ProviderContainer c) => c.read(homeSuggestionProvider).card?.type;

  test('shown to an eligible free user, after Why Kuber', () async {
    final c = await make();
    final n = c.read(homeSuggestionProvider.notifier);
    await n.resolve();
    expect(shown(c), SgType.whyKuber);
    await n.dismiss(kWhyKuberCard);
    await n.runNow();
    expect(shown(c), SgType.proTrialClaim);
  });

  test('not shown to Pro users, when not eligible, or after a claim', () async {
    for (final c in [
      await make(pro: paidPro()),
      await make(trial: TrialInfo.none(kNow)),
      await make(trial: activeTrial()),
    ]) {
      await c.read(homeSuggestionProvider.notifier).dismiss(kWhyKuberCard);
      await c.read(homeSuggestionProvider.notifier).runNow();
      expect(shown(c), isNull);
    }
  });

  test('not in the session the trial sheet appeared', () async {
    TrialSession.sheetShown = true;
    final c = await make();
    final n = c.read(homeSuggestionProvider.notifier);
    await n.dismiss(kWhyKuberCard);
    await n.runNow();
    expect(shown(c), isNull);
  });

  test('Not now hides for the session, dismiss for good, Undo restores', () async {
    final c = await make();
    final n = c.read(homeSuggestionProvider.notifier);
    await n.dismiss(kWhyKuberCard);
    await n.runNow();
    await n.notNow(kProTrialClaimCard);
    await n.resolve(force: true);
    expect(shown(c), isNull);
    await n.dismiss(kProTrialClaimCard);
    expect(c.read(trialSuggestionsProvider).claimDismissed, isTrue);
    await n.undoDismiss(kProTrialClaimCard);
    expect(c.read(trialSuggestionsProvider).claimDismissed, isFalse);
    expect(shown(c), SgType.proTrialClaim);
  });

  testWidgets('tapping Claim calls claim() and the card resolves', (t) async {
    final fake = FakeTrial(eligibleTrial(), TrialStartOutcome.notEligible);
    late ProviderContainer c;
    await t.runAsync(() async {
      c = await make(fake: fake);
      await c.read(homeSuggestionProvider.notifier).dismiss(kWhyKuberCard);
      await c.read(homeSuggestionProvider.notifier).runNow();
    });
    expect(shown(c), SgType.proTrialClaim);
    await t.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: SuggestionCard(candidate: kProTrialClaimCard)),
      ),
    ));
    expect(find.text('Claim 14 days of Pro, free'), findsOneWidget);
    // A promo banner makes the follow-up resolve a no-op (no Isar in fake time).
    c.read(_promo.notifier).state = true;
    await t.tap(find.text('Claim'));
    await t.pump(const Duration(seconds: 1));
    expect(fake.claims, 1);
    expect(c.read(trialSuggestionsProvider).claimDismissed, isTrue);
    expect(shown(c), isNull);
  });
}
