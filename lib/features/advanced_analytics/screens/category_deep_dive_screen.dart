import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/paywall/pro_state.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import '../widgets/aa_bar_chart.dart';
import '../widgets/analytics_common.dart';
import '../widgets/trends_over_time_section.dart' show AaCategorySelector;

class CategoryDeepDiveScreen extends ConsumerStatefulWidget {
  const CategoryDeepDiveScreen({super.key});

  @override
  ConsumerState<CategoryDeepDiveScreen> createState() =>
      _CategoryDeepDiveScreenState();
}

class _CategoryDeepDiveScreenState
    extends ConsumerState<CategoryDeepDiveScreen> {
  var _gateShown = false;

  @override
  Widget build(BuildContext context) {
    final hasAccess = ref.watch(kuberProStateProvider).hasProAccess;
    if (!hasAccess && !_gateShown) {
      _gateShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        showAdvancedAnalyticsGateSheet(context);
      });
    }
    if (!hasAccess) {
      return const Scaffold(
        body: KuberScrollAwayHeader(
          header: KuberAppBar(title: 'Category deep-dive', showBack: true),
          body: SizedBox.shrink(),
        ),
      );
    }

    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final selected = ref.watch(selectedDeepDiveCategoryProvider);
    final async = ref.watch(categoryDeepDiveProvider);

    return Scaffold(
      body: KuberScrollAwayHeader(
        header: KuberAppBar(title: 'Category deep-dive', showBack: true),
        body: ListView(
          padding: const EdgeInsets.only(bottom: KuberSpace.xxl),
          children: [
            const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Board "Category deep-dive": category chip + date chip.
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: KuberSpace.sm,
                      children: [
                        AaCategorySelector(
                          categories: categories,
                          selectedId: selected,
                          onSelected: (id) =>
                              ref
                                      .read(
                                        selectedDeepDiveCategoryProvider
                                            .notifier,
                                      )
                                      .state =
                                  id,
                        ),
                        const SectionDateRangePicker(
                          section: AdvancedAnalyticsSection.category,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: KuberSpace.lg),
                  async.when(
                    loading: () => const AnalyticsSkeletonBlock(),
                    error: (error, _) => KuberEmptyState(
                      icon: Icons.error_outline_rounded,
                      title: 'Could not load category',
                      description: '$error',
                    ),
                    data: (data) {
                      if (data.categoryId == null) {
                        return const KuberEmptyState(
                          icon: Icons.category_outlined,
                          title: 'Select a category to analyze',
                          description:
                              'Pick a category above to see its spend over time, top '
                              'merchants, and weekday habits.',
                        );
                      }
                      if (data.totalSpent <= 0) {
                        return const KuberEmptyState(
                          icon: Icons.category_outlined,
                          title: 'Not enough data',
                          description:
                              'This category has no expenses in the selected range.',
                        );
                      }
                      return _Results(data: data, categories: categories);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final CategoryDeepDiveResult data;
  final List<Category> categories;

  const _Results({required this.data, required this.categories});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final merchants = data.topMerchants.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberCard(
          child: Row(
            children: [
              _figure(context, 'Total spent', aaMoney(data.totalSpent)),
              _figure(context, 'Monthly avg', aaMoney(data.monthlyAverage)),
            ],
          ),
        ),
        const SizedBox(height: KuberSpace.sectionGap - 4),
        const _Label('SPEND OVER TIME'),
        const SizedBox(height: KuberSpace.sectionHeaderGap),
        AaBarChart(
          height: 170,
          currentLabel: 'Spent',
          data: [
            for (final m in data.series)
              AaBarDatum(
                label: DateFormat('MMM').format(m.month),
                current: m.expense,
              ),
          ],
        ),
        const SizedBox(height: KuberSpace.sectionGap - 4),
        const _Label('TOP 5 MERCHANTS AND THEIR TOTALS'),
        const SizedBox(height: KuberSpace.sm),
        KuberGroup(
          children: [
            for (var i = 0; i < merchants.length; i++)
              KuberListRow(
                leading: SizedBox(
                  width: 28,
                  child: Text(
                    '#${i + 1}',
                    style: tt.labelLarge!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                title: merchants[i].name,
                trailing: Text(
                  aaMoney(merchants[i].total),
                  style: tt.titleSmall!.copyWith(color: cs.onSurface),
                ),
              ),
          ],
        ),
        const SizedBox(height: KuberSpace.sectionGap - 4),
        const _Label('WEEKDAY DISTRIBUTION'),
        const SizedBox(height: KuberSpace.sectionHeaderGap),
        AaBarChart(
          height: 130,
          currentLabel: 'Spent',
          showYAxis: false,
          scrollable: false,
          highlightIndex: _peakIndex(data.weekdayTotals),
          data: [
            for (var i = 0; i < data.weekdayTotals.length; i++)
              AaBarDatum(
                label: const ['M', 'T', 'W', 'T', 'F', 'S', 'S'][i],
                current: data.weekdayTotals[i],
              ),
          ],
        ),
        _CoOccurrence(data: data, categories: categories),
      ],
    );
  }
}

Widget _figure(BuildContext context, String label, String value) {
  final cs = Theme.of(context).colorScheme;
  final tt = Theme.of(context).textTheme;
  return Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        Text(value, style: tt.titleMedium!.copyWith(color: cs.onSurface)),
      ],
    ),
  );
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text, style: sectionHeaderStyle(context));
  }
}

int _peakIndex(List<double> values) {
  var idx = 0;
  var max = double.negativeInfinity;
  for (var i = 0; i < values.length; i++) {
    if (values[i] > max) {
      max = values[i];
      idx = i;
    }
  }
  return idx;
}

/// "You often also spend on X when you spend on Y" — the design's co-occurrence
/// card. Replaces the old raw related-category-ids line.
class _CoOccurrence extends StatelessWidget {
  final CategoryDeepDiveResult data;
  final List<Category> categories;

  const _CoOccurrence({required this.data, required this.categories});

  String? _name(String? id) {
    final intId = int.tryParse(id ?? '');
    final matches = categories.where((c) => c.id == intId);
    return matches.isEmpty ? null : matches.first.name;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (data.relatedCategoryIds.isEmpty) return const SizedBox.shrink();
    final relatedName = _name(data.relatedCategoryIds.first);
    final thisName = _name(data.categoryId);
    if (relatedName == null || thisName == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.md),
      child: Text.rich(
        TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          children: [
            const TextSpan(text: 'You often also spend on '),
            TextSpan(
              text: relatedName,
              style: localeFont(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const TextSpan(text: ' when you spend on '),
            TextSpan(
              text: thisName,
              style: localeFont(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }
}
