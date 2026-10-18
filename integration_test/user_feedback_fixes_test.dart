// On-device checks for specs/fixes/user-feedback-oct-2026.md.
// Run: flutter test integration_test/user_feedback_fixes_test.dart -d <emulator>
//
// Uses its own temporary Isar (name `itest`), never the app's database.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/categories/data/category_group.dart';
import 'package:kuber/features/recurring/data/recurring_interval.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/recurring/screens/add_recurring_screen.dart';
import 'package:kuber/features/recurring/widgets/recurring_detail_sheet.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/tags/data/transaction_tag.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Isar isar;

RecurringRule _rule(String name, int count, RecurrenceUnit unit) {
  final now = DateTime.now();
  return RecurringRule()
    ..name = name
    ..amount = 1250000
    ..type = 'expense'
    ..categoryId = '1'
    ..accountId = '1'
    ..frequency = 'custom'
    ..customDays = count
    ..intervalUnit = unit.name
    ..startDate = DateTime(now.year, now.month, now.day)
    ..nextDueAt = DateTime(now.year, now.month, now.day)
    ..endType = 'never'
    ..createdAt = now
    ..updatedAt = now;
}

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  (String, NumberSystem) currency = ('INR', NumberSystem.indian),
}) async {
  // settingsProvider reads SharedPreferences; keep the device's real prefs
  // out of it so each case sees exactly the currency it asks for.
  SharedPreferences.setMockInitialValues({
    PrefsKeys.currency: currency.$1,
    PrefsKeys.numberSystem: currency.$2.index,
  });
  await tester.pumpWidget(const SizedBox());
  await tester.pumpWidget(ProviderScope(
    overrides: [
      isarProvider.overrideWithValue(isar),
      bootNumberFormatProvider.overrideWithValue(currency),
    ],
    child: MaterialApp(
      theme: AppTheme.light(const Locale('en')),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  ));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('itest');
    isar = await Isar.open([
      TransactionSchema,
      CategorySchema,
      CategoryGroupSchema,
      AccountSchema,
      RecurringRuleSchema,
      TagSchema,
      TransactionTagSchema,
    ], directory: dir.path, name: 'itest');
    await isar.writeTxn(() async {
      await isar.categorys.put(Category()
        ..id = 1
        ..name = 'Rent'
        ..icon = 'home'
        ..colorValue = 0xFF3B82F6
        ..type = 'expense');
      await isar.accounts.put(Account()
        ..id = 1
        ..name = 'Bank'
        ..type = 'bank');
    });
  });

  testWidgets('editing a quarterly rule selects the Quarterly preset',
      (tester) async {
    final rule = _rule('Insurance', 3, RecurrenceUnit.month);
    await isar.writeTxn(() => isar.recurringRules.put(rule));
    await _pump(tester, AddRecurringScreen(existingRule: rule));

    await tester.ensureVisible(find.text('Quarterly'));
    await tester.pumpAndSettle();
    expect(find.text('Every 6 months'), findsOneWidget);
    expect(find.textContaining('then every 3 months'), findsOneWidget);
    // Custom inputs stay hidden for a preset.
    expect(find.byKey(const Key('recurring_custom_count')), findsNothing);
  });

  testWidgets('custom interval rejects 0 / empty and describes N units',
      (tester) async {
    await _pump(tester, const AddRecurringScreen());
    await tester.ensureVisible(find.text('Custom'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom'));
    await tester.pumpAndSettle();

    final field = find.byKey(const Key('recurring_custom_count'));
    expect(find.text('Enter a whole number of 1 or more'), findsOneWidget);
    await tester.enterText(field, '0');
    await tester.pumpAndSettle();
    expect(find.text('Enter a whole number of 1 or more'), findsOneWidget);

    await tester.enterText(field, '10');
    await tester.pumpAndSettle();
    expect(find.text('Enter a whole number of 1 or more'), findsNothing);
    expect(find.textContaining('then every 10 days'), findsOneWidget);

    await tester.enterText(field, '2');
    await tester.tap(find.text('weeks').last);
    await tester.pumpAndSettle();
    expect(find.textContaining('then every 2 weeks'), findsOneWidget);
  });

  testWidgets('recurring detail sheet follows the currency setting',
      (tester) async {
    final rule = _rule('Rent', 1, RecurrenceUnit.month);
    await isar.writeTxn(() => isar.recurringRules.put(rule));

    await _pump(tester, Scaffold(body: RecurringDetailSheet(rule: rule)),
        currency: ('USD', NumberSystem.international));
    expect(find.textContaining(r'$1,250,000'), findsWidgets);
    expect(find.textContaining('₹'), findsNothing);

    await _pump(tester, Scaffold(body: RecurringDetailSheet(rule: rule)));
    expect(find.textContaining('₹12,50,000'), findsWidgets);

    await _pump(tester, Scaffold(body: RecurringDetailSheet(rule: rule)),
        currency: ('EUR', NumberSystem.international));
    expect(find.textContaining('€1,250,000'), findsWidgets);
  });
}
