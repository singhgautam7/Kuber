import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showAdvancedAnalyticsGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.insert_chart_outlined_rounded,
    featureName: 'Advanced Analytics',
    headline: 'Advanced Analytics is a Kuber Pro feature',
    body:
        'Unlock trends, category deep-dives, spending patterns, forecasts, '
        'cash flow, anomalies, merchant analysis, savings rate tracking and '
        'your financial health score with Kuber Pro.',
  );
}
