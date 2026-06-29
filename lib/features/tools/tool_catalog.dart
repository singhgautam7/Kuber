import 'package:flutter/material.dart';

import 'widgets/tool_accents.dart';

/// Metadata for a single tool: route key, display name, subtitle, icon and
/// accent colour. Shared by the Tools landing page and the Saved Calculations
/// screen so naming/iconography stays consistent.
class ToolMeta {
  final String key; // route segment, e.g. 'emi-calculator'
  final String name;
  final String subtitle;
  final IconData icon;
  final Color accent;

  const ToolMeta({
    required this.key,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.accent,
  });
}

class ToolGroup {
  final String title;
  final List<ToolMeta> tools;
  const ToolGroup(this.title, this.tools);
}

class ToolCatalog {
  static const finance = ToolGroup('Finance Calculators', [
    ToolMeta(
      key: 'emi-calculator',
      name: 'EMI Calculator',
      subtitle: 'Monthly payment and total interest over the loan life',
      icon: Icons.account_balance_rounded,
      accent: ToolAccents.blue,
    ),
    ToolMeta(
      key: 'sip-calculator',
      name: 'Investment Returns',
      subtitle: 'How your investment grows over the years',
      icon: Icons.trending_up_rounded,
      accent: ToolAccents.green,
    ),
    ToolMeta(
      key: 'sip-amount-finder',
      name: 'SIP Amount',
      subtitle: 'Monthly amount to reach a target corpus',
      icon: Icons.savings_rounded,
      accent: ToolAccents.purple,
    ),
    ToolMeta(
      key: 'fd-rd-calculator',
      name: 'FD / RD',
      subtitle: 'Maturity value of fixed and recurring deposits',
      icon: Icons.account_balance_wallet_rounded,
      accent: ToolAccents.amber,
    ),
    ToolMeta(
      key: 'ppf-calculator',
      name: 'PPF Calculator',
      subtitle: 'Tax-free maturity built over 15 years',
      icon: Icons.shield_rounded,
      accent: ToolAccents.emerald,
    ),
    ToolMeta(
      key: 'inflation-calculator',
      name: 'Inflation',
      subtitle: 'What your money will be worth in the future',
      icon: Icons.trending_down_rounded,
      accent: ToolAccents.pink,
    ),
    ToolMeta(
      key: 'loan-prepayment',
      name: 'Loan Prepayment Impact',
      subtitle: 'Tenure and interest you could save',
      icon: Icons.content_cut_rounded,
      accent: ToolAccents.blue,
    ),
    ToolMeta(
      key: 'lumpsum-vs-sip',
      name: 'Lumpsum vs SIP',
      subtitle: 'Which way of investing the same money wins',
      icon: Icons.compare_arrows_rounded,
      accent: ToolAccents.emerald,
    ),
  ]);

  static const taxSalary = ToolGroup('Tax & Salary', [
    ToolMeta(
      key: 'salary-calculator',
      name: 'Salary Breakdown',
      subtitle: 'Take-home pay, old regime vs new regime',
      icon: Icons.work_rounded,
      accent: ToolAccents.blue,
    ),
    ToolMeta(
      key: 'gst-calculator',
      name: 'GST Calculator',
      subtitle: 'Add or remove GST from any amount',
      icon: Icons.percent_rounded,
      accent: ToolAccents.amber,
    ),
    ToolMeta(
      key: 'hra-calculator',
      name: 'HRA Exemption',
      subtitle: 'Exempt vs taxable portion of your HRA',
      icon: Icons.home_work_rounded,
      accent: ToolAccents.purple,
    ),
  ]);

  static const planning = ToolGroup('Planning', [
    ToolMeta(
      key: 'goal-planner',
      name: 'Goal Planner',
      subtitle: 'Monthly investment to reach a goal',
      icon: Icons.flag_rounded,
      accent: ToolAccents.amber,
    ),
    ToolMeta(
      key: 'retirement-corpus',
      name: 'Retirement Corpus',
      subtitle: 'Corpus you need and how to build it',
      icon: Icons.elderly_rounded,
      accent: ToolAccents.emerald,
    ),
  ]);

  static const quick = ToolGroup('Quick Calculators', [
    ToolMeta(
      key: 'split-calculator',
      name: 'Bill Splitter',
      subtitle: 'Split expenses between people',
      icon: Icons.people_rounded,
      accent: ToolAccents.blue,
    ),
    ToolMeta(
      key: 'currency-converter',
      name: 'Currency Converter',
      subtitle: 'Convert currencies',
      icon: Icons.currency_exchange_rounded,
      accent: ToolAccents.emerald,
    ),
    ToolMeta(
      key: 'breakeven-calculator',
      name: 'Break-even',
      subtitle: 'Months to recover',
      icon: Icons.timeline_rounded,
      accent: ToolAccents.green,
    ),
    ToolMeta(
      key: 'tip-calculator',
      name: 'Tip Calculator',
      subtitle: 'Bills and gratuity',
      icon: Icons.receipt_long_rounded,
      accent: ToolAccents.blue,
    ),
    ToolMeta(
      key: 'discount-calculator',
      name: 'Discount Calculator',
      subtitle: 'Find the best deal',
      icon: Icons.local_offer_rounded,
      accent: ToolAccents.red,
    ),
  ]);

  static const groups = [finance, taxSalary, planning, quick];

  static List<ToolMeta> get all =>
      [for (final g in groups) ...g.tools];

  static ToolMeta? byKey(String key) {
    for (final g in groups) {
      for (final t in g.tools) {
        if (t.key == key) return t;
      }
    }
    return null;
  }
}
