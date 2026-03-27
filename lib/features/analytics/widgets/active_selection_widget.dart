import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class ActiveSelectionWidget extends StatelessWidget {
  final DateTime start;
  final DateTime end;
  final VoidCallback onEdit;

  const ActiveSelectionWidget({
    super.key,
    required this.start,
    required this.end,
    required this.onEdit,
  });


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final startDateStr = DateFormat('MMM d').format(start);
    final startYearStr = DateFormat('yyyy').format(start);
    final endDateStr = DateFormat('MMM d').format(end);
    final endYearStr = DateFormat('yyyy').format(end);

    final headlineStyle = tt.headlineMedium?.copyWith(
      fontWeight: FontWeight.w900,
      letterSpacing: -1,
    );
    final yearStyle = tt.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: cs.onSurface.withValues(alpha: 0.4),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVE SELECTION',
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            IconButton(
              onPressed: onEdit,
              icon: Icon(Icons.edit_outlined, size: 20, color: cs.primary),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // [Year] [Date]
              Text(startYearStr, style: yearStyle),
              const SizedBox(width: 8),
              Text(startDateStr, style: headlineStyle),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Baseline(
                  baseline: 18, // Adjust to center arrow roughly with text
                  baselineType: TextBaseline.alphabetic,
                  child: Icon(Icons.arrow_forward_rounded, 
                    color: cs.primary.withValues(alpha: 0.5), 
                    size: 20
                  ),
                ),
              ),
              
              // [Date] [Year]
              Text(endDateStr, style: headlineStyle),
              const SizedBox(width: 8),
              Text(endYearStr, style: yearStyle),
            ],
          ),
        ),
      ],
    );
  }
}
