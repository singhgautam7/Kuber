import 'dart:io';

import 'package:collection/collection.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/attachment_service.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/transfer_helpers.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider, formatterProvider;
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';
import '../providers/suggestion_provider.dart';
import '../providers/transaction_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../widgets/account_picker_sheet.dart';
import '../widgets/category_picker_sheet.dart';
import '../../tags/data/tag.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/widgets/tag_selector_bottom_sheet.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../settings/widgets/settings_widgets.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final Transaction? transaction;
  final String? initialType;

  const AddTransactionScreen({
    super.key,
    this.transaction,
    this.initialType,
  });

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _amountFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();

  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  int? _selectedFromAccountId;
  int? _selectedToAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _suppressSuggestions = false;
  List<Tag> _selectedTags = [];

  // Attachment state
  List<String> _attachmentPaths = [];
  final List<String> _pendingAttachments = [];
  final Set<String> _removedAttachments = {};
  bool _isPickingFile = false;

  int get _totalAttachmentCount =>
      _attachmentPaths.length +
      _pendingAttachments.length -
      _removedAttachments.length;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _nameController.text = t.name;
      _amountController.text = t.amount.toString();
      _notesController.text = t.notes ?? '';
      _type = t.isTransfer ? 'transfer' : t.type;
      _selectedCategoryId = int.tryParse(t.categoryId);
      _selectedAccountId = int.tryParse(t.accountId);
      _selectedDate = t.createdAt;
      if (t.isTransfer) {
        // This transaction is the expense (FROM) leg
        _selectedFromAccountId = int.tryParse(t.accountId);
        // Find TO leg — will be resolved after provider loads
        _loadTransferPair(t);
      }
      _attachmentPaths = List.from(t.attachmentPaths);
      _loadTags();
    } else {
      _type = widget.initialType ?? 'expense';
    }
  }

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
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _nameFocusNode.dispose();
    _amountFocusNode.dispose();
    _notesFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTags() async {
    if (widget.transaction == null) return;
    final tags = await ref.read(tagRepositoryProvider).getTagsForTransaction(widget.transaction!.id);
    if (mounted) {
      setState(() => _selectedTags = tags);
    }
  }

  Future<void> _loadTransferPair(Transaction t) async {
    if (t.transferId == null) return;
    final pair = await ref.read(transactionRepositoryProvider).findTransferPair(t.transferId!, t.id);
    if (pair != null && mounted) {
      setState(() => _selectedToAccountId = int.tryParse(pair.accountId));
    }
  }

  Color get _typeColor {
    final cs = Theme.of(context).colorScheme;
    if (_type == 'transfer') return cs.primary;
    return _type == 'income' ? cs.tertiary : cs.error;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;
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

    // Listen for pending account selection from Add Account flow
    ref.listen<int?>(pendingAccountSelectionProvider, (_, accId) {
      if (accId != null) {
        setState(() {
          if (_type == 'transfer') {
            // If we're in transfer mode and we don't have a selection yet, 
            // assign it to the first empty slot.
            if (_selectedFromAccountId == null) {
              _selectedFromAccountId = accId;
            } else {
              _selectedToAccountId ??= accId;
            }
          } else {
            _selectedAccountId = accId;
          }
        });
        ref.read(pendingAccountSelectionProvider.notifier).state = null;
      }
    }
    );

    return Scaffold(
      backgroundColor: cs.surface,
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
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                      final cs = Theme.of(context).colorScheme;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        autofocus: !_isEditing,
                        textCapitalization: TextCapitalization.sentences,
                        style: textTheme.bodyLarge?.copyWith(
                          color: cs.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Transaction name',
                          hintStyle: textTheme.bodyLarge?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          prefixIcon: Icon(
                            Icons.edit_outlined,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      final cs = Theme.of(context).colorScheme;
                      final catMap =
                          ref.read(categoryMapProvider).valueOrNull ?? {};
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: KuberSpacing.xs),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(8),
                            color: cs.surfaceContainerHigh,
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
                                    final cs = Theme.of(context).colorScheme;
                                    final s = options.elementAt(index);
                                    final cat =
                                        catMap[int.tryParse(s.categoryId)];
                                    final catColor = cat != null
                                        ? harmonizeCategory(
                                            context, Color(cat.colorValue))
                                        : cs.onSurfaceVariant;
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
                                                          color: cs.onSurface,
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
                                                            color: cs.onSurfaceVariant,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              ref.watch(formatterProvider).formatCurrency(s.amount),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: KuberSpacing.xxl,
                      horizontal: KuberSpacing.lg,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Amount — truly centered across full width
                        RepaintBoundary(
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
                            maxLines: 1,
                            style: textTheme.displayLarge?.copyWith(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: _typeColor,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: textTheme.displayLarge?.copyWith(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: cs.onSurfaceVariant,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                              isCollapsed: true,
                            ),
                          ),
                        ),
                        // currency symbol — pinned left
                        Positioned(
                          left: 0,
                          child: Text(
                            ref.watch(currencyProvider).symbol,
                            style: textTheme.titleLarge?.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w300,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        // Calculator button — pinned right
                        Positioned(
                          right: 0,
                          child: GestureDetector(
                            onTap: _openCalculator,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: cs.surfaceContainerHigh,
                                borderRadius:
                                    BorderRadius.circular(KuberRadius.md),
                                border: Border.all(
                                  color: cs.outline,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.calculate_outlined,
                                size: 20,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                              border: Border.all(color: colorScheme.outlineVariant),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+$amount',
                              style: textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSurface,
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
                                  : cs.onSurfaceVariant,
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
                                  : cs.onSurfaceVariant,
                              onTap: () => _showAccountPicker(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_selectedCategoryId != null) ...[
                    const SizedBox(height: KuberSpacing.md),
                    _BudgetProgressIndicator(categoryId: _selectedCategoryId!.toString()),
                  ],
                  const SizedBox(height: KuberSpacing.md),

                  // [E] Date & Time tile
                  InkWell(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline),
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
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _formatDate(_selectedDate),
                                style: textTheme.bodyMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Icon(
                            Icons.chevron_right,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.md),

                  // Tags section
                  InkWell(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    onTap: _showTagSelector,
                    child: Container(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: cs.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.sell_outlined,
                                  size: 18,
                                  color: cs.primary,
                                ),
                              ),
                              const SizedBox(width: KuberSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TAGS',
                                    style: textTheme.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _selectedTags.isEmpty
                                        ? 'No tags selected'
                                        : '${_selectedTags.length} tags selected',
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: _selectedTags.isEmpty
                                          ? cs.onSurfaceVariant
                                          : cs.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Icon(
                                Icons.chevron_right,
                                color: cs.onSurfaceVariant,
                              ),
                            ],
                          ),
                          if (_selectedTags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _selectedTags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: cs.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: cs.primary.withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: Text(
                                    '#${tag.name}',
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.md),

                  // Notes field
                  TextField(
                    controller: _notesController,
                    focusNode: _notesFocusNode,
                    maxLines: 2,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a note (optional)',
                      hintStyle: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.md),

                  // Attachments section
                  _buildAttachmentsSection(cs, textTheme),
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
              color: cs.surface,
              border: Border(
                top: BorderSide(color: cs.outline),
              ),
            ),
            child: AppButton(
              label: _isEditing
                  ? (_type == 'expense'
                      ? 'Update Expense'
                      : _type == 'income'
                          ? 'Update Income'
                          : 'Update Transfer')
                  : (_type == 'expense'
                      ? 'Save Expense'
                      : _type == 'income'
                          ? 'Save Income'
                          : 'Save Transfer'),
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _save,
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildSelectorTilePlaceholder(String label) {
    final cs = Theme.of(context).colorScheme;
    return _SelectorTile(
      label: label,
      icon: Icons.hourglass_empty,
      value: '...',
      iconColor: cs.onSurfaceVariant,
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

  void _openCalculator() {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => KuberCalculator(
        initialValue: double.tryParse(_amountController.text.trim()) ?? 0,
        onConfirm: (result) {
          setState(() {
            _amountController.text = result == result.truncateToDouble()
                ? result.toInt().toString()
                : result.toStringAsFixed(2);
          });
        },
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
  }

  void _showCategoryPicker() {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _selectedCategoryId,
        defaultType: _type == 'transfer' ? null : _type,
        onSelected: (id) {
          setState(() => _selectedCategoryId = id);
          Navigator.pop(context);
        },
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
  }

  void _showAccountPicker() {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: _selectedAccountId,
        onSelected: (id) {
          setState(() => _selectedAccountId = id);
          Navigator.pop(context);
        },
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
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
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
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

    if (name.isEmpty) {
      showKuberSnackBar(context, 'Please enter a transaction name', isError: true);
      return;
    }
    if (amount == null || amount <= 0) {
      showKuberSnackBar(context, 'Please enter a valid amount', isError: true);
      return;
    }
    if (_selectedCategoryId == null) {
      showKuberSnackBar(context, 'Please select a category', isError: true);
      return;
    }
    if (_selectedAccountId == null) {
      showKuberSnackBar(context, 'Please select an account', isError: true);
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
    t.createdAt = _selectedDate;
    t.updatedAt = DateTime.now();

    // Set attachment paths for existing attachments (edit mode)
    if (_isEditing) {
      t.attachmentPaths = _attachmentPaths
          .where((p) => !_removedAttachments.contains(p))
          .toList();
    }

    try {
      final int resultId;
      if (_isEditing) {
        resultId = await ref.read(transactionListProvider.notifier).updateTransaction(t);
      } else {
        resultId = await ref.read(transactionListProvider.notifier).add(t);
      }

      // Save attachments
      if (_pendingAttachments.isNotEmpty || _removedAttachments.isNotEmpty) {
        await _saveAttachments(resultId);
      }

      // Save tags
      await ref.read(tagRepositoryProvider).updateTransactionTags(
        resultId,
        _selectedTags.map((tag) => tag.id).toList(),
      );
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
    if (amount == null || amount <= 0) {
      showKuberSnackBar(context, 'Please enter a valid amount', isError: true);
      return;
    }
    if (_selectedFromAccountId == null) {
      showKuberSnackBar(context, 'Please select a source account', isError: true);
      return;
    }
    if (_selectedToAccountId == null) {
      showKuberSnackBar(context, 'Please select a destination account', isError: true);
      return;
    }
    if (_selectedFromAccountId == _selectedToAccountId) {
      showKuberSnackBar(context, 'Source and destination accounts must be different', isError: true);
      return;
    }

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
        );
      } else {
        await ref.read(transactionListProvider.notifier).saveTransfer(
          fromAccountId: _selectedFromAccountId.toString(),
          toAccountId: _selectedToAccountId.toString(),
          amount: amount,
          createdAt: _selectedDate,
          notes: notes,
        );
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
      _isEditing ? 'Transfer updated' : 'Transfer saved',
    );
  }

  Widget _buildTransferForm(
    ColorScheme colorScheme,
    TextTheme textTheme,
    AsyncValue<List<Account>> accounts,
  ) {
    final cs = colorScheme;
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
      bgColor = cs.tertiary.withValues(alpha: 0.15);
      txtColor = cs.tertiary;
    } else if (subtype == TransferSubtype.creditCardWithdrawal) {
      bgColor = cs.error.withValues(alpha: 0.15);
      txtColor = cs.error;
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
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: KuberSpacing.xxl,
            horizontal: KuberSpacing.lg,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Amount — truly centered across full width
              TextField(
                controller: _amountController,
                focusNode: _amountFocusNode,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d*\.?\d{0,2}'),
                  ),
                ],
                textAlign: TextAlign.center,
                maxLines: 1,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: '0',
                  hintStyle: textTheme.displayLarge?.copyWith(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: cs.onSurfaceVariant,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  isCollapsed: true,
                ),
              ),
              // currency symbol — pinned left
              Positioned(
                left: 0,
                child: Text(
                  ref.watch(currencyProvider).symbol,
                  style: textTheme.titleLarge?.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w300,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              // Calculator button — pinned right
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: _openCalculator,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius:
                          BorderRadius.circular(KuberRadius.md),
                      border: Border.all(
                        color: cs.outline,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.calculate_outlined,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ],
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
                    border: Border.all(color: colorScheme.outlineVariant),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+$amount',
                    style: textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
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
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
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
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(_selectedDate),
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.md),

        // Tags section
        InkWell(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          onTap: _showTagSelector,
          child: Container(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.sell_outlined,
                        size: 18,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAGS',
                          style: textTheme.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedTags.isEmpty
                              ? 'No tags selected'
                              : '${_selectedTags.length} tags selected',
                          style: textTheme.bodyMedium?.copyWith(
                            color: _selectedTags.isEmpty
                                ? cs.onSurfaceVariant
                                : cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: cs.onSurfaceVariant,
                    ),
                  ],
                ),
                if (_selectedTags.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selectedTags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: cs.primary.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Text(
                          '#${tag.name}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: cs.primary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
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
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Add a note (optional)',
            hintStyle: textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
            prefixIcon: Icon(
              Icons.note_outlined,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.md),

        // Attachments section
        _buildAttachmentsSection(cs, textTheme),
        const SizedBox(height: KuberSpacing.xl),
      ],
    );
  }

  // ── Attachments ──────────────────────────────────────────────────────────

  Widget _buildAttachmentsSection(ColorScheme cs, TextTheme textTheme) {
    final allPaths = [
      ..._attachmentPaths.where((p) => !_removedAttachments.contains(p)),
      ..._pendingAttachments,
    ];
    final canAdd = _totalAttachmentCount < 5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          onTap: canAdd && !_isPickingFile ? _showAttachmentPicker : null,
          child: Container(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isPickingFile
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        )
                      : Icon(
                          Icons.attach_file_rounded,
                          size: 18,
                          color: cs.primary,
                        ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATTACHMENTS',
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      allPaths.isEmpty
                          ? 'Add image or PDF'
                          : '${allPaths.length} file${allPaths.length == 1 ? '' : 's'} attached',
                      style: textTheme.bodyMedium?.copyWith(
                        color: allPaths.isEmpty
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (canAdd && !_isPickingFile)
                  Icon(Icons.add, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        if (allPaths.isNotEmpty) ...[
          const SizedBox(height: KuberSpacing.sm),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: allPaths.length,
              separatorBuilder: (_, __) => const SizedBox(width: KuberSpacing.sm),
              itemBuilder: (context, index) {
                final path = allPaths[index];
                final isImage = AttachmentService.getFileType(path) == 'image';
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onTap: () => OpenFilex.open(path),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          border: Border.all(color: cs.outline),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isImage
                            ? Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                width: 80,
                                height: 80,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image_outlined,
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: cs.primary,
                                  size: 32,
                                ),
                              ),
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removeAttachment(path),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: cs.error,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  void _showAttachmentPicker() {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(
          KuberSpacing.xl,
          KuberSpacing.lg,
          KuberSpacing.xl,
          MediaQuery.of(context).viewPadding.bottom + KuberSpacing.xxl,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),
            Text(
              'Add Attachment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: KuberSpacing.xl),
            SettingsCardSelector<String>(
              options: const [
                SelectorOption(
                  value: 'camera',
                  label: 'Camera',
                  subtitle: 'TAKE PHOTO',
                  icon: Icons.camera_alt_outlined,
                ),
                SelectorOption(
                  value: 'gallery',
                  label: 'Gallery',
                  subtitle: 'CHOOSE IMAGE',
                  icon: Icons.photo_library_outlined,
                ),
                SelectorOption(
                  value: 'pdf',
                  label: 'PDF',
                  subtitle: 'DOCUMENT',
                  icon: Icons.picture_as_pdf_outlined,
                ),
              ],
              selectedValue: '', // no pre-selection
              onSelected: (value) {
                Navigator.pop(context);
                switch (value) {
                  case 'camera':
                    _pickImage(ImageSource.camera);
                    break;
                  case 'gallery':
                    _pickImage(ImageSource.gallery);
                    break;
                  case 'pdf':
                    _pickPdf();
                    break;
                }
              },
            ),
            const SizedBox(height: KuberSpacing.lg),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_totalAttachmentCount >= 5) {
      showKuberSnackBar(context, 'Maximum 5 attachments allowed', isError: true);
      return;
    }
    setState(() => _isPickingFile = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked != null && mounted) {
        final file = File(picked.path);
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          if (mounted) {
            showKuberSnackBar(context, 'File exceeds 5MB limit', isError: true);
          }
          return;
        }
        setState(() => _pendingAttachments.add(picked.path));
      }
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(context, 'Failed to pick image: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  Future<void> _pickPdf() async {
    if (_totalAttachmentCount >= 5) {
      showKuberSnackBar(context, 'Maximum 5 attachments allowed', isError: true);
      return;
    }
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          if (mounted) {
            showKuberSnackBar(context, 'File exceeds 5MB limit', isError: true);
          }
          return;
        }
        setState(() => _pendingAttachments.add(path));
      }
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(context, 'Failed to pick PDF: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _removeAttachment(String path) {
    setState(() {
      if (_pendingAttachments.contains(path)) {
        _pendingAttachments.remove(path);
      } else {
        _removedAttachments.add(path);
      }
    });
  }

  Future<void> _saveAttachments(int transactionId) async {
    final attachmentService = ref.read(attachmentServiceProvider);

    // Delete removed attachments
    for (final path in _removedAttachments) {
      await attachmentService.deleteAttachment(path);
    }

    // Copy pending attachments
    final savedPaths = <String>[];
    final existingCount = _attachmentPaths
        .where((p) => !_removedAttachments.contains(p))
        .length;
    for (int i = 0; i < _pendingAttachments.length; i++) {
      final saved = await attachmentService.saveAttachment(
        transactionId,
        _pendingAttachments[i],
        existingCount + i,
      );
      savedPaths.add(saved);
    }

    // Build final attachment list
    final finalPaths = [
      ..._attachmentPaths.where((p) => !_removedAttachments.contains(p)),
      ...savedPaths,
    ];

    // Update the transaction with attachment paths
    final allTxns = await ref.read(transactionListProvider.future);
    final txn = allTxns.firstWhereOrNull((t) => t.id == transactionId);
    if (txn != null) {
      txn.attachmentPaths = finalPaths;
      await ref.read(transactionListProvider.notifier).updateTransaction(txn);
    }
  }

  void _showTransferAccountPicker({
    required bool isFrom,
    int? excludeId,
  }) {
    FocusScope.of(context).unfocus();
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
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
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
  }

  void _showTagSelector() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => TagSelectorBottomSheet(
        initialSelectedTags: _selectedTags,
        onDone: (tags) {
          setState(() => _selectedTags = tags);
        },
      ),
    ).then((_) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) FocusScope.of(context).unfocus();
      });
    });
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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = account != null
        ? resolveAccountColor(account!)
        : cs.onSurfaceVariant;
    final icon = account != null
        ? resolveAccountIcon(account!)
        : Icons.account_balance_wallet_outlined;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
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
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    account?.name ?? 'Select Account',
                    style: textTheme.bodyMedium?.copyWith(
                      color: account != null
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: cs.onSurfaceVariant,
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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
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
                      color: cs.onSurface,
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
    final cs = Theme.of(context).colorScheme;
    final colorScheme = cs;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
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
                        : cs.onSurfaceVariant,
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

class _BudgetProgressIndicator extends ConsumerWidget {
  final String categoryId;
  const _BudgetProgressIndicator({required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetByCategoryProvider(categoryId));
    final cs = Theme.of(context).colorScheme;

    return budgetAsync.when(
      data: (budget) {
        if (budget == null || !budget.isActive) return const SizedBox.shrink();
        
        final progressAsync = ref.watch(budgetProgressProvider(budget));
        return progressAsync.when(
          data: (p) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                Icon(Icons.account_balance_wallet_outlined, size: 14, color: cs.primary),
                const SizedBox(width: 8),
                Text(
                  'Budget',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ref.watch(formatterProvider).formatCurrency(p.spent)} / ${ref.watch(formatterProvider).formatCurrency(p.limit)} (${p.percentage.toStringAsFixed(0)}% used)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: p.percentage >= 100 ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                ),
                if (p.percentage >= 100)
                  Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
