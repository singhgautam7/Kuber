import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import 'settings_widgets.dart' show SquircleIcon;

/// Shared settings-list primitives, lifted verbatim from `settings_screen.dart`
/// so the Kuber Cards settings page reads identically to the main Settings page.
/// (The main screen aliases its old private names to these.)

/// Uppercase section heading (primary-tinted).
class SettingsSectionLabel extends StatelessWidget {
  final String label;
  const SettingsSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: KuberSpacing.xs),
      child: Text(
        label,
        style: localeFont(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: cs.primary,
        ),
      ),
    );
  }
}

/// Muted one-line description below a [SettingsSectionLabel].
class SettingsSectionDescription extends StatelessWidget {
  final String text;
  const SettingsSectionDescription(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.xs,
        4,
        KuberSpacing.xs,
        KuberSpacing.sm,
      ),
      child: Text(
        text,
        style: localeFont(
          fontSize: 12.5,
          color: cs.onSurfaceVariant,
          height: 1.4,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

/// Bordered card wrapping a column of [SettingsTile]s.
class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: children),
    );
  }
}

/// One settings row: leading squircle icon, label + optional subtitle, optional
/// trailing widget (chevron / switch).
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const SettingsTile({
    super.key,
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: icon, size: 18, padding: 8),
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
                  if (subtitle case final s?)
                    Text(
                      s,
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            if (trailing case final Widget t) t,
          ],
        ),
      ),
    );
  }
}
