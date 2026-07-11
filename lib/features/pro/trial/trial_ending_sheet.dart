import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/sheet_button_section.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';

/// Shown once, on app open, on day 14 of the trial (guard the "once" part
/// with a SharedPreferences flag keyed to the trial end date — see
/// HANDOFF.md).
void showTrialEndingSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return KuberBottomSheet(
        title: 'Your Kuber Pro trial ends today',
        leadingIcon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: context.kuberColors.warningSubtle,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(
            Icons.hourglass_bottom_rounded,
            color: context.kuberColors.warning,
            size: 20,
          ),
        ),
        actions: SheetButtonSection(
          padding: EdgeInsets.zero,
          primary: SheetAction(
            label: 'See Pro options',
            icon: Icons.workspace_premium_rounded,
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/pro');
            },
          ),
          actions: [
            SheetAction(
              label: 'Continue on free tier',
              icon: Icons.check_rounded,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        child: Text(
          "After today, features like SMS Import, unlimited notes and "
          "automatic backups go back to the free limits. You can pick up "
          "where you left off any time.",
          style: localeFont(
            fontSize: 14,
            color: cs.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      );
    },
  );
}
