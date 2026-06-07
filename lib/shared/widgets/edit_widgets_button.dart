import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../features/widget_editor/models/home_widget_config.dart';

/// Outlined "Edit Widgets" button. Place at the bottom of the Home or
/// Analytics scrollable list — not sticky.
class EditWidgetsButton extends StatelessWidget {
  final WidgetEditorScope scope;
  final VoidCallback? onTap;

  const EditWidgetsButton({
    super.key,
    required this.scope,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: onTap ??
              () {
                final r = scope == WidgetEditorScope.home
                    ? '/widget-editor/home'
                    : '/widget-editor/analytics';
                context.push(r);
              },
          style: OutlinedButton.styleFrom(
            foregroundColor: cs.onSurface,
            side: BorderSide(color: cs.outline),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
          ),
          icon: Icon(Icons.tune_rounded, size: 18, color: cs.onSurfaceVariant),
          label: Text(
            context.l10n.editWidgets,
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Two rows for More → Settings: opens the home / analytics editor.
class EditWidgetsSettingsRows extends StatelessWidget {
  final VoidCallback onHomeTap;
  final VoidCallback onAnalyticsTap;

  const EditWidgetsSettingsRows({
    super.key,
    required this.onHomeTap,
    required this.onAnalyticsTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        _SettingsRow(
          icon: Icons.home_outlined,
          label: context.l10n.editHomeWidgets,
          subtitle: context.l10n.editHomeWidgetsDesc,
          onTap: onHomeTap,
        ),
        Divider(height: 1, color: cs.outline),
        _SettingsRow(
          icon: Icons.insert_chart_outlined_rounded,
          label: context.l10n.editAnalyticsWidgets,
          subtitle: context.l10n.editAnalyticsWidgetsDesc,
          onTap: onAnalyticsTap,
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Icon(icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: localeFont(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}