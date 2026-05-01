import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../providers/history_filter_provider.dart';
import '../models/history_filter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';

class AdvancedFilterScreen extends ConsumerStatefulWidget {
  const AdvancedFilterScreen({super.key});

  @override
  ConsumerState<AdvancedFilterScreen> createState() => _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends ConsumerState<AdvancedFilterScreen> {
  late HistoryFilter _localFilter;

  @override
  void initState() {
    super.initState();
    _localFilter = ref.read(historyFilterProvider);
  }

  void _reset() {
    setState(() {
      _localFilter = const HistoryFilter();
    });
  }

  void _apply() {
    ref.read(historyFilterProvider.notifier).setFilters(
      types: _localFilter.types,
      isRecurring: _localFilter.isRecurring,
      from: _localFilter.from,
      to: _localFilter.to,
      accountIds: _localFilter.accountIds,
      categoryIds: _localFilter.categoryIds,
      tagIds: _localFilter.tagIds,
      clearTypes: _localFilter.types.isEmpty,
      clearRecurring: _localFilter.isRecurring == null,
      clearFrom: _localFilter.from == null,
      clearTo: _localFilter.to == null,
    );
    Navigator.pop(context);
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: _localFilter.from != null && _localFilter.to != null
          ? DateTimeRange(start: _localFilter.from!, end: _localFilter.to!)
          : null,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Theme.of(context).colorScheme.onPrimary,
              surface: Theme.of(context).colorScheme.surface,
              onSurface: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _localFilter = _localFilter.copyWith(
          from: picked.start,
          to: picked.end,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(accountListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          'Advanced Filters',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(
              'CLEAR ALL',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: cs.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              _Section(
                title: 'DATE RANGE',
                child: InkWell(
                  onTap: _selectDateRange,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  child: Container(
                    padding: const EdgeInsets.all(KuberSpacing.lg),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(
                        color: _localFilter.from != null ? cs.primary : cs.outline.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 20, color: _localFilter.from != null ? cs.primary : cs.onSurfaceVariant),
                        const SizedBox(width: KuberSpacing.md),
                        Text(
                          _localFilter.from != null && _localFilter.to != null
                              ? '${DateFormat('MMM d, y').format(_localFilter.from!)} - ${DateFormat('MMM d, y').format(_localFilter.to!)}'
                              : 'Select date range',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _localFilter.from != null ? cs.onSurface : cs.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _Section(
                title: 'TYPE',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _TypePill(
                      label: 'Expense',
                      isSelected: _localFilter.types.contains('expense'),
                      onTap: () => _toggleType('expense'),
                    ),
                    _TypePill(
                      label: 'Income',
                      isSelected: _localFilter.types.contains('income'),
                      onTap: () => _toggleType('income'),
                    ),
                    _TypePill(
                      label: 'Transfer',
                      isSelected: _localFilter.types.contains('transfer'),
                      onTap: () => _toggleType('transfer'),
                    ),
                    _TypePill(
                      label: 'Recurring',
                      isSelected: _localFilter.isRecurring == true,
                      onTap: () => setState(() {
                        _localFilter = _localFilter.copyWith(
                          isRecurring: _localFilter.isRecurring == true ? null : true,
                          clearRecurring: _localFilter.isRecurring == true,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              _Section(
                title: 'ACCOUNTS',
                child: accountsAsync.when(
                  data: (accounts) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: accounts.map((a) => _AccountPill(
                      account: a,
                      isSelected: _localFilter.accountIds.contains(a.id.toString()),
                      onTap: () => _toggleAccount(a.id.toString()),
                    )).toList(),
                  ),
                  loading: () => _SkeletonGrid(itemCount: 3),
                  error: (_, __) => const Text('Error loading accounts'),
                ),
              ),
              const SizedBox(height: 32),
              _Section(
                title: 'CATEGORIES',
                child: categoriesAsync.when(
                  data: (categories) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.map((c) => _CategoryPill(
                      category: c,
                      isSelected: _localFilter.categoryIds.contains(c.id.toString()),
                      onTap: () => _toggleCategory(c.id.toString()),
                    )).toList(),
                  ),
                  loading: () => _SkeletonGrid(itemCount: 6),
                  error: (_, __) => const Text('Error loading categories'),
                ),
              ),
              const SizedBox(height: 32),
              _Section(
                title: 'TAGS',
                child: tagsAsync.when(
                  data: (tags) => Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: tags.map((t) {
                      final isSelected = _localFilter.tagIds.contains(t.id);
                      return GestureDetector(
                        onTap: () => _toggleTag(t.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primary : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            border: Border.all(
                              color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            '#${t.name.toUpperCase()}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  loading: () => _SkeletonGrid(itemCount: 5, height: 32),
                  error: (_, __) => const Text('Error loading tags'),
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(context).padding.bottom),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    cs.surface.withValues(alpha: 0),
                    cs.surface,
                    cs.surface,
                  ],
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KuberRadius.md)),
                  ),
                  child: Text(
                    'APPLY FILTERS',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleType(String type) {
    final types = Set<String>.from(_localFilter.types);
    if (types.contains(type)) {
      types.remove(type);
    } else {
      types.add(type);
    }
    setState(() => _localFilter = _localFilter.copyWith(types: types));
  }

  void _toggleAccount(String id) {
    final ids = Set<String>.from(_localFilter.accountIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    setState(() => _localFilter = _localFilter.copyWith(accountIds: ids));
  }

  void _toggleCategory(String id) {
    final ids = Set<String>.from(_localFilter.categoryIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    setState(() => _localFilter = _localFilter.copyWith(categoryIds: ids));
  }

  void _toggleTag(int id) {
    final ids = Set<int>.from(_localFilter.tagIds);
    if (ids.contains(id)) {
      ids.remove(id);
    } else {
      ids.add(id);
    }
    setState(() => _localFilter = _localFilter.copyWith(tagIds: ids));
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant.withValues(alpha: 0.6),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}

class _AccountPill extends StatelessWidget {
  final Account account;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountPill({
    required this.account,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconData = resolveAccountIcon(account);
    final iconColor = resolveAccountColor(account);
    final typeLabel = account.isCreditCard ? 'CREDIT' : account.type.toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Icon(iconData, size: 20, color: iconColor),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  account.name,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? cs.primary : cs.onSurface,
                  ),
                ),
                Text(
                  typeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.6),
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  final Category category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconData = IconMapper.fromString(category.icon);
    final iconColor = harmonizeCategory(context, Color(category.colorValue));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Icon(iconData, size: 20, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(
              category.name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? cs.primary : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  final int itemCount;
  final double height;

  const _SkeletonGrid({required this.itemCount, this.height = 44});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: cs.surfaceContainerHigh,
      highlightColor: cs.surfaceContainerHighest,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: List.generate(itemCount, (index) => Container(
          width: (MediaQuery.of(context).size.width - 48) / 2,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
        )),
      ),
    );
  }
}
