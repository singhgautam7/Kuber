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

  static const loans = KuberInfoConfig(
    title: 'About Loans',
    description: 'Track your EMIs, outstanding balances and repayment progress.',
    items: [
      KuberInfoItem(
        icon: Icons.account_balance_outlined,
        title: 'EMI Tracking',
        description: 'Record monthly EMI payments and track progress.',
      ),
      KuberInfoItem(
        icon: Icons.trending_down,
        title: 'Outstanding Balance',
        description: 'See how much principal remains to be paid off.',
      ),
      KuberInfoItem(
        icon: Icons.calendar_month_outlined,
        title: 'Auto-Payment',
        description: 'Automatically create EMI transactions on bill date.',
      ),
      KuberInfoItem(
        icon: Icons.bar_chart_outlined,
        title: 'Separate from Analytics',
        description: 'Loan payments are excluded from spending analytics.',
      ),
    ],
  );

  static const investments = KuberInfoConfig(
    title: 'About Investments',
    description: 'Track your portfolio value, contributions and growth.',
    items: [
      KuberInfoItem(
        icon: Icons.show_chart,
        title: 'Portfolio Tracking',
        description: 'Track investments across SIP, stocks, crypto and more.',
      ),
      KuberInfoItem(
        icon: Icons.add_chart,
        title: 'Contributions',
        description: 'Record buy-ins and monthly SIP contributions.',
      ),
      KuberInfoItem(
        icon: Icons.trending_up,
        title: 'Gain & Loss',
        description: 'Compare current value against total invested for P&L.',
      ),
      KuberInfoItem(
        icon: Icons.bar_chart_outlined,
        title: 'Separate from Analytics',
        description: 'Investment contributions are excluded from spending analytics.',
      ),
    ],
  );

  static const billSplitter = KuberInfoConfig(
    title: 'About Bill Splitter',
    description: 'Split expenses fairly among friends and groups.',
    items: [
      KuberInfoItem(
        icon: Icons.receipt_long_rounded,
        title: 'Multiple Split Modes',
        description: 'Split equally, by amount, percentage, or custom fractions.',
      ),
      KuberInfoItem(
        icon: Icons.group_outlined,
        title: 'People List',
        description: 'Save people you split with for quick reuse.',
      ),
      KuberInfoItem(
        icon: Icons.handshake_outlined,
        title: 'Lend / Borrow',
        description: 'Add splits directly to your Lend/Borrow tracker (coming soon).',
      ),
    ],
  );

  static const currencyConverter = KuberInfoConfig(
    title: 'Currency Converter',
    description: 'Convert between currencies using live exchange rates.',
    items: [
      KuberInfoItem(
        icon: Icons.currency_exchange_rounded,
        title: 'Live Rates',
        description: 'Rates fetched from frankfurter.app.',
      ),
      KuberInfoItem(
        icon: Icons.offline_bolt_outlined,
        title: 'Offline Support',
        description: 'Cached rates used when offline (up to 24 hours old).',
      ),
      KuberInfoItem(
        icon: Icons.swap_horiz_rounded,
        title: 'Quick Swap',
        description: 'Swap FROM and TO currencies instantly.',
      ),
    ],
  );

  static const emiCalculator = KuberInfoConfig(
    title: 'EMI Calculator',
    description: 'Calculate monthly loan repayments and total interest.',
    items: [
      KuberInfoItem(
        icon: Icons.account_balance_outlined,
        title: 'EMI Formula',
        description: 'Uses standard reducing-balance EMI calculation.',
      ),
      KuberInfoItem(
        icon: Icons.percent_rounded,
        title: 'Annual Rate',
        description: 'Enter yearly interest rate — monthly rate is calculated automatically.',
      ),
      KuberInfoItem(
        icon: Icons.calendar_month_outlined,
        title: 'Flexible Tenure',
        description: 'Enter tenure in years or months.',
      ),
    ],
  );

  static const investmentReturnsCalculator = KuberInfoConfig(
    title: 'Investment Returns',
    description: 'Estimate SIP and lump-sum investment growth.',
    items: [
      KuberInfoItem(
        icon: Icons.trending_up_rounded,
        title: 'SIP (Monthly)',
        description: 'Systematic Investment Plan — invest a fixed amount each month.',
      ),
      KuberInfoItem(
        icon: Icons.payments_outlined,
        title: 'One Time',
        description: 'Lump-sum investment growth using monthly compounding.',
      ),
      KuberInfoItem(
        icon: Icons.show_chart,
        title: 'Estimated Returns',
        description: 'Results are projections based on constant return rate.',
      ),
    ],
  );

  static const sipAmountFinder = KuberInfoConfig(
    title: 'SIP Amount Finder',
    description: 'Find how much to invest monthly to reach your goal.',
    items: [
      KuberInfoItem(
        icon: Icons.flag_outlined,
        title: 'Goal-Based Planning',
        description: 'Enter your target amount, return rate, and time horizon.',
      ),
      KuberInfoItem(
        icon: Icons.calculate_rounded,
        title: 'Reverse SIP',
        description: 'Calculates the required monthly SIP to reach your goal.',
      ),
    ],
  );

  static const tipCalculator = KuberInfoConfig(
    title: 'Tip Calculator',
    description: 'Quickly calculate how much to tip.',
    items: [
      KuberInfoItem(
        icon: Icons.percent_rounded,
        title: 'Slider + Input',
        description: 'Adjust tip percentage with a slider or type it directly.',
      ),
      KuberInfoItem(
        icon: Icons.receipt_outlined,
        title: 'Total',
        description: 'Shows tip amount and final bill total.',
      ),
    ],
  );

  static const discountCalculator = KuberInfoConfig(
    title: 'Discount Calculator',
    description: 'Find out how much you save with a discount.',
    items: [
      KuberInfoItem(
        icon: Icons.local_offer_rounded,
        title: 'Discount Amount',
        description: 'See exactly how much you save.',
      ),
      KuberInfoItem(
        icon: Icons.price_check_rounded,
        title: 'Final Price',
        description: 'Shows the price after discount is applied.',
      ),
      KuberInfoItem(
        icon: Icons.tune_rounded,
        title: 'Slider Control',
        description: 'Adjust discount % with a slider or type it directly.',
      ),
    ],
  );

  static const gstCalculator = KuberInfoConfig(
    title: 'GST Calculator',
    description: 'Add or remove GST from any amount.',
    items: [
      KuberInfoItem(
        icon: Icons.add_circle_outline,
        title: 'Add GST',
        description: 'Calculate total amount with GST on top of base price.',
      ),
      KuberInfoItem(
        icon: Icons.remove_circle_outline,
        title: 'Remove GST',
        description: 'Extract base price from a GST-inclusive amount.',
      ),
      KuberInfoItem(
        icon: Icons.account_balance_outlined,
        title: 'CGST + SGST',
        description: 'GST is split equally into CGST and SGST components.',
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
