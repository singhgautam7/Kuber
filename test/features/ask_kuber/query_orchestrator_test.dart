import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';
import 'package:kuber/features/ask_kuber/models/viz_payload.dart';
import 'package:kuber/features/ask_kuber/services/query_orchestrator.dart';

import '../../helpers/test_factories.dart';

void main() {
  final orchestrator = QueryOrchestrator.standard();

  final categories = [
    makeCategory(id: 1, name: 'Food', colorValue: 0xFFEF4444),
    makeCategory(id: 2, name: 'Travel', colorValue: 0xFF3B82F6),
  ];
  final txns = [
    makeTransaction(
        amount: 300, type: 'expense', categoryId: '1', createdAt: DateTime(2026, 6, 10)),
    makeTransaction(
        amount: 100, type: 'expense', categoryId: '2', createdAt: DateTime(2026, 6, 12)),
  ];

  QueryContext ctx(String raw) => QueryContext.forTest(
        raw: raw,
        txns: txns,
        categories: categories,
        now: DateTime(2026, 6, 15, 10),
      );

  test('conversational greeting wins over data handlers', () async {
    final r = await orchestrator.process(ctx('hi'));
    expect(r.thinking, isNull); // conversational replies carry no thinking
    expect(r.text.toLowerCase(), contains('ask me'));
  });

  test('easter egg fires for "tell me something interesting"', () async {
    final r = await orchestrator.process(ctx('tell me something interesting'));
    expect(r.thinking, isNull);
    expect(r.text, isNotEmpty);
  });

  test('how-to is checked before data handlers', () async {
    final r = await orchestrator.process(ctx('how do I set a budget'));
    expect(r.followUps.single, isA<NavChipAction>());
    expect((r.followUps.single as NavChipAction).route, '/more/budgets');
  });

  test('spending this month answers from transactions', () async {
    final r = await orchestrator.process(ctx('how much did I spend this month'));
    expect(r.thinking, isNotNull);
    expect(r.text, contains('₹400'));
    expect(r.text, contains('across 2 transactions'));
  });

  test('top category attaches a TopCategoriesViz of ranked categories', () async {
    final r = await orchestrator.process(ctx('top spending category'));
    expect(r.text, contains('Food'));
    expect(r.vizPayload, isA<TopCategoriesViz>());
    final viz = r.vizPayload as TopCategoriesViz;
    expect(viz.rows.first.name, 'Food');
    expect(viz.rows.length, 2);
  });

  test('handlers emit an intent / scanned / result reasoning trace', () async {
    final r = await orchestrator.process(ctx('top spending category'));
    final steps = r.thinking!.steps;
    expect(steps.length, 3);
    expect(steps[0].text, contains('Detected intent'));
    expect(steps[1].text, contains('Scanned'));
    // Result step names the top category and its share, with bold markers.
    expect(steps[2].text, contains('**Food**'));
    expect(steps[2].text, contains('ranks first'));
  });

  test('unknown query falls through to the fallback and is logged', () async {
    String? logged;
    final r = await orchestrator.process(
      ctx('zxcvbnm qwerty'),
      onUnhandled: (raw) => logged = raw,
    );
    expect(r.text, contains('I can answer questions'));
    expect(logged, 'zxcvbnm qwerty');

    // Fallback offers a feedback chip prefilled with the unanswered query.
    final nav = r.followUps.whereType<NavChipAction>().single;
    expect(nav.label, 'Share your feedback');
    expect(nav.route, startsWith('/more/feedback?prefill='));
    expect(nav.route, contains('zxcvbnm'));
  });

  test('non-English input routes to the language handler, not fallback', () async {
    final r = await orchestrator.process(ctx('मेरा खर्च कितना है'));
    expect(r.text, contains('9 languages'));
    expect((r.followUps.single as NavChipAction).route, '/more/settings');
  });
}
