import 'package:flutter/material.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/shared/widgets/animated_amount.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_skeleton.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../../services/ah_results.dart';
import '../common/ah_common.dart';
import 'ah_sheets.dart';

const _kCardW = 128.0;
const _kCardH = 76.0;

/// KPI cards 4a: a horizontal row, not tappable, values digit-roll. The Edit
/// tile (dashed) is the last item.
class AhKpiRow extends ConsumerWidget {
  const AhKpiRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kpis = ref.watch(ahViewProvider.select((v) => v.kpis));
    final data = ref.watch(ahKpisProvider).valueOrNull;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;

    String m(double v) => fmt.formatCurrency(v);
    double raw(AhKpi k, AhKpis d) => switch (k) {
          AhKpi.transactions => d.transactions.toDouble(),
          AhKpi.income => d.income,
          AhKpi.expense => d.expense,
          AhKpi.net => d.net,
          AhKpi.average => d.average,
          AhKpi.attachments => d.attachments.toDouble(),
          AhKpi.largest => d.largest,
        };
    String Function(double) format(AhKpi k) => switch (k) {
          AhKpi.transactions || AhKpi.attachments => (v) =>
              fmt.formatNumber(v.round()),
          AhKpi.net => (v) => (v < 0 ? '−' : '+') + m(v.abs()),
          _ => m,
        };

    Color? tint(AhKpi k, AhKpis d) => switch (k) {
          AhKpi.income => money.income,
          AhKpi.expense => money.expense,
          AhKpi.net => d.net < 0 ? money.expense : money.income,
          _ => null,
        };

    return RepaintBoundary(
      child: SizedBox(
        height: _kCardH,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: KuberSpace.screenMargin),
          children: [
            for (final k in kpis) ...[
              SkeletonCrossFade(
                loading: data == null,
                placeholder: const AhDelayed(child: _KpiSkeleton()),
                child: data == null
                    ? const SizedBox(width: _kCardW, height: _kCardH)
                    : _KpiCard(
                        label: ahKpiLabel(l, k),
                        value: raw(k, data),
                        format: format(k),
                        color: tint(k, data) ?? cs.onSurface,
                      ),
              ),
              const SizedBox(width: KuberSpace.sm),
            ],
            _EditTile(
              label: l.ahdKpiEdit,
              onTap: () =>
                  ahShowSheet<void>(context, (_) => const AhKpiSheet()),
            ),
          ],
        ),
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard(
      {required this.label,
      required this.value,
      required this.format,
      required this.color});
  final String label;
  final double value;
  final String Function(double) format;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: _kCardW,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: AnimatedAmount(
                value: value,
                format: format,
                style: tt.titleMedium!.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton();

  @override
  Widget build(BuildContext context) => const KuberSkeleton(
      width: _kCardW, height: _kCardH, borderRadius: 16);
}

class _EditTile extends StatelessWidget {
  const _EditTile({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CustomPaint(
      painter: AhDashedBorder(cs.outline, 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          width: 76,
          height: _kCardH,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit_outlined, color: cs.primary, size: 20),
              const SizedBox(height: 4),
              Text(label,
                  style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.primary)),
            ],
          ),
        ),
      ),
    );
  }
}
