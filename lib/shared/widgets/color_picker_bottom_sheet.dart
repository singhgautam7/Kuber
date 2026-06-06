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
    builder: (_) => _ColorPickerSheet(
      banks: const <_ColorBank>[
        _ColorBank('Vibrant', AppColorPalette.kVibrant),
        _ColorBank('Muted', AppColorPalette.kMuted),
        _ColorBank('Neutral', AppColorPalette.kNeutral),
      ],
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

class _ColorPickerSheet extends StatelessWidget {
  final List<_ColorBank> banks;
  final int? selected;
  final ValueChanged<int> onSelected;

  const _ColorPickerSheet({
    required this.banks,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return KuberBottomSheet(
      title: 'Choose color',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final bank in banks) ...[
            _BankLabel(text: bank.label),
            const SizedBox(height: KuberSpacing.sm),
            _SwatchGrid(
              swatches: bank.swatches,
              selected: selected,
              onTap: (value) {
                onSelected(value);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            if (bank != banks.last) const SizedBox(height: KuberSpacing.lg),
          ],
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
    final tickColor = isLight ? cs.onSurface : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        if (isSelected)
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
              decoration: BoxDecoration(
                color: swatchColor,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(
                  color: Colors.black.withValues(alpha: 0.12),
                  width: 1,
                ),
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
      ],
    );
  }
}