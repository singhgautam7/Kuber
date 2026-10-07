import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class SquircleIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double padding;

  /// Optional custom glyph rendered in place of [icon] (e.g. the Ask Kuber
  /// mark). The squircle container itself is unchanged.
  final Widget? glyph;

  const SquircleIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 20,
    this.padding = 10,
    this.glyph,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = color ?? cs.onSecondaryContainer;

    // M3 icon tile: secondaryContainer, r12, no border.
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.mediumR,
      ),
      child: glyph ?? Icon(icon, color: iconColor, size: size),
    );
  }
}

class SettingsCardSelector<T> extends StatelessWidget {
  final List<SelectorOption<T>> options;
  final T selectedValue;
  final Function(T) onSelected;

  const SettingsCardSelector({
    super.key,
    required this.options,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tt = Theme.of(context).textTheme;

    // M3 choice tiles: selected = secondaryContainer + check, others
    // surfaceContainer with an outlineVariant border, r16.
    return Row(
      children: [
        for (var i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: KuberSpace.sm),
          Expanded(
            child: Builder(
              builder: (context) {
                final option = options[i];
                final isSelected = option.value == selectedValue;
                final fg = isSelected
                    ? cs.onSecondaryContainer
                    : cs.onSurfaceVariant;
                return Material(
                  color: isSelected
                      ? cs.secondaryContainer
                      : cs.surfaceContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: KuberShape.cardR,
                    side: BorderSide(
                      color: isSelected
                          ? cs.secondaryContainer
                          : cs.outlineVariant,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelected(option.value),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: KuberSpace.lg,
                            horizontal: KuberSpace.sm,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(option.icon, size: 24, color: fg),
                                const SizedBox(height: KuberSpace.sm),
                                Text(
                                  option.label,
                                  textAlign: TextAlign.center,
                                  style: tt.labelLarge!.copyWith(
                                    color: isSelected
                                        ? cs.onSecondaryContainer
                                        : cs.onSurface,
                                  ),
                                ),
                                if (option.subtitle != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    option.subtitle!,
                                    textAlign: TextAlign.center,
                                    style: tt.bodySmall!.copyWith(color: fg),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Icon(
                              Icons.check_circle_rounded,
                              size: 18,
                              color: cs.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class SelectorOption<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData icon;

  const SelectorOption({
    required this.value,
    required this.label,
    this.subtitle,
    required this.icon,
  });
}
