import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../data/card_keystore.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/cards_secure_scaffold.dart';
import '../widgets/kuber_pin_pad.dart';

/// First-time setup, six steps (see `onboarding-setup.md`). The one sanctioned
/// exception to the landing-page pattern: centered layout, back-only app bar,
/// step dots, sticky primary button.
class SetupFlowScreen extends ConsumerStatefulWidget {
  /// Called when setup completes and the user taps "Go to my cards".
  final VoidCallback onDone;

  const SetupFlowScreen({super.key, required this.onDone});

  @override
  ConsumerState<SetupFlowScreen> createState() => _SetupFlowScreenState();
}

class _SetupFlowScreenState extends ConsumerState<SetupFlowScreen> {
  final _biometric = BiometricService();

  int _step = 0;
  int _pinLength = 6;
  String _pin = '';
  String _confirm = '';
  bool _confirmError = false;
  bool _understood = false;
  bool _committing = false;
  bool _biometricAvailable = false;

  @override
  void initState() {
    super.initState();
    _biometric.canAuthenticate().then((v) {
      if (mounted) setState(() => _biometricAvailable = v);
    });
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    setState(() {
      if (_step == 2) _confirm = ''; // leaving confirm discards it
      _step -= 1;
    });
  }

  Future<void> _commitVault() async {
    setState(() => _committing = true);
    final key = await ref
        .read(cardVaultServiceProvider)
        .setupVault(pin: _pin, pinLength: _pinLength);
    if (!mounted) return;
    ref.read(cardSessionProvider.notifier).unlock(key);
    setState(() {
      _committing = false;
      _step = _biometricAvailable ? 4 : 5; // skip biometric if unavailable
    });
  }

  Future<void> _enableBiometric() async {
    final ok = await _biometric.authenticate();
    if (!ok || !mounted) return;
    // Store the derived key (never the PIN). The vault was just committed, so
    // the session holds the key.
    final key = ref.read(cardSessionProvider).key;
    if (key != null) await CardKeystore.storeKey(key);
    await ref.read(cardVaultServiceProvider).setBiometricEnabled(true);
    if (!mounted) return;
    setState(() => _step = 5);
  }

  void _finish() {
    // Refresh hasVault so the entry swaps setup -> home (replace, not push).
    ref.invalidate(cardVaultMetaProvider);
    widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CardsSecureScaffold(
      requiresUnlock: false,
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: KuberAppBar(showBack: true, showBrand: false, onBack: _back),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: _buildStep(cs),
                ),
              ),
              _StepDots(count: 6, active: _step),
              const SizedBox(height: KuberSpacing.md),
              _footer(cs),
            ],
          ),
        ),
      ),
    );
  }

  Widget _footer(ColorScheme cs) {
    switch (_step) {
      case 0:
        return _sticky(KuberSaveButton(label: 'Get started', onPressed: () => setState(() => _step = 1)));
      case 1:
        return _sticky(KuberSaveButton(
          label: 'Continue',
          onPressed:
              _pin.length == _pinLength ? () => setState(() => _step = 2) : null,
        ));
      case 2:
        return _sticky(KuberSaveButton(
          label: 'Continue',
          loading: _committing,
          onPressed: _confirm.length == _pinLength ? _onConfirm : null,
        ));
      case 3:
        return _sticky(KuberSaveButton(
          label: 'I understand',
          loading: _committing,
          onPressed: _understood ? _commitVault : null,
        ));
      case 4:
        return _sticky(Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            KuberSaveButton(
                label: 'Enable biometrics', onPressed: _enableBiometric),
            TextButton(
              onPressed: () => setState(() => _step = 5),
              child: Text('Skip for now',
                  style: localeFont(color: cs.onSurfaceVariant)),
            ),
          ],
        ));
      default:
        return _sticky(KuberSaveButton(label: 'Go to my cards', onPressed: _finish));
    }
  }

  Widget _sticky(Widget child) => child;

  void _onConfirm() {
    if (_confirm != _pin) {
      HapticFeedback.mediumImpact();
      setState(() {
        _confirmError = true;
        _confirm = '';
      });
      return;
    }
    setState(() => _step = 3);
  }

  Widget _buildStep(ColorScheme cs) {
    switch (_step) {
      case 0:
        return _intro(cs);
      case 1:
        return _setPin(cs);
      case 2:
        return _confirmPin(cs);
      case 3:
        return _backupWarning(cs);
      case 4:
        return _biometricStep(cs);
      default:
        return _done(cs);
    }
  }

  // ── Step 1: intro ──────────────────────────────────────────────────────────
  Widget _intro(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _tile(cs, Icons.credit_card_rounded, cs.primary, 0.10),
        const SizedBox(height: KuberSpacing.lg),
        Text('Kuber Cards',
            style: localeFont(
                fontSize: 28, fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          'Store your cards, encrypted, on your device. They never leave your phone.',
          textAlign: TextAlign.center,
          style: localeFont(
              fontSize: 15, color: cs.onSurfaceVariant, height: 1.5),
        ),
        const SizedBox(height: KuberSpacing.xl),
        _highlight(cs, Icons.lock_rounded, 'Encrypted at rest'),
        _highlight(cs, Icons.wifi_off_rounded, 'Works fully offline'),
        _highlight(cs, Icons.credit_card_off_rounded, 'Your CVV is never stored'),
        _highlight(cs, Icons.pin_rounded, 'Locked behind your PIN'),
        _highlight(
            cs, Icons.fingerprint_rounded, 'Biometric unlock for convenience'),
      ],
    );
  }

  Widget _highlight(ColorScheme cs, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: localeFont(fontSize: 14, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }

  // ── Step 2: set PIN ─────────────────────────────────────────────────────────
  Widget _setPin(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text('Set your PIN',
            style: localeFont(
                fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: KuberSpacing.sm),
        Text('Choose a PIN to lock your cards.',
            style: localeFont(fontSize: 14, color: cs.onSurfaceVariant)),
        const SizedBox(height: KuberSpacing.lg),
        KuberSegmented<int>(
          groupValue: _pinLength,
          onChanged: (v) => setState(() {
            _pinLength = v;
            _pin = ''; // changing length clears entry
          }),
          segments: const [
            KuberSegment(value: 4, label: '4 digits'),
            KuberSegment(value: 6, label: '6 digits'),
          ],
        ),
        const SizedBox(height: KuberSpacing.xl),
        CardsPinDots(length: _pinLength, filled: _pin.length),
        const SizedBox(height: KuberSpacing.xl),
        KuberPinPad(
          length: _pinLength,
          value: _pin,
          onChanged: (v) => setState(() => _pin = v),
          onSubmit: (_) {},
        ),
      ],
    );
  }

  // ── Step 3: confirm PIN ──────────────────────────────────────────────────────
  Widget _confirmPin(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 24),
        Text('Confirm your PIN',
            style: localeFont(
                fontSize: 24, fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: KuberSpacing.sm),
        Text('Enter it once more.',
            style: localeFont(fontSize: 14, color: cs.onSurfaceVariant)),
        const SizedBox(height: KuberSpacing.xl),
        CardsPinDots(
            length: _pinLength, filled: _confirm.length, error: _confirmError),
        if (_confirmError) ...[
          const SizedBox(height: 10),
          Text('That did not match. Try again.',
              style: localeFont(fontSize: 13, color: cs.error)),
        ],
        const SizedBox(height: KuberSpacing.xl),
        KuberPinPad(
          length: _pinLength,
          value: _confirm,
          onChanged: (v) => setState(() {
            _confirm = v;
            _confirmError = false;
          }),
          onSubmit: (_) {},
        ),
      ],
    );
  }

  // ── Step 4: backup warning ───────────────────────────────────────────────────
  Widget _backupWarning(ColorScheme cs) {
    final warning = context.kuberColors.warning;
    return Column(
      children: [
        const SizedBox(height: 40),
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: warning.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.warning_amber_rounded, size: 28, color: warning),
        ),
        const SizedBox(height: KuberSpacing.lg),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: context.kuberColors.warningSubtle,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: warning.withValues(alpha: 0.35)),
          ),
          child: Column(
            children: [
              Text(
                'There is no way to recover this PIN',
                textAlign: TextAlign.center,
                style: localeFont(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface),
              ),
              const SizedBox(height: KuberSpacing.md),
              Text(
                'If you forget your PIN, your cards are gone for good. We cannot '
                'reset it, and neither can anyone else. That is what keeps them '
                'private.',
                textAlign: TextAlign.center,
                style: localeFont(
                    fontSize: 14, color: cs.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: KuberSpacing.lg),
              InkWell(
                onTap: () => setState(() => _understood = !_understood),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
                child: Row(
                  children: [
                    Checkbox(
                      value: _understood,
                      onChanged: (v) =>
                          setState(() => _understood = v ?? false),
                    ),
                    Expanded(
                      child: Text('I understand there is no recovery.',
                          style: localeFont(
                              fontSize: 14, color: cs.onSurface)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Step 5: biometric ─────────────────────────────────────────────────────────
  Widget _biometricStep(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _tile(cs, Icons.fingerprint_rounded, cs.primary, 0.10),
        const SizedBox(height: KuberSpacing.lg),
        Text('Unlock faster with biometrics',
            textAlign: TextAlign.center,
            style: localeFont(
                fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          'Use your fingerprint or face to unlock Kuber Cards. Your PIN still '
          'works and stays the master key.',
          textAlign: TextAlign.center,
          style: localeFont(
              fontSize: 15, color: cs.onSurfaceVariant, height: 1.5),
        ),
      ],
    );
  }

  // ── Step 6: done ───────────────────────────────────────────────────────────────
  Widget _done(ColorScheme cs) {
    return Column(
      children: [
        const SizedBox(height: 40),
        _tile(cs, Icons.check_circle_rounded, cs.tertiary, 0.12),
        const SizedBox(height: KuberSpacing.lg),
        Text('You are all set',
            style: localeFont(
                fontSize: 22, fontWeight: FontWeight.w800, color: cs.onSurface)),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          'Your vault is ready. Add your first card whenever you like.',
          textAlign: TextAlign.center,
          style: localeFont(
              fontSize: 15, color: cs.onSurfaceVariant, height: 1.5),
        ),
      ],
    );
  }

  Widget _tile(ColorScheme cs, IconData icon, Color color, double alpha) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: color.withValues(alpha: alpha),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 32, color: color),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int count;
  final int active;
  const _StepDots({required this.count, required this.active});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == active ? cs.primary : cs.outline,
            ),
          ),
      ],
    );
  }
}
