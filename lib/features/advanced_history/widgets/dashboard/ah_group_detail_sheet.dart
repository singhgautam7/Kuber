import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/ah_providers.dart';
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

class AhGroupDetailSheet extends ConsumerWidget {
  const AhGroupDetailSheet(
      {super.key, required this.groupKey, required this.title, this.total});
  final AhGroupKey groupKey;
  final String title;
  final double? total;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final kpis = ref.watch(ahGroupKpisProvider(groupKey)).valueOrNull;
    final page = ref.watch(ahTxnPagesProvider(groupKey));

    Widget tile(String label, String? value) => Expanded(
          child: Container(
            padding: const EdgeInsets.all(KuberSpace.md),
            decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: KuberShape.mediumR),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        localeFont(fontSize: 12, color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(value ?? '…',
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

    return KuberBottomSheet(
      title: title,
      subtitle: ahGroupName(l, groupKey.by),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            tile(
                l.ahdGsTotal,
                total != null
                    ? fmt.formatCurrency(total!)
                    : kpis == null
                        ? null
                        : fmt.formatCurrency(kpis.income + kpis.expense)),
            const SizedBox(width: KuberSpace.sm),
            tile(l.ahdAverage,
                kpis == null ? null : fmt.formatCurrency(kpis.average)),
            const SizedBox(width: KuberSpace.sm),
            tile(l.ahdGsLargest,
                kpis == null ? null : fmt.formatCurrency(kpis.largest)),
          ]),
          const SizedBox(height: KuberSpace.lg),
          page.when(
            // Skeleton rows (History pattern) after 150 ms.
            loading: () => const AhDelayed(
              child: Column(children: [
                KuberSkeleton(height: 72, borderRadius: 16),
                SizedBox(height: KuberSpace.sm),
                KuberSkeleton(height: 72, borderRadius: 16),
                SizedBox(height: KuberSpace.sm),
                KuberSkeleton(height: 72, borderRadius: 16),
              ]),
            ),
            error: (_, __) => Text(l.ahdErrorTitle,
                style: localeFont(color: cs.error)),
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final e in ahDayEntries(p.items, byDate: true))
                  AhDayBlock(entry: e),
                // 50 at a time: the next page loads as the sheet scrolls
                // near the end, with a small loader meanwhile.
                if (p.hasMore)
                  _AutoMore(
                    key: ValueKey(p.items.length),
                    onMore: () => ref
                        .read(ahTxnPagesProvider(groupKey).notifier)
                        .loadMore(),
                  ),
              ],
            ),
          ),
        ],
      ),
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
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(KuberSpace.lg),
        child: Center(
          child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
}
