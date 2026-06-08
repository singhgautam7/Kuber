import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/how_to_response.dart';
import '../models/query_context.dart';
import 'query_handler.dart';

/// Answers functional "how do I…" / "where do I…" questions about using the app
/// and, where useful, offers a navigate chip into the relevant screen.
///
/// Runs after conversational + easter-egg handlers and before all data
/// handlers. Triggers carry an instructional cue ("how to add budget", "set a
/// budget") rather than the bare topic word, so data questions like "show my
/// budgets" still reach the data handlers below.
class HowToHandler extends QueryHandler {
  const HowToHandler();

  /// topic triggers -> response. Order matters only where triggers overlap;
  /// first match wins.
  static const List<(List<String>, HowToResponse)> _topics = [
    (
      ['how do i add a transaction', 'how to add a transaction',
        'how to add transaction', 'how do i add transaction',
        'how to log spending', 'how do i log', 'add a transaction',
        'record a transaction', 'how to record a transaction'],
      HowToResponse(
        'Tap the + button on the home screen, then fill in the amount and details.',
        deepLinkRoute: '/add-transaction',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i set a budget', 'how to set a budget', 'how to add budget',
        'how to add a budget', 'how do i budget', 'how to create a budget',
        'set a budget', 'create a budget', 'how to make a budget'],
      HowToResponse(
        'Go to More, Budgets and tap the + button to create one for a category.',
        deepLinkRoute: '/more/budgets',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i track a loan', 'how to add loan', 'how to add a loan',
        'how to track loan', 'how do i add a loan', 'track a loan',
        'add a loan', 'set up a loan'],
      HowToResponse(
        'Open More, Loans and tap +. Enter your loan details and EMI schedule.',
        deepLinkRoute: '/more/loans',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i add a category', 'how to add category', 'how to add a category',
        'add a category', 'create a category', 'make a category'],
      HowToResponse(
        'Go to More, Categories and tap + to create one.',
        deepLinkRoute: '/more/categories',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i add an account', 'how to add account', 'how to add an account',
        'add an account', 'create an account', 'set up an account'],
      HowToResponse(
        'Go to More, Accounts and tap + to add an account.',
        deepLinkRoute: '/more/accounts',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i track lending', 'how to track lent', 'how to track borrowed',
        'how to track lend borrowed', 'track lending', 'how do i lend money',
        'how to record a loan to a friend'],
      HowToResponse(
        "Open More, Lend / Borrow to track money you've lent or borrowed from people.",
        deepLinkRoute: '/more/ledger',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i add an investment', 'how to track investments',
        'how to add investment', 'add an investment', 'track investments',
        'how do i log an investment'],
      HowToResponse(
        'Go to More, Investments and tap + to log one.',
        deepLinkRoute: '/more/investments',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i set up recurring', 'how to add recurring',
        'how to set up recurring', 'set up recurring', 'add recurring',
        'recurring transaction', 'how to add a recurring'],
      HowToResponse(
        'Go to More, Recurring Transactions and tap +.',
        deepLinkRoute: '/more/recurring',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['where do i change theme', 'how to change theme', 'change theme',
        'switch theme', 'dark mode', 'light mode', 'change the theme'],
      HowToResponse(
        'Go to More, Settings to switch between light and dark themes.',
        deepLinkRoute: '/more/settings',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['where do i change currency', 'how to change currency',
        'change currency', 'set currency', 'change the currency'],
      HowToResponse(
        'More, Settings, Currency.',
        deepLinkRoute: '/more/settings',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['where do i change language', 'how to change language',
        'change language', 'set language', 'switch language'],
      HowToResponse(
        'More, Settings, Language. Kuber supports English, Hindi, Marathi, Punjabi, Bengali, Tamil, Telugu, Malayalam and Kannada',
        deepLinkRoute: '/more/settings',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i back up', 'how to backup', 'how to back up', 'back up my data',
        'backup my data', 'automatic backup', 'how do i backup'],
      HowToResponse(
        'More, Data, Automatic Backups. Pick a folder and frequency.',
        deepLinkRoute: '/more/data/automatic-backups',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i export', 'how to export', 'export my data', 'export data',
        'save a csv', 'download my data', 'export to csv'],
      HowToResponse(
        'More, Data, Export. You can save a CSV of your transactions.',
        deepLinkRoute: '/more/data',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['how do i see my insights', 'where are stories', 'where are my stories',
        'money stories', 'see my insights', 'view stories', 'how do i see insights'],
      HowToResponse(
        'Money Stories appear at the top of your home screen each day. Tap a bubble to view.',
        deepLinkRoute: '/',
        deepLinkLabel: 'Go home',
      ),
    ),
    (
      ['how do i edit my home widgets', 'how to reorder widgets', 'edit widgets',
        'reorder widgets', 'rearrange widgets', 'hide widgets', 'customize home',
        'edit home widgets'],
      HowToResponse(
        'Tap Edit Widgets at the bottom of the home screen to reorder or hide.',
        deepLinkRoute: '/widget-editor/home',
        deepLinkLabel: 'Take me there',
      ),
    ),
    (
      ['what are the features', 'what can this app do', 'what can you do',
        'what does this app do', 'what features'],
      HowToResponse(
        'Kuber tracks expenses across accounts, manages budgets and recurring bills, '
        'handles loans and lending, tracks investments, and surfaces daily insights, '
        'all on your device, no internet needed.',
      ),
    ),
    (
      ['is this offline', 'do i need internet', 'does this need internet',
        'do you need internet', 'works offline', 'is it offline', 'need wifi'],
      HowToResponse(
        'Always offline. Kuber runs entirely on your device. Nothing is sent anywhere.',
      ),
    ),
    (
      ['is my data private', 'is my data secure', 'is my data safe',
        'do you share my data', 'where is my data stored', 'is it private',
        'data privacy'],
      HowToResponse(
        'All your data stays on your device. Kuber never sends anything to any server.',
      ),
    ),
  ];

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final lower = ctx.lower;
    for (final (triggers, response) in _topics) {
      if (triggers.any(lower.contains)) {
        return HandlerResult(
          text: response.text,
          followUps: response.deepLinkRoute == null
              ? const []
              : [
                  NavChipAction(
                    label: response.deepLinkLabel ?? 'Take me there',
                    route: response.deepLinkRoute!,
                  ),
                ],
        );
      }
    }
    return null;
  }
}
