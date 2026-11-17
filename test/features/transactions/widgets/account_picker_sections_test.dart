import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/currency_data.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/accounts/providers/account_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/widgets/account_picker_sheet.dart';
import 'package:kuber/l10n/app_localizations.dart';

Account acc(String name, String type, {bool card = false}) => Account()
  ..id = name.hashCode
  ..name = name
  ..type = type
  ..isCreditCard = card;

void main() {
  testWidgets('accounts are sectioned: Cash, Bank, Credit cards, Overdraft',
      (t) async {
    final accounts = [
      acc('HDFC Card', 'bank', card: true),
      acc('OD', 'overdraft'),
      acc('HDFC Savings', 'bank'),
      acc('Axis', 'bank'),
    ];
    await t.pumpWidget(ProviderScope(
      overrides: [
        accountListProvider.overrideWithValue(AsyncData(accounts)),
        accountBalanceProvider.overrideWith((ref, id) async => 0),
        formatterProvider.overrideWithValue(
            AppFormatter(currency: currencyFromCode('INR'))),
      ],
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: AccountPickerSheet(selectedAccountId: null, onSelected: (_) {}),
        ),
      ),
    ));
    await t.pumpAndSettle();
    // No cash account: no Cash section.
    expect(find.text('CASH'), findsNothing);
    double y(String s) => t.getTopLeft(find.text(s)).dy;
    expect(y('BANK') < y('HDFC Savings'), isTrue);
    expect(y('Axis') < y('CREDIT CARDS'), isTrue);
    expect(y('CREDIT CARDS') < y('HDFC Card'), isTrue);
    expect(y('HDFC Card') < y('OVERDRAFT'), isTrue);
    expect(y('OVERDRAFT') < y('OD'), isTrue);
  });
}
