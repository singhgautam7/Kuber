import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/card_palette.dart';
import '../../core/utils/locale_font.dart';
import 'kuber_bottom_sheet.dart';

/// Bottom-sheet color/gradient picker for Kuber Cards, following the same
/// pattern as the Accounts/Category `showColorPicker` (a `KuberBottomSheet` with
/// a swatch grid). Shows all solid colors, then the gradient presets. The
/// selected swatch carries the Vault selected-ring (2px `cs.primary`, offset
/// 3px), identical to `_SwatchCell` in `color_picker_bottom_sheet.dart`.
Future<void> showCardColorPicker({
  required BuildContext context,
  required int selectedValue,
  required bool selectedIsGradient,
  required void Function(int value, bool isGradient) onSelected,
}) {
  final cs = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: cs.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
    ),
    builder: (_) => _CardColorPickerSheet(
      selectedValue: selectedValue,
      selectedIsGradient: selectedIsGradient,
      onSelected: onSelected,
    ),
  );
}

class _CardColorPickerSheet extends StatelessWidget {
  final int selectedValue;
  final bool selectedIsGradient;
  final void Function(int value, bool isGradient) onSelected;

  const _CardColorPickerSheet({
    required this.selectedValue,
    required this.selectedIsGradient,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return KuberBottomSheet(
      title: 'Choose color',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BankLabel(text: 'Solid'),
          const SizedBox(height: KuberSpacing.sm),
          _Grid(
            count: CardPalette.solids.length,
            decorationFor: (i) => BoxDecoration(
              color: Color(CardPalette.solids[i]),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
            ),
            selectedFor: (i) =>
                !selectedIsGradient && selectedValue == CardPalette.solids[i],
            onTap: (i) {
              onSelected(CardPalette.solids[i], false);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
          const SizedBox(height: KuberSpacing.lg),
          _BankLabel(text: 'Gradient'),
          const SizedBox(height: KuberSpacing.sm),
          _Grid(
            count: CardPalette.gradients.length,
            decorationFor: (i) => BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  CardPalette.gradientColors(i).$1,
                  CardPalette.gradientColors(i).$2,
                ],
              ),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
            ),
            selectedFor: (i) => selectedIsGradient && selectedValue == i,
            onTap: (i) {
              onSelected(i, true);
              Navigator.of(context, rootNavigator: true).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _BankLabel extends StatelessWidget {
  final String text;
  const _BankLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text.toUpperCase(),
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  final int count;
  final BoxDecoration Function(int) decorationFor;
  final bool Function(int) selectedFor;
  final ValueChanged<int> onTap;

  const _Grid({
    required this.count,
    required this.decorationFor,
    required this.selectedFor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: count,
      itemBuilder: (_, i) => _SwatchCell(
        decoration: decorationFor(i),
        selected: selectedFor(i),
        onTap: () => onTap(i),
      ),
    );
  }
}

class _SwatchCell extends StatelessWidget {
  final BoxDecoration decoration;
  final bool selected;
  final VoidCallback onTap;

  const _SwatchCell({
    required this.decoration,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (selected)
          Positioned(
            left: -3,
            right: -3,
            top: -3,
            bottom: -3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(KuberRadius.md + 3),
                border: Border.all(color: cs.primary, width: 2),
              ),
            ),
          ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            child: Ink(
              decoration: decoration,
              child: selected
                  ? const Center(
                      child: Icon(Icons.check_rounded,
                          size: 18, color: Colors.white),
                    )
                  : const SizedBox.expand(),
            ),
          ),
        ),
      ],
    );
  }
}
