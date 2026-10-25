import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/timed_snackbar.dart';

// Every state of the background-tasks snackbar (plan B: progress, swipe
// rules, user snackbar interruption, result, failure).
void main() {
  final key = GlobalKey<NavigatorState>();

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      navigatorKey: key,
      theme: AppTheme.light(const Locale('en')),
      home: const Scaffold(body: SizedBox.expand()),
    ));
  }

  Future<void> cleanUp(WidgetTester tester) async {
    KuberProgressSnackBar.hide();
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 1));
  }

  OverlayState overlay() => key.currentState!.overlay!;
  BuildContext ctx() => key.currentContext!;

  testWidgets('progress: spinner, no close, swipe does nothing', (tester) async {
    await pump(tester);
    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Adding 2 recurring transactions'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Adding 2 recurring transactions'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsNothing);

    await tester.fling(find.text('Adding 2 recurring transactions'), const Offset(400, 0), 2000);
    await tester.pump(const Duration(seconds: 10)); // no timer either
    expect(find.text('Adding 2 recurring transactions'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('backup after 5 s: detail line, close and swipe allowed', (tester) async {
    await pump(tester);
    var swiped = false;
    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Backing up'), onSwiped: () => swiped = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    KuberProgressSnackBar.update(
        const KuberProgressState('Backing up', detail: 'Continues in the background', dismissible: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('Continues in the background'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(swiped, isTrue);
    expect(find.text('Backing up'), findsNothing);
    expect(KuberProgressSnackBar.isActive, isFalse);
    await cleanUp(tester);
  });

  testWidgets('a user snackbar interrupts, then progress comes back', (tester) async {
    await pump(tester);
    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Backing up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    showKuberSnackBar(ctx(), 'Transaction saved');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Transaction saved'), findsOneWidget);
    expect(find.text('Backing up'), findsNothing);
    await tester.pump(const Duration(seconds: 7));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Transaction saved'), findsNothing);
    expect(find.text('Backing up'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('result: check icon, timer, View action', (tester) async {
    await pump(tester);
    var viewed = false;
    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Adding 1 recurring transaction'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    KuberProgressSnackBar.finish(ctx(), '2 recurring added · Backup done',
        actionLabel: 'View', onAction: () => viewed = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('2 recurring added · Backup done'), findsOneWidget);
    expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.tap(find.text('View'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(viewed, isTrue);
    await cleanUp(tester);
  });

  testWidgets('failure: error icon and Retry; empty result hides', (tester) async {
    await pump(tester);
    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Backing up'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    KuberProgressSnackBar.finish(ctx(), 'Backup failed', isError: true, actionLabel: 'Retry');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.error_rounded), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await cleanUp(tester);

    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Starting'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    KuberProgressSnackBar.finish(ctx(), '');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Starting'), findsNothing);
    await cleanUp(tester);
  });

  // Regression (specs/vcal/regressions.md R2): a snackbar shown over the
  // progress snackbar put the progress back into the old overlay after the app
  // was rebuilt (RestartWidget after a restore), which threw.
  testWidgets('progress is not restored into a disposed overlay', (tester) async {
    await pump(tester);
    KuberProgressSnackBar.show(overlay(), const KuberProgressState('Backing up'));
    await tester.pump(const Duration(milliseconds: 300));
    showKuberSnackBar(ctx(), 'Restored');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpWidget(const SizedBox()); // the app is rebuilt
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    expect(KuberProgressSnackBar.isActive, isFalse);
  });
}
