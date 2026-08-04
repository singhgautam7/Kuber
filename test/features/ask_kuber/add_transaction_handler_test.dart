import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/accounts/data/account.dart';
import 'package:kuber/features/ask_kuber/handlers/add_transaction_handler.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';
import 'package:kuber/features/ask_kuber/models/viz_payload.dart';
import 'package:kuber/features/categories/data/category.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';

Category _cat(String name, int id) => Category()
  ..id = id
  ..name = name
  ..icon = 'category'
  ..colorValue = 0xFF888888
  ..type = 'expense';

Account _acct(String name, int id) => Account()
  ..id = id
  ..name = name;

QueryContext _ctx(String raw) => QueryContext.forTest(
      raw: raw,
      categories: [_cat('Groceries', 1), _cat('Movies', 2)],
      accounts: [_acct('Cash', 1)],
      settings: const SettingsState(defaultAccountId: '1'),
    );

void main() {
  const handler = AddTransactionHandler();

  test('fires on an add intent with an amount, returning a preview', () async {
    final r = await handler.tryHandle(_ctx('add 250 groceries'));
    expect(r, isNotNull);
    expect(r!.vizPayload, isA<TransactionPreviewViz>());
    expect(r.text, contains('confirm'));
  });

  test('multi-line lead counts the transactions', () async {
    final r = await handler.tryHandle(_ctx('add 250 groceries and 300 movies'));
    expect(r!.text, contains('2 transactions'));
    final viz = r.vizPayload as TransactionPreviewViz;
    expect(viz.drafts.where((d) => d.amount != null), hasLength(2));
  });

  test('ignores data-query phrasings', () async {
    expect(await handler.tryHandle(_ctx('how much did i spend on groceries')),
        isNull);
    expect(await handler.tryHandle(_ctx('what did i spend this month')), isNull);
    expect(await handler.tryHandle(_ctx('show my transactions')), isNull);
  });

  test('ignores an add cue with no amount', () async {
    expect(await handler.tryHandle(_ctx('i spent a lot today')), isNull);
  });

  test('ignores plain chatter without an add cue', () async {
    expect(await handler.tryHandle(_ctx('good morning kuber')), isNull);
  });

  test('preserves the original message for source text', () async {
    final r = await handler.tryHandle(_ctx('add 250 groceries'));
    final viz = r!.vizPayload as TransactionPreviewViz;
    expect(viz.originalMessage, 'add 250 groceries');
    expect(viz.state, 'preview');
  });
}
