import 'package:flutter/widgets.dart';

import 'tutorial_step_keys.dart';

class TutorialStep {
  final GlobalKey? key;
  final String title;
  final String description;
  final bool spotlight;

  const TutorialStep({
    required this.title,
    required this.description,
    this.key,
    this.spotlight = true,
  });
}

class TutorialChapter {
  final String emoji;
  final String title;
  final String description;
  final String route;
  final List<TutorialStep> steps;

  const TutorialChapter({
    required this.emoji,
    required this.title,
    required this.description,
    required this.route,
    required this.steps,
  });

  String get estimate => '~${steps.length <= 4 ? 1 : 2} min';
}

final tutorialChapters = <TutorialChapter>[
  TutorialChapter(
    emoji: '💸',
    title: 'Transactions',
    description: 'Add income, expenses, transfers, notes, receipts and tags.',
    route: '/add-transaction',
    steps: [
      TutorialStep(
        key: TutorialStepKeys.amountField,
        title: 'Enter amount',
        description:
            'Type the amount directly. Tap the calculator icon to open the built-in expression calculator.',
      ),
      TutorialStep(
        key: TutorialStepKeys.transactionTypeToggle,
        title: 'Transaction type',
        description:
            'Choose Income, Expense, or Transfer between your accounts.',
      ),
      TutorialStep(
        key: TutorialStepKeys.categoryPicker,
        title: 'Pick a category',
        description:
            'Categories organize your spending. Tap to choose an existing one or create your own.',
      ),
      TutorialStep(
        key: TutorialStepKeys.accountPicker,
        title: 'Pick an account',
        description: 'Choose which wallet or bank account this belongs to.',
      ),
      TutorialStep(
        key: TutorialStepKeys.descriptionField,
        title: 'Name it',
        description:
            'Start typing and Kuber will suggest from your past transactions automatically.',
      ),
      TutorialStep(
        key: TutorialStepKeys.suggestionList,
        title: 'Smart suggestions',
        description:
            'Tap a suggestion to auto-fill the name, category, and account in one tap.',
      ),
      TutorialStep(
        key: TutorialStepKeys.notesField,
        title: 'Notes & attachments',
        description: 'Add context or attach a photo of your receipt.',
      ),
      TutorialStep(
        key: TutorialStepKeys.tagsPicker,
        title: 'Add tags',
        description:
            'Tags are custom labels that group transactions across categories.',
      ),
    ],
  ),
  TutorialChapter(
    emoji: '🏠',
    title: 'Home',
    description: 'Read your monthly snapshot and use quick actions.',
    route: '/',
    steps: [
      TutorialStep(
        key: TutorialStepKeys.dashboardBalanceCard,
        title: 'Your monthly snapshot',
        description:
            'Net flow for this month at a glance. Green is income, red is expense. Tap to drill down.',
      ),
      TutorialStep(
        key: TutorialStepKeys.privacyModeIcon,
        title: 'Privacy mode',
        description:
            'Tap the eye icon to instantly hide every balance. Perfect for public places.',
      ),
      TutorialStep(
        key: TutorialStepKeys.quickAddFab,
        title: 'Quick Add',
        description:
            'Log a transaction in seconds without opening the full form. Just type and go.',
      ),
      TutorialStep(
        title: 'Recent transactions',
        description:
            'Your last few transactions appear below the balance card. Tap any to view or edit.',
        spotlight: false,
      ),
      TutorialStep(
        title: 'Navigation',
        description:
            'Use the bottom bar to switch between Home, History, Analytics, and More.',
        spotlight: false,
      ),
    ],
  ),
  TutorialChapter(
    emoji: '📋',
    title: 'History',
    description: 'Find, filter, inspect and edit past transactions.',
    route: '/history',
    steps: [
      TutorialStep(
        key: TutorialStepKeys.historyList,
        title: 'Transaction timeline',
        description:
            'All your transactions, grouped by date. Most recent at the top.',
      ),
      TutorialStep(
        key: TutorialStepKeys.historyQuickFilters,
        title: 'Quick filters',
        description:
            'Filter by Income, Expense, or Transfer instantly using these chips.',
      ),
      TutorialStep(
        key: TutorialStepKeys.historyFilterIcon,
        title: 'Advanced filters',
        description:
            'Tap the filter icon to search by date range, account, category, or tags simultaneously.',
      ),
      TutorialStep(
        key: TutorialStepKeys.historyFirstItem,
        title: 'Tap to edit',
        description:
            'Tap any transaction to view full details, edit fields, or delete it.',
      ),
    ],
  ),
  TutorialChapter(
    emoji: '📊',
    title: 'Analytics',
    description: 'Spot trends and understand where your money goes.',
    route: '/analytics',
    steps: [
      TutorialStep(
        key: TutorialStepKeys.analyticsPage,
        title: 'Your financial snapshot',
        description: 'Visual breakdowns of where your money goes each month.',
      ),
      TutorialStep(
        key: TutorialStepKeys.spendingTrendsChart,
        title: 'Spending trends',
        description:
            'A bar chart showing daily spending. Switch between 7-day and custom time ranges.',
      ),
      TutorialStep(
        key: TutorialStepKeys.categoryBreakdownChart,
        title: 'Category breakdown',
        description:
            'See which categories consume the most of your budget at a glance.',
      ),
      TutorialStep(
        title: 'Filters carry over',
        description:
            'Any filters you set on the History page also update your analytics view.',
        spotlight: false,
      ),
    ],
  ),
  TutorialChapter(
    emoji: '⚙️',
    title: 'More & Settings',
    description: 'Customize Kuber, manage data and explore deeper tools.',
    route: '/more',
    steps: [
      TutorialStep(
        key: TutorialStepKeys.moreBudgetsItem,
        title: 'Budgets',
        description:
            'Set monthly spending limits per category. Kuber tracks your progress automatically.',
      ),
      TutorialStep(
        key: TutorialStepKeys.moreAskKuberItem,
        title: 'Ask Kuber',
        description:
            'Your on-device AI assistant. Ask questions about your spending privately.',
      ),
      TutorialStep(
        key: TutorialStepKeys.moreDataItem,
        title: 'Your data',
        description:
            'Export as CSV, import from backup, or generate sample data. Everything stays on your device.',
      ),
    ],
  ),
];
