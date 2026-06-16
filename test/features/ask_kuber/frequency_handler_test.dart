import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/frequency_handler.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';

import '../../helpers/test_factories.dart';

void main() {
  const handler = FrequencyHandler();

  final categories = [
    makeCategory(id: 1, name: 'Food', colorValue: 0xFFEF4444),
    makeCategory(id: 2, name: 'Travel', colorValue: 0xFF3B82F6),
  ];
  // Three Swiggy orders + one Zomato, all this month (now = 15 Jun 2026).
  final txns = [
    makeTransaction(
        name: 'Swiggy', amount: 300, categoryId: '1', createdAt: DateTime(2026, 6, 2)),
    makeTransaction(
        name: 'Swiggy', amount: 400, categoryId: '1', createdAt: DateTime(2026, 6, 8)),
    makeTransaction(
        name: 'Swiggy', amount: 200, categoryId: '1', createdAt: DateTime(2026, 6, 12)),
    makeTransaction(
        name: 'Zomato', amount: 150, categoryId: '1', createdAt: DateTime(2026, 6, 5)),
    makeTransaction(
        name: 'Uber', amount: 100, categoryId: '2', createdAt: DateTime(2026, 6, 7)),
  ];

  QueryContext ctx(String raw) => QueryContext.forTest(
        raw: raw,
        txns: txns,
        categories: categories,
        now: DateTime(2026, 6, 15, 10),
      );

  test('counts a transaction name with total this month', () async {
    final r = await handler.tryHandle(ctx('how many times did I spend on Swiggy this month?'));
    expect(r, isNotNull);
    expect(r!.text, contains('3 times'));
    expect(r.text, contains('this month'));
    expect(r.text, contains('₹900'));
    expect(r.text, isNot(contains('*')));
  });

  test('counts a category and totals its transactions', () async {
    final r = await handler.tryHandle(ctx('how many transactions in Food this month?'));
    expect(r, isNotNull);
    // 3 Swiggy + 1 Zomato = 4 Food txns, ₹1,050.
    expect(r!.text, contains('4 Food transactions'));
    expect(r.text, contains('₹1,050'));
    expect(r.text, isNot(contains('*')));
  });

  test('how often phrasing works for a category', () async {
    final r = await handler.tryHandle(ctx('how often do I spend on Travel?'));
    expect(r, isNotNull);
    expect(r!.text, contains('Travel'));
  });

  test('unknown name returns a friendly no-match message', () async {
    final r = await handler.tryHandle(ctx('how many times did I spend on Netflix?'));
    expect(r, isNotNull);
    expect(r!.text, contains("couldn't find"));
    expect(r.text, contains('Netflix'));
  });

  test('generic count query falls through (returns null) to CountsHandler', () async {
    final r = await handler.tryHandle(ctx('how many transactions this month?'));
    expect(r, isNull);
  });

  test('non-frequency query is ignored', () async {
    final r = await handler.tryHandle(ctx('how much did I spend this month?'));
    expect(r, isNull);
  });
}
