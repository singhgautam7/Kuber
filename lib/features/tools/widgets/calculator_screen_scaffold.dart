import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/info_config.dart';
import '../../../core/models/overflow_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import 'calculator_widgets.dart' show ToolSection;
import '../../../shared/widgets/kuber_app_bar.dart';

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
    final mergedOverflow = KuberOverflowConfig(
      items: [
        if (canSave && !isSavedView)
          KuberOverflowItem(
            icon: Icons.bookmark_outline_rounded,
            label: 'Save this calculation',
            onTap: onSave,
          ),
        ...?overflowConfig?.items,
      ],
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        // Disable the Android stretch-overscroll indicator: its shader can
        // blank out complex chart/table content when scrolling back to the top.
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  title: title,
                  showBack: true,
                  infoConfig: infoConfig,
                  overflowConfig: mergedOverflow,
                ),
              ),

              if (banner != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      KuberSpace.screenMargin,
                      0,
                      KuberSpace.screenMargin,
                      KuberSpace.md,
                    ),
                    child: banner!,
                  ),
                ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  0,
                  KuberSpace.screenMargin,
                  KuberSpace.lg,
                ),
                // Inputs first, results below them (review round 3). Each
                // section fades / slides in once when it first appears (e.g.
                // the breakdown cards after the inputs become valid), and the
                // column eases to its new height instead of jumping.
                sliver: SliverToBoxAdapter(
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final (i, section) in sections.indexed) ...[
                          if (i > 0) const SizedBox(height: KuberSpace.lg),
                          _AppearOnce(
                            key: section.key ??
                                (section is ToolSection
                                    ? ValueKey('tool-section-${section.title}')
                                    : ValueKey('tool-section-$i')),
                            child: section,
                          ),
                        ],
                        const SizedBox(height: KuberSpace.lg),
                        if (isSavedView)
                          _SaveBar(
                            onTap: onUpdate ?? () {},
                            enabled: isModified,
                            label: 'Update this calculation',
                            disabledLabel: 'No changes to update',
                          )
                        else
                          _SaveBar(
                            onTap: onSave,
                            enabled: canSave,
                            label: 'Save this calculation',
                            disabledLabel: 'Enter values to save',
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: KuberSpace.xl + systemNavBarInset(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades and slides its child in once, on first mount. State survives later
/// rebuilds (the sections live in a plain Column), so it never re-runs while
/// the user keeps typing.
class _AppearOnce extends StatefulWidget {
  final Widget child;
  const _AppearOnce({super.key, required this.child});

  @override
  State<_AppearOnce> createState() => _AppearOnceState();
}

class _AppearOnceState extends State<_AppearOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 280),
  )..forward();
  late final Animation<double> _t =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _t,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.04), end: Offset.zero)
            .animate(_t),
        child: widget.child,
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
    return AppButton(
      label: enabled ? label : disabledLabel,
      icon: Icons.bookmark_outline_rounded,
      type: AppButtonType.normal,
      fullWidth: true,
      onPressed: enabled ? onTap : null,
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
    final accent = isModified ? context.kuberMoney.income : cs.primary;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpace.md,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
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
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
