import 'package:flutter/material.dart';

import 'tutorial_step_keys.dart';

class TutorialStep {
  final String title;
  final String description;
  final GlobalKey? targetKey;

  const TutorialStep({
    required this.title,
    required this.description,
    this.targetKey,
  });
}

class TutorialChapter {
  final String emoji;
  final String title;
  final String description;
  final String estimatedTime;
  final List<TutorialStep> steps;
  final String navigateTo;

  const TutorialChapter({
    required this.emoji,
    required this.title,
    required this.description,
    required this.estimatedTime,
    required this.steps,
    required this.navigateTo,
  });

  static final List<TutorialChapter> allChapters = [
    // Chapter 1 — Transactions
    TutorialChapter(
      emoji: '💸',
      title: 'Transactions',
      description: 'Add, edit, categorize, attach',
      estimatedTime: '~4 min',
      navigateTo: '/add-transaction',
      steps: [
        TutorialStep(
          title: 'Enter amount',
          description:
              'Type the amount directly. Tap the calculator icon to open the built-in expression calculator.',
          targetKey: TutorialStepKeys.amountField,
        ),
        TutorialStep(
          title: 'Transaction type',
          description:
              'Choose Income, Expense, or Transfer between your accounts.',
          targetKey: TutorialStepKeys.transactionTypeToggle,
        ),
        TutorialStep(
          title: 'Pick a category',
          description:
              'Categories organize your spending. Tap to choose an existing one or create your own.',
          targetKey: TutorialStepKeys.categoryPicker,
        ),
        TutorialStep(
          title: 'Pick an account',
          description:
              'Choose which wallet or bank account this belongs to.',
          targetKey: TutorialStepKeys.accountPicker,
        ),
        TutorialStep(
          title: 'Name it',
          description:
              'Start typing — Kuber will suggest from your past transactions automatically.',
          targetKey: TutorialStepKeys.descriptionField,
        ),
        TutorialStep(
          title: 'Smart suggestions',
          description:
              'Tap a suggestion to auto-fill the name, category, and account in one tap.',
          targetKey: TutorialStepKeys.suggestionList,
        ),
        TutorialStep(
          title: 'Notes & attachments',
          description:
              'Add context or attach a photo of your receipt.',
          targetKey: TutorialStepKeys.notesField,
        ),
        TutorialStep(
          title: 'Add tags',
          description:
              'Tags are custom labels that group transactions across categories.',
          targetKey: TutorialStepKeys.tagsPicker,
        ),
      ],
    ),

    // Chapter 2 — Home
    TutorialChapter(
      emoji: '🏠',
      title: 'Home',
      description: 'Dashboard, recurring, smart insights',
      estimatedTime: '~3 min',
      navigateTo: '/',
      steps: [
        TutorialStep(
          title: 'Your monthly snapshot',
          description:
              'Net flow for this month at a glance — green is income, red is expense. Tap to drill down.',
          targetKey: TutorialStepKeys.dashboardBalanceCard,
        ),
        TutorialStep(
          title: 'Privacy mode',
          description:
              'Tap the eye icon to instantly hide every balance. Perfect for public places.',
          targetKey: TutorialStepKeys.privacyModeIcon,
        ),
        TutorialStep(
          title: 'Quick Add',
          description:
              'Log a transaction in seconds without opening the full form. Just type and go.',
          targetKey: TutorialStepKeys.quickAddFab,
        ),
        TutorialStep(
          title: 'Recent transactions',
          description:
              'Your last few transactions appear below the balance card. Tap any to view or edit.',
        ),
        TutorialStep(
          title: 'Navigation',
          description:
              'Use the bottom bar to switch between Home, History, Analytics, and More.',
        ),
      ],
    ),

    // Chapter 3 — History
    TutorialChapter(
      emoji: '📋',
      title: 'History',
      description: 'Browse, filter, search, export',
      estimatedTime: '~2 min',
      navigateTo: '/history',
      steps: [
        TutorialStep(
          title: 'Transaction timeline',
          description:
              'All your transactions, grouped by date. Most recent at the top.',
          targetKey: TutorialStepKeys.historyList,
        ),
        TutorialStep(
          title: 'Quick filters',
          description:
              'Filter by Income, Expense, or Transfer instantly using these chips.',
          targetKey: TutorialStepKeys.historyQuickFilters,
        ),
        TutorialStep(
          title: 'Advanced filters',
          description:
              'Tap the filter icon to search by date range, account, category, or tags simultaneously.',
          targetKey: TutorialStepKeys.historyFilterIcon,
        ),
        TutorialStep(
          title: 'Tap to edit',
          description:
              'Tap any transaction to view full details, edit fields, or delete it.',
          targetKey: TutorialStepKeys.historyFirstItem,
        ),
      ],
    ),

    // Chapter 4 — Analytics
    TutorialChapter(
      emoji: '📊',
      title: 'Analytics',
      description: 'Heatmap, trends, distributions',
      estimatedTime: '~2 min',
      navigateTo: '/analytics',
      steps: [
        TutorialStep(
          title: 'Your financial snapshot',
          description:
              'Visual breakdowns of where your money goes each month.',
          targetKey: TutorialStepKeys.analyticsPage,
        ),
        TutorialStep(
          title: 'Spending trends',
          description:
              'A bar chart showing daily spending. Switch between 7-day and custom time ranges.',
          targetKey: TutorialStepKeys.spendingTrendsChart,
        ),
        TutorialStep(
          title: 'Category breakdown',
          description:
              'See which categories consume the most of your budget at a glance.',
          targetKey: TutorialStepKeys.categoryBreakdownChart,
        ),
        TutorialStep(
          title: 'Filters carry over',
          description:
              'Any filters you set on the History page also update your analytics view.',
        ),
      ],
    ),

    // Chapter 5 — More & Settings
    TutorialChapter(
      emoji: '⚙️',
      title: 'More & Settings',
      description: 'Settings, accounts, calculators',
      estimatedTime: '~2 min',
      navigateTo: '/more',
      steps: [
        TutorialStep(
          title: 'Budgets',
          description:
              'Set monthly spending limits per category. Kuber tracks your progress automatically.',
          targetKey: TutorialStepKeys.moreBudgetsItem,
        ),
        TutorialStep(
          title: 'Ask Kuber',
          description:
              'Your on-device AI assistant. Ask questions about your spending — fully private, no internet needed.',
          targetKey: TutorialStepKeys.moreAskKuberItem,
        ),
        TutorialStep(
          title: 'Your data',
          description:
              'Export as CSV, import from backup, or generate sample data. Everything stays on your device.',
          targetKey: TutorialStepKeys.moreDataItem,
        ),
      ],
    ),
  ];
}
