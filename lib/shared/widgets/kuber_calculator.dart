import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class KuberCalculator extends StatefulWidget {
  final double initialValue;
  final ValueChanged<double> onConfirm;

  const KuberCalculator({
    super.key,
    required this.initialValue,
    required this.onConfirm,
  });

  @override
  State<KuberCalculator> createState() => _KuberCalculatorState();
}

class _KuberCalculatorState extends State<KuberCalculator> {
  String _expression = '';
  String? _previewResult;
  String _rawExpression = '';

  static const _operators = ['+', '−', '×', '÷'];

  @override
  void initState() {
    super.initState();
    if (widget.initialValue > 0) {
      _expression = _formatNumber(widget.initialValue);
      _rawExpression = widget.initialValue.toString();
      _previewResult = null;
    }
  }

  bool _endsWithOperator() =>
      _rawExpression.isNotEmpty &&
      _operators.contains(_rawExpression[_rawExpression.length - 1]);

  void _onDigit(String digit) {
    HapticFeedback.selectionClick();
    setState(() {
      if (digit == '.' && _expression.endsWith('.')) return;
      if (digit == '.' && _endsWithOperator()) {
        _expression += '0.';
        _rawExpression += '0.';
      } else {
        _expression += digit;
        _rawExpression += digit;
      }
      _updatePreview();
    });
  }

  void _onOperator(String op) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_endsWithOperator()) {
        _expression = _expression.substring(0, _expression.length - 1) + op;
        _rawExpression =
            _rawExpression.substring(0, _rawExpression.length - 1) + op;
      } else if (_expression.isNotEmpty) {
        _expression += op;
        _rawExpression += op;
      }
      _updatePreview();
    });
  }

  void _onBackspace() {
    HapticFeedback.selectionClick();
    setState(() {
      if (_expression.isEmpty) return;
      _expression = _expression.substring(0, _expression.length - 1);
      _rawExpression = _rawExpression.substring(0, _rawExpression.length - 1);
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
      _expression = _formatNumber(result);
      _rawExpression = result.toString();
      _previewResult = null;
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
      return _addIndianCommas(val.toInt().toString());
    }
    final parts = val.toStringAsFixed(2).split('.');
    return '${_addIndianCommas(parts[0])}.${parts[1]}';
  }

  String _addIndianCommas(String number) {
    if (number.startsWith('-')) {
      return '-${_addIndianCommas(number.substring(1))}';
    }
    if (number.length <= 3) return number;
    final last3 = number.substring(number.length - 3);
    final rest = number.substring(0, number.length - 3);
    final formatted = rest.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    return '$formatted,$last3';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Header — surfaceCard ──────────────────
        Container(
          color: KuberColors.surfaceCard,
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: KuberColors.border,
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
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: KuberColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: KuberColors.textSecondary,
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

        // ── Everything below — pure black ─────────
        Container(
          color: KuberColors.background,
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + KuberSpacing.lg,
          ),
          child: Column(
            children: [
              // Display area
              _buildDisplay(),
              const SizedBox(height: KuberSpacing.lg),
              // Button grid
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                ),
                child: _buildButtonGrid(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDisplay() {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Preview line — always present, fades in/out
          AnimatedOpacity(
            opacity: _previewResult != null ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 150),
            child: Text(
              _previewResult ?? '',
              style: GoogleFonts.inter(
                fontSize: 18,
                color: KuberColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(height: 4),
          // Main expression line
          Text(
            _expression.isEmpty ? '0' : _expression,
            style: GoogleFonts.inter(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: KuberColors.textPrimary,
              letterSpacing: -1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildButtonGrid() {
    final rows = [
      // Row 1: C (flex 2, red), ⌫ (red), ÷ (blue)
      [
        _CalcBtn('C', _onClear, color: KuberColors.expense, flex: 2),
        _CalcBtn('⌫', _onBackspace,
            color: KuberColors.expense, icon: Icons.backspace_outlined),
        _CalcBtn('÷', () => _onOperator('÷'), color: KuberColors.primary),
      ],
      // Row 2: 7, 8, 9, × (blue)
      [
        _CalcBtn('7', () => _onDigit('7')),
        _CalcBtn('8', () => _onDigit('8')),
        _CalcBtn('9', () => _onDigit('9')),
        _CalcBtn('×', () => _onOperator('×'), color: KuberColors.primary),
      ],
      // Row 3: 4, 5, 6, − (blue)
      [
        _CalcBtn('4', () => _onDigit('4')),
        _CalcBtn('5', () => _onDigit('5')),
        _CalcBtn('6', () => _onDigit('6')),
        _CalcBtn('−', () => _onOperator('−'), color: KuberColors.primary),
      ],
      // Row 4: 1, 2, 3, + (blue)
      [
        _CalcBtn('1', () => _onDigit('1')),
        _CalcBtn('2', () => _onDigit('2')),
        _CalcBtn('3', () => _onDigit('3')),
        _CalcBtn('+', () => _onOperator('+'), color: KuberColors.primary),
      ],
      // Row 5: 0, ., = (blue), ✓ (blue filled)
      [
        _CalcBtn('0', () => _onDigit('0')),
        _CalcBtn('.', () => _onDigit('.')),
        _CalcBtn('=', _onEquals, color: KuberColors.primary),
        _CalcBtn('✓', _onConfirm,
            color: KuberColors.white, backgroundColor: KuberColors.primary),
      ],
    ];

    return Column(
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                child: Row(
                  children: row
                      .map((btn) => Expanded(
                            flex: btn.flex,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: KuberSpacing.xs),
                              child: _buildButton(btn),
                            ),
                          ))
                      .toList(),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildButton(_CalcBtn btn) {
    final bool isFilled = btn.backgroundColor != null;
    final Color bgColor = btn.backgroundColor ?? KuberColors.surfaceMuted;
    final Color fgColor = btn.color ?? KuberColors.textPrimary;

    return GestureDetector(
      onTap: btn.onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: !isFilled ? Border.all(color: KuberColors.border) : null,
        ),
        alignment: Alignment.center,
        child: btn.icon != null
            ? Icon(btn.icon, size: 20, color: fgColor)
            : Text(
                btn.label,
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: fgColor,
                ),
              ),
      ),
    );
  }
}

class _CalcBtn {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? backgroundColor;
  final int flex;
  final IconData? icon;

  _CalcBtn(this.label, this.onTap,
      {this.color, this.backgroundColor, this.flex = 1, this.icon});
}
