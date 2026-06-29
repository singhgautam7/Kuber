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
    this.infoConfig,
    this.overflowConfig,
    this.banner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // Save lives at the top of the overflow menu (the AppBar keeps just the
    // info button + overflow). The Save item only appears once inputs are
    // valid; "View saved …" is always available.
    final mergedOverflow = KuberOverflowConfig(items: [
      if (canSave)
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
                  return _SaveBar(onTap: onSave, enabled: canSave);
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
  const _SaveBar({required this.onTap, this.enabled = true});

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
              enabled
                  ? 'Save this calculation'
                  : 'Enter values to save',
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

/// Thin banner shown under the header when a calculator was opened from a saved
/// item. Switches between the "Viewing" and "Modified" states.
class SavedIndicatorBanner extends StatelessWidget {
  final String name;
  final bool isModified;
  final VoidCallback onUpdate;
  final VoidCallback onSaveAsNew;
  final VoidCallback? onDiscard;

  const SavedIndicatorBanner({
    super.key,
    required this.name,
    required this.isModified,
    required this.onUpdate,
    required this.onSaveAsNew,
    this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = isModified ? cs.tertiary : cs.primary;
    return Container(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.md, KuberSpacing.sm, KuberSpacing.sm, KuberSpacing.sm),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, top: 2, bottom: 4),
            child: Text(
              isModified ? 'Modified — update saved?' : 'Viewing: $name',
              style: localeFont(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: accent,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Wrap(
            spacing: KuberSpacing.xs,
            children: [
              _BannerAction(label: 'Update', onTap: onUpdate, color: accent),
              _BannerAction(
                  label: 'Save as new', onTap: onSaveAsNew, color: accent),
              if (isModified && onDiscard != null)
                _BannerAction(
                    label: 'Discard changes',
                    onTap: onDiscard!,
                    color: cs.onSurfaceVariant),
            ],
          ),
        ],
      ),
    );
  }
}

class _BannerAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _BannerAction(
      {required this.label, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        child: Text(
          label,
          style: localeFont(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
