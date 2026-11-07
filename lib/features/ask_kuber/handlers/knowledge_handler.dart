import '../data/email_templates.dart';
import '../models/chip_action.dart';
import '../models/handler_result.dart';
import '../models/query_context.dart';
import '../models/thinking_info.dart';
import 'query_handler.dart';

/// Answers "help" and "how does X work" knowledge questions about the app,
/// monetization, privacy, data, and support. These are NOT data queries — they
/// return static answers from a built-in knowledge base, optionally with a
/// navigate / ask / email follow-up chip.
///
/// Runs AFTER conversational + easter-egg and BEFORE the how-to handler and all
/// data handlers (see `QueryOrchestrator.standard`). Where a phrase could match
/// both this and the how-to handler ("how do I back up my data"), knowledge
/// wins: it gives the informational answer and still offers the navigate chip
/// the how-to handler would have. Triggers are full-ish phrases (not bare topic
/// words) so data questions like "show my budgets" still fall through to the
/// data handlers.
class KnowledgeHandler extends QueryHandler {
  const KnowledgeHandler();

  @override
  Future<HandlerResult?> tryHandle(QueryContext ctx) async {
    final match = _findMatch(ctx.lower);
    if (match == null) return null;
    return HandlerResult(
      text: match.response,
      thinking: ThinkingInfo(
        dateFilter: '',
        scanned: const ['Kuber help center'],
        steps: [
          ThinkingStep(
            'Detected intent: **help query** about **${match.topicLabel}**.',
          ),
          const ThinkingStep('Answered from the built-in knowledge base.'),
        ],
      ),
      followUps: match.followUps,
    );
  }

  static _KnowledgeMatch? _findMatch(String query) {
    for (final topic in _topics) {
      for (final phrase in topic.phrases) {
        if (query.contains(phrase)) return topic;
      }
    }
    return null;
  }
}

// --- Routes the navigate chips target (verified against app_router.dart). ----
const _rDevTools = '/more/dev-tools';
const _rSettings = '/more/settings';
const _rData = '/more/data';
const _rPrivacy = '/more/settings/privacy?row=privacyMode';
const _rPaywall = '/pro';
const _rAbout = '/more/about';
const _rSmsImport = '/more/sms-import';
const _rAccounts = '/more/accounts';
const _rCards = '/cards';
const _rNotes = '/more/notes';

class _KnowledgeMatch {
  final String topicLabel;
  final List<String> phrases;
  final String response;
  final List<ChipAction> followUps;
  const _KnowledgeMatch({
    required this.topicLabel,
    required this.phrases,
    required this.response,
    this.followUps = const [],
  });
}

/// All knowledge topics. Order matters only where phrases overlap: first match
/// wins, so more specific topics are listed before broader ones.
const List<_KnowledgeMatch> _topics = [
  // ---- Mock data ----------------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'mock data',
    phrases: [
      'how do i use mock data',
      'how do i generate mock data',
      'can i try the app with sample data',
      'how do i add fake data',
    ],
    response:
        'You can generate mock data from Settings, Developer Tools, Generate '
        'mock data. This adds sample transactions, accounts, budgets, and other '
        'data so you can explore Kuber\'s features. Great for trying things out '
        'before adding your real data.',
    followUps: [
      NavChipAction(label: 'Take me there', route: _rDevTools),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'removing mock data',
    phrases: [
      'i see mock data in the app',
      'how do i remove mock data',
      'how do i clear sample data',
      'how do i switch to real data',
    ],
    response:
        'If you generated mock data earlier and want to start fresh with your '
        'real data, go to Settings, Developer Tools, Clear all data. This wipes '
        'everything including the mock data. You can then add your real accounts '
        'and transactions from scratch. Make sure to back up first if you want '
        'to keep anything.',
    followUps: [
      NavChipAction(label: 'Take me there', route: _rDevTools),
      AskChipAction('How do I back up my data?'),
    ],
  ),

  // ---- Accounts and Kuber Cards -------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'Accounts and Kuber Cards',
    phrases: [
      'difference between account and kuber card',
      'difference between accounts and kuber cards',
      'difference between an account and a kuber card',
      'difference between kuber cards and accounts',
      'difference between kuber card and account',
      'account or kuber card',
      'account or kuber cards',
      'kuber cards or account',
      'accounts vs kuber cards',
      'account vs kuber card',
      'kuber cards vs accounts',
      'kuber card vs account',
      'should i add my card as an account',
      'should i add my credit card to kuber cards',
      'where do i add my credit card',
      'where should i add my card',
      'are kuber cards linked to transactions',
      'is kuber cards linked to transactions',
      'what is kuber cards',
      'what are kuber cards',
    ],
    response:
        'They do two different jobs.\n\n'
        '**Accounts** are where your money moves. Every transaction you add '
        'comes from or goes to an account: a bank account, cash, a wallet or a '
        'credit card. Balances, budgets and analytics are built from them. Add '
        'your credit card as an account to track what you spend on it and its '
        'bill.\n\n'
        '**Kuber Cards** is a locked vault for card details: number, expiry, '
        'name on the card and your own notes. It is not linked to '
        'transactions, never changes a balance, and opens only with your Cards '
        'PIN or fingerprint. Use it so the details are at hand when you pay '
        'online.\n\n'
        'Many people use both: the card as an account to track spending, and '
        'in Kuber Cards to keep its details safe.',
    followUps: [
      NavChipAction(label: 'Open Accounts', route: _rAccounts),
      NavChipAction(label: 'Open Kuber Cards', route: _rCards),
    ],
  ),

  // ---- What's free and the limits -----------------------------------------
  _KnowledgeMatch(
    topicLabel: 'SMS Import limit',
    phrases: [
      'limit on sms import',
      'sms import limit',
      'how many sms can i import',
      'how many sms imports',
      'is sms import free',
      'is sms import paid',
      'is import from sms free',
    ],
    response:
        'Import from SMS is free to use. Free users can import **5 messages a '
        'week** (a rolling 7 days); with Kuber Pro there is no limit. Scanning '
        'your inbox and pasting a message by hand are always free and never '
        'count towards the 5.',
    followUps: [
      NavChipAction(label: 'Open Import from SMS', route: _rSmsImport),
      NavChipAction(label: 'See Pro options', route: _rPaywall),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Kuber Cards limit',
    phrases: [
      'limit on kuber cards',
      'kuber cards limit',
      'how many cards can i add',
      'how many cards can i save',
      'how many kuber cards',
      'is kuber cards free',
      'is kuber cards paid',
    ],
    response:
        'Kuber Cards is free for **2 cards**. You can add more, but from the '
        'third card on they stay hidden until you have Kuber Pro. Pro removes '
        'the limit. Changing your Cards PIN and fingerprint unlock are free.',
    followUps: [
      NavChipAction(label: 'Open Kuber Cards', route: _rCards),
      NavChipAction(label: 'See Pro options', route: _rPaywall),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Kuber Notes limit',
    phrases: [
      'limit on kuber notes',
      'limit on notes',
      'kuber notes limit',
      'notes limit',
      'how many notes can i',
      'how many kuber notes',
      'is kuber notes free',
      'are kuber notes free',
      'is kuber notes paid',
    ],
    response:
        'Kuber Notes is free for **2 notes**. Kuber Pro gives you as many as '
        'you like. Notes you already have are never deleted if Pro ends.',
    followUps: [
      NavChipAction(label: 'Open Kuber Notes', route: _rNotes),
      NavChipAction(label: 'See Pro options', route: _rPaywall),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Ask Kuber limit',
    phrases: [
      'limit on ask kuber',
      'ask kuber limit',
      'how many messages can i send',
      'how many questions can i ask',
      'how many ask kuber messages',
      'is ask kuber free',
      'is ask kuber paid',
    ],
    response:
        'Ask Kuber is free for **5 messages a week**. Kuber Pro makes it '
        'unlimited. Everything runs on your phone, so your questions never '
        'leave it.',
    followUps: [
      NavChipAction(label: 'See Pro options', route: _rPaywall),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Pro only features',
    phrases: [
      'is reminders free',
      'are reminders free',
      'is advanced analytics free',
      'are automatic backups free',
      'is automatic backup free',
      'are themes free',
      'are custom themes free',
      'which features are paid',
      'what features are paid',
      'which features are pro',
      'what is paid',
    ],
    response:
        'Four features are only in Kuber Pro: **Advanced Analytics**, '
        '**Reminders**, **Automatic Backups** and **custom themes** (Kuber '
        'Signature, light and dark, is free).\n\n'
        'Four more are free with a limit that Pro removes:\n'
        '- Import from SMS: 5 imports a week\n'
        '- Kuber Notes: 2 notes\n'
        '- Ask Kuber: 5 messages a week\n'
        '- Kuber Cards: 2 cards\n\n'
        'Everything else is free.',
    followUps: [
      NavChipAction(label: 'See Pro options', route: _rPaywall),
      AskChipAction('Which features are free?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'free features',
    phrases: [
      'which features are free',
      'what features are free',
      'what is free',
      "what's free",
      'is kuber free',
      'what stays free',
    ],
    response:
        'Kuber is free to use, with no ads and no account. Free for everyone:\n'
        '- Transactions, History, accounts, categories, tags and budgets\n'
        '- Recurring payments, loans, investments, and lend and borrow\n'
        '- Analytics, Money Stories with full history, and Upcoming events\n'
        '- Calculators and tools, Quick Add, home screen widgets\n'
        '- CSV and PDF export, manual backup and restore\n'
        '- App lock, Privacy mode, every currency and all 9 languages\n\n'
        'Free with a limit: Import from SMS (5 imports a week), Kuber Notes '
        '(2 notes), Ask Kuber (5 messages a week) and Kuber Cards (2 cards).\n\n'
        'Only in Pro: Advanced Analytics, Reminders, Automatic Backups and '
        'custom themes.',
    followUps: [
      NavChipAction(label: 'See Pro options', route: _rPaywall),
      AskChipAction('What is in Kuber Pro?'),
    ],
  ),

  // ---- Pro page questions (the FAQ on the Pro page) -----------------------
  _KnowledgeMatch(
    topicLabel: 'Lifetime plan',
    phrases: [
      'is lifetime a one-time payment',
      'is lifetime a one time payment',
      'is lifetime one time',
      'does lifetime renew',
      'lifetime plan',
    ],
    response: 'Yes. Lifetime is a one-time payment and it never renews.',
    followUps: [
      NavChipAction(label: 'See Pro options', route: _rPaywall),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Pro on more than one phone',
    phrases: [
      'more than one device',
      'more than one phone',
      'another phone',
      'second phone',
      'two phones',
      'multiple devices',
    ],
    response:
        'Yes, Pro works on any phone signed in to the same Google account. '
        'Install Kuber and tap Restore purchases on the Pro page. Your data '
        "doesn't sync between phones, so use a backup to move it.",
    followUps: [
      NavChipAction(label: 'Open Pro page', route: _rPaywall),
      AskChipAction('How do I back up my data?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'changing phones',
    phrases: [
      'i changed phones',
      'i changed my phone',
      'new phone',
      'get pro back',
    ],
    response:
        'Sign in with the same Google account, install Kuber, and tap Restore '
        'purchases on the Pro page. To bring your data too, restore a backup '
        'from your old phone.',
    followUps: [
      NavChipAction(label: 'Open Pro page', route: _rPaywall),
      AskChipAction('How do I restore from backup?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'when Pro ends',
    phrases: [
      'what happens to my data if pro ends',
      'what happens if pro ends',
      'what happens when pro ends',
      'if my subscription ends',
      'if pro expires',
      'what happens if i cancel pro',
    ],
    response:
        'Nothing is deleted. Your data stays on your phone, and Pro features go '
        'back to their free limits. The theme returns to Kuber Signature.',
    followUps: [
      AskChipAction('Which features are free?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'promo codes',
    phrases: [
      'promo code',
      'redeem a code',
      'redeem code',
      'coupon',
    ],
    response:
        'Open the Pro page, tap Redeem promo code and enter your code. Kuber '
        "opens Google Play's redeem page. When you come back, Kuber checks for "
        'it automatically.',
    followUps: [
      NavChipAction(label: 'Open Pro page', route: _rPaywall),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'payment details',
    phrases: [
      'can kuber see my payment details',
      'can kuber see my card details',
      'does kuber see my payment',
      'payment details',
    ],
    response:
        'No. Google Play handles payments, and Kuber never sees your card or '
        'bank details.',
    followUps: [
      AskChipAction('Is my financial data secure?'),
    ],
  ),

  // ---- Kuber Pro ----------------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'free vs Pro',
    phrases: [
      'what is the difference between pro and normal kuber',
      'what does pro give me',
      "what's in kuber pro",
      'what is in kuber pro',
      'free vs pro',
      'pro features',
      'why should i upgrade',
    ],
    response:
        'Kuber Pro unlocks the advanced features. Here\'s how the two compare:\n\n'
        '**Free for everyone:** transactions, accounts, budgets, categories, '
        'tags, recurring, loans, investments, lend and borrow, analytics, Money '
        'Stories, calculators, widgets, CSV and PDF export, manual backup, app '
        'lock, every currency and all 9 languages.\n\n'
        '**Free with a limit Pro removes:**\n'
        '- Import from SMS: 5 imports a week\n'
        '- Kuber Notes: 2 notes\n'
        '- Ask Kuber: 5 messages a week\n'
        '- Kuber Cards: 2 cards\n\n'
        '**Only in Kuber Pro:**\n'
        '- Advanced Analytics\n'
        '- Reminders\n'
        '- Automatic Backups\n'
        '- Custom themes\n\n'
        'All Pro purchases are through Google Play. No account needed, works '
        'fully offline like the rest of Kuber.',
    followUps: [
      NavChipAction(label: 'See Pro options', route: _rPaywall),
      AskChipAction('Can I get Pro for free?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Pro discounts',
    phrases: [
      'can i get pro for free',
      'is there a discount for students',
      'student discount',
      "i can't afford pro",
      'i cant afford pro',
      'free pro',
      'any way to get pro cheaper',
    ],
    response:
        'Possibly, yes. If you\'re a student or facing genuine financial '
        'constraints but still want Kuber Pro, you can email the developer '
        'directly with proof (a student ID, or a short note explaining your '
        'situation). Requests are reviewed case by case and while approval '
        'isn\'t guaranteed, the developer tries to help where possible.\n\n'
        'Reach out to ${EmailTemplates.developerEmail} with your details.',
    followUps: [
      EmailChipAction(
        label: 'Email the developer',
        subject: EmailTemplates.studentProSubject,
        body: EmailTemplates.studentProBody,
      ),
      AskChipAction('What is in Kuber Pro?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'cancelling a subscription',
    phrases: [
      'how do i cancel my subscription',
      'how do i cancel pro',
      'unsubscribe',
      'stop my subscription',
    ],
    response:
        'Subscriptions are managed through Google Play. Open Play Store, tap '
        'your profile icon, Payments and subscriptions, Subscriptions, find '
        'Kuber, Cancel. Your Pro access continues until the end of the current '
        'billing period.',
    followUps: [
      AskChipAction('Can I get a refund?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'refunds',
    phrases: [
      'can i get a refund',
      'how do i get a refund',
      'refund policy',
    ],
    response:
        'Refund requests are handled by Google Play. Open Play Store, tap your '
        'profile icon, Payments and subscriptions, Budget and history, find the '
        'Kuber purchase, Refund. Google\'s standard refund policy applies. If '
        'your request is outside their window, you can email the developer to '
        'review it manually.',
    followUps: [
      AskChipAction("What is the developer's email?"),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'restoring a purchase',
    phrases: [
      "i bought pro but it's not showing",
      'i bought pro but its not showing',
      'how do i restore my purchase',
      'restore purchases',
      'restore purchase',
      'reinstalled the app and lost pro',
    ],
    response:
        'Open Settings, Kuber Pro, Restore purchases. This checks Google Play '
        'for your active purchases and restores your Pro access. If it doesn\'t '
        'work after a minute, make sure you\'re signed into the same Google '
        'account you used to buy Pro.',
    followUps: [
      NavChipAction(label: 'Go to Settings', route: _rSettings),
    ],
  ),

  // ---- Developer contact + feedback --------------------------------------
  _KnowledgeMatch(
    topicLabel: 'contacting the developer',
    phrases: [
      "what is the developer's email",
      'what is the developers email',
      'how do i contact the developer',
      'developer email',
      'how do i contact support',
      'how do i reach the developer',
    ],
    response:
        'The developer can be reached at ${EmailTemplates.developerEmail}. '
        'Emails are read personally by the developer (this is an indie app, not '
        'a big team). Response times vary but you\'ll usually hear back within a '
        'few days.',
    followUps: [
      EmailChipAction(
        label: 'Email the developer',
        subject: EmailTemplates.generalSubject,
        body: EmailTemplates.generalBody,
      ),
      AskChipAction('How do I submit feedback?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'feedback and bug reports',
    phrases: [
      'how do i submit feedback',
      'how do i report a bug',
      'how do i suggest a feature',
      'feedback',
      'bug report',
    ],
    response:
        'You can send feedback, bug reports, or feature suggestions directly to '
        '${EmailTemplates.developerEmail}. Please include:\n'
        '- What happened (or what you\'d like to see)\n'
        '- Your Kuber version (Settings, About)\n'
        '- Your device model if it\'s a bug\n\n'
        'The more specific, the more useful. Every piece of feedback shapes '
        'Kuber.',
    followUps: [
      EmailChipAction(
        label: 'Email feedback',
        subject: EmailTemplates.feedbackSubject,
        body: EmailTemplates.feedbackBody,
      ),
    ],
  ),

  // ---- Data + backups -----------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'backing up data',
    phrases: [
      'how do i back up my data',
      'how to backup kuber',
      'backup my transactions',
    ],
    response:
        'Kuber offers two backup options.\n\n'
        '**Manual backup** (free): Go to Settings, Data, Export. Save the file '
        'somewhere safe like Google Drive, email to yourself, or copy to a '
        'computer.\n\n'
        '**Automatic backups** (Kuber Pro): Settings, Data, Automatic Backups. '
        'Set a schedule (daily, weekly, monthly) and Kuber creates encrypted '
        'backups automatically.',
    followUps: [
      NavChipAction(label: 'Go to Data settings', route: _rData),
      AskChipAction('How do I restore from backup?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'restoring from backup',
    phrases: [
      'how do i restore from backup',
      'how do i import my data',
      'restore transactions',
    ],
    response:
        'Go to Settings, Data, Import. Select your backup file (.json for full '
        'backup or .csv for transactions only). Kuber will restore your data. If '
        'you have existing data, you can choose to merge or replace it.',
    followUps: [
      NavChipAction(label: 'Go to Data settings', route: _rData),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'where data is stored',
    phrases: [
      'where is my data stored',
      'does kuber use the cloud',
      'where is my data',
    ],
    response:
        'All your data lives on your device only. Kuber has no servers, no '
        'accounts, no cloud sync. Even Kuber Pro purchases go through Google '
        'Play and don\'t require any Kuber-side account. This is core to '
        'Kuber\'s promise: your money data is yours, and it stays with you.',
    followUps: [
      AskChipAction('Is my data safe?'),
      AskChipAction('Does Kuber send my data anywhere?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'exporting data',
    phrases: [
      'how do i export my data',
      'export transactions',
      'download my data',
    ],
    response:
        'Settings, Data, Export. Choose CSV (for spreadsheets) or JSON (for full '
        'backup with everything). The file downloads to your device where you '
        'can share, email, or upload it anywhere.',
    followUps: [
      NavChipAction(label: 'Go to Data settings', route: _rData),
    ],
  ),

  // ---- Privacy ------------------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'data safety',
    phrases: [
      'is my data safe',
      'is my financial data secure',
      'is my data secure',
      'is kuber secure',
      'how does kuber protect my data',
    ],
    response:
        'Yes. Kuber stores data only on your device using encrypted local '
        'storage. Nothing goes to any server. No accounts, no tracking, no '
        'analytics that identify you personally. Your data is only as accessible '
        'as your phone is.',
    followUps: [
      AskChipAction('Where is my data stored?'),
      AskChipAction('Does Kuber read all my SMS?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'data sharing',
    phrases: [
      'does kuber send my data anywhere',
      'does kuber track me',
      'does kuber share my data',
    ],
    response:
        'No. Kuber never sends your financial data anywhere. The only external '
        'calls the app makes are:\n'
        '- Google Play (for Pro purchases and to check for app updates)\n'
        '- A single fetch on cold start for marketing config (banners, feature '
        'announcements)\n\n'
        'None of these include your transactions, accounts, or any financial '
        'information.',
    followUps: [
      AskChipAction('How does Privacy Mode work?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Privacy Mode',
    phrases: [
      'how does privacy mode work',
      'how do i hide balances',
      'what is privacy mode',
    ],
    response:
        'Privacy Mode blurs all balance and amount displays across the app with '
        'a single tap. Useful when someone\'s looking over your shoulder or when '
        'you\'re taking screenshots. Toggle from Settings, Privacy, or via the '
        'eye icon in the app header.',
    followUps: [
      NavChipAction(label: 'Go to Privacy settings', route: _rPrivacy),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'SMS access',
    phrases: [
      'does kuber read all my sms',
      'does kuber read my messages',
      'what does sms import access',
    ],
    response:
        'No. Kuber only reads bank transaction SMS messages when you actively '
        'open the Import from SMS screen. It never reads OTP messages, personal '
        'messages, or anything from senders that aren\'t known Indian banks and '
        'payment services. Nothing is sent anywhere. All parsing happens on your '
        'device.',
    followUps: [
      AskChipAction('How does SMS Import work?'),
    ],
  ),

  // ---- Feature discovery --------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'Kuber features',
    phrases: [
      'what can kuber do',
      'what are all the features',
      'kuber features',
      'what does kuber offer',
    ],
    response:
        'Kuber tracks your money across every dimension:\n\n'
        '- Accounts, transactions, budgets, categories, tags\n'
        '- Recurring transactions and automation\n'
        '- Loans, EMIs, investments\n'
        '- Lend/Borrow ledger\n'
        '- Reminders (Pro)\n'
        '- SMS import from banks (5 a week free, unlimited with Pro)\n'
        '- Kuber Notes with math in notes\n'
        '- Kuber Cards, a locked vault for card details\n'
        '- Money Stories with daily and weekly insights\n'
        '- 13 finance calculators\n'
        '- Analytics with charts and category breakdowns\n'
        '- 9 languages\n'
        '- Both light and dark themes\n\n'
        'All offline, no accounts needed.',
    followUps: [
      AskChipAction('What is in Kuber Pro?'),
      AskChipAction('What are Money Stories?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Money Stories',
    phrases: [
      'what are money stories',
      'how do stories work',
      'story bubbles',
    ],
    response:
        'Money Stories are Instagram-style bubbles at the top of your home '
        'screen showing your financial insights. Tap one to view a full-screen '
        'story with charts, comparisons, and highlights. Types include: Daily '
        'recap, Weekly summary, Monthly review, Top category, Loans update, '
        'Investment growth, and more. They\'re generated automatically as you '
        'use Kuber.',
    followUps: [
      AskChipAction('Can I see old stories?'),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'Reminders',
    phrases: [
      'how do reminders work',
      'what are reminders',
    ],
    response:
        'Reminders (Kuber Pro) let you set alerts for anything money-related: '
        'pay rent by the 5th, collect money from a friend, review budgets on the '
        '1st. When the reminder triggers, you get a notification with quick '
        'actions like "Mark done", "Snooze", or "Add as transaction". Great for '
        'building financial habits.',
    followUps: [
      NavChipAction(label: 'See Pro options', route: _rPaywall),
    ],
  ),

  // ---- App info -----------------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'app version',
    phrases: [
      'which version am i on',
      'what version is this',
      'app version',
    ],
    response:
        'Check Settings, About for your current app version. From there you can '
        'also see build information and links to what\'s new in this release.',
    followUps: [
      NavChipAction(label: 'Go to About', route: _rAbout),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'updating the app',
    phrases: [
      'how do i update the app',
      'update kuber',
      'is there a new version',
    ],
    response:
        'Kuber updates through Google Play. Open Play Store, tap your profile, '
        'Manage apps, Updates available, find Kuber and tap Update. To get '
        'updates automatically, enable auto-update for Kuber in Play Store '
        'settings.',
  ),
  _KnowledgeMatch(
    topicLabel: 'open source',
    phrases: [
      'is kuber open source',
      'where is the code',
      'github',
    ],
    response:
        'Kuber is not open source. It\'s built independently by a solo '
        'developer. That said, if you\'re curious about how something works or '
        'want to suggest improvements, feel free to email '
        '${EmailTemplates.developerEmail}.',
    followUps: [
      EmailChipAction(
        label: 'Email the developer',
        subject: EmailTemplates.generalSubject,
        body: EmailTemplates.generalBody,
      ),
    ],
  ),

  // ---- Troubleshooting ----------------------------------------------------
  _KnowledgeMatch(
    topicLabel: 'app performance',
    phrases: [
      'the app is slow',
      'kuber is laggy',
      'app is jittery',
      'why is kuber slow',
    ],
    response:
        'A few things can help:\n'
        '1. Make sure you\'re on the latest version (Play Store, Updates)\n'
        '2. Restart the app (swipe away from recents, reopen)\n'
        '3. If it\'s still slow, try Settings, Developer Tools, Troubleshoot for '
        'diagnostic options\n\n'
        'If the problem persists, please email ${EmailTemplates.developerEmail} '
        'with your device model and Kuber version so it can be looked into.',
    followUps: [
      NavChipAction(label: 'Go to Troubleshoot', route: _rDevTools),
      EmailChipAction(
        label: 'Email the developer',
        subject: EmailTemplates.bugReportSubject,
        body: EmailTemplates.bugReportBody,
      ),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'SMS import issues',
    phrases: [
      "sms import isn't working",
      'sms import isnt working',
      'sms import not detecting',
      "my bank sms aren't showing",
      'my bank sms arent showing',
    ],
    response:
        'Try these steps:\n'
        '1. Make sure Kuber has SMS permission (Settings, Permissions, SMS)\n'
        '2. Open Import from SMS and pull down to refresh\n'
        '3. Check that your bank actually sends transaction SMS (some banks only '
        'send app notifications)\n'
        '4. If your bank isn\'t recognized, email ${EmailTemplates.developerEmail} '
        'with the SMS format (redact sensitive info) and support can be added',
    followUps: [
      NavChipAction(label: 'Go to SMS Import', route: _rSmsImport),
    ],
  ),
  _KnowledgeMatch(
    topicLabel: 'missing data',
    phrases: [
      'my data disappeared',
      'where are my transactions',
      'kuber lost my data',
    ],
    response:
        'This is rare but a few possible causes:\n'
        '1. Check if you\'re on the correct app instance (some devices sync '
        'multiple profiles)\n'
        '2. Restore from your latest backup if you have one (Settings, Data, '
        'Import)\n'
        '3. If you don\'t have a backup, email ${EmailTemplates.developerEmail} '
        'immediately with details before making any changes, sometimes data can '
        'be recovered\n\n'
        'To prevent this in future, enable Automatic Backups (Kuber Pro) or '
        'export manually every so often.',
    followUps: [
      NavChipAction(label: 'Go to Data', route: _rData),
      EmailChipAction(
        label: 'Email the developer',
        subject: EmailTemplates.bugReportSubject,
        body: EmailTemplates.bugReportBody,
      ),
    ],
  ),
];
