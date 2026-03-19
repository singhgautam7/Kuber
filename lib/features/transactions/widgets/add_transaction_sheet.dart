import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';
import '../providers/suggestion_provider.dart';
import '../providers/transaction_provider.dart';
import 'suggestion_list.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionSheet({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _nameController.text = t.name;
      _amountController.text = t.amount.toString();
      _notesController.text = t.notes ?? '';
      _type = t.type;
      _selectedCategoryId = int.tryParse(t.categoryId);
      _selectedAccountId = int.tryParse(t.accountId);
      _selectedDate = t.createdAt;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final suggestions = ref.watch(suggestionProvider);
    final categories = ref.watch(categoryListProvider);
    final accounts = ref.watch(accountListProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: KuberSpacing.lg,
        right: KuberSpacing.lg,
        top: KuberSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + KuberSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              _isEditing ? 'Edit Transaction' : 'Add Transaction',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: KuberSpacing.lg),

            // 1. Name field
            TextField(
              controller: _nameController,
              autofocus: !_isEditing,
              decoration: const InputDecoration(
                labelText: 'Transaction Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(suggestionQueryProvider.notifier).state = value;
              },
            ),

            // Suggestion list
            if (!_isEditing)
              suggestions.when(
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
                data: (list) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: KuberSpacing.xs),
                  child: SuggestionList(
                    suggestions: list,
                    onSelected: _applySuggestion,
                  ),
                ),
              ),

            const SizedBox(height: KuberSpacing.md),

            // 2. Amount
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 3. Type toggle
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 4. Category chips
            categories.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (cats) => Wrap(
                spacing: KuberSpacing.sm,
                runSpacing: KuberSpacing.sm,
                children: cats.map((c) {
                  final selected = _selectedCategoryId == c.id;
                  final harmonized =
                      harmonizeCategory(context, Color(c.colorValue));
                  return ChoiceChip(
                    selected: selected,
                    label: Text(c.name),
                    avatar: Icon(
                      IconMapper.fromString(c.icon),
                      size: 18,
                      color: selected ? colorScheme.onPrimaryContainer : harmonized,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = c.id),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 5. Account dropdown
            accounts.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (accs) => DropdownButtonFormField<int>(
                initialValue: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                ),
                items: accs
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAccountId = v),
              ),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 6. Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),

            // 7. Notes
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.sm),
          ],
        ),
      ),
    );
  }

  void _applySuggestion(Transaction suggestion) {
    setState(() {
      _nameController.text = suggestion.name;
      _amountController.text = suggestion.amount.toString();
      _type = suggestion.type;
      _selectedCategoryId = int.tryParse(suggestion.categoryId);
      _selectedAccountId = int.tryParse(suggestion.accountId);
      _notesController.text = suggestion.notes ?? '';
    });
    // Clear suggestions
    ref.read(suggestionQueryProvider.notifier).state = '';
  }

  void _save() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and amount')),
      );
      return;
    }
    if (_selectedCategoryId == null || _selectedAccountId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and account')),
      );
      return;
    }

    final t = _isEditing ? widget.transaction! : Transaction();
    t.name = name;
    t.amount = amount;
    t.type = _type;
    t.categoryId = _selectedCategoryId.toString();
    t.accountId = _selectedAccountId.toString();
    t.notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    t.nameLower = name.toLowerCase();
    if (!_isEditing) {
      t.createdAt = _selectedDate;
    }
    t.updatedAt = DateTime.now();

    if (_isEditing) {
      ref.read(transactionListProvider.notifier).updateTransaction(t);
    } else {
      ref.read(transactionListProvider.notifier).add(t);
    }

    Navigator.pop(context);
  }
}
