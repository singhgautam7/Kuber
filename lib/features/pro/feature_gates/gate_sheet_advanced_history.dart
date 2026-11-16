import 'package:flutter/material.dart';

import '../../../core/utils/l10n_ext.dart';
import 'gate_sheet_base.dart';

void showAdvancedHistoryGateSheet(BuildContext context) {
  final l = context.l10n;
  showFeatureGateSheet(
    context,
    icon: Icons.manage_search_rounded,
    featureName: l.ahdTitle,
    headline: l.ahdGateSheetHeadline,
    body: l.ahdGateSheetBody,
  );
}
