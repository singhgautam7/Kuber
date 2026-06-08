import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import 'query_handler.dart';

/// Handles non-English input and "what / how many languages" questions. Ask
/// Kuber itself only chats in English, but the app is localized into 9
/// languages. Runs after the how-to handler (which owns "how to change
/// language") and before the data handlers.
class LanguageHandler extends QueryHandler {
  const LanguageHandler();

  /// U+0900 to U+0DFF: Devanagari through Sinhala, covering every Indic script
  /// Kuber ships (Hindi/Marathi, Bengali, Gurmukhi, Tamil, Telugu, Kannada,
  /// Malayalam). Built from code points to keep the source ASCII-only.
  static final _indicScript = RegExp(
      '[${String.fromCharCode(0x0900)}-${String.fromCharCode(0x0DFF)}]');

  static const _triggers = [
    'how many language', 'what language', 'which language', 'languages does',
    'languages do you', 'languages support', 'supported language',
    'list of language', 'languages are supported', 'do you speak',
    'can you speak', 'speak english', 'only english', 'reply in',
    'answer in', 'respond in', 'in hindi', 'in marathi', 'in punjabi',
    'in bengali', 'in tamil', 'in telugu', 'in malayalam', 'in kannada',
  ];

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final hasIndic = _indicScript.hasMatch(ctx.raw);
    if (!hasIndic && !_triggers.any(ctx.lower.contains)) return null;

    return const HandlerResult(
      text: 'I can only chat in English for now. The Kuber app itself supports '
          '9 languages: English, Hindi, Marathi, Punjabi, Bengali, Tamil, '
          'Telugu, Malayalam and Kannada. You can switch any time in More, '
          'Settings, Language.',
      followUps: [
        NavChipAction(label: 'Change language', route: '/more/settings'),
      ],
    );
  }
}
