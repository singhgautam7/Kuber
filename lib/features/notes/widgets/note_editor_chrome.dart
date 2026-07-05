import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import '../../categories/data/category.dart';
import '../../tags/data/tag.dart';

/// Bespoke minimal top bar for the note editor (screen 1d): back button,
/// centered save status, read-only lock toggle, overflow menu.
class NoteEditorTopBar extends StatelessWidget {
  final bool saving;

  /// False for a brand-new note that hasn't been written to the DB yet — the
  /// status reads "Draft" rather than "Saved".
  final bool persisted;
  final bool readOnly;
  final VoidCallback onToggleReadOnly;
  final VoidCallback onShare;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const NoteEditorTopBar({
    super.key,
    required this.saving,
    required this.persisted,
    required this.readOnly,
    required this.onToggleReadOnly,
    required this.onShare,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 46,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: [
            _BarButton(
              icon: Icons.arrow_back_rounded,
              tooltip: 'Back',
              onTap: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    !persisted
                        ? Icons.edit_note_rounded
                        : saving
                            ? Icons.schedule_rounded
                            : Icons.check_rounded,
                    size: 13,
                    color: (persisted && !saving)
                        ? cs.tertiary
                        : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    !persisted
                        ? 'Draft'
                        : saving
                            ? 'Saving...'
                            : 'Saved',
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _BarButton(
              icon: readOnly ? Icons.lock_rounded : Icons.lock_open_rounded,
              tooltip:
                  readOnly ? 'Turn off read-only' : 'Turn on read-only',
              active: readOnly,
              onTap: onToggleReadOnly,
            ),
            const SizedBox(width: 10),
            PopupMenuButton<String>(
              color: cs.surfaceContainerHigh,
              elevation: 8,
              offset: const Offset(0, 40),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                side: BorderSide(color: cs.outline),
              ),
              onSelected: (v) {
                switch (v) {
                  case 'readonly':
                    onToggleReadOnly();
                  case 'share':
                    onShare();
                  case 'duplicate':
                    onDuplicate();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (ctx) => [
                _menuItem(
                  cs,
                  'readonly',
                  readOnly ? Icons.lock_open_rounded : Icons.lock_rounded,
                  readOnly ? 'Turn off read-only' : 'Turn on read-only',
                ),
                _menuItem(cs, 'share', Icons.share_rounded, 'Share'),
                _menuItem(
                    cs, 'duplicate', Icons.copy_rounded, 'Duplicate'),
                _menuItem(cs, 'delete', Icons.delete_outline_rounded,
                    'Delete',
                    destructive: true),
              ],
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border:
                      Border.all(color: cs.outline.withValues(alpha: 0.25)),
                ),
                child: Icon(Icons.more_vert_rounded,
                    color: cs.onSurfaceVariant, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(
    ColorScheme cs,
    String value,
    IconData icon,
    String label, {
    bool destructive = false,
  }) {
    final color = destructive ? cs.error : cs.onSurface;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label,
              style: localeFont(color: color, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  const _BarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: active
                ? cs.primary.withValues(alpha: 0.12)
                : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: active
                  ? cs.primary.withValues(alpha: 0.4)
                  : cs.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Icon(icon,
              color: active ? cs.primary : cs.onSurfaceVariant, size: 18),
        ),
      ),
    );
  }
}

/// Category pill + tag pills + dashed add-tag affordance (screen 1d). In
/// read-only mode the pills dim and lose their tap targets; the dashed add
/// pill disappears entirely.
class NoteMetadataRow extends StatelessWidget {
  final Category? category;
  final List<Tag> tags;
  final bool readOnly;
  final VoidCallback onCategoryTap;
  final VoidCallback onTagTap;

  const NoteMetadataRow({
    super.key,
    required this.category,
    required this.tags,
    required this.readOnly,
    required this.onCategoryTap,
    required this.onTagTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Use the category's own (harmonized) color for the pill, not the accent.
    final catColor = category != null
        ? harmonizeCategory(context, Color(category!.colorValue))
        : cs.primary;

    return Opacity(
      opacity: readOnly ? 0.6 : 1,
      child: Wrap(
        spacing: 7,
        runSpacing: 7,
        children: [
          GestureDetector(
            onTap: readOnly ? null : onCategoryTap,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: catColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category != null
                        ? IconMapper.fromString(category!.icon)
                        : Icons.category_outlined,
                    size: 12,
                    color: catColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category?.name ?? 'Category',
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: catColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (final tag in tags)
            GestureDetector(
              onTap: readOnly ? null : onTagTap,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Text(
                  '#${tag.name}',
                  style: localeFont(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          if (!readOnly)
            GestureDetector(
              onTap: onTagTap,
              child: CustomPaint(
                foregroundPainter: _DashedBorderPainter(
                  color: cs.outline,
                  radius: KuberRadius.md,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded,
                          size: 12, color: cs.onSurfaceVariant),
                      const SizedBox(width: 5),
                      Text(
                        'Tag',
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + dash),
          paint,
        );
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
