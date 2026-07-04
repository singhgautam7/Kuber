import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../providers/notes_provider.dart';

/// Search field + dedicated filter icon button (screen 1a — matches the
/// History tab's search + advanced-filter pattern). The filter button opens
/// the fullscreen NotesFilterScreen.
class NotesSearchRow extends StatelessWidget {
  final TextEditingController controller;
  final bool filterActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilterTap;

  const NotesSearchRow({
    super.key,
    required this.controller,
    required this.filterActive,
    required this.onChanged,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 42,
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              style: localeFont(fontSize: 13.5, color: cs.onSurface),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 17, color: cs.onSurfaceVariant),
                hintText: 'Search notes',
                hintStyle: localeFont(
                  fontSize: 13.5,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: filterActive
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                  color: filterActive ? cs.primary : cs.outline),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.filter_list_rounded,
                    size: 17, color: cs.onSurfaceVariant),
                if (filterActive)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.surface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Sort popover anchor button + list/grid segmented toggle (screen 1a).
class NotesSortViewRow extends StatelessWidget {
  final String sortLabel;
  final NotesViewMode viewMode;
  final void Function(BuildContext anchorContext) onSortTap;
  final ValueChanged<NotesViewMode> onViewModeChanged;

  const NotesSortViewRow({
    super.key,
    required this.sortLabel,
    required this.viewMode,
    required this.onSortTap,
    required this.onViewModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Builder(
          builder: (anchorContext) => GestureDetector(
            onTap: () => onSortTap(anchorContext),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded,
                      size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 5),
                  Text(
                    sortLabel,
                    style: localeFont(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ViewModeButton(
                icon: Icons.view_list_rounded,
                active: viewMode == NotesViewMode.list,
                onTap: () => onViewModeChanged(NotesViewMode.list),
              ),
              const SizedBox(width: 4),
              _ViewModeButton(
                icon: Icons.grid_view_rounded,
                active: viewMode == NotesViewMode.grid,
                onTap: () => onViewModeChanged(NotesViewMode.grid),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewModeButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _ViewModeButton({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 24,
        decoration: BoxDecoration(
          color: active
              ? cs.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon,
            size: 15, color: active ? cs.primary : cs.onSurfaceVariant),
      ),
    );
  }
}

/// Uppercase micro-caption between note groups (PINNED / OTHERS).
class NotesSectionCaption extends StatelessWidget {
  final String label;

  const NotesSectionCaption(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 16, 2, 10),
      child: Text(
        label,
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
