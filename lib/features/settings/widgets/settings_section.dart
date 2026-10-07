import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Shared settings-list primitives, lifted verbatim from `settings_screen.dart`
/// so the Kuber Cards settings page reads identically to the main Settings page.
/// (The main screen aliases its old private names to these.)

/// Caps section heading (board 3.11: the shared section header style).
class SettingsSectionLabel extends StatelessWidget {
  final String label;
  const SettingsSectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
      child: Text(label.toUpperCase(), style: sectionHeaderStyle(context)),
    );
  }
}

/// Section descriptions are dropped in the M3 settings pattern (board 3.11);
/// kept as a no-op so call sites and their strings stay intact.
class SettingsSectionDescription extends StatelessWidget {
  final String text;
  const SettingsSectionDescription(this.text, {super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Bordered card wrapping a column of [SettingsTile]s.
class SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const SettingsCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
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
    final tt = Theme.of(context).textTheme;

    // Board 3.11 row: plain 24 icon, titleMedium label, value / chevron right.
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: KuberSpace.listItem1),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.lg,
          vertical: KuberSpace.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 24, color: cs.onSurfaceVariant),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: tt.titleMedium!.copyWith(color: cs.onSurface),
                  ),
                  if (subtitle case final s?)
                    Text(
                      s,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tt.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.sm),
            if (trailing case final Widget t) t,
          ],
        ),
      ),
    );
  }
}
