// v7.0.0-b trial on a device (specs/v7.0.0-b/test-report.md, Part E trial).
// Run on an emulator that is allowed to lose its data (never Kuber_QA):
//   flutter test integration_test/trial_v7b_test.dart -d <id> --no-uninstall \
//     --dart-define=TRIAL_EXPECT=started|used|continued
// Fresh install expects "started"; after `pm clear` or uninstall + reinstall
// the Block Store record must make it "used".
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kuber/features/pro/trial/trial_state.dart';
import 'package:kuber/main.dart' as app;

import 'smoke_helpers.dart';

const _expect = String.fromEnvironment('TRIAL_EXPECT', defaultValue: 'started');

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  smokeTest('trial at the end of Welcome: $_expect', (t) async {
    app.main();
    await pumpUntil(t, find.text(en.obStartFresh), timeout: const Duration(seconds: 40));
    await tapText(t, en.obStartFresh);
    await pumpUntil(t, find.text(en.getStarted));
    await tapText(t, en.getStarted);
    await tapText(t, en.skip);
    await pumpUntil(t, find.byType(TextFormField));
    await t.enterText(find.byType(TextFormField).first, 'Gaurav');
    await settle(t);
    await tapText(t, en.homeV33TourNext);
    // Android 13+ only: the notifications page.
    for (var i = 0; i < 100; i++) {
      await t.pump(const Duration(milliseconds: 100));
      if (find.text(en.obNotifLater).evaluate().isNotEmpty ||
          find.text('Continue').evaluate().isNotEmpty ||
          find.text(en.obTermsCheck1).evaluate().isNotEmpty) {
        break;
      }
    }
    if (find.text(en.obNotifLater).evaluate().isNotEmpty) {
      await tapText(t, en.obNotifLater);
    } else if (find.text(en.obTermsCheck1).evaluate().isEmpty) {
      await tapText(t, 'Continue'); // below Android 13: no permission to ask
    }
    await tapText(t, en.obTermsCheck1);
    await tapText(t, en.obTermsCheck2);
    await tapText(t, en.obTermsAgree);
    final variant = await finishWelcome(t, onSheet: (v) {
      debugPrint('KUBER_SHOT trial/welcome-sheet-$v');
    });
    await settle(t, const Duration(seconds: 3));
    final info = container(t).read(proTrialProvider);
    debugPrint('KUBER_TRIAL variant=$variant status=${info.status} start=${info.startAt} '
        'end=${info.endAt} daysLeft=${info.daysLeft} eligible=${info.eligible}');
    debugPrint('KUBER_SHOT trial/home-after-$variant');
    await settle(t, const Duration(milliseconds: 1500));
    expect(variant, _expect);
    if (_expect == 'started') {
      expect(info.daysLeft, 14);
      expect(find.text(en.trialBadge('14')), findsWidgets);
    }
    expectNoErrors(t);
  });
}
