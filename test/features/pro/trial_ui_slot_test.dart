import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/trial/trial_checklist.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/features/pro/trial/trial_suggestions.dart';
import 'package:kuber/features/pro/trial/widgets/pro_suggestion_slot.dart';
import 'package:kuber/features/pro/trial/widgets/trial_checklist_sheet.dart';

import 'trial_ui_harness.dart';

SlotContent? _r(
  ProSuggestionPlace place,
  TrialInfo trial, {
  bool isPro = false,
  Set<ProTrialFeature> tried = const {},
  TrialSuggestionState? state,
  bool sheet = false,
}) =>
    resolveSlot(
      place: place,
      isPro: isPro,
      trial: trial,
      tried: tried,
      state: state ?? const TrialSuggestionState(loaded: true),
      sheetShownThisSession: sheet,
    );

void main() {
  setUp(() async {
    await resetTrialPrefs();
    TrialSession.sheetShown = false;
  });

  group('rules', () {
    test('day card is the first untried feature, on its own screen only', () {
      final t = activeTrial();
      expect((_r(ProSuggestionPlace.home, t) as SlotSuggestion).feature, ProTrialFeature.ask);
      expect(_r(ProSuggestionPlace.history, t), isNull);
      expect(_r(ProSuggestionPlace.analytics, t), isNull);
      // SMS next once Ask is tried: lives on History.
      final tried = {ProTrialFeature.ask};
      expect((_r(ProSuggestionPlace.history, t, tried: tried) as SlotSuggestion).feature,
          ProTrialFeature.sms);
      expect(_r(ProSuggestionPlace.home, t, tried: tried), isNull);
    });

    test('one new card per day: committed feature stays, no replacement', () {
      final t = activeTrial();
      final s = TrialSuggestionState(
          loaded: true, dayKey: trialDayKey(t.now), dayFeature: ProTrialFeature.ask);
      // Ask tried during the day: nothing else appears today.
      expect(_r(ProSuggestionPlace.home, t, tried: {ProTrialFeature.ask}, state: s), isNull);
      expect(_r(ProSuggestionPlace.history, t, tried: {ProTrialFeature.ask}, state: s), isNull);
    });

    test('dismiss hides that feature', () {
      final s = const TrialSuggestionState(loaded: true, dismissed: {ProTrialFeature.ask});
      expect((_r(ProSuggestionPlace.history, activeTrial(), state: s) as SlotSuggestion).feature,
          ProTrialFeature.sms);
    });

    test('hidden in the sheet session, for Pro and outside a trial', () {
      expect(_r(ProSuggestionPlace.home, activeTrial(), sheet: true), isNull);
      expect(_r(ProSuggestionPlace.home, activeTrial(), isPro: true), isNull);
      expect(_r(ProSuggestionPlace.home, endedTrial()), isNull);
      expect(_r(ProSuggestionPlace.home, eligibleTrial(), isPro: true), isNull);
    });

    test('day 12 and 14: Home shows the reminder card instead', () {
      final d12 = _r(ProSuggestionPlace.home, activeTrial(daysAgo: 11));
      expect(d12, isA<SlotReminder>());
      expect((d12 as SlotReminder).last, isFalse);
      expect((_r(ProSuggestionPlace.home, activeTrial(daysAgo: 13)) as SlotReminder).last, isTrue);
      // Other pages keep theirs: SMS (History) still offered.
      expect(_r(ProSuggestionPlace.history, activeTrial(daysAgo: 11), tried: {ProTrialFeature.ask}),
          isA<SlotSuggestion>());
    });

    test('eligible free user sees no slot card (the claim is a Home suggestion)', () {
      expect(_r(ProSuggestionPlace.home, eligibleTrial()), isNull);
    });
  });

  group('widgets', () {
    testWidgets('Home slot shows the Ask card, dismiss removes it', (t) async {
      await setView(t);
      await t.pumpWidget(trialApp(
          trial: activeTrial(), body: (_) => const ProSuggestionSlot(place: ProSuggestionPlace.home)));
      await t.pumpAndSettle();
      expect(find.text('Ask Kuber anything'), findsOneWidget);
      expect(find.text('PRO TRIAL · 0 OF 10 TRIED'), findsOneWidget);
      await t.tap(find.byTooltip('Dismiss'));
      await t.pumpAndSettle();
      expect(find.text('Ask Kuber anything'), findsNothing);
    });

    testWidgets('Pro user: no claim card, no suggestion', (t) async {
      await setView(t);
      await t.pumpWidget(trialApp(
          trial: eligibleTrial(),
          pro: paidPro(),
          body: (_) => const ProSuggestionSlot(place: ProSuggestionPlace.home)));
      await t.pumpAndSettle();
      expect(find.text('Claim 14 days of Pro, free'), findsNothing);
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('Home slot is empty in the sheet session', (t) async {
      TrialSession.sheetShown = true;
      await setView(t);
      await t.pumpWidget(trialApp(
          trial: activeTrial(), body: (_) => const ProSuggestionSlot(place: ProSuggestionPlace.home)));
      await t.pumpAndSettle();
      expect(find.text('Ask Kuber anything'), findsNothing);
    });

    testWidgets('checklist: tried first, then priority order; counts', (t) async {
      await ProTrialChecklist.markTried(ProTrialFeature.notes);
      await ProTrialChecklist.markTried(ProTrialFeature.sms);
      await setView(t, const Size(412, 1200));
      await t.pumpWidget(trialApp(
          trial: activeTrial(daysAgo: 5),
          body: (_) => openButton((c) => showTrialChecklistSheet(c))));
      await t.tap(find.text('open'));
      await t.pumpAndSettle();
      expect(find.text('2 of 10 tried · 9 days left'), findsOneWidget);
      final names = [for (final f in checklistOrder({ProTrialFeature.notes, ProTrialFeature.sms})) f];
      expect(names.take(3), [ProTrialFeature.sms, ProTrialFeature.notes, ProTrialFeature.ask]);
      expect(find.text('Tried · SMS imported'), findsOneWidget);
      expect(find.text('Try'), findsNWidgets(8));
      double y(String s) => t.getTopLeft(find.text(s)).dy;
      expect(y('Import from SMS') < y('Kuber Notes'), isTrue);
      expect(y('Kuber Notes') < y('Ask Kuber'), isTrue);
      expect(y('Ask Kuber') < y('Custom dashboards'), isTrue);
    });
  });
}
