import 'package:flutter/material.dart';
import '../models/info_config.dart';

class InfoConstants {
  static const accounts = KuberInfoConfig(
    title: 'How Accounts Work',
    description: 'Accounts represent where your money is stored or spent from.',
    items: [
      KuberInfoItem(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Track Balances',
        description: 'View real-time balances across all your accounts.',
      ),
      KuberInfoItem(
        icon: Icons.credit_card_outlined,
        title: 'Credit Cards',
        description: 'Track credit usage and outstanding dues separately.',
      ),
      KuberInfoItem(
        icon: Icons.sync_alt,
        title: 'Transfers',
        description: 'Move money between accounts without affecting net worth.',
      ),
      // KuberInfoItem(
      //   icon: Icons.history,
      //   title: 'Transaction History',
      //   description: 'Each account maintains its own transaction trail.',
      // ),
    ],
  );

  static const categories = KuberInfoConfig(
    title: 'How Categories Work',
    description: 'Categories help organize and understand your spending.',
    items: [
      KuberInfoItem(
        icon: Icons.category_outlined,
        title: 'Grouping',
        description: 'Categories are grouped for better organization.',
      ),
      KuberInfoItem(
        icon: Icons.insights_outlined,
        title: 'Spending Insights',
        description: 'Track where your money goes across categories.',
      ),
      KuberInfoItem(
        icon: Icons.account_tree_outlined,
        title: 'Flexible Types',
        description: 'Categories can be expense, income, or both.',
      ),
      KuberInfoItem(
        icon: Icons.pie_chart_outline,
        title: 'Analytics',
        description: 'Used in reports and charts to visualize trends.',
      ),
    ],
  );

  static const tags = KuberInfoConfig(
    title: 'How Tags Work',
    description: 'Tags add extra context to your transactions.',
    items: [
      KuberInfoItem(
        icon: Icons.sell_outlined,
        title: 'Custom Labels',
        description: 'Add labels like #trip, #work, or #personal.',
      ),
      KuberInfoItem(
        icon: Icons.filter_alt_outlined,
        title: 'Smart Filtering',
        description: 'Quickly filter transactions using tags.',
      ),
      KuberInfoItem(
        icon: Icons.layers_outlined,
        title: 'Multiple Tags',
        description: 'A transaction can have multiple tags.',
      ),
    ],
  );

  static const budgets = KuberInfoConfig(
    title: 'How Budgets Work',
    description: 'Budgets help you control and monitor your spending.',
    items: [
      KuberInfoItem(
        icon: Icons.calendar_today_outlined,
        title: 'Monthly Tracking',
        description: 'Budgets reset monthly or apply for a single period.',
      ),
      KuberInfoItem(
        icon: Icons.track_changes_outlined,
        title: 'Progress Tracking',
        description: 'See how much of your budget is used.',
      ),
      KuberInfoItem(
        icon: Icons.warning_amber_outlined,
        title: 'Overspending Alerts',
        description: 'Get notified when you exceed limits.',
      ),
      KuberInfoItem(
        icon: Icons.notifications_active_outlined,
        title: 'Alerts',
        description: 'Set alerts at different thresholds.',
      ),
    ],
  );

  static const ledger = KuberInfoConfig(
    title: 'About Lent / Borrow',
    description: 'Track money you lent to or borrowed from others.',
    items: [
      KuberInfoItem(
        icon: Icons.handshake_outlined,
        title: 'Lend & Borrow',
        description: 'Record when you lend money or borrow from someone.',
      ),
      KuberInfoItem(
        icon: Icons.payments_outlined,
        title: 'Track Payments',
        description: 'Log partial or full repayments over time.',
      ),
      KuberInfoItem(
        icon: Icons.check_circle_outline,
        title: 'Settlement',
        description: 'Mark entries as settled when fully repaid.',
      ),
      KuberInfoItem(
        icon: Icons.bar_chart_outlined,
        title: 'Separate from Analytics',
        description: 'Lent and borrowed amounts are excluded from spending analytics.',
      ),
    ],
  );

  static const recurring = KuberInfoConfig(
    title: 'How Recurring Works',
    description: 'Automate your regular income and expenses.',
    items: [
      KuberInfoItem(
        icon: Icons.repeat,
        title: 'Frequency',
        description: 'Set daily, weekly, monthly or custom schedules.',
      ),
      KuberInfoItem(
        icon: Icons.sync,
        title: 'Auto Processing',
        description: 'Transactions are created automatically when due.',
      ),
      KuberInfoItem(
        icon: Icons.bar_chart_outlined,
        title: 'Statistics',
        description: 'Analyze recurring totals and trends.',
      ),
      KuberInfoItem(
        icon: Icons.schedule,
        title: 'Upcoming',
        description: 'Track future and due transactions.',
      ),
      KuberInfoItem(
        icon: Icons.pause_circle_outline,
        title: 'Pause Anytime',
        description: 'Disable rules without deleting them.',
      ),
    ],
  );
}
