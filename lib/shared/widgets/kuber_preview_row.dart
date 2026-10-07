import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class KuberPreviewRow extends StatelessWidget {
  final String label;
  final Widget leading;
  final String value;
  final VoidCallback onTap;
  final IconData trailingIcon;

  const KuberPreviewRow({
    super.key,
    required this.label,
    required this.leading,
    required this.value,
    required this.onTap,
    this.trailingIcon = Icons.chevron_right_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberShape.medium),
        child: Ink(
          padding: const EdgeInsets.all(KuberSpace.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(trailingIcon, color: cs.onSurfaceVariant, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}