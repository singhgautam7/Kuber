import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showAskKuberLimitGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.auto_awesome_rounded,
    featureName: 'Ask Kuber',
    headline: "You've used your 5 weekly Ask Kuber messages",
    body:
        'Your free limit resets next week. Kuber Pro removes the weekly '
        'cap entirely, so you can ask as often as you like.',
  );
}
