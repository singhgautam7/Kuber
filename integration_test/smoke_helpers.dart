// Helpers for the full-app smoke suite (integration_test/smoke_test.dart).
// The suite runs the real app (main.dart) on a device against a fresh install;
// each test boots the app again on the same database.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/router/app_router.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/l10n/app_localizations_en.dart';
import 'package:kuber/main.dart' as app;
import 'package:kuber/shared/widgets/app_scaffold.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'dart:math';

final en = AppLocalizationsEn();

Isar get db => Isar.getInstance()!;

/// Pumps frames until [finder] matches (the app has endless animations, so
/// pumpAndSettle is not usable).
Future<void> pumpUntil(WidgetTester t, Finder finder,
    {Duration timeout = const Duration(seconds: 20), String? reason}) async {
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 100));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for ${reason ?? finder}');
}

/// Pumps for [d] of wall time (lets async work and animations run).
Future<void> settle(WidgetTester t, [Duration d = const Duration(milliseconds: 800)]) async {
  final end = DateTime.now().add(d);
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 50));
  }
}

/// Boots the app (main.dart) and waits for the tab shell.
Future<void> boot(WidgetTester t) async {
  app.main();
  await pumpUntil(t, find.byType(AppScaffold), timeout: const Duration(seconds: 40),
      reason: 'Home after boot');
  await settle(t, const Duration(seconds: 2));
}

ProviderContainer container(WidgetTester t) =>
    ProviderScope.containerOf(t.element(find.byType(MaterialApp).first));

Future<void> go(WidgetTester t, String path) async {
  container(t).read(routerProvider).go(path);
  await settle(t);
}

Future<void> push(WidgetTester t, String path, {Object? extra}) async {
  container(t).read(routerProvider).push(path, extra: extra);
  await settle(t);
}

Future<void> back(WidgetTester t) async {
  final router = container(t).read(routerProvider);
  if (router.canPop()) router.pop();
  await settle(t);
}

/// The l10n of the running app (locale may change during the suite).
AppLocalizations l10n(WidgetTester t) =>
    AppLocalizations.of(t.element(find.byType(Scaffold).last))!;

Future<void> tapText(WidgetTester t, String text, {bool last = false}) async {
  final f = find.text(text);
  await pumpUntil(t, f, reason: '"$text"');
  final target = last ? f.last : f.first;
  await t.ensureVisible(target);
  await t.pump();
  await t.tap(target, warnIfMissed: false);
  await settle(t);
}

Future<void> tapFinder(WidgetTester t, Finder f, {String? reason}) async {
  await pumpUntil(t, f, reason: reason);
  await t.ensureVisible(f.first);
  await t.pump();
  await t.tap(f.first, warnIfMissed: false);
  await settle(t);
}

Future<void> expectText(WidgetTester t, String text, {Duration? timeout}) =>
    pumpUntil(t, find.textContaining(text), timeout: timeout ?? const Duration(seconds: 15),
        reason: '"$text"');

/// Fails the test on any framework error (overflow, build error) seen so far.
void expectNoErrors(WidgetTester t) {
  final e = t.takeException();
  if (e != null) fail('Framework error: $e');
}

/// testWidgets that also prints each framework error the moment it happens,
/// while the tree is alive (the framework prints after teardown, when the
/// creator chain of an overflowing widget is already gone).
void smokeTest(String name, Future<void> Function(WidgetTester t) body) {
  testWidgets(name, (t) async {
    final original = FlutterError.onError;
    FlutterError.onError = (details) {
      debugPrint('SMOKE ERROR in "$name":\n${details.toString()}');
      original?.call(details);
    };
    addTearDown(() => FlutterError.onError = original);
    await body(t);
  });
}

/// Debug aid: prints every visible Text on screen.
void dumpTexts(WidgetTester t, [String tag = '']) {
  final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data ?? '').where((s) => s.isNotEmpty);
  debugPrint('SMOKE TEXTS $tag: ${texts.join(' | ')}');
}

/// Enters [text] into the text field that sits under the label [label]
/// (Kuber form fields draw their label as a Text above the field).
Future<void> enterField(WidgetTester t, String label, String text) async {
  final labelFinder = find.text(label);
  await pumpUntil(t, labelFinder, reason: 'field "$label"');
  await t.ensureVisible(labelFinder.first);
  await t.pump();
  final top = t.getTopLeft(labelFinder.first);
  Element? best;
  var bestDy = double.infinity;
  for (final e in find.byType(EditableText).evaluate()) {
    final r = e.renderObject;
    if (r is! RenderBox || !r.attached) continue;
    final p = r.localToGlobal(Offset.zero);
    final dy = p.dy - top.dy;
    if (dy >= -4 && dy < bestDy) {
      bestDy = dy;
      best = e;
    }
  }
  if (best == null) fail('No field under "$label"');
  final field = find.byElementPredicate((e) => identical(e, best));
  await t.tap(field, warnIfMissed: false);
  await t.pump();
  await t.enterText(field, text);
  await settle(t, const Duration(milliseconds: 300));
}

Future<void> hideKeyboard(WidgetTester t) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await settle(t, const Duration(milliseconds: 400));
}

/// Scrolls the main list until [text] is built, then taps it.
Future<void> tapTextScroll(WidgetTester t, String text) async {
  final f = find.text(text);
  if (f.evaluate().isEmpty) {
    await t.scrollUntilVisible(f, 250, scrollable: find.byType(Scrollable).first,
        maxScrolls: 60);
  }
  await tapText(t, text);
}

/// Picks [name] in the category picker sheet (a lazy grid): search, then tap.
Future<void> pickCategory(WidgetTester t, String name) async {
  final search = find.widgetWithText(TextField, en.searchCategories);
  await pumpUntil(t, search, reason: 'category search');
  await t.enterText(search, name);
  await settle(t);
  await tapText(t, name, last: true);
}

/// Closes the "About this screen" sheet that landing pages open on first visit.
Future<void> dismissInfo(WidgetTester t) async {
  await settle(t, const Duration(milliseconds: 600));
  final done = find.text('Done');
  if (done.evaluate().isNotEmpty) {
    await t.tap(done.last, warnIfMissed: false);
    await settle(t);
  }
}

/// A context under the root navigator, for opening sheets directly.
BuildContext rootContext(WidgetTester t) => rootNavigatorKey.currentContext!;

const kTxns = 20000;
const kYears = 7;

/// Seeds the 20,000 transaction / 7 year perf ledger once (v7.0.0, v7.0.0-b).
Future<void> seedLargeLedger() async {
  final isar = db;
  final count = await isar.transactions.count();
  if (count >= kTxns) return;
  final cats = await isar.categorys.where().findAll();
  final accs = await isar.accounts.where().findAll();
  final rnd = Random(7);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 365 * kYears));
  final spanMin = now.difference(start).inMinutes;
  const names = ['Swiggy', 'Uber', 'Amazon', 'Rent', 'Salary', 'Groceries', 'Fuel',
    'Netflix', 'Pharmacy', 'Coffee', 'Electricity', 'Zomato', 'Flipkart', 'Gym'];
  final batch = <Transaction>[];
  for (var i = 0; i < kTxns - count; i++) {
    final at = start.add(Duration(minutes: rnd.nextInt(spanMin)));
    final income = rnd.nextInt(10) == 0;
    final name = income ? 'Salary' : names[rnd.nextInt(names.length)];
    batch.add(Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = income ? 40000 + rnd.nextInt(60000).toDouble() : 20 + rnd.nextInt(5000).toDouble()
      ..type = income ? 'income' : 'expense'
      ..categoryId = cats[rnd.nextInt(cats.length)].id.toString()
      ..accountId = accs[rnd.nextInt(accs.length)].id.toString()
      ..createdAt = at
      ..updatedAt = at);
  }
  for (var i = 0; i < batch.length; i += 2000) {
    await isar.writeTxn(() => isar.transactions.putAll(batch.sublist(i, min(i + 2000, batch.length))));
  }
}


/// End of Welcome (v7.0.0-b): the trial sheet opens over the last setup step.
/// Returns which variant showed ('started', 'continued', 'used' or 'none'),
/// closes it and waits for Home.
Future<String> finishWelcome(WidgetTester t, {void Function(String variant)? onSheet}) async {
  final started = find.text(en.trialSheetTitle);
  final continued = find.text(en.trialRestoredTitle);
  final used = find.text(en.trialUsedTitle);
  final end = DateTime.now().add(const Duration(seconds: 30));
  var variant = 'none';
  while (DateTime.now().isBefore(end)) {
    await t.pump(const Duration(milliseconds: 100));
    if (started.evaluate().isNotEmpty) { variant = 'started'; break; }
    if (continued.evaluate().isNotEmpty) { variant = 'continued'; break; }
    if (used.evaluate().isNotEmpty) { variant = 'used'; break; }
    if (find.byType(AppScaffold).evaluate().isNotEmpty) break;
  }
  if (variant != 'none') {
    await settle(t, const Duration(milliseconds: 1500));
    onSheet?.call(variant);
    await tapText(t, variant == 'used' ? en.commonNotNow : en.trialSheetCta);
  }
  await pumpUntil(t, find.byType(AppScaffold), timeout: const Duration(seconds: 30));
  return variant;
}
