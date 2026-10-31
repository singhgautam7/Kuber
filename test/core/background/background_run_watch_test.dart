import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/background_reporter.dart';
import 'package:kuber/core/background/background_run_controller.dart';
import 'package:kuber/core/background/background_task_run.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/router/app_router.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/timed_snackbar.dart';

import '../../helpers/isar_test_helper.dart';

// The launch snackbar timing (plan B): nothing for 400 ms, a fast run goes
// straight to its result, a slow one shows progress first. Results go
// through the one background reporter (loan accuracy D3), which waits a
// moment to combine jobs that finish close together.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Isar isar;

  setUpAll(() async {
    await initialiseIsarForTests();
    isar = await openTestIsar();
  });
  tearDownAll(() => closeAndCleanIsar(isar));

  BackgroundTaskRun run(String status, {String step = 'processing', int posted = 0, int total = 0}) =>
      BackgroundTaskRun()
        ..runId = 'r1'
        ..trigger = 'coldStart'
        ..startedAt = DateTime.now()
        ..heartbeatAt = DateTime.now()
        ..status = status
        ..step = step
        ..stepTotal = total
        ..postedRecurring = posted
        ..backupStatus = 'notDue';

  Future<ProviderContainer> setUp(WidgetTester tester, BackgroundTaskRun first) async {
    BackgroundReporter.instance
      ..reset()
      ..inForeground = () => true;
    await tester.runAsync(() async {
      await isar.writeTxn(() async {
        await isar.backgroundTaskRuns.clear();
        await isar.backgroundTaskRuns.put(first);
      });
    });
    final c = ProviderContainer(overrides: [isarProvider.overrideWithValue(isar)]);
    addTearDown(c.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: MaterialApp(
        navigatorKey: rootNavigatorKey,
        theme: AppTheme.light(const Locale('en')),
        home: const Scaffold(body: SizedBox.expand()),
      ),
    ));
    c.read(backgroundRunWatchProvider.notifier).watchFrom(DateTime.now());
    return c;
  }

  // Renders (the watch reads Isar synchronously; slide-in needs two frames).
  Future<void> settleIsar(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> cleanUp(WidgetTester tester) async {
    KuberProgressSnackBar.hide();
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 1));
    // Let the watch's own async write (resultShown) finish so it doesn't hold
    // Isar's write lock into the next test or tearDownAll.
    await drainIsarWrites(tester, isar);
  }

  testWidgets('a run done within 400 ms shows only its result', (tester) async {
    await setUp(tester, run('done', step: 'done', posted: 2));
    await settleIsar(tester);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    await tester.pump(BackgroundReporter.combineWindow);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Added 2 transactions'), findsOneWidget);
    expect(find.text('View'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('a slow run: hidden first, progress after 400 ms, then result', (tester) async {
    final r = run('running', total: 2);
    await setUp(tester, r);
    await settleIsar(tester);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byType(CircularProgressIndicator), findsNothing); // < 400 ms

    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 300));
    // Step text, with the share done once there is one.
    expect(find.textContaining('Adding 2 recurring transactions…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.runAsync(() => isar.writeTxn(() => isar.backgroundTaskRuns.put(r
      ..status = 'done'
      ..step = 'done'
      ..postedRecurring = 2
      ..finishedAt = DateTime.now())));
    await tester.pump(const Duration(seconds: 1)); // poll
    await settleIsar(tester);
    await tester.pump(BackgroundReporter.combineWindow);
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Added 2 transactions'), findsOneWidget);
    await cleanUp(tester);
  });

  testWidgets('nothing done: no snackbar at all', (tester) async {
    await setUp(tester, run('done', step: 'done'));
    await settleIsar(tester);
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    await cleanUp(tester);
  });
}
