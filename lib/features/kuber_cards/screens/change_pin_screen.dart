import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../data/card_keystore.dart';
import '../data/card_vault_service.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/cards_secure_scaffold.dart';
import '../widgets/kuber_pin_pad.dart';

/// Three-step PIN change: verify current -> enter new (with length toggle) ->
/// confirm new. Reused from feature settings and global Settings. On success the
/// vault is re-encrypted under the new key (code-owned). See `feature-settings.md`.
class ChangePinScreen extends ConsumerStatefulWidget {
  const ChangePinScreen({super.key});

  @override
  ConsumerState<ChangePinScreen> createState() => _ChangePinScreenState();
}

enum _Step { current, newPin, confirm }

class _ChangePinScreenState extends ConsumerState<ChangePinScreen> {
  _Step _step = _Step.current;
  int _currentLength = 6;
  int _newLength = 6;

  final _entry = ValueNotifier<String>('');
  String _currentPin = '';
  String _newPin = '';
  bool _error = false;
  int _attemptsLeft = 5;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    ref.read(cardVaultServiceProvider).readMeta().then((meta) {
      if (mounted && meta != null) {
        setState(() {
          _currentLength = meta.pinLength;
          _newLength = meta.pinLength;
        });
      }
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  void _onPadChanged(String v) {
    _entry.value = v;
    if (_error) setState(() => _error = false);
  }

  int get _length => _step == _Step.current ? _currentLength : _newLength;

  Future<void> _submit(String pin) async {
    switch (_step) {
      case _Step.current:
        final outcome =
            await ref.read(cardVaultServiceProvider).attemptUnlock(pin);
        if (!mounted) return;
        switch (outcome.status) {
          case UnlockStatus.success:
            ref.read(cardSessionProvider.notifier).unlock(outcome.key!);
            setState(() {
              _currentPin = pin;
              _entry.value = '';
              _error = false;
              _step = _Step.newPin;
            });
          case UnlockStatus.wrongPin:
            HapticFeedback.mediumImpact();
            setState(() {
              _error = true;
              _attemptsLeft = outcome.attemptsLeft;
              _entry.value = '';
            });
          case UnlockStatus.cooldown:
          case UnlockStatus.dayLocked:
            HapticFeedback.mediumImpact();
            setState(() => _entry.value = '');
            showKuberSnackBar(
              context,
              'Too many attempts. Try again later.',
              isError: true,
            );
          case UnlockStatus.noVault:
            break;
        }
      case _Step.newPin:
        setState(() {
          _newPin = pin;
          _entry.value = '';
          _error = false;
          _step = _Step.confirm;
        });
      case _Step.confirm:
        if (pin != _newPin) {
          HapticFeedback.mediumImpact();
          setState(() {
            _error = true;
            _entry.value = '';
          });
          return;
        }
        await _commit();
    }
  }

  Future<void> _commit() async {
    setState(() => _busy = true);
    final newKey = await ref.read(cardVaultServiceProvider).changePin(
          currentPin: _currentPin,
          newPin: _newPin,
          newPinLength: _newLength,
        );
    if (!mounted) return;
    if (newKey == null) {
      setState(() {
        _busy = false;
        _step = _Step.current;
        _entry.value = '';
        _error = true;
      });
      return;
    }
    ref.read(cardSessionProvider.notifier).unlock(newKey);
    ref.invalidate(cardVaultMetaProvider);

    // Keep biometric convenience working: re-store the new key if enabled.
    final meta = await ref.read(cardVaultServiceProvider).readMeta();
    if (meta?.biometricEnabled ?? false) {
      await CardKeystore.storeKey(newKey);
    }
    if (!mounted) return;
    Navigator.pop(context);
    showKuberSnackBar(context, 'PIN updated.');
  }

  String get _title => switch (_step) {
        _Step.current => 'Enter current PIN',
        _Step.newPin => 'Enter new PIN',
        _Step.confirm => 'Confirm new PIN',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CardsSecureScaffold(
      requiresUnlock: false,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: KuberAppBar(showBack: true, title: 'Change PIN'),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),
                Text(
                  _title,
                  style: localeFont(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                if (_step == _Step.newPin) ...[
                  KuberSegmented<int>(
                    groupValue: _newLength,
                    onChanged: (v) => setState(() {
                      _newLength = v;
                      _entry.value = '';
                    }),
                    segments: const [
                      KuberSegment(value: 4, label: '4 digits'),
                      KuberSegment(value: 6, label: '6 digits'),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.lg),
                ],
                ValueListenableBuilder<String>(
                  valueListenable: _entry,
                  builder: (_, entry, __) => CardsPinDots(
                      length: _length, filled: entry.length, error: _error),
                ),
                if (_error && _step == _Step.current) ...[
                  const SizedBox(height: 10),
                  Text('Wrong PIN. $_attemptsLeft attempts left.',
                      style: localeFont(fontSize: 13, color: cs.error)),
                ],
                if (_error && _step == _Step.confirm) ...[
                  const SizedBox(height: 10),
                  Text('That did not match. Try again.',
                      style: localeFont(fontSize: 13, color: cs.error)),
                ],
                const SizedBox(height: KuberSpacing.xl),
                if (_busy)
                  const CircularProgressIndicator()
                else
                  KuberPinPad(
                    length: _length,
                    value: _entry,
                    onChanged: _onPadChanged,
                    onSubmit: _submit,
                  ),
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
