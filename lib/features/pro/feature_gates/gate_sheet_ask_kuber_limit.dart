import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showAskKuberLimitGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.auto_awesome_rounded,
    featureName: 'Ask Kuber',
    headline: 'Weekly Ask Kuber limit reached',
    body:
        'Free accounts get 5 Ask Kuber messages a week. Your limit resets next '
        'week, or upgrade to Kuber Pro to remove the weekly cap entirely so you '
        'can ask as often as you like.',
  );
}
