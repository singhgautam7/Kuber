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
const _rPrivacy = '/more/settings'; // privacy toggle lives inside Settings
const _rPaywall = '/pro';
const _rAbout = '/more/about';
const _rSmsImport = '/more/sms-import';

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
        '**Free tier includes:**\n'
        '- Manual transaction entry, budgets, categories, tags\n'
        '- All 13 calculators and tools\n'
        '- Basic analytics\n'
        '- Money Stories (last 30 days)\n'
        '- CSV export and import\n'
        '- 5 Ask Kuber messages per week\n'
        '- Up to 2 Kuber Notes\n'
        '- 1 account balance home widget\n\n'
        '**Kuber Pro adds:**\n'
        '- SMS Import (auto-detect bank transactions)\n'
        '- Unlimited Kuber Notes\n'
        '- Unlimited Ask Kuber messages\n'
        '- Reminders\n'
        '- Automatic Backups\n'
        '- Advanced Analytics with custom ranges\n'
        '- Multi-currency support\n'
        '- Custom themes\n'
        '- Full Money Stories history\n'
        '- Multiple account balance widgets\n\n'
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
        '- SMS import from banks (Pro)\n'
        '- Kuber Notes with math-in-notes\n'
        '- Money Stories with daily and weekly insights\n'
        '- 13 finance calculators\n'
        '- Analytics with charts and category breakdowns\n'
        '- 5 regional languages\n'
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
