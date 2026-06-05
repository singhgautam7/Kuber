import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          padding: const EdgeInsets.all(KuberSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15,
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
