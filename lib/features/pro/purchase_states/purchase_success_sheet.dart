import 'package:flutter/material.dart';

import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/sheet_button_section.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';

/// Shown after a successful Kuber Pro purchase or a successful promo claim.
/// `newlyUnlocked` lists the features the user just gained, so the screen
/// reads as a concrete unlock rather than a generic "thanks for paying".
void showProPurchaseSuccessSheet(
  BuildContext context, {
  required List<String> newlyUnlocked,
  VoidCallback? onGetStarted,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return KuberBottomSheet(
        title: 'Welcome to Kuber Pro',
        leadingIcon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(
            Icons.workspace_premium_rounded,
            color: cs.primary,
            size: 20,
          ),
        ),
        actions: SheetButtonSection(
          padding: EdgeInsets.zero,
          primary: SheetAction(
            label: 'Get started',
            icon: Icons.arrow_forward_rounded,
            onPressed: () {
              Navigator.pop(ctx);
              onGetStarted?.call();
            },
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Everything below is unlocked now. No restart needed.',
              style: localeFont(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < newlyUnlocked.length; i++) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                        vertical: KuberSpacing.md,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 18,
                            color: cs.tertiary,
                          ),
                          const SizedBox(width: KuberSpacing.sm),
                          Expanded(
                            child: Text(
                              newlyUnlocked[i],
                              style: localeFont(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (i != newlyUnlocked.length - 1)
                      Divider(height: 1, color: cs.outline),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

/// Full unlocked-feature list, used for both a fresh paid purchase and a
/// promo claim (Section 9 success sheet reuses this).
const kProUnlockedFeatures = <String>[
  'SMS Import',
  'Automatic Backups',
  'Reminders',
  'Unlimited Ask Kuber',
  'Advanced Analytics',
  'Money Stories archive',
  'Unlimited Kuber Notes',
  'Multi-currency accounts',
  'Custom themes',
  'Multiple widgets',
];
