import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

class HowToUseScreen extends StatelessWidget {
  const HowToUseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final faqs = [
      (title: l.faqAddTxnQ, body: l.faqAddTxnA),
      (title: l.faqAccountsQ, body: l.faqAccountsA),
      (title: l.faqTransfersQ, body: l.faqTransfersA),
      (title: l.faqCategoriesQ, body: l.faqCategoriesA),
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(showBack: true, showHome: true, title: ''),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.lg,
        ),
        children: [
          Text(
            l.faqTitle,
            style: localeFont(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          for (final faq in faqs) ...[
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
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
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                iconColor: cs.onSurfaceVariant,
                collapsedIconColor: cs.onSurfaceVariant,
                children: [
                  Text(
                    faq.body,
                    style: localeFont(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
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