import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
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
      subtitle: 'Controls & shortcuts',
      leadingIcon: _QuickActionsLeadingIcon(),
      child: QuickActionsSheetBody(),
    ),
  );
}

class _QuickActionsLeadingIcon extends StatelessWidget {
  const _QuickActionsLeadingIcon();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.32)),
      ),
      child: Icon(Icons.bolt_rounded, size: 22, color: cs.primary),
    );
  }
}

/// Body of the Quick Actions sheet: a CONTROLS group (Privacy Mode +
/// Biometrics toggle tiles) then a SHORTCUTS grid built from the user's
/// configured [quickActionShortcutsProvider] list.
class QuickActionsSheetBody extends ConsumerWidget {
  const QuickActionsSheetBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shortcutIds = ref.watch(quickActionShortcutsProvider);
    final shortcuts =
        shortcutIds.map(shortcutById).whereType<ShortcutMeta>().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GroupLabel('CONTROLS'),
        const SizedBox(height: 10),
        Row(
          children: const [
            Expanded(child: _PrivacyControlTile()),
            SizedBox(width: 10),
            Expanded(child: _BiometricsControlTile()),
          ],
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const _GroupLabel('SHORTCUTS'),
            const Spacer(),
            _EditAffordance(onTap: () => _openConfigure(context)),
          ],
        ),
        const SizedBox(height: 12),
        _ShortcutsGrid(
          shortcuts: shortcuts,
          onConfigure: () => _openConfigure(context),
        ),
      ],
    );
  }

  void _openConfigure(BuildContext context) {
    Navigator.of(context).pop();
    context.push('/settings/quick-actions');
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;
  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: localeFont(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _EditAffordance extends StatelessWidget {
  final VoidCallback onTap;
  const _EditAffordance({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.tune_rounded, size: 15, color: cs.primary),
            const SizedBox(width: 5),
            Text(
              'Edit',
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.primary,
              ),
            ),
          ],
        ),
      ),
    );
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => onChanged(!on),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: on ? cs.primary.withValues(alpha: 0.14) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: on ? cs.primary.withValues(alpha: 0.32) : cs.outline,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: on ? cs.primary : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: on ? Colors.white : cs.onSurfaceVariant,
                  ),
                ),
                Switch.adaptive(
                  value: on,
                  onChanged: onChanged,
                  activeThumbColor: Colors.white,
                  activeTrackColor: cs.primary,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: localeFont(
                fontSize: 11,
                fontWeight: on ? FontWeight.w600 : FontWeight.w400,
                color: on ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ],
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
      onChanged: (_) =>
          ref.read(settingsProvider.notifier).togglePrivacyMode(),
    );
  }
}

class _BiometricsControlTile extends ConsumerWidget {
  const _BiometricsControlTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider
        .select((s) => s.valueOrNull?.biometricsEnabled ?? false));
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
  final VoidCallback onConfigure;

  const _ShortcutsGrid({required this.shortcuts, required this.onConfigure});

  @override
  Widget build(BuildContext context) {
    // 4 columns; cells for each shortcut plus a trailing Edit cell.
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 6,
      childAspectRatio: 0.78,
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
        _EditCell(onTap: onConfigure),
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
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(KuberRadius.lg),
              border: Border.all(color: cs.primary.withValues(alpha: 0.32)),
            ),
            child: Icon(icon, size: 23, color: cs.primary),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _EditCell extends StatelessWidget {
  final VoidCallback onTap;
  const _EditCell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomPaint(
            painter: _DashedSquirclePainter(
              color: cs.outlineVariant,
              radius: KuberRadius.lg,
            ),
            child: SizedBox(
              width: 52,
              height: 52,
              child: Icon(Icons.tune_rounded, size: 22, color: cs.onSurfaceVariant),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Edit',
            textAlign: TextAlign.center,
            style: localeFont(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal dashed rounded-rect outline (no package dependency).
class _DashedSquirclePainter extends CustomPainter {
  final Color color;
  final double radius;
  _DashedSquirclePainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 4.0;
    const dashGap = 3.0;
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedSquirclePainter old) =>
      old.color != color || old.radius != radius;
}
