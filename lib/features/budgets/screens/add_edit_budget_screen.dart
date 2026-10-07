import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final Category? preselectedCategory;

  const AddEditBudgetScreen({
    super.key,
    this.existingBudget,
    this.preselectedCategory,
  });

  @override
  ConsumerState<AddEditBudgetScreen> createState() =>
      _AddEditBudgetScreenState();
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
      _alerts = List<BudgetAlert>.from(widget.existingBudget?.alerts ?? []);

      // Load selected category once categories are available
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final categories = await ref.read(categoryListProvider.future);
        if (mounted) {
          setState(() {
            _selectedCategory = categories.firstWhere(
              (c) => c.id.toString() == widget.existingBudget!.categoryId,
              orElse: () => categories.first,
            );
          });
        }
      });
    } else if (widget.preselectedCategory != null) {
      _selectedCategory = widget.preselectedCategory;
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

    debugPrint('BUDGET_SAVE: Saving budget with ${_alerts.length} alerts');
    await ref
        .read(budgetListProvider.notifier)
        .save(budget, List<BudgetAlert>.from(_alerts));

    // Check if alerts were saved (if possible)
    if (widget.existingBudget != null) {
      debugPrint(
        'BUDGET_SAVE: Verifying. Budget ID: ${budget.id}, Alerts in model: ${budget.alerts.length}',
      );
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: widget.existingBudget == null
            ? context.l10n.createBudget
            : context.l10n.editBudget,
        showBack: true,
        closeIcon: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(title: context.l10n.selectCategoryUpper),
            _CategorySelector(
              selected: _selectedCategory,
              onTap: _showCategoryPicker,
            ),
            if (_selectedCategory != null)
              Consumer(
                builder: (context, ref, _) {
                  final budgets =
                      ref.watch(budgetListProvider).valueOrNull ?? [];
                  final isDuplicate = budgets.any(
                    (b) =>
                        b.isActive &&
                        b.categoryId == _selectedCategory!.id.toString() &&
                        b.id != widget.existingBudget?.id,
                  );
                  if (isDuplicate) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 4),
                      child: Text(
                        context.l10n.budgetAlreadyExists,
                        style: localeFont(
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
            const SizedBox(height: KuberSpace.xl),
            _SectionHeader(title: context.l10n.budgetAmount),
            // Board 3.18: a large filled amount field.
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium!.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '${ref.watch(currencyProvider).symbol} ',
                prefixStyle: Theme.of(
                  context,
                ).textTheme.headlineSmall!.copyWith(color: cs.onSurfaceVariant),
                hintText: '0',
                contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              ),
            ),
            const SizedBox(height: KuberSpace.xl),
            _SectionHeader(title: context.l10n.appliesTo),
            KuberSegmentedControl<bool>(
              values: const [false, true],
              labels: [context.l10n.thisMonthOnly, context.l10n.everyMonth],
              selected: _isEveryMonth,
              onSelected: (v) => setState(() => _isEveryMonth = v),
              height: 40,
            ),
            const SizedBox(height: KuberSpace.xl),
            _SectionHeader(title: context.l10n.budgetAlerts),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _alerts
                  .map(
                    (a) => _AlertChip(
                      alert: a,
                      onDelete: () => setState(() {
                        _alerts = _alerts.where((item) => item != a).toList();
                      }),
                    ),
                  )
                  .toList(),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addAlert,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(context.l10n.addAlert),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outlineVariant)),
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).padding.bottom + KuberSpace.md,
          top: KuberSpace.md,
        ),
        child: Consumer(
          builder: (context, ref, _) {
            final budgets = ref.watch(budgetListProvider).valueOrNull ?? [];
            final isDuplicate =
                _selectedCategory != null &&
                budgets.any(
                  (b) =>
                      b.isActive &&
                      b.categoryId == _selectedCategory!.id.toString() &&
                      b.id != widget.existingBudget?.id,
                );
            final isValid =
                _selectedCategory != null &&
                _amountController.text.isNotEmpty &&
                !isDuplicate;

            return AppButton(
              label: context.l10n.saveBudget,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: isValid ? _save : null,
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

    FocusScope.of(context).unfocus();
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
    if (!mounted) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) FocusScope.of(context).unfocus();
    });
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

    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAlertBottomSheet(
        budgetAmount: amount > 0
            ? amount
            : 1000000, // Fallback high value if amount not set
        existingAlerts: _alerts,
        onAdd: (alert) {
          setState(() {
            final updated = [..._alerts, alert];
            updated.sort((a, b) {
              if (a.type == b.type) return a.value.compareTo(b.value);
              return a.type == BudgetAlertType.percentage ? -1 : 1;
            });
            _alerts = updated;
          });
        },
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return KuberSectionHeader(title: title);
  }
}

class _CategorySelector extends StatelessWidget {
  final Category? selected;
  final VoidCallback onTap;

  const _CategorySelector({this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KuberPickerRow(
      leading: selected == null
          ? KuberLeadingSwatch(
              color: cs.surfaceContainerHigh,
              icon: Icons.category_outlined,
              empty: true,
            )
          : KuberLeadingSwatch(
              color: Color(selected!.colorValue),
              icon: IconMapper.fromString(selected!.icon),
            ),
      label: selected == null
          ? context.l10n.selectCategoryUpper
          : context.l10n.tapToChangeCategory,
      value: selected?.name ?? context.l10n.chooseCategory,
      valueIsPlaceholder: selected == null,
      onTap: onTap,
    );
  }
}

class _AlertChip extends ConsumerWidget {
  final BudgetAlert alert;
  final VoidCallback onDelete;

  const _AlertChip({required this.alert, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final label = alert.type == BudgetAlertType.percentage
        ? ref.watch(formatterProvider).formatPercentage(alert.value)
        : ref.watch(formatterProvider).formatCurrency(alert.value);

    return KuberChip(
      label: label,
      icon: Icons.notifications_active_outlined,
      onDeleted: onDelete,
    );
  }
}
