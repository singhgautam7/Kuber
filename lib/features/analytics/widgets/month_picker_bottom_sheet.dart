import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class MonthPickerBottomSheet extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onMonthSelected;

  const MonthPickerBottomSheet({
    super.key,
    required this.initialDate,
    required this.onMonthSelected,
  });

  @override
  State<MonthPickerBottomSheet> createState() => _MonthPickerBottomSheetState();
}

class _MonthPickerBottomSheetState extends State<MonthPickerBottomSheet> {
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle & Header
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Jump To',
                style: tt.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              // Year Selector
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => setState(() => _selectedYear--),
                      icon: Icon(Icons.chevron_left, size: 18, color: cs.onSurfaceVariant),
                    ),
                    Text(
                      '$_selectedYear',
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _selectedYear++),
                      icon: Icon(Icons.chevron_right, size: 18, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Months Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = index + 1;
              final date = DateTime(_selectedYear, month, 1);
              final isSelected = widget.initialDate.year == _selectedYear && widget.initialDate.month == month;
              
              return GestureDetector(
                onTap: () {
                  widget.onMonthSelected(date);
                  Navigator.pop(context);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? cs.primary.withValues(alpha: 0.1) : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected ? Border.all(color: cs.primary, width: 2) : null,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    DateFormat('MMM').format(date).toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
