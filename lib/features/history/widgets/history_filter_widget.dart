import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onSearchToggle() {
    setState(() {
      _isSearching = !_isSearching;
      if (_isSearching) {
        _focusNode.requestFocus();
      }
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
      height: 48,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Row for all elements except active search input
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // FILTERS Label
              if (showFiltersLabel)
                Text(
                  'FILTERS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),

              // Buttons Row
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isSearching) ...[
                    // Quick Filters: Exp / Inc
                    Tooltip(
                      message: 'Expense',
                      child: _QuickFilterButton(
                        label: 'Exp',
                        isSelected: filter.types.contains('expense'),
                        onTap: () => notifier.setType('expense'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: 'Income',
                      child: _QuickFilterButton(
                        label: 'Inc',
                        isSelected: filter.types.contains('income'),
                        onTap: () => notifier.setType('income'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  // Search Area (Chip or Icon)
                  if (!_isSearching)
                    _buildSearchArea(hasSearchQuery, filter.searchQuery, cs),

                  if (!_isSearching) ...[
                    const SizedBox(width: 12),
                    // Filter Icon with Badge
                    Tooltip(
                      message: 'Advanced filters',
                      child: _FilterIconButton(
                        count: filter.activeFiltersCount,
                        isActive: filter.isAdvanced,
                        onTap: widget.onAdvancedTap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Clear Button
                    Tooltip(
                      message: 'Clear all filters',
                      child: _ClearButton(
                        isEnabled: !filter.isEmpty,
                        onTap: () {
                          notifier.clearAll();
                          _searchController.clear();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // Animated Search Input (Full Width Overlay)
          if (_isSearching)
            Positioned.fill(
              child: _buildSearchInput(cs),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchArea(bool hasQuery, String? query, ColorScheme cs) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: hasQuery ? _buildSearchChip(query!, cs) : _buildSearchIcon(cs),
    );
  }

  Widget _buildSearchChip(String query, ColorScheme cs) {
    return Tooltip(
      message: 'Search transactions',
      child: GestureDetector(
        key: const ValueKey('search_chip'),
        onTap: _onSearchToggle,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.primary.withValues(alpha: 0.5)),
          ),
          constraints: const BoxConstraints(maxWidth: 150),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_rounded, size: 16, color: cs.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  query,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchIcon(ColorScheme cs) {
    return Tooltip(
      message: 'Search transactions',
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary, width: 2),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _focusNode,
        style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'Search transactions...',
          hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
          prefixIcon: Icon(Icons.search_rounded, size: 20, color: cs.primary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Apply search',
                child: IconButton(
                  icon: Icon(Icons.check_rounded, color: cs.primary),
                  onPressed: () => _onSearchSubmit(_searchController.text),
                ),
              ),
              Tooltip(
                message: 'Clear search',
                child: IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () {
                    _searchController.clear();
                    // Just clear the controller, don't submit yet if user wants to keep typing
                  },
                ),
              ),
            ],
          ),
        ),
        onSubmitted: _onSearchSubmit,
      ),
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
          style: GoogleFonts.inter(
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
