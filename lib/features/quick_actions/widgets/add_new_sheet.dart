import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/add_action_catalog.dart';

/// Opens the FAB long-press "Add New" sheet — a vertical list of add-entry
/// shortcuts. The three core actions (expense/income/transfer) always lead;
/// the customizable tail comes from [addMenuActionsProvider].
Future<void> showAddNewSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const KuberBottomSheet(
      title: 'Add New',
      subtitle: 'Choose what to log',
      leadingIcon: _AddNewLeadingIcon(),
      child: _AddNewSheetBody(),
    ),
  );
}

class _AddNewLeadingIcon extends StatelessWidget {
  const _AddNewLeadingIcon();

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
      child: Icon(Icons.add_rounded, size: 22, color: cs.primary),
    );
  }
}

class _AddNewSheetBody extends ConsumerWidget {
  const _AddNewSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The sheet renders exactly the configured list, so it stays in sync with
    // the Customize Add Menu screen.
    final ids = ref.watch(addMenuActionsProvider);
    final actions =
        ids.map(addActionById).whereType<AddActionMeta>().toList();

    return Column(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _AddActionRow(
            meta: actions[i],
            onTap: () {
              Navigator.of(context).pop();
              context.push(actions[i].route);
            },
          ),
        ],
        const SizedBox(height: 12),
        _EditActionsButton(
          onTap: () {
            Navigator.of(context).pop();
            context.push('/settings/add-menu');
          },
        ),
      ],
    );
  }
}

/// Dashed "Edit Actions" row at the foot of the sheet — mirrors the dashed
/// Edit cell in the Quick Actions grid, opening the Customize Add Menu screen.
class _EditActionsButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditActionsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: CustomPaint(
        painter: _DashedRRectPainter(color: cs.outlineVariant),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.tune_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 8),
              Text(
                'Edit Actions',
                style: localeFont(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Minimal dashed rounded-rect outline (no package dependency).
class _DashedRRectPainter extends CustomPainter {
  final Color color;
  _DashedRRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(KuberRadius.md),
    );
    final path = Path()..addRRect(rrect);
    const dashWidth = 4.0;
    const dashGap = 3.0;
    for (final ui.PathMetric metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dashWidth).clamp(0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) => old.color != color;
}

class _AddActionRow extends StatelessWidget {
  final AddActionMeta meta;
  final VoidCallback onTap;

  const _AddActionRow({required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
                border: Border.all(color: cs.primary.withValues(alpha: 0.32)),
              ),
              child: Icon(meta.icon, size: 20, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                meta.label,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
