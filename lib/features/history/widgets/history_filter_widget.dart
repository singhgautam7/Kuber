import 'package:flutter/material.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_chips.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/history_filter.dart';
import '../providers/history_filter_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../tutorial/models/tutorial_step_keys.dart';

class HistoryFilterWidget extends ConsumerStatefulWidget {
  final VoidCallback onAdvancedTap;

  const HistoryFilterWidget({super.key, required this.onAdvancedTap});

  @override
  ConsumerState<HistoryFilterWidget> createState() =>
      _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends ConsumerState<HistoryFilterWidget> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus && _isSearching) {
      setState(() => _isSearching = false);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchToggle() {
    setState(() {
      _isSearching = true;
      final currentQuery = ref.read(historyFilterProvider).searchQuery;
      _searchController.text = currentQuery ?? '';
      _focusNode.requestFocus();
    });
  }

  void _onSearchCancel() {
    _searchController.clear();
    ref.read(historyFilterProvider.notifier).setSearchQuery(null);
    setState(() {
      _isSearching = false;
      _focusNode.unfocus();
    });
  }

  void _onSearchSubmit(String query) {
    ref
        .read(historyFilterProvider.notifier)
        .setSearchQuery(query.isEmpty ? null : query);
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final notifier = ref.read(historyFilterProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Keep controller in sync when query changes externally (e.g. advanced filter apply / clear all)
    ref.listen<HistoryFilter>(historyFilterProvider, (prev, next) {
      if (prev?.searchQuery != next.searchQuery && !_focusNode.hasFocus) {
        _searchController.text = next.searchQuery ?? '';
      }
    });

    final hasSearchQuery =
        filter.searchQuery != null && filter.searchQuery!.isNotEmpty;

    // Board 3.5: Exp / Inc filter chips on the left; clear (only when
    // something is applied), search and tune icon buttons on the right.
    // Search swaps the row for an inline pill field.
    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isSearching) {
          _onSearchCancel();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.screenMargin,
          vertical: KuberSpace.xs,
        ),
        child: SizedBox(
          height: 48,
          // Chips row <-> inline search cross-fade (review round 3).
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.04, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: (_isSearching || hasSearchQuery)
                ? KeyedSubtree(
                    key: const ValueKey('history-search'),
                    child: _buildSearchInput(cs),
                  )
                : Row(
                    key: const ValueKey('history-chips'),
                    children: [
                      Tooltip(
                        message: context.l10n.filterExpensesTooltip,
                        triggerMode: TooltipTriggerMode.longPress,
                        child: KuberChip(
                          label: context.l10n.filterExp,
                          pill: true,
                          selected: filter.types.contains('expense'),
                          onTap: () => notifier.setType('expense'),
                        ),
                      ),
                      const SizedBox(width: KuberSpace.sm),
                      Tooltip(
                        message: context.l10n.filterIncomeTooltip,
                        triggerMode: TooltipTriggerMode.longPress,
                        child: KuberChip(
                          label: context.l10n.filterInc,
                          pill: true,
                          selected: filter.types.contains('income'),
                          onTap: () => notifier.setType('income'),
                        ),
                      ),
                      const Spacer(),
                      Transform.translate(
                        offset: const Offset(4, 0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Clear grows / shrinks in instead of popping.
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 220),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder: (child, anim) =>
                                  FadeTransition(
                                    opacity: anim,
                                    child: SizeTransition(
                                      axis: Axis.horizontal,
                                      sizeFactor: anim,
                                      child: ScaleTransition(
                                        scale: anim,
                                        child: child,
                                      ),
                                    ),
                                  ),
                              child: filter.isEmpty
                                  ? const SizedBox.shrink(
                                      key: ValueKey('no-clear'),
                                    )
                                  : AppIconButton(
                                      key: const ValueKey('clear-filters'),
                                      icon: Icons.filter_alt_off_rounded,
                                      kind: AppIconButtonKind.danger,
                                      semanticLabel:
                                          context.l10n.clearFiltersTooltip,
                                      onPressed: () {
                                        notifier.clearAll();
                                        _searchController.clear();
                                      },
                                    ),
                            ),
                            AppIconButton(
                              key: const ValueKey('search_icon'),
                              icon: Icons.search_rounded,
                              semanticLabel:
                                  context.l10n.searchTransactionsTooltip,
                              onPressed: _onSearchToggle,
                            ),
                            AppIconButton(
                              key: TutorialStepKeys.historyFilterIcon,
                              icon: Icons.tune_rounded,
                              kind: filter.isAdvanced
                                  ? AppIconButtonKind.tonal
                                  : AppIconButtonKind.standard,
                              semanticLabel:
                                  context.l10n.advancedFiltersTooltip,
                              badge: filter.activeFiltersCount > 0
                                  ? '${filter.activeFiltersCount}'
                                  : null,
                              badgeColor: cs.primary,
                              onBadgeColor: cs.onPrimary,
                              onPressed: widget.onAdvancedTap,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchInput(ColorScheme cs) {
    final theme = Theme.of(context);
    final focused = _focusNode.hasFocus;
    // Inline search pill (board 3.5): back, query, apply.
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.fullR,
        border: Border.all(
          color: focused ? cs.primary : cs.outlineVariant,
          width: focused ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            kind: AppIconButtonKind.plain,
            semanticLabel: 'Back',
            onPressed: _onSearchCancel,
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              focusNode: _focusNode,
              textAlignVertical: TextAlignVertical.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: cs.onSurface),
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: context.l10n.searchTransactionsHint,
                hintStyle: theme.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
                filled: false,
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
              onSubmitted: _onSearchSubmit,
            ),
          ),
          AppIconButton(
            icon: Icons.check_rounded,
            kind: AppIconButtonKind.plain,
            tint: cs.primary,
            semanticLabel: context.l10n.applySearchTooltip,
            onPressed: () => _onSearchSubmit(_searchController.text),
          ),
        ],
      ),
    );
  }
}
