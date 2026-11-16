import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/kuber_cards_provider.dart';
import '../screens/cards_unlock_screen.dart';
import 'card_keystore.dart';
import 'card_vault_service.dart';

enum CardBiometricResult {
  enabled,
  disabled,

  /// The check was cancelled or failed.
  cancelled,

  /// No fingerprint, face or screen lock on this phone: the PIN still works.
  unavailable,

  /// The vault is locked, so there is no key to store yet.
  needsUnlock,
  failed,
}

/// Kuber Cards biometric on or off. Independent of the app's biometric lock:
/// this touches only the vault's own flag and its Keystore key, never the
/// `biometricsEnabled` pref (the app lock never touches the vault either).
Future<CardBiometricResult> setCardBiometric(
  WidgetRef ref,
  bool enable, {
  BiometricService? biometric,
  Future<bool> Function()? unlock,
}) async {
  final bio = biometric ?? BiometricService();
  final service = ref.read(cardVaultServiceProvider);
  if (enable) {
    // Needs the unlocked vault's derived key, stored after a biometric check
    // (never the PIN). See specs/plans/kuber-cards.md §2.5.
    // Locked (Cards not opened yet): [unlock] asks for the PIN right here.
    var key = ref.read(cardSessionProvider).key;
    final wasLocked = key == null;
    if (wasLocked && unlock != null && await unlock()) {
      key = ref.read(cardSessionProvider).key;
    }
    if (key == null) return CardBiometricResult.needsUnlock;
    try {
      return await _enable(ref, bio, service, key);
    } finally {
      // The vault was opened only for this switch: close it again.
      if (wasLocked) ref.read(cardSessionProvider.notifier).lock();
    }
  }
  return _disable(ref, bio, service);
}

Future<CardBiometricResult> _enable(WidgetRef ref, BiometricService bio,
    CardVaultService service, List<int> key) async {
  if (!await bio.canAuthenticate()) return CardBiometricResult.unavailable;
  if (!await bio.authenticate()) {
    return await bio.hasEnrolled()
        ? CardBiometricResult.cancelled
        : CardBiometricResult.unavailable;
  }
  if (!await CardKeystore.storeKey(key)) return CardBiometricResult.failed;
  await service.setBiometricEnabled(true);
  ref.invalidate(cardVaultMetaProvider);
  return CardBiometricResult.enabled;
}

Future<CardBiometricResult> _disable(
    WidgetRef ref, BiometricService bio, CardVaultService service) async {
  // With nothing enrolled there is nothing to check against, and the switch
  // must still turn off: the PIN keeps protecting the cards.
  if (!await bio.authenticate() && await bio.hasEnrolled()) {
    return CardBiometricResult.cancelled;
  }
  await CardKeystore.clear();
  await service.setBiometricEnabled(false);
  ref.invalidate(cardVaultMetaProvider);
  return CardBiometricResult.disabled;
}

/// [setCardBiometric] with its snackbar, for both places the switch lives.
Future<void> toggleCardBiometric(
  BuildContext context,
  WidgetRef ref,
  bool enable, {
  VoidCallback? onNeedsUnlock,
}) async {
  final l = context.l10n;
  final r = await setCardBiometric(ref, enable,
      unlock: () async =>
          await showDialog<bool>(
            context: context,
            useRootNavigator: true,
            builder: (ctx) => Dialog.fullscreen(
              child: CardsUnlockScreen(
                  onUnlocked: () => Navigator.of(ctx).pop(true)),
            ),
          ) ??
          false);
  if (!context.mounted) return;
  switch (r) {
    case CardBiometricResult.enabled:
      showKuberSnackBar(context, l.cardBiometricOn);
    case CardBiometricResult.disabled:
      showKuberSnackBar(context, l.cardBiometricOff);
    case CardBiometricResult.unavailable:
      showKuberSnackBar(context, l.cardBiometricUnavailable, isError: true);
    case CardBiometricResult.needsUnlock:
      showKuberSnackBar(
        context,
        l.cardBiometricUnlockFirst,
        actionLabel: onNeedsUnlock == null ? null : l.cardBiometricOpen,
        onAction: onNeedsUnlock,
      );
    case CardBiometricResult.failed:
      showKuberSnackBar(context, l.cardBiometricFailed, isError: true);
    case CardBiometricResult.cancelled:
      break;
  }
}
