import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
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
      body: KuberScrollAwayHeader(
        header: KuberAppBar(showBack: true, title: l.faqTitle),
        body: ListView(
          padding: EdgeInsets.only(
            left: KuberSpace.screenMargin,
            right: KuberSpace.screenMargin,
            top: 0,
            bottom: KuberSpace.lg + systemNavBarInset(context),
          ),
          children: [
            for (final faq in faqs) ...[
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: KuberShape.cardR,
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: ExpansionTile(
                  shape: const Border(),
                  collapsedShape: const Border(),
                  tilePadding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.lg,
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(
                    KuberSpace.lg,
                    0,
                    KuberSpace.lg,
                    KuberSpace.lg,
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
                        fontSize: 14,
                        color: cs.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.sm),
            ],
          ],
        ),
      ),
    );
  }
}
