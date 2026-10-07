import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/color_harmonizer.dart';
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

/// One block of an Advanced Analytics screen (board "Trends"): a caps
/// section header (with an optional trailing control and a bodySmall
/// subtitle under it) over a bordered surfaceContainer card. [icon] is kept
/// for callers but no longer drawn: the screen header already names it.
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
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: sectionHeaderStyle(context),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(KuberSpace.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: KuberShape.largeR,
              border: Border.all(color: cs.outlineVariant),
            ),
            child: child,
          ),
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
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.lg,
        KuberSpace.md,
        KuberSpace.lg,
        KuberSpace.md,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: tt.titleMedium!.copyWith(color: accent),
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
        SizedBox(height: KuberSpace.md),
        KuberSkeleton(height: 120),
        SizedBox(height: KuberSpace.md),
        Row(
          children: [
            Expanded(child: KuberSkeleton(height: 58)),
            SizedBox(width: KuberSpace.sm),
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
                      borderRadius: BorderRadius.circular(KuberShape.small),
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
        const SizedBox(width: KuberSpace.xs),
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

/// A grouped-list row for a category (boards "Forecast", "Year over year"):
/// 40 tile in the category colour (re-toned), name, optional subtitle and
/// trailing. Falls back to "Category id" when the category is gone.
class AnalyticsCategoryRow extends ConsumerWidget {
  final String categoryId;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const AnalyticsCategoryRow({
    super.key,
    required this.categoryId,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final id = int.tryParse(categoryId);
    final category = categories.where((c) => c.id == id).firstOrNull;
    final tones = categoryTones(
      context,
      category == null ? cs.outline : Color(category.colorValue),
    );
    return KuberListRow(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(
          category == null
              ? Icons.category_outlined
              : IconMapper.fromString(category.icon),
          size: 20,
          color: tones.fg,
        ),
      ),
      title: category?.name ?? 'Category $categoryId',
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
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
    final range = ref.watch(advancedAnalyticsRangeProvider(section));
    return KuberDropdownChip<AdvancedAnalyticsRange>(
      value: range,
      icon: Icons.calendar_today_outlined,
      label: range.longLabel,
      options: [
        for (final r in AdvancedAnalyticsRange.values)
          KuberDropdownOption(r, r.longLabel),
      ],
      onChanged: (r) =>
          ref.read(advancedAnalyticsRangeProvider(section).notifier).state = r,
    );
  }
}
