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

/// First-time setup (see `onboarding-setup.md`). The one sanctioned exception to
/// the landing-page pattern: centered layout, back-only app bar, an animated
/// non-swipeable pager, a tinted "n/total" page counter, and a sticky primary
/// button that mirrors the app's onboarding welcome flow.
///
/// Pages: intro, set PIN, confirm PIN, no-recovery warning, and (only when the
/// device supports it) biometrics. There is no separate "done" page — enabling
/// or skipping biometrics finishes setup.
class SetupFlowScreen extends ConsumerStatefulWidget {
  /// Called when setup completes.
  final VoidCallback onDone;

  const SetupFlowScreen({super.key, required this.onDone});

  @override
  ConsumerState<SetupFlowScreen> createState() => _SetupFlowScreenState();
}

class _SetupFlowScreenState extends ConsumerState<SetupFlowScreen> {
  final _biometric = BiometricService();
  final _pageController = PageController();

  static const _stepIntro = 0;
  static const _stepSetPin = 1;
  static const _stepConfirmPin = 2;
  static const _stepWarning = 3;
  static const _stepBiometric = 4;

  int _step = 0;
  int _pinLength = 6;
  final _pin = ValueNotifier<String>('');
  final _confirm = ValueNotifier<String>('');
  bool _confirmError = false;
  bool _understood = false;
  bool _committing = false;
  bool _biometricAvailable = false;

  /// Total pages for the counter: the biometric page only exists on devices
  /// that support it.
  int get _pageCount => _biometricAvailable ? 5 : 4;

  @override
  void initState() {
    super.initState();
    _biometric.canAuthenticate().then((v) {
      if (mounted) setState(() => _biometricAvailable = v);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _pin.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  void _back() {
    if (_step == _stepIntro) {
      Navigator.of(context).maybePop();
      return;
    }
    if (_step == _stepConfirmPin) _confirm.value = ''; // leaving discards it
    _goTo(_step - 1);
  }

  Future<void> _commitVault() async {
    setState(() => _committing = true);
    final key = await ref
        .read(cardVaultServiceProvider)
        .setupVault(pin: _pin.value, pinLength: _pinLength);
    if (!mounted) return;
    ref.read(cardSessionProvider.notifier).unlock(key);
    setState(() => _committing = false);
    // Biometrics is the final page when available; otherwise setup is complete.
    if (_biometricAvailable) {
      _goTo(_stepBiometric);
    } else {
      _finish();
    }
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
    _finish();
  }

  void _finish() {
    // Refresh hasVault so the entry swaps setup -> home (replace, not push).
    ref.invalidate(cardVaultMetaProvider);
    widget.onDone();
  }

  void _onConfirm() {
    if (_confirm.value != _pin.value) {
      HapticFeedback.mediumImpact();
      _confirm.value = '';
      setState(() => _confirmError = true);
      return;
    }
    _goTo(_stepWarning);
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
                child: PageView(
                  controller: _pageController,
                  // Not swipeable; navigation is driven by the buttons, so the
                  // pager only provides the animated slide between pages.
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (i) {
                    if (i != _step) setState(() => _step = i);
                  },
                  children: [
                    _intro(cs),
                    _setPin(cs),
                    _confirmPin(cs),
                    _backupWarning(cs),
                    if (_biometricAvailable) _biometricStep(cs),
                  ],
                ),
              ),
              _PageCounter(current: _step + 1, total: _pageCount),
              const SizedBox(height: KuberSpacing.md),
              _footer(cs),
            ],
          ),
        ),
      ),
    );
  }

  // ── Footer (sticky, welcome-flow feel) ──────────────────────────────────────

  Widget _footer(ColorScheme cs) {
    final Widget content;
    switch (_step) {
      case _stepIntro:
        content = _primaryButton(cs, 'Get started',
            onPressed: () => _goTo(_stepSetPin));
      case _stepSetPin:
        content = ValueListenableBuilder<String>(
          valueListenable: _pin,
          builder: (_, pin, __) => _primaryButton(
            cs,
            'Continue',
            onPressed:
                pin.length == _pinLength ? () => _goTo(_stepConfirmPin) : null,
          ),
        );
      case _stepConfirmPin:
        content = ValueListenableBuilder<String>(
          valueListenable: _confirm,
          builder: (_, confirm, __) => _primaryButton(
            cs,
            'Continue',
            loading: _committing,
            onPressed: confirm.length == _pinLength ? _onConfirm : null,
          ),
        );
      case _stepWarning:
        content = _primaryButton(
          cs,
          'I understand',
          loading: _committing,
          onPressed: _understood ? _commitVault : null,
        );
      default: // biometric
        content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Skip sits ABOVE the primary action, which stays bottom-aligned
            // like every other page.
            TextButton(
              onPressed: _finish,
              child: Text('Skip for now',
                  style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant)),
            ),
            const SizedBox(height: KuberSpacing.xs),
            _primaryButton(cs, 'Enable biometrics',
                onPressed: _enableBiometric),
          ],
        );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpacing.xl,
          0,
          KuberSpacing.xl,
          KuberSpacing.lg,
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          child: content,
        ),
      ),
    );
  }

  /// The app's onboarding-welcome primary button: full-width filled, an animated
  /// label swap, and a trailing arrow. Shows a spinner while [loading].
  Widget _primaryButton(
    ColorScheme cs,
    String label, {
    VoidCallback? onPressed,
    bool loading = false,
  }) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          disabledBackgroundColor: cs.primary.withValues(alpha: 0.35),
          disabledForegroundColor: cs.onPrimary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: cs.onPrimary),
              )
            : AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.16),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: Row(
                  key: ValueKey(label),
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        softWrap: false,
                        overflow: TextOverflow.visible,
                        style: localeFont(
                            fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    const Icon(Icons.arrow_forward_rounded, size: 24),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Page 1: intro ──────────────────────────────────────────────────────────
  Widget _intro(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _tile(cs, Icons.credit_card_rounded, cs.primary, 0.10),
          const SizedBox(height: KuberSpacing.lg),
          Text('Kuber Cards',
              style: localeFont(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
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
          _highlight(
              cs, Icons.credit_card_off_rounded, 'Your CVV is never stored'),
          _highlight(cs, Icons.pin_rounded, 'Locked behind your PIN'),
          _highlight(
              cs, Icons.fingerprint_rounded, 'Biometric unlock for convenience'),
        ],
      ),
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

  // ── Page 2: set PIN ─────────────────────────────────────────────────────────
  Widget _setPin(ColorScheme cs) {
    return _PinPage(
      title: 'Set your PIN',
      subtitle: 'Choose a PIN to lock your cards.',
      pinLength: _pinLength,
      pin: _pin,
      // The digit-length selector sits above the flexible gap, so it never
      // pushes the (bottom-aligned) pad or dots.
      topExtra: KuberSegmented<int>(
        groupValue: _pinLength,
        onChanged: (v) {
          _pin.value = ''; // changing length clears entry
          setState(() => _pinLength = v);
        },
        segments: const [
          KuberSegment(value: 4, label: '4 digits'),
          KuberSegment(value: 6, label: '6 digits'),
        ],
      ),
      onChanged: (v) => _pin.value = v,
    );
  }

  // ── Page 3: confirm PIN ──────────────────────────────────────────────────────
  Widget _confirmPin(ColorScheme cs) {
    return _PinPage(
      title: 'Confirm your PIN',
      subtitle: 'Enter it once more.',
      pinLength: _pinLength,
      pin: _confirm,
      error: _confirmError,
      errorText: 'That did not match. Try again.',
      onChanged: (v) {
        _confirm.value = v;
        if (_confirmError) setState(() => _confirmError = false);
      },
    );
  }

  // ── Page 4: backup warning ───────────────────────────────────────────────────
  Widget _backupWarning(ColorScheme cs) {
    final warning = context.kuberColors.warning;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
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
      ),
    );
  }

  // ── Page 5: biometric ─────────────────────────────────────────────────────────
  Widget _biometricStep(ColorScheme cs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _tile(cs, Icons.fingerprint_rounded, cs.primary, 0.10),
          const SizedBox(height: KuberSpacing.lg),
          Text('Unlock faster with biometrics',
              textAlign: TextAlign.center,
              style: localeFont(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface)),
          const SizedBox(height: KuberSpacing.sm),
          Text(
            'Use your fingerprint or face to unlock Kuber Cards. Your PIN still '
            'works and stays the master key.',
            textAlign: TextAlign.center,
            style: localeFont(
                fontSize: 15, color: cs.onSurfaceVariant, height: 1.5),
          ),
        ],
      ),
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

/// A PIN entry page whose keypad is pinned to the bottom, so its position never
/// shifts between "set" and "confirm" (a flexible gap absorbs any difference in
/// the header, e.g. the digit-length selector).
class _PinPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final int pinLength;
  final ValueNotifier<String> pin;
  final Widget? topExtra;
  final bool error;
  final String? errorText;
  final ValueChanged<String> onChanged;

  const _PinPage({
    required this.title,
    required this.subtitle,
    required this.pinLength,
    required this.pin,
    required this.onChanged,
    this.topExtra,
    this.error = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          // Header scrolls if it can't fit; the keypad stays pinned to the
          // bottom so its position is identical on "set" and "confirm".
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(title,
                      style: localeFont(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface)),
                  const SizedBox(height: KuberSpacing.sm),
                  Text(subtitle,
                      textAlign: TextAlign.center,
                      style:
                          localeFont(fontSize: 14, color: cs.onSurfaceVariant)),
                  if (topExtra != null) ...[
                    const SizedBox(height: KuberSpacing.lg),
                    topExtra!,
                  ],
                ],
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: pin,
            builder: (_, value, __) => CardsPinDots(
                length: pinLength, filled: value.length, error: error),
          ),
          if (error && errorText != null) ...[
            const SizedBox(height: 10),
            Text(errorText!, style: localeFont(fontSize: 13, color: cs.error)),
          ],
          const SizedBox(height: KuberSpacing.xl),
          KuberPinPad(
            length: pinLength,
            value: pin,
            onChanged: onChanged,
            onSubmit: (_) {},
          ),
          const SizedBox(height: KuberSpacing.md),
        ],
      ),
    );
  }
}

/// The tinted "n / total" page indicator that replaces swipe dots (the pager is
/// not swipeable, so dots would wrongly imply a swipe gesture).
class _PageCounter extends StatelessWidget {
  final int current;
  final int total;
  const _PageCounter({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$current',
              style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: cs.primary),
            ),
            TextSpan(
              text: ' / $total',
              style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
