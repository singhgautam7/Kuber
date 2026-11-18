import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/features/pro/trial/trial_suggestions.dart';
import 'package:kuber/features/pro/trial/widgets/trial_sheet.dart';
import 'package:kuber/features/pro/trial/widgets/trial_ended_sheet.dart';
import 'package:kuber/features/pro/trial/trial_checklist.dart';
import 'package:kuber/shared/widgets/kuber_comparison_table.dart';

import 'trial_ui_harness.dart';

Future<void> _open(WidgetTester t, TrialStartOutcome o, {TrialInfo? info}) async {
  await setView(t);
  await t.pumpWidget(trialApp(
    trial: info,
    body: (_) => openButton((c) => showTrialSheet(c, o)),
  ));
  await t.tap(find.text('open'));
  await t.pumpAndSettle();
}

void main() {
  setUp(() async {
    await resetTrialPrefs();
    TrialSession.sheetShown = false;
  });

  testWidgets('started: title, date, buttons, offers collapsed', (t) async {
    await _open(t, TrialStartOutcome.started);
    expect(find.text('Kuber Pro is yours for 14 days'), findsOneWidget);
    expect(find.text('Free until 2 Dec'), findsOneWidget);
    expect(find.text('Start exploring'), findsOneWidget);
    expect(find.text('See Kuber Pro'), findsOneWidget);
    expect(find.text('WHAT KUBER PRO OFFERS'), findsOneWidget);
    expect(find.byType(KuberComparisonTable).hitTestable(), findsNothing);
    expect(TrialSession.sheetShown, isTrue);
  });

  testWidgets('expand shows the Pro page table, collapse hides it', (t) async {
    await _open(t, TrialStartOutcome.started);
    await t.tap(find.text('WHAT KUBER PRO OFFERS'));
    await t.pumpAndSettle();
    expect(find.text('Advanced Analytics'), findsOneWidget);
    expect(find.byType(KuberComparisonTable).hitTestable(), findsOneWidget);
    await t.tap(find.text('WHAT KUBER PRO OFFERS'));
    await t.pumpAndSettle();
    expect(find.byType(KuberComparisonTable).hitTestable(), findsNothing);
  });

  testWidgets('continued: restored title and days left', (t) async {
    await _open(t, TrialStartOutcome.continued, info: activeTrial(daysAgo: 5));
    expect(find.text('Your Kuber Pro trial continues'), findsOneWidget);
    expect(find.text('9 days left · Free until 2 Dec'), findsNothing);
    expect(find.textContaining('9 days left'), findsOneWidget);
  });

  testWidgets('already used: no date block, See Kuber Pro + Not now', (t) async {
    await _open(t, TrialStartOutcome.alreadyUsed);
    expect(find.text('Your free trial was already used on this phone or backup'), findsOneWidget);
    expect(find.textContaining('Free until'), findsNothing);
    expect(find.text('See Kuber Pro'), findsOneWidget);
    expect(find.text('Not now'), findsOneWidget);
  });

  testWidgets('notEligible is a no-op', (t) async {
    await _open(t, TrialStartOutcome.notEligible);
    expect(find.text('WHAT KUBER PRO OFFERS'), findsNothing);
    expect(TrialSession.sheetShown, isFalse);
  });

  testWidgets('Start exploring closes; back closes when expanded', (t) async {
    await _open(t, TrialStartOutcome.started);
    await t.tap(find.text('Start exploring'));
    await t.pumpAndSettle();
    expect(find.text('Start exploring'), findsNothing);

    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    await t.tap(find.text('WHAT KUBER PRO OFFERS'));
    await t.pumpAndSettle();
    final nav = t.state<NavigatorState>(find.byType(Navigator));
    await nav.maybePop();
    await t.pumpAndSettle();
    expect(find.text('Start exploring'), findsNothing);
  });

  testWidgets('ended sheet: non-zero counts only, limits for tried features', (t) async {
    await resetTrialPrefs();
    await ProTrialChecklist.markTried(ProTrialFeature.sms);
    await setView(t);
    await t.pumpWidget(trialApp(
      trial: endedTrial(),
      overrides: [
        trialUsageProvider.overrideWith((_) async => const TrialUsage(sms: 42, asks: 11, notes: 0)),
      ],
      body: (_) => openButton((c) => showTrialEndedSheet(c)),
    ));
    await t.tap(find.text('open'));
    await t.pumpAndSettle();
    expect(find.text('Your Pro trial has ended'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('11'), findsOneWidget);
    expect(find.text('questions to Ask Kuber'), findsOneWidget);
    expect(find.text('notes written'), findsNothing);
    expect(find.text('5 per week'), findsOneWidget);
    expect(find.textContaining('Get Pro'), findsOneWidget);
  });
}
