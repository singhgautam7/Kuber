import 'package:flutter/material.dart';

import '../../../core/models/info_config.dart';

/// Content for the "How it works" help bottom sheet (reuses the shared
/// [KuberInfoBottomSheet] / [KuberInfoConfig]).
const askKuberInfoConfig = KuberInfoConfig(
  title: 'Ask Kuber',
  description:
      'Ask anything about your finances in plain English. Kuber runs entirely '
      'on-device (no internet required, no data shared).',
  items: [
    KuberInfoItem(
      icon: Icons.currency_rupee_rounded,
      title: 'Spending',
      description:
          '"How much have I spent today/this week/this month?" or "How much did I spend in the past two weeks?"',
    ),
    KuberInfoItem(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Balances & Net Worth',
      description:
          '"What\'s my net worth?", "What\'s my HDFC balance?", or "What\'s my total balance?"',
    ),
    KuberInfoItem(
      icon: Icons.category_outlined,
      title: 'Categories & Trends',
      description:
          '"What\'s my top spending category?", "How many categories do I have?", "Average monthly expense?"',
    ),
    KuberInfoItem(
      icon: Icons.account_balance_outlined,
      title: 'Loans & Borrowing',
      description:
          '"How much do I owe on loans?", "How much have I borrowed?", "How much have I lent?"',
    ),
    KuberInfoItem(
      icon: Icons.show_chart,
      title: 'Investments & Budgets',
      description:
          '"What\'s my portfolio value?", "Show my budgets", "Am I overspending on any budget?"',
    ),
    KuberInfoItem(
      icon: Icons.help_outline_rounded,
      title: 'How-to & app help',
      description:
          '"How do I add a transaction?", "How do I set a budget?", "Is my data private?"',
    ),
  ],
);
