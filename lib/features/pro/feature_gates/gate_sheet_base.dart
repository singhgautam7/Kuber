import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/sheet_button_section.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/locale_font.dart';

/// Shared shell for all 7 feature-gate prompts. `KuberBottomSheet` already
/// sizes itself to its content (`mainAxisSize.min`), which is the "compact"
/// look the spec calls `enableSnap: false` — the component has no such flag,
/// it is simply never full-height by default.
void showFeatureGateSheet(
  BuildContext context, {
  required IconData icon,
  required String featureName,
  required String headline,
  required String body,
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
        title: headline,
        subtitle: featureName,
        leadingIcon: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Icon(icon, color: cs.primary, size: 20),
        ),
        actions: SheetButtonSection(
          padding: EdgeInsets.zero,
          primary: SheetAction(
            label: 'See Kuber Pro',
            icon: Icons.workspace_premium_rounded,
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/pro');
            },
          ),
          actions: [
            SheetAction(
              label: 'Not now',
              icon: Icons.close_rounded,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
        child: Text(
          body,
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
