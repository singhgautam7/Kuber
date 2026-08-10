import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

/// Kuber Cards Pro gate. Follows `gate_sheet_base.dart` exactly.
/// PRO-GATE: shown by `proGate(...)` when the user lacks Pro access. Gating is
/// globally OFF right now (see specs/pro-gating-disabled.md), so this never fires.
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
