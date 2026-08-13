import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

/// Kuber Cards Pro gate. Follows `gate_sheet_base.dart` exactly.
/// PRO-GATE: shown by `proGate(...)` when the user lacks Pro access
/// (see specs/pro-gating-enabled.md).
void showKuberCardsGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.credit_card_rounded,
    featureName: 'Kuber Cards',
    headline: 'Keep your cards safe',
    body:
        'Kuber Cards stores your payment cards encrypted on this device, unlocked '
        'by your PIN. Free covers 2 cards. Kuber Pro unlocks unlimited cards.',
  );
}
