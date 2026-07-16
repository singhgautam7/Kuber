import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showNotesLimitGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.sticky_note_2_outlined,
    featureName: 'Kuber Notes',
    headline: "You've reached your 2-note limit",
    body:
        'Free accounts can keep 2 notes at a time. Kuber Pro gives you '
        'unlimited notes for quick jottings and math.',
  );
}
