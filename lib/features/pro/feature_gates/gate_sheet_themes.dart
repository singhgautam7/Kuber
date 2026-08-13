import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

/// PRO-GATE: shown by `proGate(...)` when a free user selects a non-Signature
/// accent family. Kuber Signature (light + dark) is free; the other six accent
/// families are Kuber Pro.
void showThemesGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.palette_outlined,
    featureName: 'Custom themes',
    headline: 'Accent themes are a Kuber Pro feature',
    body:
        'Kuber Signature is free in both light and dark. Kuber Pro unlocks the '
        'full set of accent families so you can recolour the whole app.',
  );
}
