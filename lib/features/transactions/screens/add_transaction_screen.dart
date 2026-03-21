import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';
import '../providers/suggestion_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/account_picker_sheet.dart';
import '../widgets/category_picker_sheet.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionScreen({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _nameFocusNode = FocusNode();

  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _suppressSuggestions = false;

  bool get _isEditing => widget.transaction != null;

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      (double.tryParse(_amountController.text.trim()) ?? 0) > 0 &&
      _selectedCategoryId != null &&
      _selectedAccountId != null;

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
    _nameController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _amountController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Color get _typeColor {
    final cs = Theme.of(context).colorScheme;
    return _type == 'income' ? cs.tertiary : cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryMap = ref.watch(categoryMapProvider);
    final accounts = ref.watch(accountListProvider);

    return Scaffold(
      backgroundColor: KuberColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Transaction' : 'Add Transaction',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: KuberSpacing.lg),

                  // [A] Type segmented button
                  _TransactionTypeSelector(
                    selected: _type,
                    onSelected: (selected) {
                      if (selected == 'transfer') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transfer coming soon'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        return;
                      }
                      setState(() => _type = selected);
                    },
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // [B] Name field with autocomplete suggestions
                  RawAutocomplete<Transaction>(
                    textEditingController: _nameController,
                    focusNode: _nameFocusNode,
                    displayStringForOption: (t) => t.name,
                    optionsBuilder: (textEditingValue) async {
                      if (_suppressSuggestions) {
                        _suppressSuggestions = false;
                        return [];
                      }
                      final query = textEditingValue.text.trim();
                      if (query.isEmpty || _isEditing) return [];
                      ref.read(suggestionQueryProvider.notifier).state = query;
                      try {
                        return await ref.read(suggestionProvider.future);
                      } catch (_) {
                        return [];
                      }
                    },
                    onSelected: (transaction) {
                      _suppressSuggestions = true;
                      _applySuggestion(transaction);
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: !_isEditing,
                        style: textTheme.bodyLarge?.copyWith(
                          color: KuberColors.textPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Transaction name',
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: KuberColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.edit_outlined,
                            color: KuberColors.textSecondary,
                          ),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final catMap =
                          ref.read(categoryMapProvider).valueOrNull ?? {};
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: KuberSpacing.xs),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            color: KuberColors.surfaceElement,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 200,
                                maxWidth: MediaQuery.of(context).size.width -
                                    2 * KuberSpacing.lg,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: ListView.builder(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: KuberSpacing.xs,
                                  ),
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (context, index) {
                                    final s = options.elementAt(index);
                                    final cat =
                                        catMap[int.tryParse(s.categoryId)];
                                    final catColor = cat != null
                                        ? harmonizeCategory(
                                            context, Color(cat.colorValue))
                                        : KuberColors.textMuted;
                                    final catIcon = cat != null
                                        ? IconMapper.fromString(cat.icon)
                                        : Icons.category;
                                    final amountColor = s.type == 'income'
                                        ? Theme.of(context)
                                            .colorScheme
                                            .tertiary
                                        : Theme.of(context).colorScheme.error;

                                    return InkWell(
                                      onTap: () => onSelected(s),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: KuberSpacing.md,
                                          vertical: KuberSpacing.md,
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: catColor.withValues(
                                                    alpha: 0.15),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(catIcon,
                                                  size: 18, color: catColor),
                                            ),
                                            const SizedBox(
                                                width: KuberSpacing.sm),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    s.name,
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: KuberColors
                                                              .textPrimary,
                                                        ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  if (cat?.name != null)
                                                    Text(
                                                      cat!.name,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .labelSmall
                                                          ?.copyWith(
                                                            color: KuberColors
                                                                .textMuted,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              '₹${s.amount.toStringAsFixed(0)}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: amountColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // [C] Large amount display
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: KuberSpacing.xxl,
                    ),
                    alignment: Alignment.center,
                    child: IntrinsicWidth(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '₹',
                            style: textTheme.headlineLarge?.copyWith(
                              color: _typeColor.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w300,
                              fontSize: 36,
                            ),
                          ),
                          const SizedBox(width: KuberSpacing.xs),
                          Flexible(
                            child: IntrinsicWidth(
                              child: TextField(
                                controller: _amountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}'),
                                  ),
                                ],
                                textAlign: TextAlign.center,
                                style: textTheme.displaySmall?.copyWith(
                                  color: _typeColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 48,
                                ),
                                decoration: InputDecoration(
                                  hintText: '0',
                                  hintStyle:
                                      textTheme.displaySmall?.copyWith(
                                    color: _typeColor.withValues(alpha: 0.3),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 48,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.sm),

                  // Quick-add amount chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [50, 100, 500, 1000].map((amount) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.xs,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            final current = double.tryParse(
                                  _amountController.text.trim(),
                                ) ??
                                0;
                            final newAmount = current + amount;
                            _amountController.text =
                                newAmount.truncateToDouble() == newAmount
                                    ? newAmount.toInt().toString()
                                    : newAmount.toStringAsFixed(2);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _typeColor.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+$amount',
                              style: textTheme.labelMedium?.copyWith(
                                color: _typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: KuberSpacing.lg),

                  // [D] Category + Account selector tiles
                  Row(
                    children: [
                      // Category tile
                      Expanded(
                        child: categoryMap.when(
                          loading: () =>
                              _buildSelectorTilePlaceholder('CATEGORY'),
                          error: (_, _) =>
                              _buildSelectorTilePlaceholder('CATEGORY'),
                          data: (catMap) {
                            final cat = _selectedCategoryId != null
                                ? catMap[_selectedCategoryId]
                                : null;
                            return _SelectorTile(
                              label: 'CATEGORY',
                              icon: cat != null
                                  ? IconMapper.fromString(cat.icon)
                                  : Icons.category_outlined,
                              value: cat?.name ?? 'Select',
                              iconColor: cat != null
                                  ? harmonizeCategory(
                                      context, Color(cat.colorValue))
                                  : KuberColors.textMuted,
                              onTap: () => _showCategoryPicker(),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: KuberSpacing.md),
                      // Account tile
                      Expanded(
                        child: accounts.when(
                          loading: () =>
                              _buildSelectorTilePlaceholder('FROM ACCOUNT'),
                          error: (_, _) =>
                              _buildSelectorTilePlaceholder('FROM ACCOUNT'),
                          data: (accs) {
                            final acc = _selectedAccountId != null
                                ? accs.where((a) => a.id == _selectedAccountId).firstOrNull
                                : null;
                            return _SelectorTile(
                              label: 'FROM ACCOUNT',
                              icon: acc != null
                                  ? accountIcon(acc.type)
                                  : Icons.account_balance_wallet_outlined,
                              value: acc?.name ?? 'Select',
                              iconColor: acc != null
                                  ? accountColor(acc.type)
                                  : KuberColors.textMuted,
                              onTap: () => _showAccountPicker(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.md),

                  // [E] Date & Time tile
                  InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      decoration: BoxDecoration(
                        color: KuberColors.surfaceElement,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: KuberColors.surfaceDivider),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: KuberSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DATE & TIME',
                                style: textTheme.labelSmall?.copyWith(
                                  color: KuberColors.textMuted,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(_selectedDate),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: KuberColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: KuberColors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.md),

                  // Notes field
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: textTheme.bodyMedium?.copyWith(
                      color: KuberColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: KuberColors.textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.note_outlined,
                        color: KuberColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),
                ],
              ),
            ),
          ),

          // [F] Pinned save button
          Container(
            padding: EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              KuberSpacing.md,
              KuberSpacing.lg,
              MediaQuery.of(context).viewPadding.bottom + KuberSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: KuberColors.background,
              border: Border(
                top: BorderSide(color: KuberColors.surfaceDivider),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton(
                onPressed: _isValid ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: _typeColor,
                  disabledBackgroundColor:
                      KuberColors.surfaceElement,
                  disabledForegroundColor: KuberColors.textMuted,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  textStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(_isEditing ? 'Update Transaction' : 'Save Transaction'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorTilePlaceholder(String label) {
    return _SelectorTile(
      label: label,
      icon: Icons.hourglass_empty,
      value: '...',
      iconColor: KuberColors.textMuted,
      onTap: () {},
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    String dayPart;
    if (dateOnly == today) {
      dayPart = 'Today';
    } else if (dateOnly == today.subtract(const Duration(days: 1))) {
      dayPart = 'Yesterday';
    } else {
      dayPart = DateFormat('dd MMM yyyy').format(date);
    }

    final timePart = DateFormat('hh:mm a').format(date);
    return '$dayPart • $timePart';
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KuberColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _selectedCategoryId,
        onSelected: (id) {
          setState(() => _selectedCategoryId = id);
          Navigator.pop(context);
          _nameFocusNode.unfocus();
        },
      ),
    );
  }

  void _showAccountPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KuberColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: _selectedAccountId,
        onSelected: (id) {
          setState(() => _selectedAccountId = id);
          Navigator.pop(context);
          _nameFocusNode.unfocus();
        },
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      if (!mounted) return;
      setState(() {
        _selectedDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time?.hour ?? _selectedDate.hour,
          time?.minute ?? _selectedDate.minute,
        );
      });
      _nameFocusNode.unfocus();
    }
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
    ref.read(suggestionQueryProvider.notifier).state = '';
    _nameFocusNode.unfocus();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (name.isEmpty || amount == null || amount <= 0) return;
    if (_selectedCategoryId == null || _selectedAccountId == null) return;

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
    t.createdAt = _selectedDate;
    t.updatedAt = DateTime.now();

    try {
      if (_isEditing) {
        await ref.read(transactionListProvider.notifier).updateTransaction(t);
      } else {
        await ref.read(transactionListProvider.notifier).add(t);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
      return;
    }

    if (!mounted) return;
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditing ? 'Transaction updated' : 'Transaction saved',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _SelectorTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final Color iconColor;
  final VoidCallback onTap;

  const _SelectorTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: KuberColors.surfaceElement,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: KuberColors.surfaceDivider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: KuberColors.textMuted,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: KuberSpacing.sm),
                Expanded(
                  child: Text(
                    value,
                    style: textTheme.bodyMedium?.copyWith(
                      color: KuberColors.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionTypeSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _TransactionTypeSelector({
    required this.selected,
    required this.onSelected,
  });

  static const _types = ['expense', 'income', 'transfer'];
  static const _labels = ['Expense', 'Income', 'Transfer'];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: KuberColors.surfaceElement,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: KuberColors.surfaceDivider),
      ),
      child: Row(
        children: List.generate(_types.length, (i) {
          final isSelected = _types[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(_types[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                alignment: Alignment.center,
                child: Text(
                  _labels[i],
                  style: textTheme.labelLarge?.copyWith(
                    color: isSelected
                        ? colorScheme.onPrimary
                        : KuberColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
