import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/last_spent_handler.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';

import '../../helpers/test_factories.dart';

void main() {
  const handler = LastSpentHandler();

  final categories = [
    makeCategory(id: 1, name: 'Food', colorValue: 0xFFEF4444),
  ];
  final txns = [
    makeTransaction(
        name: 'Netflix', amount: 649, categoryId: '1', createdAt: DateTime(2026, 5, 24)),
    makeTransaction(
        name: 'Swiggy', amount: 320, categoryId: '1', createdAt: DateTime(2026, 6, 1)),
    makeTransaction(
        name: 'Swiggy', amount: 280, categoryId: '1', createdAt: DateTime(2026, 5, 10)),
  ];

  QueryContext ctx(String raw) => QueryContext.forTest(
        raw: raw,
        txns: txns,
        categories: categories,
        now: DateTime(2026, 6, 15, 10),
      );

  test('returns date and amount of the most recent name match', () async {
    final r = await handler.tryHandle(ctx('when did I last spend on Netflix?'));
    expect(r, isNotNull);
    expect(r!.text, contains('24 May 2026'));
    expect(r.text, contains('₹649'));
    expect(r.text, isNot(contains('*')));
  });

  test('category lookup returns most recent and names the merchant', () async {
    final r = await handler.tryHandle(ctx('when was my last Food transaction?'));
    expect(r, isNotNull);
    expect(r!.text, contains('1 Jun 2026'));
    expect(r.text, contains('₹320'));
    expect(r.text, contains('at Swiggy'));
  });

  test('offers a frequency follow-up chip bridging to Task 2', () async {
    final r = await handler.tryHandle(ctx('most recent Netflix order?'));
    expect(r, isNotNull);
    final chips = r!.followUps.whereType<AskChipAction>().toList();
    expect(chips.any((c) => c.query.contains('How many times')), isTrue);
  });

  test('no match returns a friendly message', () async {
    final r = await handler.tryHandle(ctx('when did I last spend on Spotify?'));
    expect(r, isNotNull);
    expect(r!.text, contains("couldn't find"));
    expect(r.text, contains('Spotify'));
  });

  test('explicit empty period suggests dropping the filter', () async {
    final r = await handler.tryHandle(ctx('when did I last spend on Netflix this month?'));
    expect(r, isNotNull);
    // Netflix was in May, not this month (June).
    expect(r!.text, contains('No Netflix transactions found this month'));
    expect(r.followUps.whereType<AskChipAction>(), isNotEmpty);
  });
}
