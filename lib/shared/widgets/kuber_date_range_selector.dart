import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/analytics/providers/analytics_provider.dart'
    show FilterType;
import '../../features/analytics/widgets/kuber_calendar_widget.dart';
import '../../features/analytics/widgets/manual_date_range_bottom_sheet.dart';
import '../../features/analytics/widgets/month_picker_bottom_sheet.dart';
import '../../features/analytics/widgets/quick_filter_chips_row.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../core/utils/breakpoints.dart';
import 'package:intl/intl.dart';
import '../../core/utils/l10n_ext.dart';
import 'app_button.dart';
import 'kuber_app_bar.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    String fmt(DateTime d) => DateFormat('MMM d, yyyy').format(d);
    Widget dateField(String label, DateTime value) => Expanded(
          child: Material(
            color: cs.surfaceContainerHigh,
            borderRadius: KuberShape.cardR,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: _showManualInput,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.lg, vertical: KuberSpace.sm + 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 2),
                    Text(fmt(value),
                        style: tt.bodyLarge?.copyWith(color: cs.onSurface)),
                  ],
                ),
              ),
            ),
          ),
        );

    // Board 6 "Date range": presets as chips, From / To fields, range
    // calendar, Cancel / Apply. Kept as the existing pushed screen.
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: widget.title,
        showBack: true,
        closeIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, KuberSpace.sm,
            KuberSpace.screenMargin, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuickFilterChipsRow(
              selectedType: _selectedType,
              onTypeSelected: _onTypeSelected,
            ),
            const SizedBox(height: KuberSpace.lg),
            Row(
              children: [
                dateField(context.l10n.rangeFrom, _rangeStart),
                const SizedBox(width: KuberSpace.md),
                dateField(context.l10n.rangeTo, _rangeEnd),
              ],
            ),
            const SizedBox(height: KuberSpace.xl),
            KuberCalendarWidget(
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
          ],
        ),
      ),
      bottomSheet: _StickyPrimary(
        label: sentenceCase(widget.primaryButtonLabel),
        onCancel: () => Navigator.pop(context),
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
  final VoidCallback onCancel;
  const _StickyPrimary(
      {required this.label, required this.onTap, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Read the OS nav-bar inset from the root view: this button lives in
    // Scaffold.bottomSheet, where Flutter zeroes MediaQuery padding/viewPadding,
    // so viewPaddingOf would return 0 and the button slides under the system
    // nav bar (incl. 3-button navigation) in edge-to-edge mode.
    final bottomInset = systemNavBarInset(context);
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomInset),
      color: cs.surface,
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              label: MaterialLocalizations.of(context).cancelButtonLabel,
              type: AppButtonType.outline,
              fullWidth: true,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: AppButton(
              label: label,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: onTap,
            ),
          ),
        ],
      ),
    );
  }
}
