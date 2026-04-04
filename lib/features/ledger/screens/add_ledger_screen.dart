import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import 'package:flutter/services.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/ledger.dart';
import '../providers/ledger_provider.dart';

class AddLedgerScreen extends ConsumerStatefulWidget {
  final Ledger? existing;

  const AddLedgerScreen({super.key, this.existing});

  @override
  ConsumerState<AddLedgerScreen> createState() => _AddLedgerScreenState();
}

class _AddLedgerScreenState extends ConsumerState<AddLedgerScreen> {
  late String _type; // 'lent' | 'borrowed'
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedAccountId;
  DateTime _entryDate = DateTime.now();
  DateTime? _expectedDate;
  final _notesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _isEditing = true;
      _type = e.type;
      _amountController.text = e.originalAmount == e.originalAmount.truncateToDouble()
          ? e.originalAmount.toInt().toString()
          : e.originalAmount.toStringAsFixed(2);
      _nameController.text = e.personName;
      _selectedAccountId = e.accountId;
      _entryDate = e.createdAt;
      _expectedDate = e.expectedDate;
      _notesController.text = e.notes ?? '';
    } else {
      _type = 'lent';
    }
  }

  double get _amount => double.tryParse(_amountController.text.trim()) ?? 0;

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];
    final personNames = ref.watch(ledgerPersonNamesProvider).valueOrNull ?? [];
    final selectedAccount = accounts
        .where((a) => a.id.toString() == _selectedAccountId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Entry' : 'New Entry',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: KuberSpacing.lg),

                  // Type toggle
                  IgnorePointer(
                    ignoring: _isEditing,
                    child: Opacity(
                      opacity: _isEditing ? 0.5 : 1.0,
                      child: _TypeToggle(
                        selected: _type,
                        onSelected: (v) => setState(() => _type = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Amount
                  _SectionLabel('AMOUNT TO RECORD'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                    ),
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: '0',
                      hintStyle: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurfaceVariant,
                      ),
                      prefixText: '$symbol ',
                      prefixStyle: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: cs.onSurfaceVariant,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => _openCalculator(context),
                        child: Container(
                          width: 44,
                          height: 44,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(KuberRadius.md),
                            border: Border.all(color: cs.outline),
                          ),
                          child: Icon(Icons.calculate_outlined,
                              color: cs.onSurfaceVariant),
                        ),
                      ),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Person name
                  _SectionLabel('PERSON NAME'),
                  const SizedBox(height: 8),
                  RawAutocomplete<String>(
                    textEditingController: _nameController,
                    focusNode: FocusNode(),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) return [];
                      final query = textEditingValue.text.toLowerCase();
                      return personNames
                          .where((n) => n.toLowerCase().contains(query))
                          .toList();
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: GoogleFonts.inter(color: cs.onSurface),
                        decoration: InputDecoration(
                          hintText: 'Who are you dealing with?',
                          hintStyle:
                              GoogleFonts.inter(color: cs.onSurfaceVariant),
                          prefixIcon: Icon(Icons.person_outline,
                              color: cs.onSurfaceVariant),
                          filled: true,
                          fillColor: cs.surfaceContainerHighest,
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(KuberRadius.md),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          color: cs.surfaceContainer,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (ctx, i) {
                                final name = options.elementAt(i);
                                return ListTile(
                                  title: Text(name,
                                      style: GoogleFonts.inter(
                                          color: cs.onSurface)),
                                  onTap: () => onSelected(name),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  // Duplicate warning (only for new entries)
                  if (!_isEditing)
                    _DuplicateWarning(
                      personName: _nameController.text,
                      type: _type,
                    ),

                  const SizedBox(height: KuberSpacing.xl),

                  // Account picker
                  _SectionLabel('ACCOUNT'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickAccount(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_outlined,
                              size: 20, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              selectedAccount?.name ?? 'Select account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selectedAccount != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: cs.onSurfaceVariant, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Entry date
                  _SectionLabel('ENTRY DATE & TIME'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickEntryDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.schedule,
                              size: 18, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('MMM d, yyyy  h:mm a')
                                .format(_entryDate),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                          const Spacer(),
                          Icon(Icons.calendar_today,
                              size: 16, color: cs.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Expected due date
                  _SectionLabel('EXPECTED DUE DATE'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickExpectedDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              size: 18, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _expectedDate != null
                                  ? DateFormat('MMM d, yyyy')
                                      .format(_expectedDate!)
                                  : 'No due date set',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _expectedDate != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          if (_expectedDate != null)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _expectedDate = null),
                              child: Icon(Icons.close,
                                  size: 18, color: cs.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),

                  // Notes
                  _SectionLabel('NOTES (OPTIONAL)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 2,
                    style: GoogleFonts.inter(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Add a note...',
                      hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
                      filled: true,
                      fillColor: cs.surfaceContainerHighest,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.xl),
                ],
              ),
            ),
          ),

          // Pinned save button
          Container(
            padding: EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              KuberSpacing.md,
              KuberSpacing.lg,
              MediaQuery.of(context).viewPadding.bottom + KuberSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(top: BorderSide(color: cs.outline)),
            ),
            child: AppButton(
              label: _isEditing
                  ? 'UPDATE ${_type.toUpperCase()} ENTRY'
                  : 'SAVE ${_type.toUpperCase()} ENTRY',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _canSave ? _save : null,
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSave =>
      _amount > 0 &&
      _nameController.text.trim().isNotEmpty &&
      _selectedAccountId != null;

  void _openCalculator(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => KuberCalculator(
        initialValue: _amount,
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
        if (mounted) FocusScope.of(this.context).unfocus();
      });
    });
  }

  void _pickAccount(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: int.tryParse(_selectedAccountId ?? ''),
        onSelected: (id) {
          setState(() => _selectedAccountId = id.toString());
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _pickEntryDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: this.context,
      initialTime: TimeOfDay.fromDateTime(_entryDate),
    );

    if (!mounted) return;
    setState(() {
      _entryDate = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _entryDate.hour,
        time?.minute ?? _entryDate.minute,
      );
    });
  }

  Future<void> _pickExpectedDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() => _expectedDate = picked);
    }
  }

  String _toTitleCase(String input) {
    return input.trim().split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  Future<void> _save() async {
    final personName = _toTitleCase(_nameController.text);

    // Find the "Lent / Borrow" system category
    final categories =
        ref.read(categoryListProvider).valueOrNull ?? <Category>[];
    final ledgerCategory = categories
        .where((c) => c.name == 'Lent / Borrow')
        .firstOrNull;
    final categoryId = ledgerCategory?.id.toString() ?? '';

    if (_isEditing) {
      await ref.read(ledgerListProvider.notifier).updateLedger(
            ledger: widget.existing!,
            personName: personName,
            amount: _amount,
            accountId: _selectedAccountId!,
            categoryId: categoryId,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
            expectedDate: _expectedDate,
          );
    } else {
      await ref.read(ledgerListProvider.notifier).addLedger(
            personName: personName,
            type: _type,
            amount: _amount,
            accountId: _selectedAccountId!,
            categoryId: categoryId,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
            expectedDate: _expectedDate,
            createdAt: _entryDate,
          );
    }

    if (mounted) context.pop();
  }
}

class _TypeToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;

  const _TypeToggle({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final types = ['lent', 'borrowed'];
    final labels = ['Lent', 'Borrowed'];

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: List.generate(types.length, (i) {
          final isSelected = types[i] == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(types[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                alignment: Alignment.center,
                child: Text(
                  labels[i],
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? cs.onPrimary : cs.onSurfaceVariant,
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

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _DuplicateWarning extends ConsumerWidget {
  final String personName;
  final String type;

  const _DuplicateWarning({required this.personName, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (personName.trim().isEmpty) return const SizedBox.shrink();

    final ledgers = ref.watch(ledgerListProvider).valueOrNull ?? [];
    final query = personName.trim().toLowerCase();
    final hasDuplicate = ledgers.any((l) =>
        l.personNameLower == query && l.type == type && !l.isSettled);

    if (!hasDuplicate) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, size: 14, color: cs.error),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'An active ${type == 'lent' ? 'lent' : 'borrow'} record for ${personName.trim()} already exists',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
