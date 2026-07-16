import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showRemindersGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.notifications_active_outlined,
    featureName: 'Reminders',
    headline: 'Reminders is a Kuber Pro feature',
    body:
        'Get nudged before bills, EMIs and renewals are due, so nothing '
        'slips through. Reminders are unlimited on Kuber Pro.',
  );
}
