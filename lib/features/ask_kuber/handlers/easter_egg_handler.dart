import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import 'query_handler.dart';

/// Light, high-precision easter eggs. Runs before the how-to and data handlers,
/// so every entry matches only specific phrases (never bare substrings that
/// could appear in a real question). English-only, no thinking metadata.
class EasterEggHandler extends QueryHandler {
  const EasterEggHandler();

  static const _nudges = [
    AskChipAction('Top spending category'),
    AskChipAction('How much did I spend this month?'),
  ];

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final q = ctx.lower.replaceAll(RegExp(r"[^a-z' ]"), ' ').trim();
    if (q.isEmpty) return null;

    bool any(List<String> phrases) => phrases.any(q.contains);

    if (any(['something interesting', 'tell me something', 'surprise me', 'fun fact'])) {
      return const HandlerResult(
        text: "Here's one: the small, repeat purchases usually add up faster than "
            'the big one-offs. Want to see where yours go?',
        followUps: _nudges,
      );
    }
    if (any(['meaning of life', 'meaning of money'])) {
      return const HandlerResult(
        text: '42. Your budget might disagree.',
      );
    }
    if (any(['who are you', 'what are you', 'who is kuber', 'who made you',
      'are you ai', 'are you a bot', 'are you sentient', 'are you alive',
      'are you real', 'are you human'])) {
      return const HandlerResult(
        text: "I'm Kuber, a humble on-device assistant named after the Hindu god "
            'of wealth. No cloud, no feelings, just your numbers.',
      );
    }
    if (any(['tell me a joke', 'say a joke', 'make me laugh'])) {
      return const HandlerResult(
        text: 'I tried to save money on this joke, but it still came at a premium.',
      );
    }
    if (any(['i love you', 'marry me', 'do you love me'])) {
      return const HandlerResult(
        text: "That's sweet. I do love a balanced budget.",
      );
    }
    if (any(['sing a song', 'sing me', 'can you sing'])) {
      return const HandlerResult(
        text: 'Money, money, money. That is the whole setlist, sorry.',
      );
    }

    return null;
  }
}
