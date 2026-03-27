import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../transactions/providers/transaction_provider.dart';
import '../providers/analytics_provider.dart';
import '../widgets/active_selection_widget.dart';
import '../widgets/quick_filter_chips_row.dart';
import '../widgets/kuber_calendar_widget.dart';
import '../widgets/month_picker_bottom_sheet.dart';
import '../widgets/manual_date_range_bottom_sheet.dart';
import '../widgets/horizontal_fade_wrapper.dart';

class AnalyticsFilterScreen extends ConsumerStatefulWidget {
  const AnalyticsFilterScreen({super.key});

  @override
  ConsumerState<AnalyticsFilterScreen> createState() => _AnalyticsFilterScreenState();
}

class _AnalyticsFilterScreenState extends ConsumerState<AnalyticsFilterScreen> {
  late FilterType _selectedType;
  late DateTime _rangeStart;
  late DateTime _rangeEnd;
  late DateTime _viewDate;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(analyticsFilterProvider);
    _selectedType = filter.type;
    _rangeStart = filter.from;
    _rangeEnd = filter.to;
    _viewDate = DateTime(_rangeEnd.year, _rangeEnd.month, 1);
  }

  void _onTypeSelected(FilterType type) {
    setState(() {
      _selectedType = type;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      switch (type) {
        case FilterType.all:
          final transactions = ref.read(transactionListProvider).valueOrNull ?? [];
          if (transactions.isEmpty) {
            _rangeStart = today;
          } else {
            final sorted = List.from(transactions)..sort((a, b) => a.createdAt.compareTo(b.createdAt));
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

  void _onMonthChanged(int offset) {
    setState(() {
      _viewDate = DateTime(_viewDate.year, _viewDate.month + offset, 1);
    });
  }

  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthPickerBottomSheet(
        initialDate: _viewDate,
        onMonthSelected: (date) {
          setState(() {
            _viewDate = date;
          });
        },
      ),
    );
  }

  void _showManualInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ManualDateRangeBottomSheet(
        initialFrom: _rangeStart,
        initialTo: _rangeEnd,
        onApply: (from, to) {
          setState(() {
            _selectedType = FilterType.custom;
            _rangeStart = from;
            _rangeEnd = to;
            _viewDate = DateTime(_rangeEnd.year, _rangeEnd.month, 1);
          });
        },
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
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Select Range',
                    style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w900),
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
                    // Active Selection
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: ActiveSelectionWidget(
                        start: _rangeStart,
                        end: _rangeEnd,
                        onEdit: _showManualInput,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Quick Filters (Scrollable)
                    HorizontalFadeWrapper(
                      child: QuickFilterChipsRow(
                        selectedType: _selectedType,
                        onTypeSelected: _onTypeSelected,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Calendar Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: KuberCalendarWidget(
                        viewDate: _viewDate,
                        rangeStart: _rangeStart,
                        rangeEnd: _rangeEnd,
                        onDateTapped: _onDateTapped,
                        onMonthPressed: _showMonthPicker,
                        onPrevMonth: () => _onMonthChanged(-1),
                        onNextMonth: () => _onMonthChanged(1),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for sticky bottom
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _StickyBottomSection(
        onApply: () {
          ref.read(analyticsFilterProvider.notifier).setFilter(
            _selectedType,
            from: _rangeStart,
            to: _rangeEnd,
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _StickyBottomSection extends StatelessWidget {
  final VoidCallback onApply;

  const _StickyBottomSection({required this.onApply});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'APPLY FILTER',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
