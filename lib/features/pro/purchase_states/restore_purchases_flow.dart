import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../paywall/pro_state.dart';
import '../services/billing_diagnostics.dart';
import '../services/purchase_service.dart';

/// Tracks whether a restore operation has failed (timed out, errored, or returned
/// "No purchase found") in the current app session. Used by the paywall screen
/// to conditionally display the "Report a billing issue" overflow menu action.
final restoreFailedSessionProvider = StateProvider<bool>((ref) => false);

/// Asks Play Billing to re-report prior purchases (via
/// [PurchaseService.restorePurchases]) to recover an entitlement the app has
/// forgotten, e.g. after a reinstall. Restored purchases arrive on the
/// purchase stream and re-grant entitlement there; this flow drives the query,
/// dynamically awaits the stream event, and provides user feedback with
/// full timeout & exception safety.
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

  bool success = false;
  bool isTimeout = false;
  Object? caughtError;

  try {
    // 1. Issue the query (with mutex and internal 10s timeout).
    await ref.read(purchaseServiceProvider).restorePurchases(source: 'manual_ui');

    // 2. Dynamically wait for the entitlement to update rather than a static sleep.
    // Restored PurchaseDetails arrive on the purchaseStream asynchronously.
    // Poll every 100ms up to 2.5s; exit immediately as soon as Pro is granted.
    for (var i = 0; i < 25; i++) {
      if (ref.read(kuberProStateProvider).isPro) {
        success = true;
        break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }

    if (!success) {
      success = ref.read(kuberProStateProvider).isPro;
    }
  } on TimeoutException catch (e) {
    isTimeout = true;
    caughtError = e;
    BillingDiagnostics.instance.recordError('restorePurchasesFlow:timeout', e);
  } catch (e, stack) {
    caughtError = e;
    BillingDiagnostics.instance.recordError('restorePurchasesFlow:error', e, stack);
  } finally {
    // 3. Always dismiss the loading dialog defensively.
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (!context.mounted) return;

  if (isTimeout) {
    ref.read(restoreFailedSessionProvider.notifier).state = true;
    showKuberSnackBar(
      context,
      'Restore timed out. Please try again.',
      isError: true,
    );
    return;
  }

  if (caughtError != null) {
    ref.read(restoreFailedSessionProvider.notifier).state = true;
    showKuberSnackBar(
      context,
      'Could not connect to Play Store. Please try again.',
      isError: true,
    );
    return;
  }

  if (success) {
    ref.read(restoreFailedSessionProvider.notifier).state = false;
    showKuberSnackBar(context, 'Purchase restored');
  } else {
    ref.read(restoreFailedSessionProvider.notifier).state = true;
    showKuberSnackBar(
      context,
      'No previous purchase found',
      isError: false,
      actionLabel: 'Help',
      onAction: () {
        if (context.mounted) {
          showPlayStoreCacheHelpDialog(context);
        }
      },
    );
  }
}

/// Information dialog shown when restore returns "No previous purchase found",
/// offering the documented workaround for Samsung / Play Store client cache sync.
void showPlayStoreCacheHelpDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.lg),
      ),
      title: Text(
        'Didn\'t find your purchase?',
        style: localeFont(
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: cs.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you already bought Kuber Pro on this Google account, Google Play Store may need a moment to refresh its purchase cache:',
              style: localeFont(
                fontSize: 13.5,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: KuberSpacing.md),
            _StepRow(
              number: '1',
              text: 'Open the Google Play Store app.',
            ),
            const SizedBox(height: KuberSpacing.sm),
            _StepRow(
              number: '2',
              text: 'Tap your profile icon in the top right corner.',
            ),
            const SizedBox(height: KuberSpacing.sm),
            _StepRow(
              number: '3',
              text: 'Tap "Manage apps & device" or pull down to refresh.',
            ),
            const SizedBox(height: KuberSpacing.sm),
            _StepRow(
              number: '4',
              text: 'Return to Kuber and tap "Restore purchases" again.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(
            'Close',
            style: localeFont(
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(ctx);
            final uri = Uri.parse('https://play.google.com/store/apps');
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          child: Text(
            'Open Play Store',
            style: localeFont(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    ),
  );
}

class _StepRow extends StatelessWidget {
  final String number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(width: KuberSpacing.sm),
        Expanded(
          child: Text(
            text,
            style: localeFont(
              fontSize: 13,
              color: cs.onSurface,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
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
