import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../paywall/pro_state.dart';
import '../services/purchase_service.dart';

/// Asks Play Billing to re-report prior purchases (via
/// [PurchaseService.restorePurchases]) to recover an entitlement the app has
/// forgotten, e.g. after a reinstall. Restored purchases arrive on the
/// purchase stream and re-grant entitlement there; this flow just drives the
/// query and reads the resulting state to give the user feedback. Never leaves
/// the caller in a loading state longer than a moment.
Future<void> restorePurchases(BuildContext context, WidgetRef ref) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(
      child: SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(strokeWidth: 3),
      ),
    ),
  );

  await ref.read(purchaseServiceProvider).restorePurchases();
  // The query has been issued; restored PurchaseDetails land on the stream
  // just after. Give that a beat to apply before reading entitlement so the
  // feedback below reflects the real outcome.
  await Future<void>.delayed(const Duration(milliseconds: 600));

  if (!context.mounted) return;
  Navigator.of(context, rootNavigator: true).pop();

  final current = ref.read(kuberProStateProvider);
  if (current.isPro) {
    showKuberSnackBar(context, 'Purchase restored');
  } else {
    showKuberSnackBar(context, 'No previous purchase found', isError: false);
  }
}

/// Footer "Restore purchases" link used on the paywall and in Settings.
class RestorePurchasesLink extends ConsumerWidget {
  const RestorePurchasesLink({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: () => restorePurchases(context, ref),
      child: Text(
        'Restore purchases',
        style: localeFont(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: cs.primary,
        ),
      ),
    );
  }
}
