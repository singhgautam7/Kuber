import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../pro/home/shortcut_catalog.dart';
import '../../settings/providers/settings_provider.dart';

/// Opens the Quick Actions sheet (nav-bar long-press). Uses the shared
/// [KuberBottomSheet] shell so it matches every other Kuber sheet.
Future<void> showQuickActionsSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const KuberBottomSheet(
      title: 'Quick Actions',
      description: 'Controls & shortcuts',
      child: QuickActionsSheetBody(),
    ),
  );
}

/// Body of the Quick Actions sheet: a CONTROLS group (Privacy Mode +
/// Biometrics toggle tiles) then a SHORTCUTS grid built from the user's
/// configured [quickActionShortcutsProvider] list.
class QuickActionsSheetBody extends ConsumerWidget {
  const QuickActionsSheetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutIds = ref.watch(quickActionShortcutsProvider);
    final shortcuts = shortcutIds
        .map(shortcutById)
        .whereType<ShortcutMeta>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KuberSectionHeader(title: 'CONTROLS'),
        Row(
          children: const [
            Expanded(child: _PrivacyControlTile()),
            SizedBox(width: KuberSpace.sm),
            Expanded(child: _BiometricsControlTile()),
          ],
        ),
        const SizedBox(height: KuberSpace.xl),
        KuberSectionHeader(
          title: 'SHORTCUTS',
          trailing: KuberSectionAction(
            label: 'Edit',
            onTap: () => _openConfigure(context),
          ),
        ),
        _ShortcutsGrid(shortcuts: shortcuts),
      ],
    );
  }

  void _openConfigure(BuildContext context) {
    Navigator.of(context).pop();
    context.push('/settings/quick-actions');
  }
}

// ── Control tiles ──────────────────────────────────────────────────────────

/// Shared shell for a control tile (icon squircle + switch + name + caption).
class _ControlTile extends StatelessWidget {
  final IconData icon;
  final String name;
  final String caption;
  final bool on;
  final ValueChanged<bool> onChanged;

  const _ControlTile({
    required this.icon,
    required this.name,
    required this.caption,
    required this.on,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Control tile (board 3.2d): on = secondaryContainer with a primary disc,
    // off = surfaceContainer + outline. Tap toggles.
    return Semantics(
      toggled: on,
      button: true,
      child: Material(
        color: on ? cs.secondaryContainer : cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.cardR,
          side: on ? BorderSide.none : BorderSide(color: cs.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onChanged(!on),
          child: Padding(
            padding: const EdgeInsets.all(KuberSpace.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: on ? cs.primary : cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 20,
                    color: on ? cs.onPrimary : cs.onSurface,
                  ),
                ),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: on ? cs.onSecondaryContainer : cs.onSurface,
                        ),
                      ),
                      Text(
                        caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: on
                              ? cs.onSecondaryContainer
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyControlTile extends ConsumerWidget {
  const _PrivacyControlTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(privacyModeProvider);
    return _ControlTile(
      icon: Icons.visibility_off_rounded,
      name: 'Privacy Mode',
      caption: on ? 'Amounts hidden' : 'Amounts shown',
      on: on,
      onChanged: (_) => ref.read(settingsProvider.notifier).togglePrivacyMode(),
    );
  }
}

class _BiometricsControlTile extends ConsumerWidget {
  const _BiometricsControlTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(
      settingsProvider.select((s) => s.valueOrNull?.biometricsEnabled ?? false),
    );
    return _ControlTile(
      icon: Icons.fingerprint_rounded,
      name: 'Biometrics',
      caption: on ? 'Enabled' : 'Tap to lock',
      on: on,
      onChanged: (v) =>
          ref.read(settingsProvider.notifier).setBiometricsEnabled(v),
    );
  }
}

// ── Shortcuts grid ─────────────────────────────────────────────────────────

class _ShortcutsGrid extends StatelessWidget {
  final List<ShortcutMeta> shortcuts;

  const _ShortcutsGrid({required this.shortcuts});

  @override
  Widget build(BuildContext context) {
    // 4 columns, one cell per shortcut. Editing is the section header's
    // Edit action.
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: KuberSpace.lg,
      crossAxisSpacing: KuberSpace.sm,
      childAspectRatio: 0.72,
      children: [
        for (final s in shortcuts)
          _ShortcutCell(
            icon: s.icon,
            label: s.shortLabel,
            onTap: () {
              Navigator.of(context).pop();
              context.push(s.route);
            },
          ),
      ],
    );
  }
}

class _ShortcutCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShortcutCell({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: KuberShape.largeR,
            ),
            child: Icon(icon, size: 24, color: cs.onSecondaryContainer),
          ),
          const SizedBox(height: KuberSpace.sm),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.labelMedium!.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
