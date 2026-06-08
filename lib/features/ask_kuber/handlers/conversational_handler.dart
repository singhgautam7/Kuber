import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import 'query_handler.dart';

/// Small-talk: greetings, pleasantries, thanks, and clearly out-of-scope asks.
/// Sits ahead of the data handlers, so matching is deliberately high-precision
/// (a greeting must be a *pure* greeting) to avoid swallowing real questions
/// like "hey what did I spend this month?". Conversational replies carry no
/// thinking metadata.
class ConversationalHandler extends QueryHandler {
  const ConversationalHandler();

  static const _greetings = {
    'hi', 'hii', 'hiya', 'hey', 'heya', 'hello', 'helo', 'yo', 'sup',
    'namaste', 'hola', 'greetings', 'morning', 'evening', 'afternoon',
  };
  static const _greetingFillers = {
    'there', 'kuber', 'everyone', 'all', 'again', 'buddy', 'friend',
    'good', 'good morning', 'mate',
  };

  // Ask chips offered after small talk so the user has an obvious next step.
  static const _nudges = [
    AskChipAction('How much did I spend this month?'),
    AskChipAction('What\'s my net worth?'),
    AskChipAction('Top spending category'),
  ];

  // Words that mark a real finance question. When present we never treat the
  // query as a pleasantry or out-of-scope, so "spend on movies" reaches the
  // data handlers instead of matching the "movie" out-of-scope keyword.
  static const _financeSignals = [
    'spend', 'spent', 'expense', 'budget', 'income', 'balance', 'net worth',
    'networth', 'loan', 'emi', 'invest', 'portfolio', 'save', 'saving',
    'category', 'categor', 'account', 'owe', 'lent', 'lend', 'borrow',
    'transaction', 'recurring', 'salary', 'worth', 'paid', 'cost', 'how much',
    'how many',
  ];

  bool _hasFinanceSignal(String q) => _financeSignals.any(q.contains);

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final q = ctx.lower.replaceAll(RegExp(r"[^a-z' ]"), ' ').trim();
    if (q.isEmpty) return null;
    final words =
        q.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    final hasFinance = _hasFinanceSignal(q);

    // Thanks.
    if (q.contains('thank') ||
        q.contains('thanks') ||
        q.contains('thnx') ||
        q.contains('thx') ||
        q.contains('appreciate') ||
        q == 'ty' ||
        q == 'cheers') {
      return const HandlerResult(
        text: 'Anytime. Ask away whenever you need a number.',
        followUps: _nudges,
      );
    }

    // Pleasantries.
    const pleasantries = [
      'how are you', 'how r u', 'how are u', 'hows it going',
      "how's it going", 'how do you do', 'whats up', "what's up",
      'how is it going', 'are you ok', 'are you okay', 'how you doing',
    ];
    if (!hasFinance && words.length <= 7 && pleasantries.any(q.contains)) {
      return const HandlerResult(
        text: "I'm just on-device code, but I'm running smoothly. "
            'What would you like to know about your money?',
        followUps: _nudges,
      );
    }

    // Pure greeting: every word is a greeting token or a harmless filler.
    final isPureGreeting = words.isNotEmpty &&
        words.any(_greetings.contains) &&
        words.every((w) => _greetings.contains(w) || _greetingFillers.contains(w));
    if (isPureGreeting) {
      final name = ctx.settings.userName.trim();
      final hi = name.isNotEmpty ? 'Hey $name!' : 'Hey!';
      return HandlerResult(
        text: '$hi Ask me anything about your spending, income, or balances.',
        followUps: _nudges,
      );
    }

    // Clearly out-of-scope topics.
    const outOfScope = [
      'weather', 'news', 'sports', 'cricket score', 'movie', 'recipe',
      'translate', 'president', 'prime minister', 'capital of', 'who won',
      'stock tip', 'should i buy', 'will it rain', 'horoscope',
    ];
    if (!hasFinance && outOfScope.any(q.contains)) {
      return const HandlerResult(
        text: "I only know your Kuber data, so I can't help with that. "
            'But I can tell you about your spending, budgets, loans, investments, and more.',
        followUps: _nudges,
      );
    }

    return null;
  }
}
