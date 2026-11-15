import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../pro/feature_gates/gate_sheet_advanced_history.dart';
import '../pro/feature_gates/pro_gate.dart';

/// Every entry point (More › Signature, History menu, History › Filter link)
/// opens Advanced History through here: Pro goes to the page, free users get
/// the gate sheet.
void openAdvancedHistory(BuildContext context, WidgetRef ref) {
  if (proGate(context, ref, showAdvancedHistoryGateSheet)) {
    context.push('/advanced-history');
  }
}
