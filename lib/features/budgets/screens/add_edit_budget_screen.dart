import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/budget.dart';
import '../providers/budget_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/add_alert_bottom_sheet.dart';

class AddEditBudgetScreen extends ConsumerStatefulWidget {
  final Budget? existingBudget;

  const AddEditBudgetScreen({super.key, this.existingBudget});

  @override
  ConsumerState<AddEditBudgetScreen> createState() => _AddEditBudgetScreenState();
}

class _AddEditBudgetScreenState extends ConsumerState<AddEditBudgetScreen> {
  final _amountController = TextEditingController();
  Category? _selectedCategory;
  bool _isEveryMonth = true;
  List<BudgetAlert> _alerts = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingBudget != null) {
      _amountController.text = widget.existingBudget!.amount % 1 == 0
          ? widget.existingBudget!.amount.toStringAsFixed(0)
          : widget.existingBudget!.amount.toStringAsFixed(2);
      _isEveryMonth = widget.existingBudget!.isRecurring;
      // Load selected category once categories are available
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final categories = await ref.read(categoryListProvider.future);
        setState(() {
          _selectedCategory = categories.firstWhere(
            (c) => c.id.toString() == widget.existingBudget!.categoryId,
            orElse: () => categories.first,
          );
        });
        
        final alerts = await ref.read(budgetAlertsProvider(widget.existingBudget!.id).future);
        setState(() {
          _alerts = List.from(alerts);
        });
      });
    }
  }

  void _save() async {
    if (_selectedCategory == null || _amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) return;

    final budget = widget.existingBudget ?? Budget();
    budget.categoryId = _selectedCategory!.id.toString();
    budget.amount = amount;
    budget.isRecurring = _isEveryMonth;
    budget.periodType = BudgetPeriodType.monthly;
    budget.startDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
    budget.isActive = true;
    budget.updatedAt = DateTime.now();

    await ref.read(budgetListProvider.notifier).save(budget, _alerts);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: widget.existingBudget == null ? 'Create Budget' : 'Edit Budget',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: 'SELECT CATEGORY'),
            const SizedBox(height: KuberSpacing.sm),
            _CategorySelector(
              selected: _selectedCategory,
              onTap: _showCategoryPicker,
            ),
            if (_selectedCategory != null)
              Consumer(
                builder: (context, ref, _) {
                  final budgets = ref.watch(budgetListProvider).valueOrNull ?? [];
                  final isDuplicate = budgets.any((b) =>
                      b.isActive &&
                      b.categoryId == _selectedCategory!.id.toString() &&
                      b.id != widget.existingBudget?.id);
                  if (isDuplicate) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        'A budget already exists for this category',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            const SizedBox(height: KuberSpacing.xl),
            _SectionHeader(title: 'BUDGET AMOUNT'),
            const SizedBox(height: KuberSpacing.sm),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                prefixText: '${ref.watch(currencyProvider).symbol} ',
                hintText: '0',
                filled: true,
                fillColor: cs.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.outline),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),
            _SectionHeader(title: 'APPLIES TO'),
            const SizedBox(height: KuberSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _OptionCard(
                    icon: Icons.calendar_today_outlined,
                    label: 'This month\nonly',
                    isSelected: !_isEveryMonth,
                    onTap: () => setState(() => _isEveryMonth = false),
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: _OptionCard(
                    icon: Icons.refresh_rounded,
                    label: 'Every\nmonth',
                    isSelected: _isEveryMonth,
                    onTap: () => setState(() => _isEveryMonth = true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SectionHeader(title: 'BUDGET ALERTS'),
                TextButton.icon(
                  onPressed: _addAlert,
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('ADD ALERT'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              children: _alerts.map((a) => _AlertChip(
                alert: a, 
                onDelete: () => setState(() => _alerts.remove(a)),
              )).toList(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          bottom: MediaQuery.of(context).padding.bottom + KuberSpacing.md,
          top: KuberSpacing.md,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final budgets = ref.watch(budgetListProvider).valueOrNull ?? [];
            final isDuplicate = _selectedCategory != null &&
                budgets.any((b) =>
                    b.isActive &&
                    b.categoryId == _selectedCategory!.id.toString() &&
                    b.id != widget.existingBudget?.id);
            final isValid = _selectedCategory != null &&
                _amountController.text.isNotEmpty &&
                !isDuplicate;

            return FilledButton.icon(
              onPressed: isValid ? _save : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KuberRadius.md)),
                backgroundColor: isValid ? cs.primary : cs.surfaceContainerHighest,
              ),
              icon: const Icon(Icons.save_rounded),
              label: const Text('SAVE BUDGET'),
            );
          },
        ),
      ),
    );
  }

  void _showCategoryPicker() async {
    final budgets = ref.read(budgetListProvider).valueOrNull ?? [];
    final disabledIds = budgets
        .where((b) => b.isActive && b.id != widget.existingBudget?.id)
        .map((b) => int.tryParse(b.categoryId) ?? -1)
        .where((id) => id != -1)
        .toList();

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CategoryPickerSheet(
        selectedCategoryId: _selectedCategory?.id,
        onSelected: (id) => Navigator.pop(context, id),
        defaultType: 'expense',
        disabledCategoryIds: disabledIds,
      ),
    );
    if (result != null) {
      final categories = await ref.read(categoryListProvider.future);
      setState(() {
        _selectedCategory = categories.firstWhere((c) => c.id == result);
      });
    }
  }

  void _addAlert() {
    if (_alerts.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 alerts allowed per budget')),
      );
      return;
    }

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0 && _alerts.isEmpty) {
        // Just a precaution if someone tries to add alert before amount
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAlertBottomSheet(
        budgetAmount: amount > 0 ? amount : 1000000, // Fallback high value if amount not set
        existingAlerts: _alerts,
        onAdd: (alert) {
          setState(() {
            _alerts.add(alert);
            _alerts.sort((a, b) {
              if (a.type == b.type) return a.value.compareTo(b.value);
              return a.type == BudgetAlertType.percentage ? -1 : 1;
            });
          });
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final Category? selected;
  final VoidCallback onTap;

  const _CategorySelector({this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            if (selected != null) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(selected!.colorValue).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.category, color: Color(selected!.colorValue), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selected!.name,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      'Tap to change category',
                      style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ] else
              Expanded(
                child: Text(
                  'Choose category',
                  style: GoogleFonts.inter(color: cs.onSurfaceVariant),
                ),
              ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? cs.primaryContainer.withValues(alpha: 0.1) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: isSelected ? cs.primary : cs.outline),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? cs.primary : cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AlertChip extends ConsumerWidget {
  final BudgetAlert alert;
  final VoidCallback onDelete;

  const _AlertChip({required this.alert, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final label = alert.type == BudgetAlertType.percentage 
        ? ref.watch(formatterProvider).formatPercentage(alert.value)
        : ref.watch(formatterProvider).formatCurrency(alert.value);
    
    return Chip(
      label: Text(label, style: GoogleFonts.inter(fontSize: 12)),
      onDeleted: onDelete,
      backgroundColor: cs.surfaceContainer,
      deleteIconColor: cs.onSurfaceVariant,
    );
  }
}
