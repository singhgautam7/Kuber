import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

/// The numeric PIN pad used across setup, unlock, change-PIN, and import. A
/// feature widget assembled entirely from Vault tokens (like
/// `credit_billing_cycle_section.dart`), not a shared-component variant.
///
/// Controlled: the parent owns the entered PIN as a [ValueListenable] and passes
/// it as [value]. The pad reads the current value lazily on each key press (it
/// never displays the value), so a keystroke updates only the caller's dots —
/// the pad itself is built once and does not rebuild per digit (perf §1). Each
/// digit calls [onChanged]; entering the final [length] digit also calls
/// [onSubmit] (auto-submit).
class KuberPinPad extends StatelessWidget {
  final int length;
  final ValueListenable<String> value;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmit;
  final bool enabled;

  /// When set, the bottom-left key is the fingerprint (board 3.24).
  final VoidCallback? onBiometric;

  const KuberPinPad({
    super.key,
    required this.length,
    required this.value,
    required this.onChanged,
    required this.onSubmit,
    this.enabled = true,
    this.onBiometric,
  });

  void _press(String digit) {
    final current = value.value;
    if (current.length >= length) return;
    final next = current + digit;
    onChanged(next);
    if (next.length == length) onSubmit(next);
  }

  void _backspace() {
    final current = value.value;
    if (current.isEmpty) return;
    onChanged(current.substring(0, current.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final keys = <Widget>[
      for (var d = 1; d <= 9; d++)
        _PadKey(label: '$d', onTap: () => _press('$d')),
      if (onBiometric != null)
        _PadKey(
          icon: Icons.fingerprint_rounded,
          plain: true,
          accent: true,
          onTap: onBiometric!,
        )
      else
        const SizedBox(width: _PadKey.size, height: _PadKey.size),
      _PadKey(label: '0', onTap: () => _press('0')),
      _PadKey(
        icon: Icons.backspace_outlined,
        plain: true,
        onTap: _backspace,
        onLongPress: () {
          HapticFeedback.selectionClick();
          onChanged('');
        },
      ),
    ];

    // 72 circles on surfaceContainerHigh, 4 x 3 (board 3.24).
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < 4; r++) ...[
              if (r > 0) const SizedBox(height: KuberSpace.lg),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var c = 0; c < 3; c++) ...[
                    if (c > 0) const SizedBox(width: KuberSpace.xl),
                    keys[r * 3 + c],
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PadKey extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  /// Icon keys (fingerprint, backspace) have no fill.
  final bool plain;
  final bool accent;

  static const double size = 72;

  const _PadKey({
    this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
    this.plain = false,
    this.accent = false,
  });

  @override
  State<_PadKey> createState() => _PadKeyState();
}

class _PadKeyState extends State<_PadKey> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onLongPress: widget.onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: _PadKey.size,
        height: _PadKey.size,
        decoration: BoxDecoration(
          color: _pressed
              ? cs.secondaryContainer
              : widget.plain
              ? Colors.transparent
              : cs.surfaceContainerHigh,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: widget.icon != null
            ? Icon(
                widget.icon,
                size: widget.accent ? 32 : 24,
                color: widget.accent ? cs.primary : cs.onSurfaceVariant,
              )
            : Text(
                widget.label!,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: cs.onSurface,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
      ),
    );
  }
}

/// A row of 4 or 6 hollow PIN dots. Filled = `cs.primary`, empty = `cs.outlineVariant`
/// ring. Digits are never shown. Plays a horizontal shake + error flash when
/// [error] flips true (wrong-PIN state).
class CardsPinDots extends StatefulWidget {
  final int length;
  final int filled;
  final bool error;

  const CardsPinDots({
    super.key,
    required this.length,
    required this.filled,
    this.error = false,
  });

  @override
  State<CardsPinDots> createState() => _CardsPinDotsState();
}

class _CardsPinDotsState extends State<CardsPinDots> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final row = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < widget.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: _Dot(filled: i < widget.filled, error: widget.error, cs: cs),
          ),
      ],
    );

    if (!widget.error) return row;

    // Shake: 3 damped oscillations, ~400ms, +/-8px.
    return TweenAnimationBuilder<double>(
      key: ValueKey('shake-${widget.filled}'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, t, child) {
        final dx = 8 * (1 - t) * math.sin(t * math.pi * 6);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: row,
    );
  }
}

class _Dot extends StatelessWidget {
  final bool filled;
  final bool error;
  final ColorScheme cs;

  const _Dot({required this.filled, required this.error, required this.cs});

  @override
  Widget build(BuildContext context) {
    final color = error ? cs.error : cs.primary;
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(
          color: filled ? color : cs.outlineVariant,
          width: 1.5,
        ),
      ),
    );
  }
}
