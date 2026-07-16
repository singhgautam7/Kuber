import 'package:flutter/material.dart';

import 'gate_sheet_base.dart';

void showMultiCurrencyGateSheet(BuildContext context) {
  showFeatureGateSheet(
    context,
    icon: Icons.currency_exchange_rounded,
    featureName: 'Multi-currency',
    headline: 'Multi-currency is a Kuber Pro feature',
    body:
        'Track accounts and transactions in more than one currency. Kuber '
        'Pro removes the single-currency limit.',
  );
}
