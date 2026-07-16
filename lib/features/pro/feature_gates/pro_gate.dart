import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../paywall/pro_state.dart';

/// Central Kuber Pro feature gate. Returns true when the user may use a gated
/// feature right now (Pro or in-trial) and false otherwise, showing [gate] as
/// a side effect so the caller can simply bail.
///
/// Every gated entry point routes through here so the "trial counts as Pro"
/// rule ([KuberProState.hasProAccess]) lives in exactly one place:
///
/// ```dart
/// onTap: () {
///   if (proGate(context, ref, showSmsImportGateSheet)) {
///     context.push('/more/sms-import');
///   }
/// }
/// ```
bool proGate(
  BuildContext context,
  WidgetRef ref,
  void Function(BuildContext) gate,
) {
  if (ref.read(kuberProStateProvider).hasProAccess) return true;
  gate(context);
  return false;
}
