import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/knowledge_handler.dart';
import 'package:kuber/features/ask_kuber/models/chip_action.dart';
import 'package:kuber/features/ask_kuber/models/query_context.dart';

void main() {
  const handler = KnowledgeHandler();

  Future<String?> answer(String q) async {
    final r = await handler.tryHandle(QueryContext.forTest(raw: q));
    return r?.text;
  }

  group('KnowledgeHandler matching', () {
    test('matches Pro comparison phrasings', () async {
      for (final q in [
        "What's in Kuber Pro?",
        'free vs pro',
        'why should I upgrade',
      ]) {
        final text = await answer(q);
        expect(text, isNotNull, reason: q);
        expect(text, contains('Free tier includes'));
      }
    });

    test('matches privacy / data questions', () async {
      expect(await answer('is my data safe'), contains('encrypted local'));
      expect(await answer('where is my data stored'), contains('on your device only'));
      expect(await answer('does kuber read all my sms'), contains('bank transaction SMS'));
    });

    test('matches support and refund questions', () async {
      expect(await answer('how do I cancel my subscription'), contains('Google Play'));
      expect(await answer('can I get a refund'), contains('refund'));
      expect(
        await answer('what is the developer\'s email'),
        contains('singhgautam.dev@gmail.com'),
      );
    });

    test('a plain data query is NOT swallowed (falls through)', () async {
      // These belong to the data handlers; knowledge must return null so the
      // orchestrator keeps walking the chain.
      expect(await answer('how much did I spend this month'), isNull);
      expect(await answer('show my budgets'), isNull);
      expect(await answer('what is my balance'), isNull);
    });
  });

  group('KnowledgeHandler follow-up chips', () {
    test('student-discount answer offers an email chip', () async {
      final r = await handler.tryHandle(
        QueryContext.forTest(raw: 'can I get pro for free'),
      );
      expect(r, isNotNull);
      expect(r!.followUps.whereType<EmailChipAction>(), isNotEmpty);
    });

    test('backup answer offers a navigate chip to Data settings', () async {
      final r = await handler.tryHandle(
        QueryContext.forTest(raw: 'how do I back up my data'),
      );
      final nav = r!.followUps.whereType<NavChipAction>().first;
      expect(nav.route, '/more/data');
    });

    test('every response has thinking steps tagged as a help query', () async {
      final r = await handler.tryHandle(
        QueryContext.forTest(raw: 'what can kuber do'),
      );
      expect(r!.thinking!.steps.first.text, contains('help query'));
    });
  });
}
