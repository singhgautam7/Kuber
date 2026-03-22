import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

class TagsScreen extends StatelessWidget {
  const TagsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuberColors.background,
      appBar: const KuberAppBar(showBack: true, title: 'Tags'),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: KuberColors.surfaceCard,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: KuberColors.border),
              ),
              child: const Icon(Icons.label_outlined,
                  color: KuberColors.textSecondary, size: 28),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              'Tags',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: KuberColors.textPrimary,
              ),
            ),
            const SizedBox(height: KuberSpacing.xs),
            Text(
              'Coming soon',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: KuberColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
