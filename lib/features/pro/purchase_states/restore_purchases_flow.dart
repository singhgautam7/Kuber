import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../paywall/pro_state.dart';
import 'purchase_failure_snackbar.dart';
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
Future<void> restorePurchases(
  BuildContext context,
  WidgetRef ref, {
  String successMessage = 'Purchase restored',
  String notFoundMessage = 'No previous purchase found',
}) async {
  final service = ref.read(purchaseServiceProvider)..watchForPurchase();
  // No Play Billing (no Play services / Play Store signed out), even after a
  // fresh re-check: say so now instead of spinning through every retry.
  if (!await service.ensureAvailable()) {
    if (context.mounted) showPlayStoreUnavailableSnackbar(context);
    return;
  }
  if (!context.mounted) return;

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
    // 1. First query — a forced, fresh Play reconcile. Surfacing connectivity
    //    failures (offline / Play timeout) explicitly here keeps them from
    //    being mislabeled as "no purchase found".
    await service.restorePurchases(source: 'manual_ui', force: true);

    // 2. Wait a beat for a restored purchase to land on the stream.
    success = await pollForProEntitlement(
      () => ref.read(kuberProStateProvider).isPro,
      timeout: const Duration(seconds: 2),
    );

    // 3. Still nothing? Run the 3s/8s retry ladder. A returning owner whose
    //    Play cache was cold on the first query is caught here — we do NOT
    //    show "No purchase found" until every retry has come back empty.
    if (!success) {
      success = await service.reconcileWithRetries(source: 'manual_ui');
    }
  } on TimeoutException catch (e) {
    isTimeout = true;
    caughtError = e;
    BillingDiagnostics.instance.recordError('restorePurchasesFlow:timeout', e);
  } catch (e, stack) {
    caughtError = e;
    BillingDiagnostics.instance.recordError(
      'restorePurchasesFlow:error',
      e,
      stack,
    );
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
    showKuberSnackBar(context, successMessage);
  } else {
    ref.read(restoreFailedSessionProvider.notifier).state = true;
    showKuberSnackBar(
      context,
      notFoundMessage,
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

/// Opens Google Play's redeem page (with [code] prefilled when given) and,
/// once the user comes back to Kuber, runs the full [restorePurchases] flow so
/// the redemption shows up without restarting the app.
///
/// `launchUrl` returns as soon as Play opens, not when the user returns, so
/// the check waits for the app to go to the background and come back first.
Future<void> redeemOnPlayStore(
  BuildContext context,
  WidgetRef ref, {
  String? code,
}) async {
  final c = code?.trim() ?? '';
  final uri = Uri.parse(
    c.isEmpty
        ? 'https://play.google.com/redeem'
        : 'https://play.google.com/redeem?code=${Uri.encodeQueryComponent(c)}',
  );
  ref.read(purchaseServiceProvider).watchForPurchase();
  final returned = waitForReturnToApp();
  final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!launched) {
    returned.ignore();
    if (context.mounted) showPlayStoreUnavailableSnackbar(context);
    return;
  }
  // If the screen that opened the sheet is gone, its `ref` is too; the
  // app-level resume reconcile (app.dart) still picks the redemption up.
  if (!await returned || !context.mounted) return;
  await checkRedemption(context, ref);
}

/// The [restorePurchases] flow worded for a promo-code redemption.
Future<void> checkRedemption(BuildContext context, WidgetRef ref) {
  return restorePurchases(
    context,
    ref,
    successMessage: 'Kuber Pro unlocked',
    notFoundMessage: "Couldn't find your redemption yet",
  );
}

/// Completes true when the app goes to the background and then comes back to
/// the foreground, or false after [timeout]. A resume without a prior
/// background (a dialog, a chooser) does not count.
Future<bool> waitForReturnToApp({
  Duration timeout = const Duration(minutes: 30),
}) {
  final done = Completer<bool>();
  var wentAway = false;
  late final AppLifecycleListener listener;
  listener = AppLifecycleListener(
    onHide: () => wentAway = true,
    onPause: () => wentAway = true,
    onResume: () {
      if (wentAway && !done.isCompleted) done.complete(true);
    },
  );
  return done.future
      .timeout(timeout, onTimeout: () => false)
      .whenComplete(listener.dispose);
}

/// Information dialog shown when restore returns "No previous purchase found",
/// offering the documented workaround for Samsung / Play Store client cache sync.
void showPlayStoreCacheHelpDialog(BuildContext context) {
  final cs = Theme.of(context).colorScheme;

  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberShape.extraLarge),
      ),
      title: Text(
        'Didn\'t find your purchase?',
        style: localeFont(
          fontWeight: FontWeight.w600,
          fontSize: 16,
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
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: KuberSpace.md),
            _StepRow(number: '1', text: 'Open the Google Play Store app.'),
            const SizedBox(height: KuberSpace.sm),
            _StepRow(
              number: '2',
              text: 'Tap your profile icon in the top right corner.',
            ),
            const SizedBox(height: KuberSpace.sm),
            _StepRow(
              number: '3',
              text: 'Tap "Manage apps & device" or pull down to refresh.',
            ),
            const SizedBox(height: KuberSpace.sm),
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
              borderRadius: BorderRadius.circular(KuberShape.medium),
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
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ),
        const SizedBox(width: KuberSpace.sm),
        Expanded(
          child: Text(
            text,
            style: localeFont(fontSize: 14, color: cs.onSurface, height: 1.35),
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
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cs.primary,
        ),
      ),
    );
  }
}
