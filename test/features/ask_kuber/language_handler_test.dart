import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/language_handler.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';

void main() {
  const handler = LanguageHandler();
  QueryContext ctx(String raw) => QueryContext.forTest(raw: raw);

  test('answers "how many languages" with the count + a settings chip', () async {
    final r = await handler.tryHandle(ctx('how many languages does kuber support'));
    expect(r, isNotNull);
    expect(r!.text, contains('9 languages'));
    expect(r.text.toLowerCase(), contains('only'));
    final chip = r.followUps.single;
    expect(chip, isA<NavChipAction>());
    expect((chip as NavChipAction).route, '/more/settings');
  });

  test('catches non-English (Indic) input', () async {
    final r = await handler.tryHandle(ctx('नमस्ते कुबेर, मेरा खर्च कितना है'));
    expect(r, isNotNull);
    expect(r!.text, contains('English'));
  });

  test('catches "do you speak" / "answer in" style asks', () async {
    expect(await handler.tryHandle(ctx('do you speak Hindi?')), isNotNull);
    expect(await handler.tryHandle(ctx('can you answer in Tamil')), isNotNull);
  });

  test('does not claim ordinary English data queries', () async {
    expect(await handler.tryHandle(ctx('how much did I spend this month')), isNull);
    expect(await handler.tryHandle(ctx('top spending category')), isNull);
  });
}
