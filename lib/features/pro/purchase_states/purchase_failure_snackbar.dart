import 'package:flutter/material.dart';

import '../../../../shared/widgets/timed_snackbar.dart';

/// The three Play Billing failure modes called out in the spec (Section 10).
/// Each returns the user to the paywall in whatever state it was already in;
/// none of these ever navigate away or clear state.
///
/// [overlay] lets a global caller (the purchase service, which only holds a
/// root-navigator context) supply the overlay directly — see
/// [showKuberSnackBar].

void showPurchaseCancelledSnackbar(BuildContext context, {OverlayState? overlay}) {
  showKuberSnackBar(context, 'Purchase cancelled',
      isError: false, overlay: overlay);
}

void showPurchaseFailedSnackbar(
  BuildContext context, {
  VoidCallback? onRetry,
  OverlayState? overlay,
}) {
  showKuberSnackBar(
    context,
    'Payment failed. Try again.',
    isError: true,
    actionLabel: onRetry != null ? 'Retry' : null,
    onAction: onRetry,
    overlay: overlay,
  );
}

void showPlayStoreUnavailableSnackbar(BuildContext context,
    {OverlayState? overlay}) {
  // Round 2: softened copy. This fires for a transient Play Services hiccup
  // as often as a real outage, so it should not read as a hard failure. This
  // is the single source for "billing unavailable" copy — do not duplicate it.
  showKuberSnackBar(
    context,
    'Play Store unavailable. Try again in a moment.',
    isError: true,
    overlay: overlay,
  );
}
