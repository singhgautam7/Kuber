import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/ah_providers.dart';
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import 'ah_sheets.dart';
import 'ah_txn_list.dart';

/// Group sheet: Total / Average / Largest, then the group's transactions
/// (newest first, 50 at a time).
Future<void> showAhGroupDetail(
  BuildContext context, {
  required AhGroupKey groupKey,
  required String title,
  double? total,
}) =>
    ahShowSheet<void>(
      context,
      (_) => AhGroupDetailSheet(groupKey: groupKey, title: title, total: total),
    );

class AhGroupDetailSheet extends ConsumerStatefulWidget {
  const AhGroupDetailSheet(
      {super.key, required this.groupKey, required this.title, this.total});
  final AhGroupKey groupKey;
  final String title;
  final double? total;

  @override
  ConsumerState<AhGroupDetailSheet> createState() => _AhGroupDetailSheetState();
}

// Rough sizes used to fit the sheet to short groups (a long one fills the
// screen and scrolls).
const _kSheetChrome = 190.0, _kRowEst = 76.0, _kDayEst = 44.0;

class _AhGroupDetailSheetState extends ConsumerState<AhGroupDetailSheet> {
  final _days = AhDayEntryCache();
  final _scrolled = ValueNotifier(false);

  @override
  void dispose() {
    _scrolled.dispose();
    super.dispose();
  }

  Widget _tile(ColorScheme cs, String label, String? value) => Expanded(
        child: value == null
            // Same loading look as the dashboard KPI cards.
            ? const AhDelayed(child: KuberSkeleton(height: 64, borderRadius: 12))
            : Container(
                padding: const EdgeInsets.all(KuberSpace.md),
                decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: KuberShape.mediumR),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: localeFont(
                            fontSize: 12, color: cs.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(value,
                          style: localeFont(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                              fontFeatures: kAhTabular)),
                    ),
                  ],
                ),
              ),
      );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final groupKey = widget.groupKey;
    final total = widget.total;
    final kpis = ref.watch(ahGroupKpisProvider(groupKey)).valueOrNull;
    final page = ref.watch(ahTxnPagesProvider(groupKey));
    final mq = MediaQuery.of(context);
    final maxBody = mq.size.height - mq.padding.vertical - _kSheetChrome;

    final entries = page.valueOrNull == null
        ? const <AhDayEntry>[]
        : _days.of(page.value!.items,
            byDate: true, salt: Localizations.localeOf(context));
    final p = page.valueOrNull;
    final est = 100 +
        (p == null
            ? 3 * _kRowEst
            : p.items.length * _kRowEst +
                entries.length * _kDayEst +
                (p.hasMore ? 72 : 0));
    final bodyH = est.clamp(200.0, maxBody < 200 ? 200.0 : maxBody).toDouble();

    return KuberBottomSheet(
      title: widget.title,
      subtitle: ahGroupName(l, groupKey.by),
      bodyPadding: EdgeInsets.zero,
      child: SizedBox(
        height: bodyH,
        child: Stack(
          children: [
            NotificationListener<ScrollNotification>(
              onNotification: (n) {
                if (n.metrics.axis == Axis.vertical) {
                  _scrolled.value = n.metrics.pixels > 0;
                }
                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                    sliver: SliverToBoxAdapter(
                      child: Row(children: [
                        _tile(
                            cs,
                            l.ahdGsTotal,
                            total != null
                                ? fmt.formatCurrency(total)
                                : kpis == null
                                    ? null
                                    : fmt.formatCurrency(
                                        kpis.income + kpis.expense)),
                        const SizedBox(width: KuberSpace.sm),
                        _tile(
                            cs,
                            l.ahdAverage,
                            kpis == null
                                ? null
                                : fmt.formatCurrency(kpis.average)),
                        const SizedBox(width: KuberSpace.sm),
                        _tile(
                            cs,
                            l.ahdGsLargest,
                            kpis == null
                                ? null
                                : fmt.formatCurrency(kpis.largest)),
                      ]),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: KuberSpace.lg)),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: _list(context, page, entries),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: ValueListenableBuilder<bool>(
                valueListenable: _scrolled,
                builder: (context, scrolled, _) => Divider(
                  height: 1,
                  thickness: 1,
                  color: scrolled ? cs.outlineVariant : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(BuildContext context, AsyncValue<AhTxnPage> page,
      List<AhDayEntry> entries) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final p = page.valueOrNull;
    if (p == null) {
      if (page.hasError) {
        return SliverToBoxAdapter(
            child: Text(l.ahdErrorTitle, style: localeFont(color: cs.error)));
      }
      // Skeleton rows (History pattern) after 150 ms.
      return const SliverToBoxAdapter(
        child: AhDelayed(
          child: Column(children: [
            KuberSkeleton(height: 72, borderRadius: 16),
            SizedBox(height: KuberSpace.sm),
            KuberSkeleton(height: 72, borderRadius: 16),
            SizedBox(height: KuberSpace.sm),
            KuberSkeleton(height: 72, borderRadius: 16),
          ]),
        ),
      );
    }
    // 50 at a time: the next page loads as the sheet scrolls near the end,
    // with a small loader meanwhile. Day blocks build lazily.
    return SliverList.builder(
      itemCount: entries.length + (p.hasMore ? 1 : 0),
      itemBuilder: (context, i) => i == entries.length
          ? _AutoMore(
              key: ValueKey(p.items.length),
              onMore: () => ref
                  .read(ahTxnPagesProvider(widget.groupKey).notifier)
                  .loadMore(),
            )
          : AhDayBlock(entry: entries[i]),
    );
  }
}

/// Calls [onMore] once the sheet's scroll view is within 400 dp of its end
/// (or already is, when the page is short). Shows the loader.
class _AutoMore extends StatefulWidget {
  const _AutoMore({super.key, required this.onMore});
  final VoidCallback onMore;

  @override
  State<_AutoMore> createState() => _AutoMoreState();
}

class _AutoMoreState extends State<_AutoMore> {
  ScrollPosition? _pos;
  bool _fired = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pos?.removeListener(_check);
    _pos = Scrollable.maybeOf(context)?.position;
    _pos?.addListener(_check);
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  void _check() {
    final p = _pos;
    if (_fired || !mounted) return;
    if (p == null || !p.hasContentDimensions || p.extentAfter < 400) {
      _fired = true;
      widget.onMore();
    }
  }

  @override
  void dispose() {
    _pos?.removeListener(_check);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const AhLoadMoreFooter();
}
