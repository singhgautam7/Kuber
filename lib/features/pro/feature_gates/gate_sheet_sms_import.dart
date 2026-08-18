import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'gate_sheet_base.dart';

/// SMS Import is free to open and use; only the weekly import allowance is
/// capped. This sheet is shown when a free user hits that cap (not as an entry
/// gate). [resetDate] is when their weekly count rolls over, when known.
void showSmsImportLimitGateSheet(BuildContext context, {DateTime? resetDate}) {
  final resetLine = resetDate != null
      ? 'or wait until ${DateFormat('d MMM').format(resetDate)} for your weekly '
          'count to reset.'
      : 'or wait for your weekly count to reset.';
  showFeatureGateSheet(
    context,
    icon: Icons.sms_outlined,
    featureName: 'SMS Import',
    headline: 'Weekly SMS import limit reached',
    body:
        'Free accounts get 5 SMS imports a week. Upgrade to Kuber Pro for '
        'unlimited imports, $resetLine',
  );
}
