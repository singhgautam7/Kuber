import 'package:flutter/material.dart';

class TutorialStepKeys {
  // Chapter 1 — Transactions
  static final amountField = GlobalKey(debugLabel: 'amountField');
  static final transactionTypeToggle =
      GlobalKey(debugLabel: 'transactionTypeToggle');
  static final categoryPicker = GlobalKey(debugLabel: 'categoryPicker');
  static final accountPicker = GlobalKey(debugLabel: 'accountPicker');
  static final descriptionField = GlobalKey(debugLabel: 'descriptionField');
  static final suggestionList = GlobalKey(debugLabel: 'suggestionList');
  static final notesField = GlobalKey(debugLabel: 'notesField');
  static final tagsPicker = GlobalKey(debugLabel: 'tagsPicker');

  // Chapter 2 — Home (spotlight targets only)
  static final dashboardBalanceCard =
      GlobalKey(debugLabel: 'dashboardBalanceCard');
  static final privacyModeIcon = GlobalKey(debugLabel: 'privacyModeIcon');
  static final quickAddFab = GlobalKey(debugLabel: 'quickAddFab');

  // Chapter 3 — History
  static final historyList = GlobalKey(debugLabel: 'historyList');
  static final historyQuickFilters =
      GlobalKey(debugLabel: 'historyQuickFilters');
  static final historyFilterIcon = GlobalKey(debugLabel: 'historyFilterIcon');
  static final historyFirstItem = GlobalKey(debugLabel: 'historyFirstItem');

  // Chapter 4 — Analytics
  static final analyticsPage = GlobalKey(debugLabel: 'analyticsPage');
  static final spendingTrendsChart =
      GlobalKey(debugLabel: 'spendingTrendsChart');
  static final categoryBreakdownChart =
      GlobalKey(debugLabel: 'categoryBreakdownChart');

  // Chapter 5 — More
  static final moreBudgetsItem = GlobalKey(debugLabel: 'moreBudgetsItem');
  static final moreAskKuberItem = GlobalKey(debugLabel: 'moreAskKuberItem');
  static final moreDataItem = GlobalKey(debugLabel: 'moreDataItem');
}
