import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../../pro/paywall/pro_state.dart';
import '../engine/analytics_engine_adapter.dart';
import '../providers/advanced_analytics_provider.dart';
import '../widgets/aa_bar_chart.dart';
import '../widgets/analytics_common.dart';

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
        appBar: KuberAppBar(showBack: true, showHome: true, showBrand: false),
        body: SizedBox.shrink(),
      );
    }

    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final selected = ref.watch(selectedDeepDiveCategoryProvider);
    final async = ref.watch(categoryDeepDiveProvider);

    return Scaffold(
      appBar: const KuberAppBar(
        showBack: true,
        showHome: true,
        showBrand: false,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: KuberSpacing.xxl),
        children: [
          const KuberPageHeader(
            title: 'Category deep-dive',
            description:
                'Inspect a category across time, merchants, and weekday habits',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category (60%) + date filter (40%) share a row of equal
                // height, per the design.
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 6,
                        child: _CategorySelector(
                          categories: categories,
                          selectedId: selected,
                          onSelected: (id) => ref
                              .read(selectedDeepDiveCategoryProvider.notifier)
                              .state = id,
                        ),
                      ),
                      const SizedBox(width: KuberSpacing.sm),
                      const Expanded(
                        flex: 4,
                        child: SectionDateRangePicker(
                          section: AdvancedAnalyticsSection.category,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
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
    final merchants = data.topMerchants.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatPill(
                label: 'Total spent',
                value: aaMoney(data.totalSpent),
                color: cs.onSurface,
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(
              child: StatPill(
                label: 'Monthly avg',
                value: aaMoney(data.monthlyAverage),
                color: cs.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.lg),
        const _Label('SPEND OVER TIME'),
        const SizedBox(height: KuberSpacing.sm),
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
        const SizedBox(height: KuberSpacing.lg),
        const _Label('TOP 5 MERCHANTS AND THEIR TOTALS'),
        const SizedBox(height: KuberSpacing.sm),
        for (var i = 0; i < merchants.length; i++)
          Container(
            padding: const EdgeInsets.symmetric(vertical: KuberSpacing.sm),
            decoration: BoxDecoration(
              border: i == merchants.length - 1
                  ? null
                  : Border(bottom: BorderSide(color: cs.outline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    merchants[i].name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(fontSize: 13.5, color: cs.onSurface),
                  ),
                ),
                Text(
                  aaMoney(merchants[i].total),
                  style: localeFont(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: KuberSpacing.lg),
        const _Label('WEEKDAY DISTRIBUTION'),
        const SizedBox(height: KuberSpacing.sm),
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: localeFont(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.4,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
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
      padding: const EdgeInsets.only(top: KuberSpacing.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Text.rich(
          TextSpan(
            style: localeFont(
              fontSize: 12.5,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
            children: [
              const TextSpan(text: 'You often also spend on '),
              TextSpan(
                text: relatedName,
                style: localeFont(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const TextSpan(text: ' when you spend on '),
              TextSpan(
                text: thisName,
                style: localeFont(
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const TextSpan(text: '.'),
            ],
          ),
        ),
      ),
    );
  }
}

/// Category chooser that opens the same [CategoryPickerSheet] as Add
/// Transaction (search, grouped grid, icons and colors).
class _CategorySelector extends StatelessWidget {
  final List<Category> categories;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  const _CategorySelector({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final selectedIntId = int.tryParse(selectedId ?? '');
    final matches = categories.where((c) => c.id == selectedIntId);
    final selectedCat = matches.isEmpty ? null : matches.first;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: () {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: cs.surfaceContainer,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(KuberRadius.lg),
            ),
          ),
          builder: (_) => CategoryPickerSheet(
            selectedCategoryId: selectedIntId,
            onSelected: (id) {
              onSelected(id.toString());
              Navigator.pop(context);
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            if (selectedCat != null) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Color(selectedCat.colorValue).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                ),
                child: Icon(
                  IconMapper.fromString(selectedCat.icon),
                  size: 16,
                  color: Color(selectedCat.colorValue),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: Text(
                  selectedCat.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'Select a category',
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
