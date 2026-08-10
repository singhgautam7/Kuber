import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../data/card_keystore.dart';
import '../data/card_vault_service.dart';
import '../providers/kuber_cards_provider.dart';
import '../widgets/kuber_pin_pad.dart';

/// Full-screen PIN unlock, shown on cold start of Kuber Cards and after the
/// section has been backgrounded > 60s (via the secure scaffold overlay). On
/// success it opens the in-memory session; the surrounding widgets react.
/// See `unlock-screen.md`.
class CardsUnlockScreen extends ConsumerStatefulWidget {
  /// Called after a successful unlock (optional; the session flip usually
  /// suffices for entry/overlay presentations).
  final VoidCallback? onUnlocked;

  const CardsUnlockScreen({super.key, this.onUnlocked});

  @override
  ConsumerState<CardsUnlockScreen> createState() => _CardsUnlockScreenState();
}

class _CardsUnlockScreenState extends ConsumerState<CardsUnlockScreen> {
  final _biometric = BiometricService();

  int _pinLength = 6;
  bool _biometricEnabled = false;
  bool _importContext = false; // vault came from a backup, needs the old PIN
  bool _ready = false;

  String _pin = '';
  bool _error = false;
  int _attemptsLeft = 5;

  DateTime? _lockedUntil; // cooldown or day-lock end
  bool _isDayLock = false;
  Timer? _countdown;
  Duration _remaining = Duration.zero;
  bool _biometricTried = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final meta = await ref.read(cardVaultServiceProvider).readMeta();
    if (!mounted || meta == null) return;
    final now = DateTime.now();
    setState(() {
      _pinLength = meta.pinLength;
      _importContext = meta.hasLockedImport;
      // Biometric can't authorize an imported vault (its PIN may differ and this
      // device's Keystore has no matching PIN), so it is hidden in that case.
      _biometricEnabled = meta.biometricEnabled && !meta.hasLockedImport;
      if (meta.dayLockedUntil != null && now.isBefore(meta.dayLockedUntil!)) {
        _startLock(meta.dayLockedUntil!, dayLock: true);
      } else if (meta.cooldownUntil != null &&
          now.isBefore(meta.cooldownUntil!)) {
        _startLock(meta.cooldownUntil!, dayLock: false);
      }
      _ready = true;
    });

    if (_biometricEnabled && _lockedUntil == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 300), _tryBiometric);
      });
    }
  }

  @override
  void dispose() {
    _countdown?.cancel();
    super.dispose();
  }

  void _startLock(DateTime until, {required bool dayLock}) {
    _lockedUntil = until;
    _isDayLock = dayLock;
    _remaining = until.difference(DateTime.now());
    _countdown?.cancel();
    _countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      final left = until.difference(DateTime.now());
      if (left.isNegative || left.inSeconds == 0) {
        _countdown?.cancel();
        if (mounted) {
          setState(() {
            _lockedUntil = null;
            _isDayLock = false;
            _error = false;
            _attemptsLeft = 5;
            _pin = '';
          });
        }
      } else if (mounted) {
        setState(() => _remaining = left);
      }
    });
  }

  Future<void> _tryBiometric() async {
    if (_biometricTried || !mounted || _lockedUntil != null) return;
    _biometricTried = true;
    final can = await _biometric.canAuthenticate();
    if (!can || !mounted) return;
    final ok = await _biometric.authenticate();
    if (!ok || !mounted) return;
    final raw = await CardKeystore.retrieveSecret();
    if (raw == null || !mounted) return;
    final service = ref.read(cardVaultServiceProvider);

    // New format: a base64-encoded 32-byte key -> unlock directly (no Argon2).
    List<int>? key;
    try {
      final decoded = base64Decode(raw);
      if (decoded.length == 32) key = decoded;
    } catch (_) {}
    if (key != null && await service.unlockWithKey(key)) {
      if (mounted) _openSession(key);
      return;
    }

    // Legacy format: the raw value is a plaintext PIN from an older build.
    // Derive the key from it, unlock, then migrate to key storage so future
    // biometric unlocks use the new format.
    final outcome = await service.attemptUnlock(raw);
    if (!mounted) return;
    if (outcome.status == UnlockStatus.success) {
      await CardKeystore.storeKey(outcome.key!);
      if (mounted) _openSession(outcome.key!);
    }
    // Any other outcome: fall through to the PIN pad.
  }

  void _openSession(List<int> key) {
    ref.read(cardSessionProvider.notifier).unlock(key);
    ref.invalidate(cardVaultMetaProvider);
    widget.onUnlocked?.call();
  }

  void _onChanged(String v) {
    setState(() {
      _pin = v;
      _error = false;
    });
  }

  Future<void> _submit(String pin) async {
    final outcome = await ref.read(cardVaultServiceProvider).attemptUnlock(pin);
    if (!mounted) return;
    switch (outcome.status) {
      case UnlockStatus.success:
        ref.read(cardSessionProvider.notifier).unlock(outcome.key!);
        ref.invalidate(cardVaultMetaProvider);
        widget.onUnlocked?.call();
      case UnlockStatus.wrongPin:
        HapticFeedback.mediumImpact();
        setState(() {
          _error = true;
          _attemptsLeft = outcome.attemptsLeft;
          _pin = '';
        });
      case UnlockStatus.cooldown:
        HapticFeedback.mediumImpact();
        setState(() => _pin = '');
        _startLock(outcome.until!, dayLock: false);
      case UnlockStatus.dayLocked:
        setState(() => _pin = '');
        _startLock(outcome.until!, dayLock: true);
        showKuberSnackBar(
          context,
          'Kuber Cards is locked for today. Your cards are safe.',
          isError: true,
        );
      case UnlockStatus.noVault:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (!_ready) {
      return Scaffold(
        backgroundColor: cs.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final locked = _lockedUntil != null;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Icon(Icons.lock_rounded, size: 34, color: cs.primary),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Text(
                'Kuber Cards',
                style: localeFont(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              if (locked)
                _lockBlock(cs)
              else ...[
                Text(
                  _importContext
                      ? 'Enter the PIN from your previous device'
                      : (_biometricEnabled
                          ? 'Unlock with biometrics or enter your PIN'
                          : 'Enter your PIN'),
                  textAlign: TextAlign.center,
                  style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                ),
                if (_importContext) ...[
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
                ],
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
              const Spacer(flex: 3),
              if (!locked && _biometricEnabled)
                AppButton(
                  label: 'Unlock with biometrics',
                  type: AppButtonType.outline,
                  icon: Icons.fingerprint_rounded,
                  fullWidth: true,
                  onPressed: () {
                    _biometricTried = false;
                    _tryBiometric();
                  },
                ),
              const SizedBox(height: KuberSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lockBlock(ColorScheme cs) {
    final mm = _remaining.inMinutes.remainder(60).toString();
    final ss = _remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpacing.xl),
      child: Column(
        children: [
          Icon(Icons.lock_clock_rounded, size: 30, color: cs.onSurfaceVariant),
          const SizedBox(height: KuberSpacing.md),
          Text(
            _isDayLock ? 'Locked for today' : 'Too many attempts',
            style: localeFont(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
            ),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            _isDayLock
                ? 'Your cards are safe. Try again later.'
                : 'Try again in $mm:$ss',
            textAlign: TextAlign.center,
            style: localeFont(
              fontSize: 14,
              color: cs.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
