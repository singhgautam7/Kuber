import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/transfer_helpers.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';
import '../providers/suggestion_provider.dart';
import '../providers/transaction_provider.dart';
import '../../../shared/widgets/timed_snackbar.dart';
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
  int? _selectedFromAccountId;
  int? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _suppressSuggestions = false;

  bool get _isEditing => widget.transaction != null;

  bool get _isValid =>
      _type == 'transfer' ? _isTransferValid : (
      _amountController.text.trim().isNotEmpty &&
      (double.tryParse(_amountController.text.trim()) ?? 0) > 0 &&
      _selectedCategoryId != null &&
      _selectedAccountId != null);

  bool get _isTransferValid =>
      (double.tryParse(_amountController.text.trim()) ?? 0) > 0 &&
      _selectedFromAccountId != null &&
      _selectedToAccountId != null &&
      _selectedFromAccountId != _selectedToAccountId;

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
      if (t.type == 'transfer') {
        _selectedFromAccountId = int.tryParse(t.fromAccountId ?? '');
        _selectedToAccountId = int.tryParse(t.toAccountId ?? '');
      }
    }
    _nameController.addListener(_onFieldChanged);
    _amountController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() => setState(() {});

  void _onTypeChanged(String newType) {
    setState(() {
      _type = newType;

      // Check if selected category is still valid for the new type
      if (_selectedCategoryId != null) {
        final categories =
            ref.read(categoryListProvider).valueOrNull ?? [];
        final selectedCat = categories
            .where((c) => c.id == _selectedCategoryId)
            .firstOrNull;

        if (selectedCat != null) {
          final catType = selectedCat.type;
          final isStillValid = catType == 'both' ||
              (newType == 'expense' && catType == 'expense') ||
              (newType == 'income' && catType == 'income');

          if (!isStillValid) {
            _selectedCategoryId = null;
          }
        }
      }
    });
  }

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
    if (_type == 'transfer') return cs.primary;
    return _type == 'income' ? cs.tertiary : cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryMap = ref.watch(categoryMapProvider);
    final accounts = ref.watch(accountListProvider);

    // Listen for pending category selection from Add Category flow
    ref.listen<int?>(pendingCategorySelectionProvider, (_, catId) {
      if (catId != null) {
        setState(() => _selectedCategoryId = catId);
        ref.read(pendingCategorySelectionProvider.notifier).state = null;
      }
    });

    return Scaffold(
      backgroundColor: KuberColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing
              ? (_type == 'transfer' ? 'Edit Transfer' : 'Edit Transaction')
              : 'Add Transaction',
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
                    onSelected: _onTypeChanged,
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  if (_type == 'transfer')
                    _buildTransferForm(colorScheme, textTheme, accounts)
                  else ...[

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
                            color: KuberColors.textSecondary,
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
                            borderRadius: BorderRadius.circular(8),
                            color: KuberColors.surfaceMuted,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: 200,
                                maxWidth: MediaQuery.of(context).size.width -
                                    2 * KuberSpacing.lg,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
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
                                        : KuberColors.textSecondary;
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
                                                                .textSecondary,
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
                                  : KuberColors.textSecondary,
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
                                  ? resolveAccountIcon(acc)
                                  : Icons.account_balance_wallet_outlined,
                              value: acc?.name ?? 'Select',
                              iconColor: acc != null
                                  ? resolveAccountColor(acc)
                                  : KuberColors.textSecondary,
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
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      decoration: BoxDecoration(
                        color: KuberColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: KuberColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
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
                                  color: KuberColors.textSecondary,
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
                            color: KuberColors.textSecondary,
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
                        color: KuberColors.textSecondary,
                      ),
                      prefixIcon: const Icon(
                        Icons.note_outlined,
                        color: KuberColors.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),
                  ], // end else (non-transfer)
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
                top: BorderSide(color: KuberColors.border),
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
                      KuberColors.surfaceMuted,
                  disabledForegroundColor: KuberColors.textSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  textStyle: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(_isEditing
                    ? (_type == 'transfer' ? 'Update Transfer' : 'Update Transaction')
                    : (_type == 'transfer' ? 'Save Transfer' : 'Save Transaction')),
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
      iconColor: KuberColors.textSecondary,
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
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KuberColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _selectedCategoryId,
        defaultType: _type == 'transfer' ? null : _type,
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
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KuberColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
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
    _nameFocusNode.requestFocus();
  }

  Future<void> _save() async {
    if (_type == 'transfer') {
      await _saveTransfer();
      return;
    }

    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
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
        showKuberSnackBar(context, 'Failed to save: $e', isError: true);
      }
      return;
    }

    if (!mounted) return;
    context.pop();
    showKuberSnackBar(
      context,
      _isEditing ? 'Transaction updated' : 'Transaction saved',
    );
  }

  Future<void> _saveTransfer() async {
    final amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) return;
    if (_selectedFromAccountId == null || _selectedToAccountId == null) return;
    if (_selectedFromAccountId == _selectedToAccountId) return;

    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final fromAccount = accounts
        .where((a) => a.id == _selectedFromAccountId)
        .firstOrNull;
    final fromIsCreditCard = fromAccount?.isCreditCard ?? false;

    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();

    try {
      if (_isEditing) {
        await ref.read(transactionListProvider.notifier).updateTransfer(
          id: widget.transaction!.id,
          fromAccountId: _selectedFromAccountId.toString(),
          toAccountId: _selectedToAccountId.toString(),
          amount: amount,
          createdAt: _selectedDate,
          notes: notes,
          fromIsCreditCard: fromIsCreditCard,
        );
      } else {
        await ref.read(transactionListProvider.notifier).saveTransfer(
          fromAccountId: _selectedFromAccountId.toString(),
          toAccountId: _selectedToAccountId.toString(),
          amount: amount,
          createdAt: _selectedDate,
          notes: notes,
          fromIsCreditCard: fromIsCreditCard,
        );
      }
    } on InsufficientBalanceException catch (e) {
      if (mounted) {
        showKuberSnackBar(
          context,
          'Insufficient balance: ₹${e.available.toStringAsFixed(2)} available',
          isError: true,
        );
      }
      return;
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(context, 'Failed to save: $e', isError: true);
      }
      return;
    }

    if (!mounted) return;
    context.pop();
    showKuberSnackBar(
      context,
      _isEditing ? 'Transfer updated' : 'Transfer saved',
    );
  }

  Widget _buildTransferForm(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AsyncValue<List<Account>> accounts,
  ) {
    final accs = accounts.valueOrNull ?? [];
    final fromAccount = _selectedFromAccountId != null
        ? accs.where((a) => a.id == _selectedFromAccountId).firstOrNull
        : null;
    final toAccount = _selectedToAccountId != null
        ? accs.where((a) => a.id == _selectedToAccountId).firstOrNull
        : null;

    // Determine transfer subtype
    TransferSubtype? subtype;
    if (fromAccount != null && toAccount != null) {
      subtype = getTransferSubtype(fromAccount, toAccount);
    }

    Color bgColor;
    Color txtColor;
    if (subtype == TransferSubtype.creditCardPayment) {
      bgColor = KuberColors.income.withValues(alpha: 0.15);
      txtColor = KuberColors.income;
    } else if (subtype == TransferSubtype.creditCardWithdrawal) {
      bgColor = KuberColors.expense.withValues(alpha: 0.15);
      txtColor = KuberColors.expense;
    } else if (subtype == TransferSubtype.creditCardTransfer) {
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      txtColor = const Color(0xFFF59E0B);
    } else {
      bgColor = colorScheme.primaryContainer;
      txtColor = colorScheme.onPrimaryContainer;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Subtype badge
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: subtype != null && subtype != TransferSubtype.normalTransfer
              ? Container(
                  key: ValueKey(subtype),
                  margin: const EdgeInsets.only(top: KuberSpacing.xl),
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.md,
                    vertical: KuberSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    transferSubtypeLabel(subtype),
                    style: textTheme.labelMedium?.copyWith(
                      color: txtColor,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
        if (subtype != null && subtype != TransferSubtype.normalTransfer)
          const SizedBox(height: KuberSpacing.sm),

        // Amount display
        Container(
          padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xxl),
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
                    color: KuberColors.textSecondary,
                    fontWeight: FontWeight.w300,
                    fontSize: 36,
                  ),
                ),
                const SizedBox(width: KuberSpacing.xs),
                Flexible(
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}'),
                        ),
                      ],
                      textAlign: TextAlign.center,
                      style: textTheme.displaySmall?.copyWith(
                        color: KuberColors.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 48,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: textTheme.displaySmall?.copyWith(
                          color: KuberColors.textSecondary.withValues(alpha: 0.3),
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

        // Quick chips
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [50, 100, 500, 1000].map((amount) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.xs),
              child: GestureDetector(
                onTap: () {
                  final current =
                      double.tryParse(_amountController.text.trim()) ?? 0;
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
                    color: colorScheme.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$amount',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: KuberSpacing.lg),

        // FROM Account tile
        _TransferAccountTile(
          label: 'FROM ACCOUNT',
          account: fromAccount,
          onTap: () => _showTransferAccountPicker(
            isFrom: true,
            excludeId: _selectedToAccountId,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),

        // Swap button
        Center(
          child: GestureDetector(
            onTap: () {
              setState(() {
                final temp = _selectedFromAccountId;
                _selectedFromAccountId = _selectedToAccountId;
                _selectedToAccountId = temp;
              });
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                color: colorScheme.onPrimary,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),

        // TO Account tile
        _TransferAccountTile(
          label: 'TO ACCOUNT',
          account: toAccount,
          onTap: () => _showTransferAccountPicker(
            isFrom: false,
            excludeId: _selectedFromAccountId,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),

        // Date & Time
        InkWell(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          onTap: _pickDate,
          child: Container(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            decoration: BoxDecoration(
              color: KuberColors.surfaceMuted,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: KuberColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
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
                        color: KuberColors.textSecondary,
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
                  color: KuberColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.md),

        // Notes
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: textTheme.bodyMedium?.copyWith(
            color: KuberColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note (optional)',
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: KuberColors.textSecondary,
            ),
            prefixIcon: const Icon(
              Icons.note_outlined,
              color: KuberColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),
      ],
    );
  }

  void _showTransferAccountPicker({
    required bool isFrom,
    int? excludeId,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: KuberColors.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId:
            isFrom ? _selectedFromAccountId : _selectedToAccountId,
        excludeAccountId: excludeId,
        onSelected: (id) {
          setState(() {
            if (isFrom) {
              _selectedFromAccountId = id;
            } else {
              _selectedToAccountId = id;
            }
          });
          Navigator.pop(context);
        },
      ),
    );
  }
}

class _TransferAccountTile extends StatelessWidget {
  final String label;
  final Account? account;
  final VoidCallback onTap;

  const _TransferAccountTile({
    required this.label,
    required this.account,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = account != null
        ? resolveAccountColor(account!)
        : KuberColors.textSecondary;
    final icon = account != null
        ? resolveAccountIcon(account!)
        : Icons.account_balance_wallet_outlined;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: KuberColors.surfaceMuted,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: KuberColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: textTheme.labelSmall?.copyWith(
                      color: KuberColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account?.name ?? 'Select Account',
                    style: textTheme.bodyMedium?.copyWith(
                      color: account != null
                          ? KuberColors.textPrimary
                          : KuberColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: KuberColors.textSecondary,
            ),
          ],
        ),
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
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: KuberColors.surfaceMuted,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: KuberColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: KuberColors.textSecondary,
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
                    borderRadius: BorderRadius.circular(8),
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
        color: KuberColors.surfaceMuted,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: KuberColors.border),
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
                  borderRadius: BorderRadius.circular(KuberRadius.md),
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
