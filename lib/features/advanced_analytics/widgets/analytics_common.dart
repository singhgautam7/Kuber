import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../categories/providers/category_provider.dart';
import '../providers/advanced_analytics_provider.dart';

final _moneyFormat = NumberFormat.currency(
  locale: 'en_IN',
  symbol: '₹',
  decimalDigits: 0,
);

String aaMoney(double amount) => _moneyFormat.format(amount);
String aaPercent(double value) => '${value.toStringAsFixed(1)}%';

class AnalyticsSectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const AnalyticsSectionCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: KuberSpacing.lg),
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Icon(icon, color: cs.primary, size: 20),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: KuberSpacing.lg),
          child,
        ],
      ),
    );
  }
}

class StatPill extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const StatPill({
    super.key,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = color ?? cs.primary;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}

class AnalyticsSkeletonBlock extends StatelessWidget {
  const AnalyticsSkeletonBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        KuberSkeleton(height: 44),
        SizedBox(height: KuberSpacing.md),
        KuberSkeleton(height: 120),
        SizedBox(height: KuberSpacing.md),
        Row(
          children: [
            Expanded(child: KuberSkeleton(height: 58)),
            SizedBox(width: KuberSpacing.sm),
            Expanded(child: KuberSkeleton(height: 58)),
          ],
        ),
      ],
    );
  }
}

class TinyBars extends StatelessWidget {
  final List<double> values;
  final Color? color;
  final double height;

  const TinyBars({
    super.key,
    required this.values,
    this.color,
    this.height = 96,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxValue = values.fold<double>(0, (a, b) => b > a ? b : a);
    final barColor = color ?? cs.primary;
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final v in values)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: FractionallySizedBox(
                  heightFactor: maxValue <= 0
                      ? 0.04
                      : (v / maxValue).clamp(0.04, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: barColor.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CategoryLabel extends ConsumerWidget {
  final String categoryId;

  const CategoryLabel(this.categoryId, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final id = int.tryParse(categoryId);
    final category = categories.where((c) => c.id == id).firstOrNull;
    final cs = Theme.of(context).colorScheme;
    if (category == null) {
      return Text(
        'Category $categoryId',
        style: localeFont(color: cs.onSurface, fontWeight: FontWeight.w700),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          IconMapper.fromString(category.icon),
          size: 16,
          color: Color(category.colorValue),
        ),
        const SizedBox(width: KuberSpacing.xs),
        Flexible(
          child: Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(color: cs.onSurface, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }
}

/// Per-section date filter. A compact pill that opens a bottom sheet of the
/// four presets (1M / 3M / 6M / 12M), matching the design and the category
/// picker's interaction.
class SectionDateRangePicker extends ConsumerWidget {
  final AdvancedAnalyticsSection section;

  const SectionDateRangePicker({super.key, required this.section});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final range = ref.watch(advancedAnalyticsRangeProvider(section));
    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _RangeSheet(section: section),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today_rounded, size: 14, color: cs.primary),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                range.pillLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded, size: 16, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _RangeSheet extends ConsumerWidget {
  final AdvancedAnalyticsSection section;

  const _RangeSheet({required this.section});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final selected = ref.watch(advancedAnalyticsRangeProvider(section));
    return KuberBottomSheet(
      title: 'Date range',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final r in AdvancedAnalyticsRange.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected == r
                      ? cs.primaryContainer
                      : cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: selected == r ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
              title: Text(
                r.longLabel,
                style: localeFont(
                  fontSize: 14,
                  fontWeight:
                      selected == r ? FontWeight.w600 : FontWeight.w400,
                  color: cs.onSurface,
                ),
              ),
              trailing: selected == r
                  ? Icon(Icons.check_rounded, color: cs.primary, size: 20)
                  : null,
              onTap: () {
                ref.read(advancedAnalyticsRangeProvider(section).notifier)
                    .state = r;
                Navigator.pop(context);
              },
            ),
        ],
      ),
    );
  }
}
