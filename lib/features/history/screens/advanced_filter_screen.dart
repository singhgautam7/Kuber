import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/data/tag.dart';
import '../../tags/providers/tag_providers.dart';
import '../../advanced_history/advanced_history_entry.dart';
import '../providers/history_filter_provider.dart';
import '../models/history_filter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/formatters.dart' show CurrencyInputFormatter;
import '../../settings/providers/settings_provider.dart' show formatterProvider, NumberSystem;
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_date_range_selector.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../analytics/providers/analytics_provider.dart' show FilterType;

class AdvancedFilterScreen extends ConsumerStatefulWidget {
  const AdvancedFilterScreen({super.key});

  @override
  ConsumerState<AdvancedFilterScreen> createState() =>
      _AdvancedFilterScreenState();
}

class _AdvancedFilterScreenState extends ConsumerState<AdvancedFilterScreen> {
  late HistoryFilter _localFilter;
  late TextEditingController _searchCtrl;
  late TextEditingController _minAmountCtrl;
  late TextEditingController _maxAmountCtrl;
  final _catSearchCtrl = TextEditingController();
  final _tagSearchCtrl = TextEditingController();
  _Sec? _open;

  @override
  void initState() {
    super.initState();
    _localFilter = ref.read(historyFilterProvider);
    _searchCtrl = TextEditingController(text: _localFilter.searchQuery ?? '');
    _minAmountCtrl = TextEditingController(
      text: _localFilter.minAmount != null
          ? CurrencyInputFormatter(isIndian: _isIndian)
                .format(_localFilter.minAmount!.toStringAsFixed(0))
          : '',
    );
    _maxAmountCtrl = TextEditingController(
      text: _localFilter.maxAmount != null
          ? CurrencyInputFormatter(isIndian: _isIndian)
                .format(_localFilter.maxAmount!.toStringAsFixed(0))
          : '',
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _minAmountCtrl.dispose();
    _maxAmountCtrl.dispose();
    _catSearchCtrl.dispose();
    _tagSearchCtrl.dispose();
    super.dispose();
  }

  bool get _isIndian =>
      ref.read(formatterProvider).system == NumberSystem.indian;

  void _reset() {
    _searchCtrl.clear();
    _minAmountCtrl.clear();
    _maxAmountCtrl.clear();
    setState(() {
      _localFilter = const HistoryFilter();
    });
  }

  void _apply() {
    final searchQuery = _searchCtrl.text.trim();
    final minText = _minAmountCtrl.text.trim();
    final maxText = _maxAmountCtrl.text.trim();
    final minAmount = minText.isNotEmpty ? double.tryParse(minText.replaceAll(',', '')) : null;
    final maxAmount = maxText.isNotEmpty ? double.tryParse(maxText.replaceAll(',', '')) : null;

    final notifier = ref.read(historyFilterProvider.notifier);
    notifier.setFilters(
      types: _localFilter.types,
      isRecurring: _localFilter.isRecurring,
      from: _localFilter.from,
      to: _localFilter.to,
      accountIds: _localFilter.accountIds,
      categoryIds: _localFilter.categoryIds,
      tagIds: _localFilter.tagIds,
      minAmount: minAmount,
      maxAmount: maxAmount,
      clearTypes: _localFilter.types.isEmpty,
      clearRecurring: _localFilter.isRecurring == null,
      clearFrom: _localFilter.from == null,
      clearTo: _localFilter.to == null,
      clearMinAmount: minAmount == null,
      clearMaxAmount: maxAmount == null,
    );
    notifier.setSearchQuery(searchQuery.isEmpty ? null : searchQuery);
    Navigator.pop(context);
  }

  Future<void> _selectDateRange() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final initFrom = _localFilter.from ?? today;
    final initTo = _localFilter.to ?? today;

    await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => KuberDateRangeSelector(
          primaryButtonLabel: context.l10n.selectRange,
          initialType: FilterType.custom,
          initialFrom: initFrom,
          initialTo: initTo,
          onApply: (result) {
            if (!mounted) return;
            setState(() {
              _localFilter = _localFilter.copyWith(
                from: result.from,
                to: result.to,
              );
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final accountsAsync = ref.watch(accountListProvider);
    final categoriesAsync = ref.watch(categoryListProvider);
    final tagsAsync = ref.watch(tagListProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: context.l10n.advancedFiltersTitle,
        showBack: true,
        closeIcon: true,
        actions: [
          TextButton(
            onPressed: _reset,
            child: Text(sentenceCase(context.l10n.clearAll)),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              // 1. DATE RANGE
              _Section(
                title: context.l10n.dateRangeLabel,
                child: KuberGroup(
                  children: [
                    KuberListRow(
                      onTap: _selectDateRange,
                      leading: KuberIconTile(
                        icon: Icons.calendar_today_rounded,
                        tone: _localFilter.from != null
                            ? KuberTone.secondary
                            : KuberTone.neutral,
                      ),
                      title:
                          _localFilter.from != null && _localFilter.to != null
                          ? '${DateFormat('MMM d, y').format(_localFilter.from!)} - ${DateFormat('MMM d, y').format(_localFilter.to!)}'
                          : context.l10n.selectDateRange,
                      trailing: const KuberChevron(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.sectionGap),
              // 2. TRANSACTION NAME
              _Section(
                title: context.l10n.transactionNameLabel,
                child: TextField(
                  controller: _searchCtrl,
                  style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchViaName,
                    hintStyle: textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpace.sectionGap),
              // 3. TYPE
              _Section(
                title: context.l10n.typeFilterLabel,
                child: Wrap(
                  spacing: KuberSpace.sm,
                  runSpacing: KuberSpace.sm,
                  children: [
                    _TypePill(
                      label: context.l10n.expenseLabel,
                      isSelected: _localFilter.types.contains('expense'),
                      onTap: () => _toggleType('expense'),
                    ),
                    _TypePill(
                      label: context.l10n.incomeLabel,
                      isSelected: _localFilter.types.contains('income'),
                      onTap: () => _toggleType('income'),
                    ),
                    _TypePill(
                      label: context.l10n.transferLabel,
                      isSelected: _localFilter.types.contains('transfer'),
                      onTap: () => _toggleType('transfer'),
                    ),
                    _TypePill(
                      label: context.l10n.recurringModule,
                      isSelected: _localFilter.isRecurring == true,
                      onTap: () => setState(() {
                        _localFilter = _localFilter.copyWith(
                          isRecurring: _localFilter.isRecurring == true
                              ? null
                              : true,
                          clearRecurring: _localFilter.isRecurring == true,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.sectionGap),
              // 4. AMOUNT RANGE
              _Section(
                title: context.l10n.amountRangeLabel,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _minAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          CurrencyInputFormatter(isIndian: _isIndian),
                        ],
                        style: textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.minLabel,
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _maxAmountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          CurrencyInputFormatter(isIndian: _isIndian),
                        ],
                        style: textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: context.l10n.maxLabel,
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.sectionGap),
              // 5-7. ACCOUNTS, CATEGORIES, TAGS: collapsible, one open at a time.
              _buildAccounts(accountsAsync),
              const SizedBox(height: KuberSpace.sectionGap),
              _buildCategories(categoriesAsync),
              const SizedBox(height: KuberSpace.sectionGap),
              _buildTags(tagsAsync),
              const SizedBox(height: KuberSpace.sectionGap),
              _AdvancedHistoryLink(
                onTap: () => openAdvancedHistory(context, ref),
              ),
              const SizedBox(height: 120),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.fromLTRB(
                20,
                20,
                20,
                20 + MediaQuery.of(context).padding.bottom,
              ),
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
              child: AppButton(
                label: sentenceCase(context.l10n.applyFilters),
                type: AppButtonType.primary,
                fullWidth: true,
                onPressed: _apply,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSection(_Sec sec) =>
      setState(() => _open = _open == sec ? null : sec);

  Widget _buildAccounts(AsyncValue<List<Account>> async) {
    final l10n = context.l10n;
    final selected = _localFilter.accountIds;
    final sorted = [...?async.valueOrNull]
      ..sort((a, b) {
        int typePriority(Account account) {
          if (account.isCreditCard) return 2;
          if (account.isOverdraft) return 3;
          if (account.type == 'cash') return 0;
          return 1;
        }

        final tp = typePriority(a).compareTo(typePriority(b));
        if (tp != 0) return tp;
        return a.name.compareTo(b.name);
      });
    return _FilterCard(
      title: sentenceCase(l10n.accountsLabel),
      selectedCount: selected.length,
      open: _open == _Sec.accounts,
      onToggle: () => _toggleSection(_Sec.accounts),
      chips: [
        for (final a in sorted)
          if (selected.contains(a.id.toString()))
            KuberChip(
              label: a.name,
              selected: true,
              onDeleted: () => _toggleAccount(a.id.toString()),
            ),
      ],
      body: async.when(
        data: (_) => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final a in sorted)
              _AccountPill(
                account: a,
                isSelected: selected.contains(a.id.toString()),
                onTap: () => _toggleAccount(a.id.toString()),
              ),
          ],
        ),
        loading: () => _SkeletonGrid(itemCount: 3),
        error: (_, __) => Text(l10n.errorLoadingAccounts),
      ),
    );
  }

  Widget _buildCategories(AsyncValue<List<Category>> async) {
    final l10n = context.l10n;
    final selected = _localFilter.categoryIds;
    final sorted = [...?async.valueOrNull]
      ..sort((a, b) => a.name.compareTo(b.name));
    return _FilterCard(
      title: sentenceCase(l10n.categoriesLabel),
      selectedCount: selected.length,
      open: _open == _Sec.categories,
      onToggle: () => _toggleSection(_Sec.categories),
      chips: [
        for (final c in sorted)
          if (selected.contains(c.id.toString()))
            KuberChip(
              label: c.name,
              selected: true,
              onDeleted: () => _toggleCategory(c.id.toString()),
            ),
      ],
      body: async.when(
        data: (_) => _SearchableList(
          controller: _catSearchCtrl,
          hint: l10n.filterSearchCategories,
          sectionName: l10n.categoriesLabel.toLowerCase(),
          names: [for (final c in sorted) c.name],
          build: (i) {
            final c = sorted[i];
            return _CategoryPill(
              category: c,
              isSelected: selected.contains(c.id.toString()),
              onTap: () => _toggleCategory(c.id.toString()),
            );
          },
        ),
        loading: () => _SkeletonGrid(itemCount: 6),
        error: (_, __) => Text(l10n.errorLoadingCategories),
      ),
    );
  }

  Widget _buildTags(AsyncValue<List<Tag>> async) {
    final l10n = context.l10n;
    final selected = _localFilter.tagIds;
    final sorted = [...?async.valueOrNull]
      ..sort((a, b) => a.name.compareTo(b.name));
    return _FilterCard(
      title: sentenceCase(l10n.tagsUpper),
      selectedCount: selected.length,
      open: _open == _Sec.tags,
      onToggle: () => _toggleSection(_Sec.tags),
      chips: [
        for (final t in sorted)
          if (selected.contains(t.id))
            KuberChip(
              label: '#${t.name}',
              selected: true,
              onDeleted: () => _toggleTag(t.id),
            ),
      ],
      body: async.when(
        data: (_) => _SearchableList(
          controller: _tagSearchCtrl,
          hint: l10n.filterSearchTags,
          sectionName: l10n.tagsUpper.toLowerCase(),
          names: [for (final t in sorted) t.name],
          build: (i) {
            final t = sorted[i];
            return KuberChip(
              label: '#${t.name}',
              selected: selected.contains(t.id),
              onTap: () => _toggleTag(t.id),
            );
          },
        ),
        loading: () => _SkeletonGrid(itemCount: 5, height: 32),
        error: (_, __) => Text(l10n.errorLoadingTags),
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

enum _Sec { accounts, categories, tags }

/// Collapsible card (AH.H): header with "· N selected" / "· All" and a
/// chevron; collapsed with selections it shows removable chips. Height
/// animates 250 ms emphasized, chips and list cross-fade 150 ms.
class _FilterCard extends StatelessWidget {
  final String title;
  final int selectedCount;
  final bool open;
  final VoidCallback onToggle;
  final List<Widget> chips;
  final Widget body;

  const _FilterCard({
    required this.title,
    required this.selectedCount,
    required this.open,
    required this.onToggle,
    required this.chips,
    required this.body,
  });

  static const _emphasized = Cubic(0.2, 0, 0, 1);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final reduced = KuberMotion.reduced(context);
    final sizeDur = reduced ? Duration.zero : const Duration(milliseconds: 250);
    final fadeDur = reduced ? Duration.zero : KuberMotion.fast;
    final hasSelection = selectedCount > 0;
    final Widget content = open
        ? Padding(
            key: const ValueKey('open'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: body,
          )
        : hasSelection
        ? Padding(
            key: const ValueKey('chips'),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(spacing: 8, runSpacing: 8, children: chips),
            ),
          )
        : const SizedBox(key: ValueKey('none'), width: double.infinity);

    return Container(
      decoration: BoxDecoration(
        borderRadius: KuberShape.largeR,
        border: Border.all(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: open,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          text: title,
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: cs.onSurface,
                          ),
                          children: [
                            TextSpan(
                              text:
                                  ' ${hasSelection ? l10n.filterSelectedN(selectedCount) : l10n.filterAll}',
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: hasSelection
                                    ? cs.primary
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: sizeDur,
                      curve: _emphasized,
                      child: Icon(
                        Icons.expand_more_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: sizeDur,
            curve: _emphasized,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: fadeDur,
              layoutBuilder: (current, previous) => Stack(
                alignment: Alignment.topCenter,
                children: [...previous, ?current],
              ),
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}

/// Search field plus the matching items (anywhere in the name, ignoring case).
class _SearchableList extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String sectionName;
  final List<String> names;
  final Widget Function(int index) build;

  const _SearchableList({
    required this.controller,
    required this.hint,
    required this.sectionName,
    required this.names,
    required this.build,
  });

  @override
  State<_SearchableList> createState() => _SearchableListState();
}

class _SearchableListState extends State<_SearchableList> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onText);
    super.dispose();
  }

  void _onText() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = widget.controller.text.trim();
    final q = text.toLowerCase();
    final hits = [
      for (var i = 0; i < widget.names.length; i++)
        if (q.isEmpty || widget.names[i].toLowerCase().contains(q)) i,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: widget.controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            prefixIcon: const Icon(Icons.search_rounded),
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 100),
          child: hits.isEmpty
              ? Text(
                  context.l10n.filterNoMatch(widget.sectionName, text),
                  key: const ValueKey('empty'),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                )
              : Wrap(
                  key: const ValueKey('list'),
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final i in hits) widget.build(i)],
                ),
        ),
      ],
    );
  }
}

/// "Need AND / OR filters? Try Advanced History" (link part in primary).
class _AdvancedHistoryLink extends StatelessWidget {
  final VoidCallback onTap;
  const _AdvancedHistoryLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = context.l10n;
    final link = l10n.historyMenuAdvanced;
    final full = l10n.filterTryAdvanced(link);
    final at = full.indexOf(link);
    final style = theme.textTheme.bodyMedium!;
    final spans = at < 0
        ? [TextSpan(text: full, style: style.copyWith(color: cs.primary))]
        : [
            TextSpan(
              text: full.substring(0, at),
              style: style.copyWith(color: cs.onSurfaceVariant),
            ),
            TextSpan(
              text: link,
              style: style.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextSpan(
              text: full.substring(at + link.length),
              style: style.copyWith(color: cs.onSurfaceVariant),
            ),
          ];
    return InkWell(
      onTap: onTap,
      borderRadius: KuberShape.smallR,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text.rich(TextSpan(children: spans), textAlign: TextAlign.center),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title.toUpperCase(), style: sectionHeaderStyle(context)),
        const SizedBox(height: KuberSpace.sectionHeaderGap),
        child,
      ],
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) =>
      KuberChip(label: label, selected: isSelected, onTap: onTap);
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
    final typeLabel = (account.isCreditCard
        ? context.l10n.creditShort
        : account.isOverdraft
        ? context.l10n.accountTypeOverdraft
        : switch (account.type.toLowerCase()) {
            'bank' => context.l10n.bankLabel,
            'wallet' => context.l10n.walletLabel,
            'cash' => context.l10n.cashLabel,
            _ => account.type,
          });

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.secondaryContainer : Colors.transparent,
          borderRadius: KuberShape.smallR,
          border: Border.all(
            color: isSelected ? cs.secondaryContainer : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: categoryTones(context, iconColor).container,
                borderRadius: KuberShape.mediumR,
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
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? cs.onSecondaryContainer : cs.onSurface,
                  ),
                ),
                Text(
                  typeLabel,
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? cs.onSecondaryContainer
                        : cs.onSurfaceVariant,
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
          color: isSelected ? cs.secondaryContainer : Colors.transparent,
          borderRadius: KuberShape.smallR,
          border: Border.all(
            color: isSelected ? cs.secondaryContainer : cs.outlineVariant,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: categoryTones(context, iconColor).container,
                borderRadius: KuberShape.mediumR,
              ),
              child: Icon(iconData, size: 20, color: iconColor),
            ),
            const SizedBox(width: 10),
            Text(
              category.name,
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? cs.onSecondaryContainer : cs.onSurface,
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
        children: List.generate(
          itemCount,
          (index) => Container(
            width: (MediaQuery.of(context).size.width - 48) / 2,
            height: height,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: KuberShape.smallR,
            ),
          ),
        ),
      ),
    );
  }
}
