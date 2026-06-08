import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/easter_egg_handler.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';

import '../../helpers/test_factories.dart';

void main() {
  const handler = EasterEggHandler();

  test('something-interesting always returns a non-empty response', () async {
    final ctx = QueryContext.forTest(raw: 'tell me something interesting');
    for (var i = 0; i < 50; i++) {
      final r = await handler.tryHandle(ctx);
      expect(r, isNotNull);
      expect(r!.text.trim(), isNotEmpty);
    }
  });

  test('the dynamic fact can surface category count + oldest age', () async {
    final ctx = QueryContext.forTest(
      raw: 'surprise me',
      categories: [makeCategory(id: 1, name: 'Food')],
      txns: [
        makeTransaction(
            amount: 100, categoryId: '1', createdAt: DateTime(2025, 1, 10)),
      ],
      now: DateTime(2026, 6, 15),
    );
    // Draw until the dynamic option appears (4 options => certain within many draws).
    var sawDynamic = false;
    for (var i = 0; i < 200 && !sawDynamic; i++) {
      final r = await handler.tryHandle(ctx);
      if (r!.text.contains('logged transactions in')) sawDynamic = true;
    }
    expect(sawDynamic, isTrue);
  });
}
