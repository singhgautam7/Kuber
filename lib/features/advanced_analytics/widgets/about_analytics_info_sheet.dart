import 'package:flutter/material.dart';

import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';

const kAboutAdvancedAnalyticsInfoConfig = KuberInfoConfig(
  title: 'About Advanced Analytics',
  description:
      'Advanced Analytics runs fully offline and computes financial insights entirely on your device.',
  items: [
    KuberInfoItem(
      icon: Icons.analytics_outlined,
      title: 'What it is',
      description:
          'Deeper views into trends, cash flow, patterns, forecasts, merchants, savings rate, financial health, anomalies, and category behavior.',
    ),
    KuberInfoItem(
      icon: Icons.online_prediction_rounded,
      title: 'Forecast',
      description:
          'Estimates based on current month activity, active recurring commitments, discretionary pace, and recent monthly history. These are estimates, not precise predictions.',
    ),
    KuberInfoItem(
      icon: Icons.favorite_border_rounded,
      title: 'Health score',
      description:
          'Combines Savings Rate, Expense Ratio, Budget Adherence, Emergency Fund, and Debt Ratio into five 0-20 components. Missing income-dependent data is skipped instead of showing a false score.',
    ),
    KuberInfoItem(
      icon: Icons.shield_outlined,
      title: 'Privacy',
      description:
          'All calculations run locally on your device. No financial data ever leaves your phone.',
    ),
  ],
  customChild: _DateFilterBlock(),
);

void showAboutAdvancedAnalyticsSheet(BuildContext context) {
  KuberInfoBottomSheet.show(context, kAboutAdvancedAnalyticsInfoConfig);
}

/// Which sections honour the section date filter and which use a fixed or
/// independent window. Rendered as the shared [InfoTable] so it matches every
/// other key/value table in the app.
class _DateFilterBlock extends StatelessWidget {
  const _DateFilterBlock();

  static const _ownFilter = <String>[
    'Trends',
    'Category deep-dive',
    'Spending patterns',
    'Cash flow and ledger',
    'Merchant analysis',
    'Savings rate',
  ];

  static const _fixedWindow = <String>[
    'Forecast',
    'Anomaly detection',
    'Financial health score',
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final warning = context.kuberColors.warning;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Date filters',
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          InfoTable(
            rows: [
              for (final section in _ownFilter)
                InfoTableDataRow(
                  label: section,
                  value: 'Own filter',
                  valueColor: cs.tertiary,
                ),
              for (final section in _fixedWindow)
                InfoTableDataRow(
                  label: section,
                  value: 'Fixed window',
                  valueColor: warning,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

