import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../data/card_keystore.dart';
import '../data/card_vault_service.dart';
import '../providers/kuber_cards_provider.dart';
import 'kuber_pin_pad.dart';

/// The post-import "Encrypted cards found" prompt (see `import-flow.md`). Shown
/// after a JSON restore that carried locked Kuber Cards. The user enters the PIN
/// from the device that made the backup to unlock and keep the cards, or
/// discards them (the rest of the imported data is untouched).
///
/// Biometric is intentionally NOT offered here: this device's biometric maps to
/// this device's PIN, which may differ from the backup's PIN. Only PIN entry can
/// decrypt the imported payload.
Future<void> showImportedCardsPrompt(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    isDismissible: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ImportedCardsSheet(),
  );
}

class _ImportedCardsSheet extends ConsumerStatefulWidget {
  const _ImportedCardsSheet();

  @override
  ConsumerState<_ImportedCardsSheet> createState() =>
      _ImportedCardsSheetState();
}

class _ImportedCardsSheetState extends ConsumerState<_ImportedCardsSheet> {
  int _pinLength = 6;
  int _cardCount = 0;
  bool _ready = false;

  String _pin = '';
  bool _error = false;
  int _attemptsLeft = 5;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final service = ref.read(cardVaultServiceProvider);
    final meta = await service.readMeta();
    final cards = await service.allCards();
    if (!mounted) return;
    setState(() {
      _pinLength = meta?.pinLength ?? 6;
      _cardCount = cards.length;
      _ready = true;
    });
  }

  void _onChanged(String v) => setState(() {
        _pin = v;
        _error = false;
      });

  Future<void> _submit(String pin) async {
    if (_busy) return;
    // Capture the navigator + a root overlay/context before the async gap: the
    // sheet's own context is dead once we pop, but these outlive it, so the
    // confirmation snackbar still resolves an overlay.
    final navigator = Navigator.of(context);
    final overlay = Overlay.of(context, rootOverlay: true);
    final rootContext = navigator.context;
    setState(() => _busy = true);
    final outcome = await ref.read(cardVaultServiceProvider).attemptUnlock(pin);
    if (!mounted) return;
    setState(() => _busy = false);
    switch (outcome.status) {
      case UnlockStatus.success:
        // The imported vault is now this device's vault. Open the session and
        // refresh the card providers so the cards render, then confirm.
        ref.read(cardSessionProvider.notifier).unlock(outcome.key!);
        ref.invalidate(cardVaultMetaProvider);
        ref.read(storedCardsProvider.notifier).reload();
        navigator.pop();
        if (rootContext.mounted) {
          showKuberSnackBar(
            rootContext,
            _cardCount == 1
                ? '1 card added from your backup.'
                : '$_cardCount cards added from your backup.',
            overlay: overlay,
          );
        }
      case UnlockStatus.wrongPin:
        HapticFeedback.mediumImpact();
        setState(() {
          _error = true;
          _attemptsLeft = outcome.attemptsLeft;
          _pin = '';
        });
      case UnlockStatus.cooldown:
      case UnlockStatus.dayLocked:
        HapticFeedback.mediumImpact();
        setState(() => _pin = '');
        if (rootContext.mounted) {
          showKuberSnackBar(
            rootContext,
            'Too many attempts. Try unlocking these cards later from Kuber Cards.',
            isError: true,
            overlay: overlay,
          );
        }
      case UnlockStatus.noVault:
        navigator.pop();
    }
  }

  Future<void> _discard() async {
    if (_busy) return;
    final navigator = Navigator.of(context);
    final overlay = Overlay.of(context, rootOverlay: true);
    final rootContext = navigator.context;
    setState(() => _busy = true);
    await ref.read(cardVaultServiceProvider).discardImportedVault();
    await CardKeystore.clear();
    ref.read(cardSessionProvider.notifier).lock();
    ref.invalidate(cardVaultMetaProvider);
    ref.read(storedCardsProvider.notifier).reload();
    if (!mounted) return;
    navigator.pop();
    if (rootContext.mounted) {
      showKuberSnackBar(rootContext, 'Imported cards discarded.',
          overlay: overlay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KuberBottomSheet(
      title: 'Encrypted cards found',
      leadingIcon: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Icon(Icons.credit_card_rounded, size: 22, color: cs.primary),
      ),
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Not now',
              type: AppButtonType.outline,
              fullWidth: true,
              height: 46,
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: AppButton(
              label: 'Discard cards',
              type: AppButtonType.danger,
              fullWidth: true,
              height: 46,
              onPressed: _busy ? null : _discard,
            ),
          ),
        ],
      ),
      child: !_ready
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'This backup has cards from another device. Enter the PIN '
                  'from that device to unlock and add them here.',
                  style: localeFont(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                KuberCallout(
                  child: Text(
                    'This is the PIN from your old device, not this one.',
                    style: localeFont(
                      fontSize: 12.5,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(height: KuberSpacing.xl),
                CardsPinDots(
                  length: _pinLength,
                  filled: _pin.length,
                  error: _error,
                ),
                if (_error) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Wrong PIN. $_attemptsLeft attempts left.',
                    textAlign: TextAlign.center,
                    style: localeFont(fontSize: 13, color: cs.error),
                  ),
                ],
                const SizedBox(height: KuberSpacing.xl),
                KuberPinPad(
                  length: _pinLength,
                  value: _pin,
                  onChanged: _onChanged,
                  onSubmit: _submit,
                ),
              ],
            ),
    );
  }
}
