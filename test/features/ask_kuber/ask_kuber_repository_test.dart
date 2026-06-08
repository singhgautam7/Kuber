import 'package:flutter/material.dart' show Color;
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/features/ask_kuber/models/chat_message.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/models/thinking_info.dart';
import 'package:kuber/features/ask_kuber/models/viz_payload.dart';
import 'package:kuber/features/ask_kuber/services/ask_kuber_repository.dart';

import '../../helpers/isar_test_helper.dart';

void main() {
  late Isar isar;
  late AskKuberRepository repo;

  setUpAll(initialiseIsarForTests);

  setUp(() async {
    isar = await openTestIsar();
    repo = AskKuberRepository(isar);
  });

  tearDown(() async {
    await closeAndCleanIsar(isar);
  });

  ChatMessage kuberMessage() => ChatMessage(
        text: 'Your top spending category overall is Food at ₹300.',
        isUser: false,
        time: DateTime(2026, 6, 1, 9, 1),
        thinking: const ThinkingInfo(
          dateFilter: 'All time',
          scanned: ['Transactions', 'Categories'],
          steps: [
            ThinkingStep('Detected intent: **top expense category**.'),
            ThinkingStep('**Food** ranks first at **₹300**.'),
          ],
        ),
        vizPayload: const TopCategoriesViz([
          CategoryVizRow(
              name: 'Food',
              color: Color(0xFFEF4444),
              amount: 300,
              percentOfTotal: 0.75),
        ]),
        followUps: const [
          AskChipAction('How much did I spend this month?'),
          NavChipAction(label: 'View budget', route: '/more/budgets'),
        ],
      );

  test('append back-fills storedId and preserves order', () async {
    final user = ChatMessage(
        text: 'top category?', isUser: true, time: DateTime(2026, 6, 1, 9, 0));
    await repo.append(user);
    await repo.append(kuberMessage());
    expect(user.storedId, isNotNull);

    final loaded = await repo.loadAll();
    expect(loaded.length, 2);
    expect(loaded.first.isUser, isTrue);
    expect(loaded.last.isUser, isFalse);
  });

  test('visualization and chip actions survive a reload', () async {
    await repo.append(kuberMessage());
    final loaded = await repo.loadAll();
    final k = loaded.single;

    expect(k.text, contains('Food'));
    expect(k.thinking?.dateFilter, 'All time');
    expect(k.thinking?.scanned, ['Transactions', 'Categories']);
    expect(k.thinking?.steps.map((s) => s.text).toList(), [
      'Detected intent: **top expense category**.',
      '**Food** ranks first at **₹300**.',
    ]);

    expect(k.vizPayload, isA<TopCategoriesViz>());
    final viz = k.vizPayload as TopCategoriesViz;
    expect(viz.rows.single.name, 'Food');
    expect(viz.rows.single.color.toARGB32(), 0xFFEF4444);
    expect(viz.rows.single.percentOfTotal, 0.75);

    expect(k.followUps.length, 2);
    expect(k.followUps[0], isA<AskChipAction>());
    expect((k.followUps[0] as AskChipAction).query,
        'How much did I spend this month?');
    expect(k.followUps[1], isA<NavChipAction>());
    expect((k.followUps[1] as NavChipAction).route, '/more/budgets');
  });

  test('clear wipes the conversation', () async {
    await repo.append(kuberMessage());
    await repo.clear();
    expect(await repo.loadAll(), isEmpty);
  });
}
