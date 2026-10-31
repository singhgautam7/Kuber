// Loan accuracy D3: the one background reporter.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/background/background_reporter.dart';
import 'package:kuber/core/router/app_router.dart';
import 'package:kuber/l10n/app_localizations.dart';

void main() {
  final r = BackgroundReporter.instance;
  var front = true;

  Future<void> host(WidgetTester t) async {
    r.reset();
    front = true;
    r.inForeground = () => front;
    await t.pumpWidget(MaterialApp(
      navigatorKey: rootNavigatorKey,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const Scaffold(body: SizedBox()),
    ));
  }

  Future<void> settle(WidgetTester t) async {
    await t.pump(const Duration(seconds: 2));
    await t.pump(const Duration(seconds: 6)); // the done snackbar's timer
  }

  testWidgets('a quick job goes straight to its result, with View', (t) async {
    await host(t);
    var opened = <int>[];
    r.openAdded = (ids) => opened = ids;
    final id = r.begin('Adding transactions…');
    await t.pump(const Duration(milliseconds: 100));
    r.finish(id, const BgOutcome('Added 3 transactions', transactionIds: [7, 8, 9]));
    await t.pump(const Duration(seconds: 1));
    expect(r.log, ['done: Added 3 transactions']);
    expect(find.text('Added 3 transactions'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 600)); // slides in
    await t.tap(find.text('View'));
    await t.pump(const Duration(milliseconds: 500)); // runs after the exit
    expect(opened, [7, 8, 9]);
    await settle(t);
  });

  testWidgets('a run that did nothing shows nothing', (t) async {
    await host(t);
    final id = r.begin('Catching up…');
    await t.pump(const Duration(milliseconds: 600)); // progress was shown
    r.finish(id, BgOutcome.none);
    await settle(t);
    expect(r.log.where((e) => e.startsWith('done')), isEmpty);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('jobs finishing close together are one message', (t) async {
    await host(t);
    final a = r.begin('Adding transactions…');
    final b = r.begin('Backing up…');
    await t.pump(const Duration(milliseconds: 500));
    r.finish(a, const BgOutcome('Added 5 transactions', transactionIds: [1]));
    await t.pump(const Duration(milliseconds: 300));
    r.finish(b, const BgOutcome('Backup saved'));
    await t.pump(const Duration(seconds: 1));
    expect(r.log.where((e) => e.startsWith('done')), ['done: Added 5 transactions · Backup saved']);
    await settle(t);
  });

  testWidgets('progress updates at most 4 times a second, only on change', (t) async {
    await host(t);
    final id = r.begin('Adding past EMIs…');
    await t.pump(const Duration(milliseconds: 450)); // shown
    // 1,000 updates over one second: every 1 ms, 0.1% each.
    for (var i = 0; i < 1000; i++) {
      r.progress(id, done: i, total: 1000);
      await t.pump(const Duration(milliseconds: 1));
    }
    final updates = r.log.where((e) => e.startsWith('progress')).length;
    expect(updates, lessThanOrEqualTo(1 + 5), reason: 'first show + 4 per second');
    // The same percentage again is not a new frame.
    final before = r.log.length;
    r.progress(id, done: 999, total: 1000);
    await t.pump(const Duration(milliseconds: 300));
    expect(r.log.length, before);
    r.finish(id, BgOutcome.none);
    await settle(t);
  });

  testWidgets('finishing in the background: no snackbar now or on return', (t) async {
    await host(t);
    final id = r.begin('Backing up…');
    await t.pump(const Duration(milliseconds: 500));
    front = false;
    r.finish(id, const BgOutcome('Backup saved'));
    await t.pump(const Duration(seconds: 2));
    front = true;
    await t.pump(const Duration(seconds: 2));
    expect(r.log.where((e) => e.startsWith('done')), isEmpty);
    await settle(t);
  });

  testWidgets('an error offers Details', (t) async {
    await host(t);
    await r
        .run<void>('Adding past EMIs…', (_) async => throw StateError('disk full'),
            outcome: (_) => BgOutcome.none)
        .catchError((_) {});
    await t.pump(const Duration(seconds: 1));
    expect(find.text('Details'), findsOneWidget);
    await t.pump(const Duration(milliseconds: 600)); // slides in
    await t.tap(find.text('Details'));
    await t.pump(const Duration(milliseconds: 500));
    await t.pump(const Duration(milliseconds: 500));
    expect(find.textContaining('disk full'), findsOneWidget);
    await t.tap(find.text('Got it'));
    await settle(t);
  });
}
