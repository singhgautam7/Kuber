import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/providers/analytics_provider.dart'
    show FilterType;
import '../../features/analytics/widgets/active_selection_widget.dart';
import '../../features/analytics/widgets/kuber_calendar_widget.dart';
import '../../features/analytics/widgets/manual_date_range_bottom_sheet.dart';
import '../../features/analytics/widgets/month_picker_bottom_sheet.dart';
import '../../features/analytics/widgets/quick_filter_chips_row.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import 'horizontal_fade_wrapper.dart';

class KuberDateRangeResult {
  final FilterType type;
  final DateTime from;
  final DateTime to;
  const KuberDateRangeResult({
    required this.type,
    required this.from,
    required this.to,
  });
}

/// Reusable date-range picker screen — quick chips + manual entry + inline
/// calendar + sticky primary action. Used by both Analytics ("Apply Filter")
/// and History ("Select Range").
class KuberDateRangeSelector extends ConsumerStatefulWidget {
  /// Label on the sticky primary button. Analytics passes "Apply Filter"
  /// (default). History passes "Select Range".
  final String primaryButtonLabel;
  final FilterType initialType;
  final DateTime initialFrom;
  final DateTime initialTo;
  final ValueChanged<KuberDateRangeResult> onApply;

  /// Header title — defaults to "Select Range".
  final String title;

  const KuberDateRangeSelector({
    super.key,
    this.primaryButtonLabel = 'Apply Filter',
    this.title = 'Select Range',
    required this.initialType,
    required this.initialFrom,
    required this.initialTo,
    required this.onApply,
  });

  @override
  ConsumerState<KuberDateRangeSelector> createState() =>
      _KuberDateRangeSelectorState();
}

class _KuberDateRangeSelectorState
    extends ConsumerState<KuberDateRangeSelector> {
  late FilterType _selectedType;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  late DateTime _viewDate;

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType;
    _rangeStart = widget.initialFrom;
    _rangeEnd = widget.initialTo;
    _viewDate = DateTime(_rangeEnd.year, _rangeEnd.month, 1);
  }

  void _onTypeSelected(FilterType type) {
    setState(() {
      _selectedType = type;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      switch (type) {
        case FilterType.all:
          final transactions =
              ref.read(transactionListProvider).valueOrNull ?? [];
          if (transactions.isEmpty) {
            _rangeStart = today;
          } else {
            final sorted = List.from(transactions)
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
            _rangeStart = sorted.first.createdAt;
          }
          _rangeEnd = today;
          break;
        case FilterType.today:
          _rangeStart = today;
          _rangeEnd = today;
          break;
        case FilterType.thisWeek:
          final weekday = now.weekday;
          _rangeStart = today.subtract(Duration(days: weekday - 1));
          _rangeEnd = today;
          break;
        case FilterType.lastWeek:
          final weekday = now.weekday;
          _rangeStart = today.subtract(Duration(days: weekday + 6));
          _rangeEnd = today.subtract(Duration(days: weekday));
          break;
        case FilterType.thisMonth:
          _rangeStart = DateTime(now.year, now.month, 1);
          _rangeEnd = today;
          break;
        case FilterType.lastMonth:
          _rangeStart = DateTime(now.year, now.month - 1, 1);
          _rangeEnd = DateTime(now.year, now.month, 0);
          break;
        case FilterType.thisYear:
          _rangeStart = DateTime(now.year, 1, 1);
          _rangeEnd = today;
          break;
        case FilterType.custom:
          break;
      }
      _viewDate = DateTime(_rangeEnd.year, _rangeEnd.month, 1);
    });
  }

  void _onDateTapped(DateTime date) {
    if (date.isAfter(DateTime.now())) return;
    setState(() {
      _selectedType = FilterType.custom;
      if (_rangeStart == _rangeEnd) {
        if (date.isBefore(_rangeStart)) {
          _rangeStart = date;
          _rangeEnd = date;
        } else {
          _rangeEnd = date;
        }
      } else {
        _rangeStart = date;
        _rangeEnd = date;
      }
    });
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MonthPickerBottomSheet(
        initialDate: _viewDate,
        onMonthSelected: (date) => setState(() => _viewDate = date),
      ),
    );
  }

  void _showManualInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ManualDateRangeBottomSheet(
        initialFrom: _rangeStart,
        initialTo: _rangeEnd,
        onApply: (from, to) => setState(() {
          _selectedType = FilterType.custom;
          _rangeStart = from;
          _rangeEnd = to;
          _viewDate = DateTime(from.year, from.month, 1);
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.title,
                    style:
                        tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ActiveSelectionWidget(
                        start: _rangeStart,
                        end: _rangeEnd,
                        onEdit: _showManualInput,
                      ),
                    ),
                    const SizedBox(height: 32),
                    HorizontalFadeWrapper(
                      child: QuickFilterChipsRow(
                        selectedType: _selectedType,
                        onTypeSelected: _onTypeSelected,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: KuberCalendarWidget(
                        viewDate: _viewDate,
                        rangeStart: _rangeStart,
                        rangeEnd: _rangeEnd,
                        onDateTapped: _onDateTapped,
                        onMonthPressed: _showMonthPicker,
                        onPrevMonth: () => setState(() => _viewDate =
                            DateTime(_viewDate.year, _viewDate.month - 1, 1)),
                        onNextMonth: () => setState(() => _viewDate =
                            DateTime(_viewDate.year, _viewDate.month + 1, 1)),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _StickyPrimary(
        label: widget.primaryButtonLabel.toUpperCase(),
        onTap: () {
          widget.onApply(KuberDateRangeResult(
            type: _selectedType,
            from: _rangeStart,
            to: _rangeEnd,
          ));
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _StickyPrimary extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _StickyPrimary({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Use viewPadding (raw system inset, never zeroed by an ancestor SafeArea)
    // so the sticky button always clears the system navigation bar in
    // edge-to-edge mode, including 3-button navigation.
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 12 + bottomInset),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            top: BorderSide(color: cs.outline.withValues(alpha: 0.1)),
          ),
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: cs.primary,
              foregroundColor: cs.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              label,
              style: localeFont(
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
    );
  }
}