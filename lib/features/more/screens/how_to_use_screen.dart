import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  static const _faqs = [
    (
      title: 'How do I add a transaction?',
      body:
          'Tap the + button on the bottom right to add a new transaction. Fill in the amount, select a category and account, then save.',
    ),
    (
      title: 'How do I manage accounts?',
      body:
          'Go to More → Accounts to see all your wallets and bank accounts. You can add new accounts or edit existing ones from there.',
    ),
    (
      title: 'How do transfers work?',
      body:
          'When adding a transaction, select "Transfer" as the type. Pick the source and destination accounts and the amount will be moved between them.',
    ),
    (
      title: 'Can I customize categories?',
      body:
          'Yes! Go to More → Categories to view all categories. Default categories cannot be deleted, but you can add your own custom categories.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuberColors.background,
      appBar: const KuberAppBar(showBack: true, title: 'How to Use'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.lg,
        ),
        children: [
          Text(
            'Frequently Asked Questions',
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: KuberColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          for (final faq in _faqs) ...[
            Container(
              decoration: BoxDecoration(
                color: KuberColors.surfaceCard,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: KuberColors.border),
              ),
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                tilePadding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                ),
                childrenPadding: const EdgeInsets.fromLTRB(
                  KuberSpacing.lg,
                  0,
                  KuberSpacing.lg,
                  KuberSpacing.lg,
                ),
                title: Text(
                  faq.title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: KuberColors.textPrimary,
                  ),
                ),
                iconColor: KuberColors.textSecondary,
                collapsedIconColor: KuberColors.textSecondary,
                children: [
                  Text(
                    faq.body,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: KuberColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
          ],
        ],
      ),
    );
  }
}
