import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
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
            loading: () => const Padding(
              padding: EdgeInsets.all(KuberSpace.xl),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => Text(l.ahdErrorTitle,
                style: localeFont(color: cs.error)),
            data: (p) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final e in ahDayEntries(p.items, byDate: true))
                  AhDayBlock(entry: e),
                if (p.hasMore)
                  AppButton(
                    label: l.ahdLoadMore,
                    type: AppButtonType.outline,
                    fullWidth: true,
                    onPressed: () => ref
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
