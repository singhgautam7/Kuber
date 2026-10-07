import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/color_palette.dart';
import 'kuber_bottom_sheet.dart';

class _ColorBank {
  final String label;
  final List<int> swatches;

  const _ColorBank(this.label, this.swatches);
}

Future<void> showColorPicker({
  required BuildContext context,
  required int? selected,
  required ValueChanged<int> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => KuberBottomSheet(
      title: 'Choose colour',
      child: ColorPickerBody(
        selected: selected,
        onSelected: (value) {
          onSelected(value);
          Navigator.of(sheetContext, rootNavigator: true).pop();
        },
      ),
    ),
  );
}

/// The colour banks (Vibrant / Muted / Neutral) as circular swatches.
class ColorPickerBody extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onSelected;

  const ColorPickerBody({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  static const _banks = <_ColorBank>[
    _ColorBank('Vibrant', AppColorPalette.kVibrant),
    _ColorBank('Muted', AppColorPalette.kMuted),
    _ColorBank('Neutral', AppColorPalette.kNeutral),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final bank in _banks) ...[
          _BankLabel(text: bank.label),
          _SwatchGrid(
            swatches: bank.swatches,
            selected: selected,
            onTap: onSelected,
          ),
          if (bank != _banks.last) const SizedBox(height: KuberSpace.lg),
        ],
      ],
    );
  }
}

class _BankLabel extends StatelessWidget {
  final String text;

  const _BankLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
      child: Text(text.toUpperCase(), style: sectionHeaderStyle(context)),
    );
  }
}

class _SwatchGrid extends StatelessWidget {
  final List<int> swatches;
  final int? selected;
  final ValueChanged<int> onTap;

  const _SwatchGrid({
    required this.swatches,
    required this.selected,
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
      itemCount: swatches.length,
      itemBuilder: (_, index) {
        final value = swatches[index];
        return _SwatchCell(
          value: value,
          isSelected: selected == value,
          onTap: () => onTap(value),
        );
      },
    );
  }
}

class _SwatchCell extends StatelessWidget {
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const _SwatchCell({
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final swatchColor = Color(value);
    final isLight =
        ThemeData.estimateBrightnessForColor(swatchColor) == Brightness.light;
    // A light tick on dark swatches in both themes (surface is white in light
    // mode, onSurface is near-white in dark mode).
    final lightTick =
        cs.brightness == Brightness.dark ? cs.onSurface : cs.surface;
    final darkTick =
        cs.brightness == Brightness.dark ? cs.surface : cs.onSurface;
    final tickColor = isLight ? darkTick : lightTick;

    // Circle swatch; selected = 2dp primary ring outside a 2dp gap + check.
    return Material(
      color: Colors.transparent,
      shape: CircleBorder(
        side: BorderSide(
          color: isSelected ? cs.primary : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Ink(
            decoration: BoxDecoration(
              color: swatchColor,
              shape: BoxShape.circle,
            ),
            child: isSelected
                ? Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 18,
                      color: tickColor,
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
