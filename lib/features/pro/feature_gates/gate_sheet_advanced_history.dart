import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

// Owned by H-UI (localise; copy from advanced-history-v1/copy.md › Pro gate).
void showAdvancedHistoryGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.manage_search_rounded,
    featureName: 'Advanced History',
    headline: 'Advanced History is a Kuber Pro feature',
    body:
        'Type or build any filter over all your transactions, group and chart '
        'the results, save filters and export them as CSV with Kuber Pro.',
  );
}
