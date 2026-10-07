import 'package:flutter/material.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_chips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider, NumberSystem;
import '../../../core/utils/formatters.dart';
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isIndian = ref.watch(formatterProvider).system == NumberSystem.indian;

    return Column(
      children: [
        Padding(
          // About half of the old 32 / 32: the amount gets room to breathe
          // without pushing the form down as far as before.
          padding: const EdgeInsets.only(
            top: KuberSpace.xl,
            bottom: KuberSpace.lg,
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
                  inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: textTheme.displaySmall?.copyWith(color: amountColor),
                  decoration: InputDecoration(
                    hintText: '0',
                    hintStyle: textTheme.displaySmall?.copyWith(
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
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              // Calculator button — pinned right
              Positioned(
                right: -4,
                child: AppIconButton(
                  icon: Icons.calculate_outlined,
                  semanticLabel: 'Calculator',
                  onPressed: () => _openCalculator(context, ref),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.sm),

        // Quick-add amount chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: KuberSpace.sm,
          children: [50, 100, 500, 1000].map((amount) {
            return KuberChip(
              label: '+$amount',
              pill: true,
              onTap: () {
                final current =
                    double.tryParse(
                      controller.text.trim().replaceAll(',', ''),
                    ) ??
                    0;
                final newAmount = current + amount;
                final unformattedText =
                    newAmount.truncateToDouble() == newAmount
                    ? newAmount.toInt().toString()
                    : newAmount.toStringAsFixed(2);

                controller.value = CurrencyInputFormatter(isIndian: isIndian)
                    .formatEditUpdate(
                      TextEditingValue.empty,
                      TextEditingValue(
                        text: unformattedText,
                        selection: TextSelection.collapsed(
                          offset: unformattedText.length,
                        ),
                      ),
                    );
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openCalculator(BuildContext context, WidgetRef ref) {
    FocusScope.of(context).unfocus();
    final isIndian = ref.read(formatterProvider).system == NumberSystem.indian;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberCalculator(
        initialValue:
            double.tryParse(controller.text.trim().replaceAll(',', '')) ?? 0,
        onConfirm: (result) {
          final unformattedText = result == result.truncateToDouble()
              ? result.toInt().toString()
              : result.toStringAsFixed(2);
          controller.value = CurrencyInputFormatter(isIndian: isIndian)
              .formatEditUpdate(
                TextEditingValue.empty,
                TextEditingValue(
                  text: unformattedText,
                  selection: TextSelection.collapsed(
                    offset: unformattedText.length,
                  ),
                ),
              );
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
