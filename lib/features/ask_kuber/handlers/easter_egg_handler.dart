import 'dart:math';

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
      final options = <HandlerResult>[
        const HandlerResult(
          text: 'Some say if you tap a number seven times in the Kuber app '
              'settings, something hidden appears...',
        ),
        const HandlerResult(
          text: "Here's one: the small, repeat purchases usually add up faster "
              'than the big one-offs. Want to see where yours go?',
          followUps: _nudges,
        ),
        const HandlerResult(
          text: "Kuber means 'wealth' in Hindi mythology - the God of Treasure.",
        ),
      ];
      // Dynamic fact, only when there is data to draw from.
      final realTxns = ctx.txns.where((t) => !t.isBalanceAdjustment).toList();
      if (realTxns.isNotEmpty) {
        final n = realTxns
            .map((t) => t.categoryId)
            .where((c) => c.isNotEmpty)
            .toSet()
            .length;
        final oldest = realTxns
            .map((t) => t.createdAt)
            .reduce((a, b) => a.isBefore(b) ? a : b);
        final months =
            (ctx.now.year - oldest.year) * 12 + (ctx.now.month - oldest.month);
        final ago = months <= 0
            ? 'this month'
            : 'about $months month${months == 1 ? '' : 's'} ago';
        options.add(HandlerResult(
          text:
              "You've logged transactions in $n categor${n == 1 ? 'y' : 'ies'}. "
              'The oldest one is from $ago.',
          followUps: _nudges,
        ));
      }
      return options[Random().nextInt(options.length)];
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
