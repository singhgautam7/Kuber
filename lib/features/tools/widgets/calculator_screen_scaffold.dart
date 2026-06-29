import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/info_config.dart';
import '../../../core/models/overflow_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';

/// Standard template every calculator screen builds on: app bar (back + home +
/// Save bookmark action + overflow), page header, an optional saved-indicator
/// banner, the calculator [sections] and an inline "Save this calculation"
/// button at the end.
class ToolScreenScaffold extends ConsumerWidget {
  final String title;
  final String subtitle;
  final List<Widget> sections;
  final VoidCallback onSave;

  /// When false, the Save action is disabled (inputs incomplete / invalid).
  final bool canSave;

  /// True when the screen was opened from a saved calculation. The bottom bar
  /// then shows "Update this calculation" (enabled only when [isModified]).
  final bool isSavedView;
  final bool isModified;
  final VoidCallback? onUpdate;

  final KuberInfoConfig? infoConfig;
  final KuberOverflowConfig? overflowConfig;
  final Widget? banner;

  const ToolScreenScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sections,
    required this.onSave,
    this.canSave = true,
    this.isSavedView = false,
    this.isModified = false,
    this.onUpdate,
    this.infoConfig,
    this.overflowConfig,
    this.banner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Save lives at the top of the overflow menu (the AppBar keeps just the
    // info button + overflow). The Save item only appears for a fresh, valid
    // calculation; "View saved …" is always available.
    final mergedOverflow = KuberOverflowConfig(items: [
      if (canSave && !isSavedView)
        KuberOverflowItem(
          icon: Icons.bookmark_outline_rounded,
          label: 'Save this calculation',
          onTap: onSave,
        ),
      ...?overflowConfig?.items,
    ]);

    return Scaffold(
      backgroundColor: cs.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        // Disable the Android stretch-overscroll indicator: its shader can
        // blank out complex chart/table content when scrolling back to the top.
        child: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  title: '',
                  showBack: true,
                  showHome: true,
                  infoConfig: infoConfig,
                  overflowConfig: mergedOverflow,
                ),
              ),
            SliverToBoxAdapter(
              child: KuberPageHeader(title: title, description: subtitle),
            ),
            if (banner != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.md),
                  child: banner!,
                ),
              ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                  KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.lg),
              sliver: SliverList.separated(
                itemCount: sections.length + 1,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: KuberSpacing.lg),
                itemBuilder: (context, i) {
                  if (i < sections.length) return sections[i];
                  if (isSavedView) {
                    return _SaveBar(
                      onTap: onUpdate ?? () {},
                      enabled: isModified,
                      label: 'Update this calculation',
                      disabledLabel: 'No changes to update',
                    );
                  }
                  return _SaveBar(
                    onTap: onSave,
                    enabled: canSave,
                    label: 'Save this calculation',
                    disabledLabel: 'Enter values to save',
                  );
                },
              ),
            ),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: KuberSpacing.xl + systemNavBarInset(context)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final String disabledLabel;
  const _SaveBar({
    required this.onTap,
    required this.label,
    required this.disabledLabel,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = enabled
        ? cs.primary
        : cs.onSurfaceVariant.withValues(alpha: 0.4);
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_outline_rounded, color: color, size: 18),
            const SizedBox(width: 9),
            Text(
              enabled ? label : disabledLabel,
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin informational banner shown under the header when a calculator was
/// opened from a saved item. Pure status (no action buttons) — the bottom bar
/// handles updating.
class SavedIndicatorBanner extends StatelessWidget {
  final String name;
  final bool isModified;

  const SavedIndicatorBanner({
    super.key,
    required this.name,
    required this.isModified,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = isModified ? cs.tertiary : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.bookmark_rounded, size: 15, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Viewing: $name',
              style: localeFont(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isModified)
            Text(
              'Unsaved changes',
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}
