import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class KuberLoader extends StatelessWidget {
  final String label;

  const KuberLoader({super.key, this.label = 'Loading...'});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.xl),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: cs.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              label,
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}