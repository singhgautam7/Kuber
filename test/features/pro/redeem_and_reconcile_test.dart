import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/pro/home/premium_home_button.dart';
import 'package:kuber/features/pro/paywall/billing_ui_state.dart';
import 'package:kuber/features/pro/paywall/pro_state.dart';
import 'package:kuber/features/pro/purchase_states/restore_purchases_flow.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  group('waitForReturnToApp (redeem: check when the user comes back)', () {
    testWidgets('completes after background then foreground', (tester) async {
      var returned = false;
      waitForReturnToApp().then((v) => returned = v);
      await tester.pump();

      // Opening the Play Store: the app goes to the background.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();
      expect(returned, isFalse);

      // Back in Kuber.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(returned, isTrue);
    });

    testWidgets('a resume without going to the background does not count',
        (tester) async {
      bool? result;
      waitForReturnToApp(timeout: const Duration(seconds: 1))
          .then((v) => result = v);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      expect(result, isNull);
      await tester.pump(const Duration(seconds: 2));
      expect(result, isFalse); // timed out, no check fired
    });
  });

  group('entitlement state', () {
    late Isar isar;
    setUpAll(() async => initialiseIsarForTests());
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => closeAndCleanIsar(isar));

    test('KuberProState has value equality', () {
      final at = DateTime(2026, 10, 1);
      expect(
        KuberProState.purchased(plan: ProPlan.yearly, activatedAt: at),
        KuberProState.purchased(plan: ProPlan.yearly, activatedAt: at),
      );
      expect(
        KuberProState.purchased(plan: ProPlan.yearly, activatedAt: at),
        isNot(KuberProState.purchased(plan: ProPlan.lifetime, activatedAt: at)),
      );
    });

    test('re-applying an unchanged purchase does not notify listeners', () {
      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);
      var notifications = 0;
      container.listen(kuberProStateProvider, (_, _) => notifications++);
      final notifier = container.read(kuberProStateProvider.notifier);

      final at = DateTime(2026, 10, 1);
      notifier.applyPurchase(plan: ProPlan.lifetime, activatedAt: at);
      expect(notifications, 1); // free -> Pro
      expect(container.read(kuberProStateProvider).isPro, isTrue);

      // What every resume reconcile does: the same purchase again.
      notifier.applyPurchase(plan: ProPlan.lifetime, activatedAt: at);
      notifier.applyPurchase(plan: ProPlan.lifetime, activatedAt: at);
      expect(notifications, 1);
    });
  });

  group('home header badge', () {
    late Isar isar;
    setUpAll(() async => initialiseIsarForTests());
    setUp(() async => isar = await openTestIsar());
    tearDown(() async => closeAndCleanIsar(isar));

    Future<void> pumpBadge(WidgetTester tester, {required bool pro}) async {
      final container = ProviderContainer(overrides: [
        isarProvider.overrideWithValue(isar),
        proBootstrapLoadingProvider.overrideWith((_) => false),
      ]);
      addTearDown(container.dispose);
      if (pro) {
        container
            .read(kuberProStateProvider.notifier)
            .applyPurchase(plan: ProPlan.lifetime);
      }
      await tester.pumpWidget(UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: Scaffold(body: PremiumHomeButton())),
      ));
      await tester.pumpAndSettle();
    }

    testWidgets('free user sees "Kuber Pro"', (tester) async {
      await pumpBadge(tester, pro: false);
      expect(find.text('Kuber Pro'), findsOneWidget);
    });

    testWidgets('Pro user sees "Pro User"', (tester) async {
      await pumpBadge(tester, pro: true);
      expect(find.text('Pro User'), findsOneWidget);
      expect(find.text('PRO'), findsNothing);
    });
  });
}
