import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SquircleIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final double size;
  final double padding;

  const SquircleIcon({
    super.key,
    required this.icon,
    this.color,
    this.size = 20,
    this.padding = 10,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconColor = color ?? cs.primary;
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Icon(icon, color: iconColor, size: size),
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

    return Row(
      children: options.map((option) {
        final isSelected = option.value == selectedValue;
        final isFirst = options.first == option;
        final isLast = options.last == option;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: isFirst ? 0 : 8,
              right: isLast ? 0 : 8,
            ),
            child: InkWell(
              onTap: () => onSelected(option.value),
              borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary.withValues(alpha: 0.08) : cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.5),
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SquircleIcon(
                        icon: option.icon,
                        size: 16,
                        padding: 8,
                        color: isSelected ? cs.primary : cs.onSurfaceVariant,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        option.label,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? cs.primary : cs.onSurfaceVariant,
                        ),
                      ),
                      if (option.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          option.subtitle!,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
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
          ),
        );
      }).toList(),
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
