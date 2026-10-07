import 'package:flutter/material.dart';
import 'app_icon_button.dart';
import 'kuber_chips.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_theme.dart';

class DateRangePickerValue {
  final String label;
  final DateTime from;
  final DateTime to;

  const DateRangePickerValue({
    required this.label,
    required this.from,
    required this.to,
  });
}

class KuberDateRangePicker extends StatelessWidget {
  final DateRangePickerValue value;
  final VoidCallback onTap;
  final VoidCallback? onReset;
  final bool canReset;
  final String resetTooltip;

  const KuberDateRangePicker({
    super.key,
    required this.value,
    required this.onTap,
    this.onReset,
    this.canReset = true,
    this.resetTooltip = 'Reset',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Board 3.6: the period as a selected dropdown chip, the range as a
    // calendar chip that ellipsizes, and the reset icon button.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpace.xs),
      child: Row(
        children: [
          KuberChip(
            label: value.label,
            selected: true,
            dropdown: true,
            onTap: onTap,
          ),
          const SizedBox(width: KuberSpace.sm),
          // Takes all the free width up to the reset button; ellipsizes only
          // when the full range doesn't fit.
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: KuberChip(
                label: formatKuberRangeLabel(value.from, value.to),
                icon: Icons.calendar_today_rounded,
                iconColor: cs.onSurfaceVariant,
                shrink: true,
                onTap: onTap,
              ),
            ),
          ),
          const SizedBox(width: KuberSpace.sm),
          if (onReset != null)
            Transform.translate(
              offset: const Offset(4, 0),
              child: AppIconButton(
                icon: Icons.restart_alt_rounded,
                semanticLabel: resetTooltip,
                onPressed: canReset ? onReset : null,
              ),
            ),
        ],
      ),
    );
  }
}

String formatKuberRangeLabel(DateTime from, DateTime to) {
  if (from.year == to.year) {
    final fmtStart = DateFormat('MMM d');
    final fmtEnd = DateFormat('MMM d, yyyy');
    return '${fmtStart.format(from)} - ${fmtEnd.format(to)}';
  }
  final fmt = DateFormat('MMM d, yyyy');
  return '${fmt.format(from)} - ${fmt.format(to)}';
}
