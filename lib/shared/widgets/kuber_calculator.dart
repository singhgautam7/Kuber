import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/settings/providers/settings_provider.dart' show formatterProvider, currencyProvider;

class KuberCalculator extends ConsumerStatefulWidget {
  final double initialValue;
  final ValueChanged<double> onConfirm;

  const KuberCalculator({
    super.key,
    required this.initialValue,
    required this.onConfirm,
  });

  @override
  ConsumerState<KuberCalculator> createState() => _KuberCalculatorState();
}

class _KuberCalculatorState extends ConsumerState<KuberCalculator> {
  String _expression = '';
  String? _previewResult;
  String _rawExpression = '';

  static const _operators = ['+', '−', '×', '÷'];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue > 0) {
      _rawExpression = widget.initialValue.toString();
      _expression = _formatExpressionString(_rawExpression);
      _previewResult = null;
    }
  }

  bool _endsWithOperator() =>
      _rawExpression.isNotEmpty &&
      _operators.contains(_rawExpression[_rawExpression.length - 1]);

  void _onDigit(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (digit == '.' && _rawExpression.endsWith('.')) return;
      if (digit == '.' && _endsWithOperator()) {
        _rawExpression += '0.';
      } else {
        _rawExpression += digit;
      }
      _expression = _formatExpressionString(_rawExpression);
      _updatePreview();
    });
  }

  void _onOperator(String op) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_endsWithOperator()) {
        _rawExpression =
            _rawExpression.substring(0, _rawExpression.length - 1) + op;
      } else if (_rawExpression.isNotEmpty) {
        _rawExpression += op;
      }
      _expression = _formatExpressionString(_rawExpression);
      _updatePreview();
    });
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_rawExpression.isEmpty) return;
      _rawExpression = _rawExpression.substring(0, _rawExpression.length - 1);
      _expression = _formatExpressionString(_rawExpression);
      _updatePreview();
    });
  }

  void _onClear() {
    HapticFeedback.selectionClick();
    setState(() {
      _expression = '';
      _rawExpression = '';
      _previewResult = null;
    });
  }

  void _onEquals() {
    HapticFeedback.mediumImpact();
    final result = _evaluate(_rawExpression);
    if (result == null) return;
    setState(() {
      _rawExpression = result.toString();
      _expression = _formatExpressionString(_rawExpression);
      _previewResult = null;
    });
  }

  void _onPercent() {
    HapticFeedback.selectionClick();
    final expr = _rawExpression;
    if (expr.isEmpty) return;
    setState(() {
      int lastOpIdx = -1;
      for (final op in _operators) {
        final idx = expr.lastIndexOf(op);
        if (idx > lastOpIdx) lastOpIdx = idx;
      }
      if (lastOpIdx == -1) {
        final v = double.tryParse(expr) ?? 0;
        final result = v / 100;
        _rawExpression = result.toString();
      } else {
        final left = double.tryParse(expr.substring(0, lastOpIdx).trim()) ?? 0;
        final right = double.tryParse(expr.substring(lastOpIdx + 1).trim()) ?? 0;
        final pct = left * right / 100;
        final prefix = expr.substring(0, lastOpIdx + 1);
        _rawExpression = '$prefix$pct';
      }
      _expression = _formatExpressionString(_rawExpression);
      _updatePreview();
    });
  }

  void _onConfirm() {
    HapticFeedback.mediumImpact();
    final result =
        _evaluate(_rawExpression) ?? double.tryParse(_rawExpression) ?? 0;
    Navigator.of(context).pop();
    widget.onConfirm(result);
  }

  void _updatePreview() {
    if (!_rawExpression.contains(RegExp('[+−×÷]'))) {
      _previewResult = null;
      return;
    }
    final result = _evaluate(_rawExpression);
    if (result != null) {
      _previewResult = _formatNumber(result);
    }
  }

  double? _evaluate(String expr) {
    if (expr.isEmpty) return null;
    try {
      String clean = expr;
      if (_operators.contains(clean[clean.length - 1])) {
        clean = clean.substring(0, clean.length - 1);
      }
      if (clean.isEmpty) return null;

      // Split on operators while keeping them
      final tokens = clean.split(RegExp('(?=[+−×÷])|(?<=[+−×÷])'));
      if (tokens.isEmpty) return double.tryParse(clean);

      double result = 0;
      String pendingOp = '+';

      for (final token in tokens) {
        final t = token.trim();
        if (t.isEmpty) continue;
        if (_operators.contains(t)) {
          pendingOp = t;
        } else {
          final val = double.tryParse(t);
          if (val == null) continue;
          switch (pendingOp) {
            case '+':
              result += val;
              break;
            case '−':
              result -= val;
              break;
            case '×':
              result *= val;
              break;
            case '÷':
              result = val != 0 ? result / val : 0;
              break;
          }
        }
      }
      return result;
    } catch (_) {
      return null;
    }
  }

  String _formatNumber(double val) {
    if (val == val.truncateToDouble()) {
      return ref.read(formatterProvider).formatNumber(val, decimalDigits: 0);
    }
    return ref.read(formatterProvider).formatNumber(val, decimalDigits: 2);
  }

  String _formatExpressionString(String raw) {
    if (raw.isEmpty) return '';

    // Operators are +, −, ×, ÷
    final pattern = RegExp(r'([+−×÷%])');
    final parts = raw.split(pattern);
    final matches = pattern.allMatches(raw).map((m) => m.group(0)!).toList();

    final formattedParts = <String>[];
    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isEmpty) {
        formattedParts.add('');
        continue;
      }

      if (trimmed == '.') {
        formattedParts.add('.');
        continue;
      }

      if (trimmed.endsWith('.')) {
        final numStr = trimmed.substring(0, trimmed.length - 1);
        final parsed = double.tryParse(numStr);
        if (parsed != null) {
          formattedParts.add('${_formatNumber(parsed)}.');
        } else {
          formattedParts.add(trimmed);
        }
      } else {
        final parsed = double.tryParse(trimmed);
        if (parsed != null) {
          if (trimmed.contains('.')) {
            final splitVal = trimmed.split('.');
            final integralPart = double.tryParse(splitVal[0]) ?? 0;
            final formattedIntegral = ref.read(formatterProvider).formatNumber(integralPart, decimalDigits: 0);
            formattedParts.add('$formattedIntegral.${splitVal[1]}');
          } else {
            formattedParts.add(_formatNumber(parsed));
          }
        } else {
          formattedParts.add(trimmed);
        }
      }
    }

    final buffer = StringBuffer();
    for (int i = 0; i < formattedParts.length; i++) {
      buffer.write(formattedParts[i]);
      if (i < matches.length) {
        final op = matches[i];
        if (op == '%') {
          buffer.write(op);
        } else {
          buffer.write(' $op ');
        }
      }
    }

    return buffer.toString().trim();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header — surfaceContainer ──────────────────
        Container(
          color: cs.surfaceContainer,
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: cs.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title row
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Calculator',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ── Everything below — surface ─────────
        Container(
          color: cs.surface,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 12.0,
          ),
          child: Column(
            children: [
              _buildDisplay(),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: _buildButtonGrid(),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: _buildHeroCTA(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplay() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currency = ref.watch(currencyProvider);

    final resultStr = _previewResult ?? (_expression.isEmpty ? '0' : _expression);
    final hasExpression = _expression.isNotEmpty;

    return Container(
      width: double.infinity,
      height: 140,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AnimatedOpacity(
            opacity: hasExpression ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              _expression,
              style: textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currency.symbol,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  resultStr,
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                    color: cs.onSurface,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    return Column(
      children: [
        Row(
          children: [
            _CalcKey(
              label: 'C',
              onTap: _onClear,
              kind: _CalcKeyKind.danger,
            ),
            _CalcKey(
              label: '%',
              onTap: _onPercent,
              kind: _CalcKeyKind.operator,
            ),
            _CalcKey(
              label: '⌫',
              onTap: _onBackspace,
              kind: _CalcKeyKind.number,
              icon: Icons.backspace_outlined,
            ),
            _CalcKey(
              label: '÷',
              onTap: () => _onOperator('÷'),
              kind: _CalcKeyKind.operator,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CalcKey(
              label: '7',
              onTap: () => _onDigit('7'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '8',
              onTap: () => _onDigit('8'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '9',
              onTap: () => _onDigit('9'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '×',
              onTap: () => _onOperator('×'),
              kind: _CalcKeyKind.operator,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CalcKey(
              label: '4',
              onTap: () => _onDigit('4'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '5',
              onTap: () => _onDigit('5'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '6',
              onTap: () => _onDigit('6'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '−',
              onTap: () => _onOperator('−'),
              kind: _CalcKeyKind.operator,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CalcKey(
              label: '1',
              onTap: () => _onDigit('1'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '2',
              onTap: () => _onDigit('2'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '3',
              onTap: () => _onDigit('3'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '+',
              onTap: () => _onOperator('+'),
              kind: _CalcKeyKind.operator,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _CalcKey(
              label: '.',
              onTap: () => _onDigit('.'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '0',
              onTap: () => _onDigit('0'),
              kind: _CalcKeyKind.number,
            ),
            _CalcKey(
              label: '=',
              onTap: _onEquals,
              kind: _CalcKeyKind.operator,
              flex: 2,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeroCTA() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final currency = ref.watch(currencyProvider);

    final evaluated = _evaluate(_rawExpression) ?? double.tryParse(_rawExpression) ?? 0.0;
    final formattedResult = _formatNumber(evaluated);

    return GestureDetector(
      onTap: _onConfirm,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: cs.primary,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: cs.primary.withValues(alpha: 0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: cs.onPrimary, size: 22),
            const SizedBox(width: 10),
            Text(
              'Use ${currency.symbol}$formattedResult',
              style: textTheme.titleSmall?.copyWith(
                color: cs.onPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _CalcKeyKind {
  number,
  operator,
  danger,
}

class _CalcKey extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final _CalcKeyKind kind;
  final int flex;

  const _CalcKey({
    required this.label,
    required this.onTap,
    required this.kind,
    this.icon,
    this.flex = 1,
  });

  @override
  State<_CalcKey> createState() => _CalcKeyState();
}

/// Per-kind accent overlay + subtle scale-down.
///
/// The visual shape is `0 → peak → 0` over one press. We deliberately do
/// NOT use `CurvedAnimation` here — its `.value` getter asserts that any
/// attached curve maps `1.0` to near `1.0`, which is a contract for
/// monotonic curves. A bell shape violates that. Instead we listen to
/// `_ctrl` directly and apply `sin(t·π)` inline in the AnimatedBuilder.
class _CalcKeyState extends State<_CalcKey>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  static const _flashDuration = Duration(milliseconds: 260);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _flashDuration);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  /// Single flash — controller runs 0 → 1 once. The builder maps that
  /// linear ramp through `sin(t·π)` so the visible value rises to 1 at
  /// the midpoint and falls back to ~0 at the end. Rapid taps restart
  /// from 0 (any in-flight animation is cancelled), so successive
  /// presses read as distinct pulses.
  void _flash() {
    _ctrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Resting palette per kind. accent is the colour the button flashes
    // toward on press — grey for numbers, blue for operators, red for danger.
    final Color restBg;
    final Color restFg;
    final Color restBorder;
    final Color accent;

    switch (widget.kind) {
      case _CalcKeyKind.number:
        restBg = cs.surfaceContainer;
        restFg = cs.onSurface;
        restBorder = cs.outline;
        accent = cs.onSurface;
        break;
      case _CalcKeyKind.operator:
        restBg = cs.primary.withValues(alpha: 0.10);
        restFg = cs.primary;
        restBorder = cs.primary.withValues(alpha: 0.18);
        accent = cs.primary;
        break;
      case _CalcKeyKind.danger:
        restBg = cs.error.withValues(alpha: 0.10);
        restFg = cs.error;
        restBorder = cs.error.withValues(alpha: 0.10);
        accent = cs.error;
        break;
    }

    return Expanded(
      flex: widget.flex,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        // RepaintBoundary keeps the 60 Hz tap animation isolated from the
        // sibling keys and the receipt/hero panel above.
        child: RepaintBoundary(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Fire the flash and the action together — the accent pulse
            // lands at the same instant the digit/operator appears in the
            // expression, so the two events read as one.
            onTap: () {
              _flash();
              widget.onTap();
            },
            child: AnimatedBuilder(
              animation: _ctrl,
              builder: (context, _) {
                // Bell shape: 0 → 1 → 0 over the single forward run.
                // sin(π) is 1.22e-16 in doubles, i.e. visually 0.
                final v = math.sin(_ctrl.value * math.pi);
                // Interpolate to a stronger accent tint on press.
                final bg = Color.lerp(
                    restBg, accent.withValues(alpha: 0.28), v)!;
                final border = Color.lerp(
                    restBorder, accent.withValues(alpha: 0.55), v)!;
                // 0.97 scale — enough to feel, not enough to jitter neighbours.
                final scale = 1.0 - (v * 0.03);
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: bg,
                      border: Border.all(color: border),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: widget.icon != null
                        ? Icon(widget.icon, size: 22, color: restFg)
                        : Text(
                            widget.label,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: restFg,
                            ),
                          ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

