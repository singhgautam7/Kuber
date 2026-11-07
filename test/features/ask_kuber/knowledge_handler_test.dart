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
        expect(text, contains('Only in Kuber Pro'));
      }
    });

    test('tells Accounts from Kuber Cards, with links to both', () async {
      for (final q in [
        'What is the difference between an account and a Kuber card?',
        'Should I add my card as an account?',
        'accounts vs kuber cards',
        'What is Kuber Cards?',
      ]) {
        final r = await handler.tryHandle(QueryContext.forTest(raw: q));
        expect(r?.text, contains('not linked to transactions'), reason: q);
        final routes = r!.followUps.whereType<NavChipAction>().map((c) => c.route).toList();
        expect(routes, containsAll(['/more/accounts', '/cards']), reason: q);
      }
    });

    test('answers what is free, what is paid and each limit', () async {
      expect(await answer('Which features are free?'), contains('Only in Pro'));
      expect(await answer('which features are paid'), contains('Advanced Analytics'));
      expect(await answer('What is the limit on SMS import?'), contains('5 messages a week'));
      expect(await answer('How many cards can I add?'), contains('2 cards'));
      expect(await answer('how many notes can I make'), contains('2 notes'));
      expect(await answer('Is Ask Kuber free?'), contains('5 messages a week'));
      expect(await answer('are reminders free'), contains('only in Kuber Pro'));
    });

    test('answers the Pro page questions', () async {
      expect(await answer('Is Lifetime a one-time payment?'), contains('never renews'));
      expect(await answer('Can I use Pro on more than one device?'), contains('same Google account'));
      expect(await answer('What happens to my data if Pro ends?'), contains('Nothing is deleted'));
      expect(await answer('I changed phones. How do I get Pro back?'), contains('Restore purchases'));
      expect(await answer('How do I use a promo code?'), contains('Redeem promo code'));
      expect(await answer('Is my financial data secure?'), isNotNull);
      expect(await answer('Can Kuber see my payment details?'), contains('Google Play'));
      expect(await answer('How do I cancel my subscription?'), contains('Google Play'));
      expect(await answer('Can I get a refund?'), contains('refund'));
    });

    test('new answers use plain English: no long dashes', () async {
      for (final q in ['accounts vs kuber cards', 'which features are free', 'which features are paid', 'sms import limit']) {
        expect(await answer(q), isNot(matches(RegExp('[—–]'))), reason: q);
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
