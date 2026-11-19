// Separate file: PremiumHomeButton pulls main.dart (on-open gate) and with it
// the whole app, so a compile error elsewhere only breaks this file.
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/home/premium_home_button.dart';
import 'package:kuber/features/pro/paywall/billing_ui_state.dart';

import 'trial_ui_harness.dart';

void main() {
  setUp(() => resetTrialPrefs());
  group('badge', () {
    for (final (daysAgo, text) in [(0, 'Pro trial · 14 days left'), (13, 'Pro trial · last day')]) {
      testWidgets('badge day ${daysAgo + 1}', (t) async {
        await setView(t);
        await t.pumpWidget(trialApp(
          trial: activeTrial(daysAgo: daysAgo),
          overrides: [proBootstrapLoadingProvider.overrideWith((_) => false)],
          body: (_) => const PremiumHomeButton(),
        ));
        await t.pumpAndSettle();
        expect(find.text(text), findsOneWidget);
      });
    }

    testWidgets('badge for Pro user stays Pro User', (t) async {
      await setView(t);
      await t.pumpWidget(trialApp(
        trial: activeTrial(),
        pro: paidPro(),
        overrides: [proBootstrapLoadingProvider.overrideWith((_) => false)],
        body: (_) => const PremiumHomeButton(),
      ));
      await t.pumpAndSettle();
      expect(find.text('Pro User'), findsOneWidget);
      expect(find.textContaining('Pro trial'), findsNothing);
    });
  });
}
