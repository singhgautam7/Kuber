import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showAdvancedAnalyticsGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.insert_chart_outlined_rounded,
    featureName: 'Advanced Analytics',
    headline: 'Advanced Analytics is a Kuber Pro feature',
    body:
        'See spending trends, category breakdowns and budget performance '
        'in more depth with Kuber Pro.',
  );
}
