import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showSmsImportGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.sms_outlined,
    featureName: 'SMS Import',
    headline: 'SMS Import is a Kuber Pro feature',
    body:
        'Kuber can read your bank SMS and fill in transactions for you, so '
        'you never type an expense by hand again. Unlock it with Kuber Pro.',
  );
}
