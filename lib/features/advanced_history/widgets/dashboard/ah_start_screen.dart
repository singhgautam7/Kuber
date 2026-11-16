import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_ast.dart';
import '../common/ah_common.dart';
import '../saved/ah_saved_sheet.dart';
import 'ah_sheets.dart';

/// Start screen 5a: nothing is queried until a filter or a grouping is set.
class AhStartScreen extends ConsumerWidget {
  const AhStartScreen({super.key});

  AhView _example(WidgetRef ref, List<ConditionNode> conds, String text,
      {AhGroupBy group = AhGroupBy.none}) {
    final kpis = ref.read(ahViewProvider).kpis;
    return AhView(
      queryText: text,
      node: conds.length == 1 ? conds.first : AndNode(conds),
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
    final saved = ref.watch(savedFiltersProvider).valueOrNull ?? const [];
    final notifier = ref.read(ahViewProvider.notifier);

    Widget chip(String label, VoidCallback onTap) => ActionChip(
          label: Text(label, style: localeFont(fontSize: 14, color: cs.onSurface)),
          backgroundColor: cs.surfaceContainer,
          side: BorderSide(color: cs.outlineVariant),
          shape: const StadiumBorder(),
          onPressed: onTap,
        );

    return ListView(
      primary: false,
      padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin, KuberSpace.lg, KuberSpace.screenMargin, 48),
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
          sub: saved.isEmpty
              ? l.ahdNothingSaved
              : l.ahdSavedViewsN(saved.length),
          onTap: () => showAhSavedSheet(context),
        ),
        const SizedBox(height: KuberSpace.sectionGap),
        _Caps(l.ahdTryOne),
        Wrap(spacing: 8, runSpacing: 8, children: [
          chip(
            l.ahdEx1,
            () => notifier.applyView(_example(
              ref,
              const [
                ConditionNode(QueryField.category, QueryOp.eq, ['food']),
                ConditionNode(QueryField.amount, QueryOp.gt, ['500']),
                ConditionNode(QueryField.date, QueryOp.eq, ['thisyear']),
              ],
              'category:food amount:>500 date:thisyear',
            )),
          ),
          chip(
            l.ahdEx2,
            () => notifier.applyView(_example(
              ref,
              const [
                ConditionNode(QueryField.type, QueryOp.eq, ['expense']),
                ConditionNode(QueryField.tag, QueryOp.eq, ['none']),
              ],
              'type:expense tag:none',
            )),
          ),
          chip(
            l.ahdEx3,
            () => notifier.applyView(_example(
              ref,
              const [
                ConditionNode(QueryField.category, QueryOp.eq, ['travel']),
                ConditionNode(QueryField.date, QueryOp.eq, ['2026']),
              ],
              'category:travel date:2026',
              group: AhGroupBy.month,
            )),
          ),
        ]),
        if (saved.isNotEmpty) ...[
          const SizedBox(height: KuberSpace.sectionGap),
          _Caps(l.ahdYourSaved),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final f in saved)
              chip(f.name, () => ahApplySaved(ref, f)),
          ]),
        ],
      ],
    );
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
