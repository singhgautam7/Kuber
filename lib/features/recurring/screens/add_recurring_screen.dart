import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';

class AddRecurringScreen extends ConsumerStatefulWidget {
  final RecurringRule? existingRule;

  const AddRecurringScreen({super.key, this.existingRule});

  @override
  ConsumerState<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends ConsumerState<AddRecurringScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _customDaysController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _startDate = DateTime.now();
  String _frequency = 'monthly';
  String _endType = 'never';
  final _endAfterController = TextEditingController();
  DateTime? _endDate;

  bool get _isEdit => widget.existingRule != null;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      double.tryParse(_amountController.text.trim()) != null &&
      _selectedCategoryId != null &&
      _selectedAccountId != null;

  static const _frequencies = [
    ('daily', 'Daily'),
    ('weekly', 'Weekly'),
    ('biweekly', 'Biweekly'),
    ('monthly', 'Monthly'),
    ('yearly', 'Yearly'),
    ('custom', 'Custom'),
  ];

  @override
  void initState() {
    super.initState();
    final rule = widget.existingRule;
    if (rule != null) {
      _nameController.text = rule.name;
      _amountController.text = rule.amount.toStringAsFixed(2);
      _notesController.text = rule.notes ?? '';
      _type = rule.type;
      _selectedCategoryId = int.tryParse(rule.categoryId);
      _selectedAccountId = int.tryParse(rule.accountId);
      _startDate = rule.startDate;
      _frequency = rule.frequency;
      _endType = rule.endType;
      if (rule.customDays != null) {
        _customDaysController.text = rule.customDays.toString();
      }
      if (rule.endAfter != null) {
        _endAfterController.text = rule.endAfter.toString();
      }
      _endDate = rule.endDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _customDaysController.dispose();
    _endAfterController.dispose();
    super.dispose();
  }

  void _openCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _selectedCategoryId,
        onSelected: (id) {
          setState(() => _selectedCategoryId = id);
          Navigator.pop(context);
        },
        defaultType: _type,
      ),
    );
  }

  void _openAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => AccountPickerSheet(
        selectedAccountId: _selectedAccountId,
        onSelected: (id) {
          setState(() => _selectedAccountId = id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickStartDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(now) ? now : _startDate,
      firstDate: now,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _pickEndDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final earliest = _startDate.isBefore(now) ? now : _startDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: (_endDate != null && !_endDate!.isBefore(earliest))
          ? _endDate!
          : earliest,
      firstDate: earliest,
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _endDate = picked);
  }

  Future<void> _save() async {
    final rule = widget.existingRule ?? RecurringRule();
    rule
      ..name = _nameController.text.trim()
      ..amount = double.parse(_amountController.text.trim())
      ..type = _type
      ..categoryId = _selectedCategoryId.toString()
      ..accountId = _selectedAccountId.toString()
      ..notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()
      ..frequency = _frequency
      ..customDays = _frequency == 'custom'
          ? int.tryParse(_customDaysController.text.trim())
          : null
      ..startDate = _startDate
      ..endType = _endType
      ..endAfter = _endType == 'occurrences'
          ? int.tryParse(_endAfterController.text.trim())
          : null
      ..endDate = _endType == 'date' ? _endDate : null;

    rule.nextDueAt = _startDate;

    if (_isEdit) {
      await ref.read(recurringListProvider.notifier).updateRule(rule);
    } else {
      await ref.read(recurringListProvider.notifier).add(rule);
    }

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final categories = ref.watch(categoryListProvider);
    final accounts = ref.watch(accountListProvider);
    final symbol = ref.watch(currencyProvider).symbol;

    return Scaffold(
      backgroundColor: KuberColors.background,
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Recurring' : 'Add Recurring'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        children: [
          // Type toggle
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'expense', label: Text('Expense')),
              ButtonSegment(value: 'income', label: Text('Income')),
            ],
            selected: {_type},
            onSelectionChanged: (s) => setState(() {
              _type = s.first;
              _selectedCategoryId = null;
            }),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // Name
          TextField(
            controller: _nameController,
            style: textTheme.bodyMedium?.copyWith(color: KuberColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Netflix, Rent, Salary',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Amount
          TextField(
            controller: _amountController,
            style: textTheme.bodyMedium?.copyWith(color: KuberColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Amount',
              prefixText: '$symbol ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
            ],
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Category picker
          _PickerTile(
            label: 'Category',
            value: categories.whenOrNull(
              data: (cats) {
                final cat = _selectedCategoryId != null
                    ? cats.where((c) => c.id == _selectedCategoryId).firstOrNull
                    : null;
                return cat?.name;
              },
            ),
            icon: categories.whenOrNull(
              data: (cats) {
                final cat = _selectedCategoryId != null
                    ? cats.where((c) => c.id == _selectedCategoryId).firstOrNull
                    : null;
                if (cat == null) return null;
                return _CategoryChip(
                  icon: IconMapper.fromString(cat.icon),
                  color: harmonizeCategory(context, Color(cat.colorValue)),
                  name: cat.name,
                );
              },
            ),
            onTap: _openCategoryPicker,
          ),
          const SizedBox(height: KuberSpacing.md),

          // Account picker
          _PickerTile(
            label: 'Account',
            value: accounts.whenOrNull(
              data: (accs) {
                final acc = _selectedAccountId != null
                    ? accs.where((a) => a.id == _selectedAccountId).firstOrNull
                    : null;
                return acc?.name;
              },
            ),
            icon: accounts.whenOrNull(
              data: (accs) {
                final acc = _selectedAccountId != null
                    ? accs.where((a) => a.id == _selectedAccountId).firstOrNull
                    : null;
                if (acc == null) return null;
                return _AccountChip(
                  icon: resolveAccountIcon(acc),
                  color: resolveAccountColor(acc),
                );
              },
            ),
            onTap: _openAccountPicker,
          ),
          const SizedBox(height: KuberSpacing.xl),

          // Start date
          _PickerTile(
            label: 'Start Date',
            value: DateFormat('MMM d, yyyy').format(_startDate),
            onTap: _pickStartDate,
          ),
          const SizedBox(height: KuberSpacing.xl),

          // Frequency
          Text(
            'FREQUENCY',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KuberColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: KuberSpacing.sm,
            crossAxisSpacing: KuberSpacing.sm,
            childAspectRatio: 3.5,
            children: _frequencies.map((f) {
              final selected = _frequency == f.$1;
              return GestureDetector(
                onTap: () => setState(() => _frequency = f.$1),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? KuberColors.primarySubtle
                        : KuberColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                      color: selected ? KuberColors.primary : KuberColors.border,
                    ),
                  ),
                  child: Text(
                    f.$2,
                    style: textTheme.bodyMedium?.copyWith(
                      color: selected
                          ? KuberColors.primary
                          : KuberColors.textSecondary,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // Custom days input
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            child: _frequency == 'custom'
                ? Padding(
                    padding: const EdgeInsets.only(top: KuberSpacing.md),
                    child: TextField(
                      controller: _customDaysController,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: KuberColors.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Every X days',
                        hintText: 'e.g. 10',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // End condition
          Text(
            'ENDS',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: KuberColors.textSecondary,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          _EndRadio(
            value: 'never',
            groupValue: _endType,
            label: 'Never',
            onChanged: (v) => setState(() => _endType = v),
          ),
          _EndRadio(
            value: 'occurrences',
            groupValue: _endType,
            label: 'After occurrences',
            onChanged: (v) => setState(() => _endType = v),
            trailing: _endType == 'occurrences'
                ? SizedBox(
                    width: 80,
                    child: TextField(
                      controller: _endAfterController,
                      style: textTheme.bodyMedium
                          ?.copyWith(color: KuberColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: '#',
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  )
                : null,
          ),
          _EndRadio(
            value: 'date',
            groupValue: _endType,
            label: 'On date',
            onChanged: (v) => setState(() => _endType = v),
            trailing: _endType == 'date'
                ? TextButton(
                    onPressed: _pickEndDate,
                    child: Text(
                      _endDate != null
                          ? DateFormat('MMM d, yyyy').format(_endDate!)
                          : 'Pick date',
                    ),
                  )
                : null,
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Notes
          TextField(
            controller: _notesController,
            style: textTheme.bodyMedium?.copyWith(color: KuberColors.textPrimary),
            decoration: const InputDecoration(
              labelText: 'Notes (optional)',
              hintText: 'Add a note...',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: KuberSpacing.xxl),

          // Save button
          FilledButton(
            onPressed: _canSave ? _save : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
            child: Text(_isEdit ? 'Update' : 'Create Recurring'),
          ),
          const SizedBox(height: KuberSpacing.xl),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    this.value,
    this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: KuberColors.surfaceCard,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: KuberColors.border),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: KuberSpacing.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: KuberColors.textSecondary,
                    ),
                  ),
                  Text(
                    value ?? 'Select',
                    style: textTheme.bodyMedium?.copyWith(
                      color: value != null
                          ? KuberColors.textPrimary
                          : KuberColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: KuberColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String name;

  const _CategoryChip({
    required this.icon,
    required this.color,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _AccountChip({
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Icon(icon, color: color, size: 16),
    );
  }
}

class _EndRadio extends StatelessWidget {
  final String value;
  final String groupValue;
  final String label;
  final ValueChanged<String> onChanged;
  final Widget? trailing;

  const _EndRadio({
    required this.value,
    required this.groupValue,
    required this.label,
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => onChanged(value),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: KuberSpacing.sm),
        child: Row(
          children: [
            Icon(
              value == groupValue
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: value == groupValue
                  ? KuberColors.primary
                  : KuberColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: KuberColors.textPrimary,
                ),
              ),
            ),
            // ignore: use_null_aware_elements
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
