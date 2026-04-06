import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../../../shared/widgets/kuber_calculator.dart';

/// Shared amount input widget used by both normal and transfer forms.
/// Contains the large amount text field, currency symbol, calculator button,
/// and quick-add amount chips.
class AmountInput extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final Color amountColor;

  const AmountInput({
    super.key,
    required this.controller,
    this.focusNode,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: KuberSpacing.xxl,
            horizontal: KuberSpacing.lg,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Amount — truly centered across full width
              RepaintBoundary(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d*\.?\d{0,2}'),
                    ),
                  ],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    isCollapsed: true,
                  ),
                ),
              ),
              // Currency symbol — pinned left
              Positioned(
                left: 0,
                child: Text(
                  ref.watch(currencyProvider).symbol,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              // Calculator button — pinned right
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => _openCalculator(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(color: cs.outline),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.calculate_outlined,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),

        // Quick-add amount chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [50, 100, 500, 1000].map((amount) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.xs,
              ),
              child: GestureDetector(
                onTap: () {
                  final current =
                      double.tryParse(controller.text.trim()) ?? 0;
                  final newAmount = current + amount;
                  controller.text =
                      newAmount.truncateToDouble() == newAmount
                          ? newAmount.toInt().toString()
                          : newAmount.toStringAsFixed(2);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$amount',
                    style: textTheme.labelMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openCalculator(BuildContext context) {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => KuberCalculator(
        initialValue: double.tryParse(controller.text.trim()) ?? 0,
        onConfirm: (result) {
          controller.text = result == result.truncateToDouble()
              ? result.toInt().toString()
              : result.toStringAsFixed(2);
        },
      ),
    ).then((_) {
      // Use WidgetsBinding to safely unfocus after sheet dismissal
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) FocusScope.of(context).unfocus();
      });
    });
  }
}
