import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
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
              const SizedBox(height: KuberSpace.md),
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
        content = _primaryButton(
          cs,
          'Get started',
          onPressed: () => _goTo(_stepSetPin),
        );
      case _stepSetPin:
        content = ValueListenableBuilder<String>(
          valueListenable: _pin,
          builder: (_, pin, __) => _primaryButton(
            cs,
            'Continue',
            onPressed: pin.length == _pinLength
                ? () => _goTo(_stepConfirmPin)
                : null,
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
            TextButton(onPressed: _finish, child: const Text('Skip for now')),
            const SizedBox(height: KuberSpace.xs),
            _primaryButton(
              cs,
              'Enable biometrics',
              onPressed: _enableBiometric,
            ),
          ],
        );
    }

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          0,
          KuberSpace.screenMargin,
          KuberSpace.lg,
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
          disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.12),
          disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
          shape: const StadiumBorder(),
        ),
        child: loading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: cs.onPrimary,
                ),
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
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Page 1: intro ──────────────────────────────────────────────────────────
  Widget _intro(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    Widget row(IconData icon, String label) => KuberListRow(
      dense: true,
      leading: Icon(icon, size: 20, color: cs.onSurfaceVariant),
      title: label,
    );
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: KuberSpace.sm),
          _tile(cs, Icons.credit_card_rounded),
          const SizedBox(height: KuberSpace.lg),
          Text(
            'Kuber Cards',
            style: tt.headlineMedium!.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: KuberSpace.sm),
          Text(
            'Store your cards, encrypted, on your device. They never leave your phone.',
            style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: KuberSpace.lg),
          KuberGroup(
            children: [
              row(Icons.lock_outline_rounded, 'Encrypted at rest'),
              row(Icons.wifi_off_rounded, 'Works fully offline'),
              row(Icons.credit_card_off_outlined, 'Your CVV is never stored'),
              row(Icons.pin_outlined, 'Locked behind your PIN'),
              row(
                Icons.fingerprint_rounded,
                'Biometric unlock for convenience',
              ),
            ],
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
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: KuberSpace.sm),
          Container(
            padding: const EdgeInsets.all(KuberSpace.lg),
            decoration: BoxDecoration(
              color: cs.errorContainer,
              borderRadius: KuberShape.largeR,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_rounded,
                  size: 24,
                  color: cs.onErrorContainer,
                ),
                const SizedBox(height: KuberSpace.md),
                Text(
                  'There is no way to recover this PIN',
                  style: tt.headlineSmall!.copyWith(color: cs.onErrorContainer),
                ),
                const SizedBox(height: KuberSpace.sm),
                Text(
                  'If you forget your PIN, your cards are gone for good. We cannot '
                  'reset it, and neither can anyone else. That is what keeps them '
                  'private.',
                  style: tt.bodyMedium!.copyWith(color: cs.onErrorContainer),
                ),
              ],
            ),
          ),
          const SizedBox(height: KuberSpace.md),
          KuberGroup(
            children: [
              InkWell(
                onTap: () => setState(() => _understood = !_understood),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _understood,
                        onChanged: (v) =>
                            setState(() => _understood = v ?? false),
                      ),
                      Expanded(
                        child: Text(
                          'I understand there is no recovery.',
                          style: tt.labelLarge!.copyWith(color: cs.onSurface),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Page 5: biometric ─────────────────────────────────────────────────────────
  Widget _biometricStep(ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: KuberSpace.sm),
          _tile(cs, Icons.fingerprint_rounded),
          const SizedBox(height: KuberSpace.lg),
          Text(
            'Unlock faster with biometrics',
            style: tt.headlineMedium!.copyWith(color: cs.onSurface),
          ),
          const SizedBox(height: KuberSpace.sm),
          Text(
            'Use your fingerprint or face to unlock Kuber Cards. Your PIN still '
            'works and stays the master key.',
            style: tt.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /// 56 primary tile, r16 (board 3.24 intro).
  Widget _tile(ColorScheme cs, IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: cs.primary,
        borderRadius: KuberShape.largeR,
      ),
      child: Icon(icon, size: 28, color: cs.onPrimary),
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
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: Column(
        children: [
          // Header scrolls if it can't fit; the keypad stays pinned to the
          // bottom so its position is identical on "set" and "confirm".
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.headlineSmall!.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (topExtra != null) ...[
                    const SizedBox(height: KuberSpace.lg),
                    topExtra!,
                  ],
                ],
              ),
            ),
          ),
          ValueListenableBuilder<String>(
            valueListenable: pin,
            builder: (_, value, __) => CardsPinDots(
              length: pinLength,
              filled: value.length,
              error: error,
            ),
          ),
          if (error && errorText != null) ...[
            const SizedBox(height: 10),
            Text(
              errorText!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: cs.error),
            ),
          ],
          const SizedBox(height: KuberSpace.xl),
          KuberPinPad(
            length: pinLength,
            value: pin,
            onChanged: onChanged,
            onSubmit: (_) {},
          ),
          const SizedBox(height: KuberSpace.md),
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
        borderRadius: BorderRadius.circular(KuberShape.full),
      ),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$current',
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
            TextSpan(
              text: ' / $total',
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
