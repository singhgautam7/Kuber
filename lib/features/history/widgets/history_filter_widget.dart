import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/history_filter_provider.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryFilterWidget extends ConsumerStatefulWidget {
  final VoidCallback onAdvancedTap;

  const HistoryFilterWidget({
    super.key,
    required this.onAdvancedTap,
  });

  @override
  ConsumerState<HistoryFilterWidget> createState() => _HistoryFilterWidgetState();
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
    setState(() {
      _isSearching = false;
      _focusNode.unfocus();
    });
  }

  void _onSearchSubmit(String query) {
    ref.read(historyFilterProvider.notifier).setSearchQuery(query.isEmpty ? null : query);
    setState(() => _isSearching = false);
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(historyFilterProvider);
    final notifier = ref.read(historyFilterProvider.notifier);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final hasSearchQuery =
        filter.searchQuery != null && filter.searchQuery!.isNotEmpty;
    final showFiltersLabel = !hasSearchQuery && !_isSearching;

    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isSearching) {
          _onSearchCancel();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: 4,
        ),
        height: 56,
        child: Row(
          children: [
            // Left side elements: FILTERS label OR Back button + Search Input
            if (_isSearching || hasSearchQuery)
              Expanded(child: _buildSearchInput(cs))
            else ...[
              // FILTERS Label
              if (showFiltersLabel)
                Text(
                  'FILTERS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              const Spacer(),
              // Quick Filters: Exp / Inc
              Tooltip(
                message: 'Filter expenses',
                triggerMode: TooltipTriggerMode.longPress,
                child: _QuickFilterButton(
                  label: 'Exp',
                  isSelected: filter.types.contains('expense'),
                  onTap: () => notifier.setType('expense'),
                ),
              ),
              const SizedBox(width: 8),
              Tooltip(
                message: 'Filter income',
                triggerMode: TooltipTriggerMode.longPress,
                child: _QuickFilterButton(
                  label: 'Inc',
                  isSelected: filter.types.contains('income'),
                  onTap: () => notifier.setType('income'),
                ),
              ),
              const SizedBox(width: 8),
              // Search Icon (to expand)
              _buildSearchIcon(cs),
            ],

            // Right side elements: Advanced Filter and Clear buttons
            // They should always be visible (unless we want to hide them when searching, but user explicitly asked:
            // "The clear all filters and advance filters option should still be visible.")
            const SizedBox(width: 8),
            // Filter Icon with Badge
            Tooltip(
              message: 'Advanced filters',
              triggerMode: TooltipTriggerMode.longPress,
              child: _FilterIconButton(
                count: filter.activeFiltersCount,
                isActive: filter.isAdvanced,
                onTap: widget.onAdvancedTap,
              ),
            ),
            const SizedBox(width: 8),
            // Clear Button
            Tooltip(
              message: 'Clear filters',
              triggerMode: TooltipTriggerMode.longPress,
              child: _ClearButton(
                isEnabled: !filter.isEmpty,
                onTap: () {
                  notifier.clearAll();
                  _searchController.clear();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchIcon(ColorScheme cs) {
    return Tooltip(
      message: 'Search transactions',
      triggerMode: TooltipTriggerMode.longPress,
      child: GestureDetector(
        key: const ValueKey('search_icon'),
        onTap: _onSearchToggle,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child:
              Icon(Icons.search_rounded, size: 20, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }

  Widget _buildSearchInput(ColorScheme cs) {
    final theme = Theme.of(context);
    return TextField(
      controller: _searchController,
      focusNode: _focusNode,
      textAlignVertical: TextAlignVertical.center,
      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: cs.onSurface),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: theme.textTheme.bodyMedium?.copyWith(fontSize: 14, color: cs.onSurfaceVariant),
        prefixIcon: IconButton(
          icon: Icon(Icons.arrow_back_rounded, size: 20, color: cs.onSurfaceVariant),
          onPressed: _onSearchCancel,
        ),
        filled: true,
        fillColor: cs.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(vertical: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide(color: cs.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide(color: cs.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide(color: cs.outline),
        ),
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Clear search',
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant, size: 18),
                onPressed: () {
                  _searchController.clear();
                  ref.read(historyFilterProvider.notifier).setSearchQuery(null);
                  _onSearchCancel();
                },
              ),
            ),
            Tooltip(
              message: 'Apply search',
              child: IconButton(
                icon: Icon(Icons.check_rounded, color: cs.primary, size: 20),
                onPressed: () => _onSearchSubmit(_searchController.text),
              ),
            ),
          ],
        ),
      ),
      onSubmitted: _onSearchSubmit,
    );
  }
}

class _QuickFilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickFilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _FilterIconButton extends StatelessWidget {
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterIconButton({
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                color: isActive ? cs.primary : cs.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 20,
              color: isActive ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: BorderRadius.circular(KuberRadius.sm),
                    border: Border.all(color: cs.surface, width: 2),
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onTap;

  const _ClearButton({
    required this.isEnabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.3,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: isEnabled 
                ? Border.all(color: cs.error.withValues(alpha: 0.5))
                : null,
          ),
          child: Icon(
            Icons.delete_sweep_rounded, // Use a "clear all" style icon
            size: 20,
            color: isEnabled ? cs.error : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
