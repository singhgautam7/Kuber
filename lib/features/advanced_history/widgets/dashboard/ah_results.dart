import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/color_harmonizer.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/kuber_empty_state.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_labels.dart';
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import '../common/ah_motion.dart';
import 'ah_group_detail_sheet.dart';
import 'ah_share_bar.dart';
import 'ah_txn_list.dart';

/// The results sliver: grouped rows when grouped, else transaction rows.
class AhResults extends ConsumerWidget {
  const AhResults({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grouped =
        ref.watch(ahViewProvider.select((v) => v.groupBy != AhGroupBy.none));
    return grouped ? const _GroupedResults() : const _TxnResults();
  }
}

/// Fades its sliver in (200 ms) whenever [version] changes: the results
/// cross-fade when the filter, grouping or a saved view changes.
class _FadeOnChange extends StatefulWidget {
  const _FadeOnChange({required this.version, required this.sliver});
  final Object version;
  final Widget sliver;

  @override
  State<_FadeOnChange> createState() => _FadeOnChangeState();
}

class _FadeOnChangeState extends State<_FadeOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200), value: 1);

  @override
  void didUpdateWidget(_FadeOnChange old) {
    super.didUpdateWidget(old);
    if (old.version != widget.version) {
      _c.duration = AhMotion.dur(context, const Duration(milliseconds: 200));
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      SliverFadeTransition(opacity: _c, sliver: widget.sliver);
}

Widget _skeleton() => const SliverToBoxAdapter(
      child: AhDelayed(
        child: Column(children: [
          KuberSkeleton(height: 72, borderRadius: 16),
          SizedBox(height: 8),
          KuberSkeleton(height: 72, borderRadius: 16),
          SizedBox(height: 8),
          KuberSkeleton(height: 72, borderRadius: 16),
        ]),
      ),
    );

Widget _empty(BuildContext context, WidgetRef ref) {
  final l = context.l10n;
  return SliverToBoxAdapter(
    child: KuberEmptyState(
      icon: Icons.search_off_rounded,
      title: l.ahdEmptyTitle,
      description: l.ahdEmptyBody,
    ),
  );
}

Widget _error(BuildContext context, VoidCallback retry) {
  final l = context.l10n;
  return SliverToBoxAdapter(
    child: KuberEmptyState(
      icon: Icons.error_outline_rounded,
      title: l.ahdErrorTitle,
      description: l.ahdErrorBody,
      actionLabel: l.ahdTryAgain,
      onAction: retry,
    ),
  );
}

class _GroupedResults extends ConsumerWidget {
  const _GroupedResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ahGroupsProvider);
    final g = async.valueOrNull;
    if (g == null) {
      return async.hasError
          ? _error(context, () => ref.invalidate(ahGroupsProvider))
          : _skeleton();
    }
    if (g.rows.isEmpty) return _empty(context, ref);
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return _FadeOnChange(
      version: g,
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverList.builder(
            itemCount: g.rows.length,
            itemBuilder: (context, i) => _GroupRow(row: g.rows[i], index: i),
          ),
          if (g.multiTagNote)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: KuberSpace.md),
                child: Text(l.ahdTagNote,
                    style: localeFont(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                        height: 1.4)),
              ),
            ),
        ],
      ),
    );
  }
}

class _GroupRow extends ConsumerWidget {
  const _GroupRow({required this.row, required this.index});
  final AhGroupRow row;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final name = ahGroupLabel(row.by, row.key, row.label, l);
    final raw = row.colorValue != null ? Color(row.colorValue!) : cs.primary;
    final tones = categoryTones(context, raw);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: KuberShape.largeR,
          side: BorderSide(color: cs.outlineVariant),
        ),
        child: InkWell(
          borderRadius: KuberShape.largeR,
          onTap: () => showAhGroupDetail(context,
              groupKey: AhGroupKey(row.by, row.key),
              title: name,
              total: row.total),
          child: Padding(
            padding: const EdgeInsets.all(KuberSpace.md),
            child: Column(
              children: [
                Row(
                  children: [
                    CategoryIcon.square(
                      icon: row.icon != null
                          ? IconMapper.fromString(row.icon!)
                          : ahGroupIcon(row.by),
                      rawColor: raw,
                    ),
                    const SizedBox(width: KuberSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tt.titleSmall!
                                  .copyWith(color: cs.onSurface)),
                          Text(l.ahdTxnN(row.count),
                              style: tt.bodySmall!
                                  .copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(fmt.formatCurrency(row.total),
                            style: tt.titleSmall!.copyWith(
                                color: cs.onSurface,
                                fontFeatures: kAhTabular)),
                        Text(fmt.formatPercentage(row.share * 100),
                            style: tt.bodySmall!.copyWith(
                                color: cs.onSurfaceVariant,
                                fontFeatures: kAhTabular)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.sm),
                AhShareBar(
                  share: row.share,
                  color: tones.viz,
                  track: cs.surfaceContainerHighest,
                  delay: Duration(milliseconds: 30 * (index < 8 ? index : 8)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TxnResults extends ConsumerStatefulWidget {
  const _TxnResults();

  @override
  ConsumerState<_TxnResults> createState() => _TxnResultsState();
}

class _TxnResultsState extends ConsumerState<_TxnResults> {
  bool _loadingMore = false;

  Future<void> _more() async {
    if (_loadingMore) return;
    _loadingMore = true;
    await ref.read(ahTxnPagesProvider(null).notifier).loadMore();
    _loadingMore = false;
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(ahTxnPagesProvider(null));
    final page = async.valueOrNull;
    if (page == null) {
      return async.hasError
          ? _error(context, () => ref.invalidate(ahTxnPagesProvider(null)))
          : _skeleton();
    }
    if (page.items.isEmpty) return _empty(context, ref);
    final byDate = ref.watch(
        ahViewProvider.select((v) => v.sort.field == AhSortField.date));
    final entries = ahDayEntries(page.items, byDate: byDate);
    return _FadeOnChange(
      version: entries.isEmpty ? 0 : entries.first.txns.first.id ^ byDate.hashCode ^ page.total,
      sliver: SliverList.builder(
        itemCount: entries.length + (page.hasMore ? 1 : 0),
        itemBuilder: (context, i) {
          if (i == entries.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _more();
            });
            return const Padding(
              padding: EdgeInsets.all(KuberSpace.lg),
              child: Center(
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            );
          }
          return AhDayBlock(entry: entries[i]);
        },
      ),
    );
  }
}
