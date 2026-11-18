import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/features/dashboard/widgets/balance_hero_card.dart';
import 'package:kuber/shared/widgets/animated_amount.dart';

import 'balance_card_harness.dart';

Finder _amount(String s) =>
    find.descendant(of: find.byType(AnimatedAmount), matching: find.text(s));

Future<void> _tap(WidgetTester t, String key) async {
  await t.tap(find.byKey(Key(key)));
  await t.pumpAndSettle();
}

void main() {
  testWidgets('rest: net, + and - legend', (t) async {
    await pumpBalance(t, balanceApp());
    expect(find.text('NET'), findsOneWidget);
    expect(_amount('−₹33,014'), findsOneWidget);
    expect(find.text('+₹11,000'), findsOneWidget);
    expect(find.text('−₹44,014'), findsOneWidget);
  });

  testWidgets('focus expense, then back by tapping the same part', (t) async {
    await pumpBalance(t, balanceApp());
    await _tap(t, 'balBarExpense');
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(_amount('−₹44,014'), findsOneWidget);
    expect(find.text('Spending ₹6,200 more than last month'), findsOneWidget);
    await _tap(t, 'balBarExpense');
    expect(find.text('NET'), findsOneWidget);
    expect(_amount('−₹33,014'), findsOneWidget);
  });

  testWidgets('focus income through its number, switch directly to expense', (t) async {
    await pumpBalance(t, balanceApp());
    await _tap(t, 'balNumIncome');
    expect(find.text('INCOME'), findsOneWidget);
    expect(_amount('+₹11,000'), findsOneWidget);
    expect(find.text('Earnings ₹4,000 less than last month'), findsOneWidget);
    await _tap(t, 'balBarExpense'); // no stop at net
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(find.text('NET'), findsNothing);
    expect(_amount('−₹44,014'), findsOneWidget);
  });

  testWidgets('tap outside returns to net and the outside button still fires', (t) async {
    await pumpBalance(t, balanceApp());
    await _tap(t, 'balBarIncome');
    expect(find.text('INCOME'), findsOneWidget);
    await t.tap(find.text('other'));
    await t.pumpAndSettle();
    expect(balTaps, 1);
    expect(find.text('NET'), findsOneWidget);
  });

  testWidgets('scrolling the page returns to net', (t) async {
    await pumpBalance(t, balanceApp());
    await _tap(t, 'balBarExpense');
    await t.drag(find.byType(ListView), const Offset(0, -120));
    await t.pumpAndSettle();
    expect(find.text('NET'), findsOneWidget);
  });

  testWidgets('comparison: same, first month, spending less', (t) async {
    await pumpBalance(t, balanceApp(summary: balSummary(prevExpense: 44014)));
    await _tap(t, 'balBarExpense');
    expect(find.text('Same as last month'), findsOneWidget);

    await pumpBalance(t, balanceApp(summary: balSummary(hasEarlier: false)));
    await _tap(t, 'balBarIncome');
    expect(find.text('First month in Kuber'), findsOneWidget);

    // Earlier data, but nothing of that kind last month: no "more than".
    await pumpBalance(t, balanceApp(summary: balSummary(prevIncome: 0)));
    await _tap(t, 'balBarIncome');
    expect(find.text('No earnings last month'), findsOneWidget);
    await pumpBalance(t, balanceApp(summary: balSummary(prevExpense: 0)));
    await _tap(t, 'balBarExpense');
    expect(find.text('No spending last month'), findsOneWidget);

    await pumpBalance(t, balanceApp(summary: balSummary(prevExpense: 50000)));
    await _tap(t, 'balBarExpense');
    expect(find.text('Spending ₹5,986 less than last month'), findsOneWidget);

    await pumpBalance(t, balanceApp(summary: balSummary(prevIncome: 9000)));
    await _tap(t, 'balBarIncome');
    expect(find.text('Earnings ₹2,000 more than last month'), findsOneWidget);
  });

  testWidgets('privacy mode masks every amount and focus still works', (t) async {
    await pumpBalance(t, balanceApp(privacy: true));
    expect(find.textContaining('₹'), findsNothing);
    await _tap(t, 'balBarExpense');
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(find.textContaining('₹'), findsNothing);
    expect(find.text('Spending **** more than last month'), findsOneWidget);
    expect(find.bySemanticsLabel('Show income, ****'), findsOneWidget);
  });

  testWidgets('semantics: parts are buttons with amounts', (t) async {
    await pumpBalance(t, balanceApp());
    expect(find.bySemanticsLabel('Show expense, ₹44,014'), findsWidgets);
    expect(find.bySemanticsLabel('Show income, ₹11,000'), findsWidgets);
  });

  testWidgets('card height is identical at rest and focused (largest font, 360 x 640)', (t) async {
    await pumpBalance(t, balanceApp(textScale: 2), size: const Size(360, 640));
    final rest = t.getSize(find.byType(BalanceHeroCard)).height;
    await _tap(t, 'balBarExpense');
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(t.getSize(find.byType(BalanceHeroCard)).height, rest);
    await _tap(t, 'balBarIncome');
    expect(t.getSize(find.byType(BalanceHeroCard)).height, rest);
  });

  testWidgets('card height is identical at the default font too', (t) async {
    await pumpBalance(t, balanceApp());
    final rest = t.getSize(find.byType(BalanceHeroCard)).height;
    await _tap(t, 'balBarExpense');
    expect(t.getSize(find.byType(BalanceHeroCard)).height, rest);
  });

  testWidgets('a transaction added while focused keeps focus and updates in place', (t) async {
    await pumpBalance(t, balanceApp());
    await _tap(t, 'balBarExpense');
    final c = ProviderScope.containerOf(t.element(find.byType(BalanceHeroCard)));
    c.read(balSrc.notifier).state = balSummary(expense: 46014);
    await t.pump(); // reload starts: previous value stays, no skeleton
    expect(find.byKey(const Key('balSkeleton')), findsNothing);
    expect(find.byType(BalanceHeroCard), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('EXPENSE'), findsOneWidget);
    expect(_amount('−₹46,014'), findsOneWidget);
    expect(find.text('Spending ₹8,200 more than last month'), findsOneWidget);
  });

  testWidgets('focus causes no provider rebuild', (t) async {
    await pumpBalance(t, balanceApp());
    final before = balEvals;
    expect(before, 1);
    await _tap(t, 'balBarExpense');
    await _tap(t, 'balBarExpense'); // back to net
    await _tap(t, 'balNumIncome');
    await _tap(t, 'balBarIncome');
    expect(balEvals, before);
  });

  testWidgets('Subtle and Off still focus', (t) async {
    for (final l in [MotionLevel.subtle, MotionLevel.off]) {
      await pumpBalance(t, balanceApp(level: l));
      await _tap(t, 'balBarExpense');
      expect(find.text('EXPENSE'), findsOneWidget);
      expect(_amount('−₹44,014'), findsOneWidget);
      await _tap(t, 'balBarExpense');
      expect(find.text('NET'), findsOneWidget);
    }
  });
}
