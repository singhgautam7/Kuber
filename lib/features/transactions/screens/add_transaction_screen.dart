import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/attachment_service.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/transfer_helpers.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider, privacyModeProvider;
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';
import '../providers/suggestion_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/suggestion_service.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../widgets/account_picker_sheet.dart';
import '../widgets/amount_input.dart';
import '../widgets/attachments_section.dart';
import '../widgets/budget_progress_indicator.dart';
import '../widgets/category_picker_sheet.dart';
import '../widgets/date_time_tile.dart';
import '../widgets/notes_field.dart';
import '../widgets/selector_tile.dart';
import '../widgets/tags_tile.dart';
import '../widgets/transaction_type_selector.dart';
import '../widgets/transfer_account_tile.dart';
import '../../tags/data/tag.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/widgets/tag_selector_bottom_sheet.dart';

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

  int get _totalAttachmentCount =>
      _attachmentPaths.length +
      _pendingAttachments.length -
      _removedAttachments.length;

  List<String> get _displayPaths => [
        ..._attachmentPaths.where((p) => !_removedAttachments.contains(p)),
        ..._pendingAttachments,
      ];

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
        _selectedFromAccountId = int.tryParse(t.accountId);
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

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
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
    });

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

                    // Type segmented button
                    TransactionTypeSelector(
                      selected: _type,
                      onSelected: _onTypeChanged,
                      enabled: !_isEditing,
                    ),
                    const SizedBox(height: KuberSpacing.xl),

                    if (_type == 'transfer')
                      _buildTransferForm(cs, textTheme, accounts)
                    else ...[
                      // Name field with autocomplete
                      _buildAutocompleteField(cs, textTheme),
                      const SizedBox(height: KuberSpacing.xl),

                      // Amount input
                      AmountInput(
                        controller: _amountController,
                        amountColor: _typeColor,
                      ),
                      const SizedBox(height: KuberSpacing.lg),

                      // Category + Account selector tiles
                      _buildCategoryAccountRow(cs, categoryMap, accounts),
                      if (_selectedCategoryId != null) ...[
                        const SizedBox(height: KuberSpacing.md),
                        BudgetProgressIndicator(categoryId: _selectedCategoryId!.toString()),
                      ],
                      const SizedBox(height: KuberSpacing.md),

                      // Shared form fields
                      ..._buildSharedFormFields(showNotesPrefixIcon: false),
                    ],
                  ],
                ),
              ),
            ),

            // Pinned save button
            _buildSaveButton(cs),
          ],
        ),
      ),
    );
  }

  /// Shared form fields: Date, Tags, Notes, Attachments.
  /// Used by both normal and transfer forms.
  List<Widget> _buildSharedFormFields({required bool showNotesPrefixIcon}) {
    return [
      DateTimeTile(
        selectedDate: _selectedDate,
        onTap: _pickDate,
      ),
      const SizedBox(height: KuberSpacing.md),

      TagsTile(
        selectedTags: _selectedTags,
        onTap: _showTagSelector,
      ),
      const SizedBox(height: KuberSpacing.md),

      NotesField(
        controller: _notesController,
        focusNode: showNotesPrefixIcon ? null : _notesFocusNode,
        showPrefixIcon: showNotesPrefixIcon,
      ),
      const SizedBox(height: KuberSpacing.md),

      AttachmentsSection(
        displayPaths: _displayPaths,
        canAdd: _totalAttachmentCount < 5,
        onFileAdded: (path) => setState(() => _pendingAttachments.add(path)),
        onFileRemoved: _removeAttachment,
      ),
      const SizedBox(height: KuberSpacing.xl),
    ];
  }

  // ── Transfer Form ────────────────────────────────────────────────────────

  Widget _buildTransferForm(
    ColorScheme cs,
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
      bgColor = cs.tertiary.withValues(alpha: 0.15);
      txtColor = cs.tertiary;
    } else if (subtype == TransferSubtype.creditCardWithdrawal) {
      bgColor = cs.error.withValues(alpha: 0.15);
      txtColor = cs.error;
    } else if (subtype == TransferSubtype.creditCardTransfer) {
      bgColor = const Color(0xFFF59E0B).withValues(alpha: 0.15);
      txtColor = const Color(0xFFF59E0B);
    } else {
      bgColor = cs.primaryContainer;
      txtColor = cs.onPrimaryContainer;
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

        // Amount input (shared widget)
        AmountInput(
          controller: _amountController,
          focusNode: _amountFocusNode,
          amountColor: cs.onSurface,
        ),
        const SizedBox(height: KuberSpacing.lg),

        // FROM Account tile
        TransferAccountTile(
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
                color: cs.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                color: cs.onPrimary,
                size: 22,
              ),
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),

        // TO Account tile
        TransferAccountTile(
          label: 'TO ACCOUNT',
          account: toAccount,
          onTap: () => _showTransferAccountPicker(
            isFrom: false,
            excludeId: _selectedFromAccountId,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),

        // Shared form fields (date, tags, notes, attachments)
        ..._buildSharedFormFields(showNotesPrefixIcon: true),
      ],
    );
  }

  // ── Autocomplete ─────────────────────────────────────────────────────────

  Widget _buildAutocompleteField(ColorScheme cs, TextTheme textTheme) {
    return RawAutocomplete<TransactionSuggestion>(
      textEditingController: _nameController,
      focusNode: _nameFocusNode,
      displayStringForOption: (s) => s.displayName,
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
      onSelected: (suggestion) {
        _suppressSuggestions = true;
        _applySuggestion(suggestion);
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
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
        final catMap = ref.read(categoryMapProvider).valueOrNull ?? {};
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
                      final s = options.elementAt(index);
                      final cat = catMap[int.tryParse(s.categoryId ?? '')];
                      final catColor = cat != null
                          ? harmonizeCategory(
                              context, Color(cat.colorValue))
                          : cs.onSurfaceVariant;
                      final catIcon = cat != null
                          ? IconMapper.fromString(cat.icon)
                          : Icons.category;

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
                                  color: catColor.withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(catIcon,
                                    size: 18, color: catColor),
                              ),
                              const SizedBox(width: KuberSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      s.displayName,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: cs.onSurface,
                                          ),
                                      overflow: TextOverflow.ellipsis,
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
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                ),
                              ),
                              if (s.amount != null)
                                Text(
                                  maskAmount(ref.watch(formatterProvider).formatCurrency(s.amount!), ref.watch(privacyModeProvider)),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: cs.onSurfaceVariant,
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
    );
  }

  // ── Category + Account Row ───────────────────────────────────────────────

  Widget _buildCategoryAccountRow(
    ColorScheme cs,
    AsyncValue<Map<int, dynamic>> categoryMap,
    AsyncValue<List<Account>> accounts,
  ) {
    return Row(
      children: [
        Expanded(
          child: categoryMap.when(
            loading: () => _buildSelectorTilePlaceholder('CATEGORY'),
            error: (_, _) => _buildSelectorTilePlaceholder('CATEGORY'),
            data: (catMap) {
              final cat = _selectedCategoryId != null
                  ? catMap[_selectedCategoryId]
                  : null;
              return SelectorTile(
                label: 'CATEGORY',
                icon: cat != null
                    ? IconMapper.fromString(cat.icon)
                    : Icons.category_outlined,
                value: cat?.name ?? 'Select',
                iconColor: cat != null
                    ? harmonizeCategory(context, Color(cat.colorValue))
                    : cs.onSurfaceVariant,
                onTap: () => _showCategoryPicker(),
              );
            },
          ),
        ),
        const SizedBox(width: KuberSpacing.md),
        Expanded(
          child: accounts.when(
            loading: () => _buildSelectorTilePlaceholder('FROM ACCOUNT'),
            error: (_, _) => _buildSelectorTilePlaceholder('FROM ACCOUNT'),
            data: (accs) {
              final acc = _selectedAccountId != null
                  ? accs.where((a) => a.id == _selectedAccountId).firstOrNull
                  : null;
              return SelectorTile(
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
    );
  }

  // ── Save Button ──────────────────────────────────────────────────────────

  Widget _buildSaveButton(ColorScheme cs) {
    return Container(
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
    );
  }

  Widget _buildSelectorTilePlaceholder(String label) {
    final cs = Theme.of(context).colorScheme;
    return SelectorTile(
      label: label,
      icon: Icons.hourglass_empty,
      value: '...',
      iconColor: cs.onSurfaceVariant,
      onTap: () {},
    );
  }

  // ── Pickers ──────────────────────────────────────────────────────────────

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

  // ── Suggestions ──────────────────────────────────────────────────────────

  void _applySuggestion(TransactionSuggestion suggestion) {
    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];

    final accountExists = suggestion.accountId != null &&
        accounts.any((a) => a.id.toString() == suggestion.accountId);
    final categoryExists = suggestion.categoryId != null &&
        categories.any((c) => c.id.toString() == suggestion.categoryId);

    setState(() {
      _nameController.text = suggestion.displayName;
      if (suggestion.amount != null) {
        _amountController.text = suggestion.amount.toString();
      }
      if (categoryExists) {
        _selectedCategoryId = int.tryParse(suggestion.categoryId!);
      }
      if (accountExists) {
        _selectedAccountId = int.tryParse(suggestion.accountId!);
      }
    });
    ref.read(suggestionQueryProvider.notifier).state = '';
    _nameFocusNode.requestFocus();
  }

  // ── Save Logic ───────────────────────────────────────────────────────────

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
      ref.read(suggestionServiceProvider).upsertSuggestion(t).ignore();

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

  // ── Attachments ──────────────────────────────────────────────────────────

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
}

