import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../data/reminder.dart';
import 'reminder_form_fields.dart';

/// Collapsible "Add more details" section (screens 2b/2c): Notes, Amount +
/// Expense/Income toggle, Category, Repeat.
class ReminderDetailsSection extends StatelessWidget {
  final bool expanded;
  final VoidCallback onToggle;
  final TextEditingController notesController;
  final TextEditingController amountController;
  final String transactionType;
  final ValueChanged<String> onTypeChanged;
  final String? categoryName;
  final VoidCallback onCategoryTap;
  final String? repeat;
  final ValueChanged<String?> onRepeatChanged;

  const ReminderDetailsSection({
    super.key,
    required this.expanded,
    required this.onToggle,
    required this.notesController,
    required this.amountController,
    required this.transactionType,
    required this.onTypeChanged,
    required this.categoryName,
    required this.onCategoryTap,
    required this.repeat,
    required this.onRepeatChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (!expanded) {
      return GestureDetector(
        onTap: onToggle,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              Icon(Icons.add_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Add more details',
                      style: localeFont(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Notes, amount, category, repeat',
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onToggle,
          behavior: HitTestBehavior.opaque,
          child: Row(
            children: [
              Icon(Icons.keyboard_arrow_up_rounded,
                  size: 16, color: cs.primary),
              const SizedBox(width: 10),
              Text(
                'MORE DETAILS',
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Divider(height: 1, color: cs.outline)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const ReminderFieldLabel('Notes'),
        ReminderTextField(
          controller: notesController,
          hint: 'Anything worth remembering',
          maxLines: 3,
        ),
        const SizedBox(height: 14),
        const ReminderFieldLabel('Amount'),
        Row(
          children: [
            Expanded(
              child: ReminderTextField(
                controller: amountController,
                hint: '₹0',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                ],
              ),
            ),
            const SizedBox(width: 9),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: [
                  _TypeSegment(
                    label: 'Expense',
                    active: transactionType == 'expense',
                    color: cs.error,
                    onTap: () => onTypeChanged('expense'),
                  ),
                  _TypeSegment(
                    label: 'Income',
                    active: transactionType == 'income',
                    color: cs.tertiary,
                    onTap: () => onTypeChanged('income'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReminderFieldLabel('Category'),
                  ReminderPickerField(
                    icon: Icons.category_outlined,
                    label: categoryName ?? 'Pick a category',
                    onTap: onCategoryTap,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ReminderFieldLabel('Repeat'),
                  _RepeatDropdown(
                    value: repeat,
                    onChanged: onRepeatChanged,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeSegment extends StatelessWidget {
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _TypeSegment({
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: localeFont(
            fontSize: 12,
            fontWeight: active ? FontWeight.w700 : FontWeight.w600,
            color: active ? color : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _RepeatDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;

  const _RepeatDropdown({required this.value, required this.onChanged});

  String _label(String? v) => switch (v) {
        ReminderRepeat.daily => 'Daily',
        ReminderRepeat.weekly => 'Weekly',
        ReminderRepeat.monthly => 'Monthly',
        ReminderRepeat.yearly => 'Yearly',
        _ => 'None',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      color: cs.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        side: BorderSide(color: cs.outline),
      ),
      onSelected: (v) => onChanged(v == 'none' ? null : v),
      itemBuilder: (ctx) => [
        for (final v in ['none', ...ReminderRepeat.all])
          PopupMenuItem<String>(
            value: v,
            child: Text(
              _label(v == 'none' ? null : v),
              style: localeFont(fontSize: 13.5, fontWeight: FontWeight.w500),
            ),
          ),
      ],
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                _label(value),
                style: localeFont(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded,
                size: 15, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
