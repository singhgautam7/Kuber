import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showBackupsGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.backup_outlined,
    featureName: 'Automatic Backups',
    headline: 'Automatic Backups is a Kuber Pro feature',
    body:
        'Kuber Pro backs up your data on a schedule you set, so a lost or '
        'reset phone never means lost history.',
  );
}
