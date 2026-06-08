import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/how_to_handler.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';

void main() {
  const handler = HowToHandler();
  QueryContext ctx(String raw) => QueryContext.forTest(raw: raw);

  test('add-transaction topic returns text plus a navigate chip', () async {
    final r = await handler.tryHandle(ctx('How do I add a transaction?'));
    expect(r, isNotNull);
    expect(r!.text, contains('+'));
    expect(r.followUps.length, 1);
    final chip = r.followUps.single;
    expect(chip, isA<NavChipAction>());
    expect((chip as NavChipAction).route, '/add-transaction');
    expect(chip.label, 'Take me there');
  });

  test('budget how-to routes to the budgets list', () async {
    final r = await handler.tryHandle(ctx('how do I set a budget'));
    expect((r!.followUps.single as NavChipAction).route, '/more/budgets');
  });

  test('informational topics return text only (no chip)', () async {
    expect((await handler.tryHandle(ctx('what are the features')))!.followUps,
        isEmpty);
    expect((await handler.tryHandle(ctx('is my data private')))!.followUps,
        isEmpty);
    expect((await handler.tryHandle(ctx('do I need internet')))!.followUps,
        isEmpty);
  });

  test('does not claim data queries that merely share a topic word', () async {
    // "show my budgets" / "how much did I spend" must fall through to data handlers.
    expect(await handler.tryHandle(ctx('show my budgets')), isNull);
    expect(await handler.tryHandle(ctx('how much did I spend this month')), isNull);
    expect(await handler.tryHandle(ctx('top spending category')), isNull);
  });
}
