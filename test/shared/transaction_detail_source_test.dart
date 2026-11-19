// v7.0.0-b: the transaction sheet's Source row and the SourceLinkButton.
// Goldens: flutter test --update-goldens test/shared/transaction_detail_source_test.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/core/database/seed_service.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/features/investments/data/investment.dart';
import 'package:kuber/features/investments/providers/investment_provider.dart';
import 'package:kuber/features/loans/data/loan.dart';
import 'package:kuber/features/loans/providers/loan_provider.dart';
import 'package:kuber/features/recurring/data/recurring_rule.dart';
import 'package:kuber/features/recurring/providers/recurring_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/money_widgets.dart';
import 'package:kuber/shared/widgets/transaction_detail_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/golden_fonts.dart';
import '../helpers/isar_test_helper.dart';

class _Loan implements Loan {
  _Loan(this.uid, this.name);
  @override
  final String uid;
  @override
  final String name;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Inv implements Investment {
  _Inv(this.uid, this.name);
  @override
  final String uid;
  @override
  final String name;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Rule implements RecurringRule {
  _Rule(this.id, this.name);
  @override
  final int id;
  @override
  final String name;
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Loans extends LoanListNotifier {
  @override
  FutureOr<List<Loan>> build() => [_Loan('L1', 'Home loan'), _Loan('L2', _long)];
}

class _Invs extends InvestmentListNotifier {
  @override
  FutureOr<List<Investment>> build() => [_Inv('I1', 'Index fund SIP')];
}

class _Rules extends RecurringListNotifier {
  @override
  FutureOr<List<RecurringRule>> build() => [_Rule(7, 'Netflix')];
}

const _long = 'Extremely long loan name for the housing finance corporation of India';

late Isar _isar;

Transaction _txn(void Function(Transaction t) f) {
  final t = Transaction()
    ..name = 'EMI - Home loan'
    ..nameLower = 'emi'
    ..amount = 18450
    ..type = 'expense'
    ..categoryId = '1'
    ..accountId = '1'
    ..createdAt = DateTime(2026, 10, 5, 9, 30)
    ..updatedAt = DateTime(2026, 10, 5, 9, 30);
  f(t);
  return t;
}

Future<void> _open(WidgetTester t, Transaction txn,
    {double scale = 1, ThemeData? theme, Brightness b = Brightness.light}) async {
  t.view.physicalSize = const Size(412, 892);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  final c = ProviderContainer(overrides: [
    isarProvider.overrideWithValue(_isar),
    loanListProvider.overrideWith(_Loans.new),
    investmentListProvider.overrideWith(_Invs.new),
    recurringListProvider.overrideWith(_Rules.new),
  ]);
  addTearDown(c.dispose);
  await t.runAsync(() async {
    await SharedPreferences.getInstance();
    await c.read(settingsProvider.future);
  });
  await t.pumpWidget(UncontrolledProviderScope(
    container: c,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme ??
          (b == Brightness.dark
              ? AppTheme.dark(const Locale('en'), ThemeVariant.signature)
              : AppTheme.light(const Locale('en'), ThemeVariant.signature)),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Consumer(
        builder: (context, ref, _) => Scaffold(
          body: Center(
            child: TextButton(
                onPressed: () => showTransactionDetailSheet(context, ref, txn),
                child: const Text('open')),
          ),
        ),
      ),
    ),
  ));
  await t.tap(find.text('open'));
  for (var i = 0; i < 6; i++) {
    await t.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 30)));
    await t.pump(const Duration(milliseconds: 150));
  }
  await settleFonts(t);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  setUpAll(() async {
    await initialiseIsarForTests();
    await loadGoldenFonts();
    _isar = await openTestIsar();
    await SeedService().seedInitialData(_isar);
  });

  Transaction loan([String id = 'L1']) => _txn((t) => t
    ..sourceType = 'loan'
    ..sourceId = id
    ..linkedRuleType = 'loan'
    ..linkedRuleId = id
    ..occurrenceDate = 20261005);
  Transaction inv() => _txn((t) => t
    ..name = 'Contribution - Index fund SIP'
    ..sourceType = 'investment'
    ..sourceId = 'I1'
    ..linkedRuleType = 'investment'
    ..linkedRuleId = 'I1'
    ..occurrenceDate = 20261005);
  Transaction rec([String id = '7']) => _txn((t) => t
    ..name = 'Netflix'
    ..sourceType = 'recurring'
    ..sourceId = id
    ..linkedRuleType = 'recurring'
    ..linkedRuleId = id
    ..occurrenceDate = 20261005);

  void expectButtonBelowTable(WidgetTester t, String label) {
    final btn = find.byType(SourceLinkButton);
    expect(btn, findsOneWidget);
    expect(find.descendant(of: btn, matching: find.text(label)), findsOneWidget);
    final table = t.getRect(find.text('Source').first);
    expect(t.getTopLeft(btn).dy, greaterThan(table.bottom));
  }

  testWidgets('loan EMI', (t) async {
    await _open(t, loan());
    expect(find.text('Auto-recorded from loans'), findsOneWidget);
    expectButtonBelowTable(t, 'From Home loan');
    expect(find.text('From Home loan'), findsOneWidget);
  });

  testWidgets('investment', (t) async {
    await _open(t, inv());
    expect(find.text('Auto-recorded from investments'), findsOneWidget);
    expect(find.text('SIP installment'), findsNothing);
    expectButtonBelowTable(t, 'From Index fund SIP');
  });

  testWidgets('recurring', (t) async {
    await _open(t, rec());
    expect(find.text('Auto-recorded from recurring'), findsOneWidget);
    expectButtonBelowTable(t, 'From Netflix');
  });

  for (final (name, txn, text) in <(String, Transaction Function(), String)>[
    ('loan', () => loan('gone'), 'Auto-recorded from a deleted loan'),
    ('investment', () => inv()..sourceId = 'gone'..linkedRuleId = 'gone',
        'Auto-recorded from a deleted investment'),
    ('recurring', () => rec('99'), 'Auto-recorded from a deleted recurring payment'),
  ]) {
    testWidgets('deleted $name source', (t) async {
      await _open(t, txn());
      expect(find.text(text), findsOneWidget);
      expect(find.byType(SourceLinkButton), findsNothing);
    });
  }

  testWidgets('SMS keeps its text', (t) async {
    await _open(t, _txn((x) => x.importSource = 'sms'));
    expect(find.textContaining('Auto-recorded'), findsNothing);
    expect(find.byType(SourceLinkButton), findsNothing);
    expect(find.text('SMS import'), findsOneWidget);
  });

  testWidgets('manual keeps its text', (t) async {
    await _open(t, _txn((x) => x));
    expect(find.textContaining('Auto-recorded'), findsNothing);
    expect(find.byType(SourceLinkButton), findsNothing);
  });

  testWidgets('largest font, long name: no overflow, two lines max', (t) async {
    await _open(t, loan('L2'), scale: 2.0);
    expect(t.takeException(), isNull);
    final btn = find.byType(SourceLinkButton);
    expect(btn, findsOneWidget);
    expect(t.getSize(btn).height, lessThan(160));
    await expectLater(find.byType(MaterialApp),
        matchesGoldenFile('../goldens/v7b/txn_sheet/loan_long_large_font.png'));
  });

  for (final b in Brightness.values) {
    testWidgets('golden loan EMI ${b.name}', (t) async {
      await _open(t, loan(), b: b);
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../goldens/v7b/txn_sheet/loan_${b.name}.png'));
    });
    testWidgets('golden recurring ${b.name}', (t) async {
      await _open(t, rec(), b: b);
      await expectLater(find.byType(MaterialApp),
          matchesGoldenFile('../goldens/v7b/txn_sheet/recurring_${b.name}.png'));
    });
  }
}
