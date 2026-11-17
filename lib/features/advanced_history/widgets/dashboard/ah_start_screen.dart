import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_chips.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_ast.dart';
import '../../query/query_parser.dart' show serializeNode;
import '../../../categories/providers/category_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import '../common/ah_common.dart';
import '../saved/ah_saved_sheet.dart';
import 'ah_sheets.dart';

/// Start screen 5a: nothing is queried until a filter or a grouping is set.
class AhStartScreen extends ConsumerWidget {
  const AhStartScreen({super.key});

  AhView _example(WidgetRef ref, List<ConditionNode> conds,
      {AhGroupBy group = AhGroupBy.none}) {
    final kpis = ref.read(ahViewProvider).kpis;
    final node = conds.length == 1 ? conds.first : AndNode(conds);
    return AhView(
      queryText: serializeNode(node),
      node: node,
      groupBy: group,
      sort: group == AhGroupBy.none
          ? AhSort.ungroupedDefault
          : AhSort.groupedDefault,
      kpis: kpis,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final savedAsync = ref.watch(savedFiltersProvider);
    final saved = savedAsync.valueOrNull ?? const [];
    final catsAsync = ref.watch(categoryListProvider);
    // Skeletons (after 150 ms) only while the data hasn't loaded yet.
    final savedLoading = !savedAsync.hasValue;
    final catsLoading = !catsAsync.hasValue;
    final notifier = ref.read(ahViewProvider.notifier);
    // Examples use the user's own categories and currency.
    final cats = ahExampleCategories(catsAsync.valueOrNull ?? const []);
    final money = ref.watch(formatterProvider).formatCurrency;
    final year = DateTime.now().year;

    Widget chip(String label, VoidCallback onTap, [IconData? icon]) =>
        KuberChip(label: label, icon: icon, onTap: onTap);

    // A sliver: the page's one scroll view also holds the app bar.
    return SliverToBoxAdapter(
        child: AhFadeIn(
            child: Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin, KuberSpace.lg, KuberSpace.screenMargin, 48),
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l.ahdStartLine,
            style: localeFont(
                fontSize: 16, color: cs.onSurfaceVariant, height: 1.4)),
        const SizedBox(height: KuberSpace.lg),
        _StartAction(
          first: true,
          primary: true,
          icon: Icons.filter_list_rounded,
          title: l.ahdAddFilter,
          sub: l.ahdAddFilterSub,
          onTap: () => context.push('/advanced-history/filter'),
        ),
        const SizedBox(height: 2),
        _StartAction(
          icon: Icons.category_outlined,
          title: l.ahdGroupBy,
          sub: l.ahdGroupBySub,
          onTap: () => ahShowSheet<void>(context, (_) => const AhGroupSheet()),
        ),
        const SizedBox(height: 2),
        _StartAction(
          last: true,
          icon: Icons.bookmarks_outlined,
          title: l.ahdOpenSaved,
          sub: savedLoading
              ? '\u00A0'
              : saved.isEmpty
              ? l.ahdNothingSaved
              : l.ahdSavedViewsN(saved.length),
          onTap: () => showAhSavedSheet(context),
        ),
        const SizedBox(height: KuberSpace.sectionGap),
        _Caps(l.ahdTryOne),
        Wrap(spacing: 8, runSpacing: 8, children: [
          if (cats.isNotEmpty)
            chip(
              l.ahExCatOver(cats.first, money(500)),
              () => notifier.applyView(_example(ref, [
                ConditionNode(QueryField.category, QueryOp.eq, [cats.first]),
                const ConditionNode(QueryField.amount, QueryOp.gt, ['500']),
                const ConditionNode(QueryField.date, QueryOp.eq, ['thisyear']),
              ])),
              Icons.payments_outlined,
            ),
          chip(
            l.ahdEx2,
            () => notifier.applyView(_example(
              ref,
              const [
                ConditionNode(QueryField.type, QueryOp.eq, ['expense']),
                ConditionNode(QueryField.tag, QueryOp.eq, ['none']),
              ],
            )),
            Icons.label_off_outlined,
          ),
          if (catsLoading)
            const AhDelayed(
                child: KuberSkeleton(width: 150, height: 32, borderRadius: 16)),
          if (cats.isNotEmpty)
            chip(
              l.ahExCatByMonth(cats.last, '$year'),
              () => notifier.applyView(_example(
                ref,
                [
                  ConditionNode(QueryField.category, QueryOp.eq, [cats.last]),
                  ConditionNode(QueryField.date, QueryOp.eq, ['$year']),
                ],
                group: AhGroupBy.month,
              )),
              Icons.calendar_month_outlined,
            ),
        ]),
        if (savedLoading)
          const AhDelayed(
              child: Padding(
            padding: EdgeInsets.only(top: KuberSpace.sectionGap),
            child: KuberSkeleton(height: 32, borderRadius: 16),
          )),
        if (saved.isNotEmpty) ...[
          const SizedBox(height: KuberSpace.sectionGap),
          _Caps(l.ahdYourSaved),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final f in saved)
              chip(f.name, () => ahApplySaved(ref, f), Icons.bookmark_outline_rounded),
          ]),
        ],
      ],
    ))));
  }
}

class _Caps extends StatelessWidget {
  const _Caps(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
      child: Text(text.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium!
              .copyWith(letterSpacing: 0.8, color: cs.onSurfaceVariant)),
    );
  }
}

class _StartAction extends StatelessWidget {
  const _StartAction({
    required this.icon,
    required this.title,
    required this.sub,
    required this.onTap,
    this.first = false,
    this.last = false,
    this.primary = false,
  });
  final IconData icon;
  final String title;
  final String sub;
  final VoidCallback onTap;
  final bool first;
  final bool last;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = primary ? cs.onPrimary : cs.onSurface;
    final fg2 = primary ? cs.onPrimary : cs.onSurfaceVariant;
    const o = Radius.circular(20), i = Radius.circular(6);
    return AhPill(
      color: primary ? cs.primary : cs.surfaceContainer,
      radius: BorderRadius.vertical(
          top: first ? o : i, bottom: last ? o : i),
      height: 64,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: fg2, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: fg)),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: fg2)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: fg2),
        ],
      ),
    );
  }
}
