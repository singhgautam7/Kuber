import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/trial/trial_checklist.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final kNow = DateTime(2026, 11, 18, 12);

/// Active trial that started [daysAgo] days before [kNow] (0 = day 1).
TrialInfo activeTrial({int daysAgo = 0}) {
  final start = DateTime(2026, 11, 18 - daysAgo, 10);
  return TrialInfo(
    status: TrialStatus.active,
    now: kNow,
    startAt: start,
    endAt: start.add(kTrialLength),
  );
}

TrialInfo endedTrial() {
  final start = DateTime(2026, 11, 1, 10);
  return TrialInfo(
    status: TrialStatus.ended,
    now: kNow,
    startAt: start,
    endAt: start.add(kTrialLength),
  );
}

TrialInfo eligibleTrial() => TrialInfo(status: TrialStatus.none, now: kNow, eligible: true);

class FakeTrial extends ProTrialNotifier {
  FakeTrial(this.info, [this.outcome = TrialStartOutcome.started]);
  final TrialInfo info;
  final TrialStartOutcome outcome;
  int claims = 0;
  @override
  TrialInfo build() => info;
  @override
  Future<TrialStartOutcome> claim() async {
    claims++;
    return outcome;
  }

  @override
  Future<void> markEndedNoticeShown() async {}
}

class FakePro extends KuberProStateNotifier {
  FakePro(this.value);
  final KuberProState value;
  @override
  KuberProState build() => value;
}

KuberProState paidPro() => KuberProState.purchased(plan: ProPlan.yearly);

Future<void> resetTrialPrefs([Map<String, Object> values = const {}]) async {
  SharedPreferences.setMockInitialValues(values);
  ProTrialChecklist.reset();
}

/// A Scaffold with one button that runs [onTap] (opens a sheet / card).
Widget trialApp({
  required Widget Function(BuildContext) body,
  TrialInfo? trial,
  FakeTrial? fakeTrial,
  KuberProState pro = const KuberProState(),
  List<Override> overrides = const [],
  ThemeData? theme,
  double textScale = 1,
  MotionLevel level = MotionLevel.off,
}) {
  return ProviderScope(
    overrides: [
      proTrialProvider.overrideWith(() => fakeTrial ?? FakeTrial(trial ?? activeTrial())),
      kuberProStateProvider.overrideWith(() => FakePro(pro)),
      ...overrides,
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: MotionScope(level: level, systemOff: false, child: child!),
      ),
      home: Scaffold(body: Builder(builder: body)),
    ),
  );
}

Widget openButton(void Function(BuildContext) open) => Builder(
      builder: (c) => TextButton(onPressed: () => open(c), child: const Text('open')),
    );

Future<void> setView(WidgetTester t, [Size size = const Size(412, 892)]) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
}
