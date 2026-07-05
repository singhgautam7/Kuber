// =============================================================================
// add_ledger_screen.dart  — POLISHED
//
// Drop-in replacement for lib/features/ledger/screens/add_ledger_screen.dart.
// =============================================================================

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider, formatterProvider, NumberSystem;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../../tools/bill_splitter/providers/people_provider.dart';
import '../../tools/bill_splitter/widgets/bs_avatar.dart';
import '../data/ledger.dart';
import '../data/ledger_prefill.dart';
import '../providers/ledger_provider.dart';

class AddLedgerScreen extends ConsumerStatefulWidget {
  final Ledger? existing;
  final LedgerPrefill? prefill;

  /// Amount-only pre-fill for Kuber Notes tap-to-convert (create mode only).
  final double? amountPrefill;

  const AddLedgerScreen({
    super.key,
    this.existing,
    this.prefill,
    this.amountPrefill,
  });

  @override
  ConsumerState<AddLedgerScreen> createState() => _AddLedgerScreenState();
}

class _AddLedgerScreenState extends ConsumerState<AddLedgerScreen> {
  late String _type; // 'lent' | 'borrowed'
  final _amountController = TextEditingController();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();
  final _nameFocusNode = FocusNode();
  
  DateTime _date = DateTime.now();
  DateTime? _expectedDate;
  String? _selectedAccountId;
  bool _isEditing = false;

  double get _amount =>
      double.tryParse(_amountController.text.trim().replaceAll(',', '')) ?? 0;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _amount > 0 &&
      _selectedAccountId != null;

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
      _date = e.createdAt;
      _expectedDate = e.expectedDate;
      _notesController.text = e.notes ?? '';
      _selectedAccountId = e.accountId;
    } else {
      final prefill = widget.prefill;
      _type = prefill?.type ?? 'lent';
      final amountOnly = widget.amountPrefill;
      if (prefill == null && amountOnly != null && amountOnly > 0) {
        _amountController.text =
            amountOnly == amountOnly.truncateToDouble()
                ? amountOnly.toInt().toString()
                : amountOnly.toStringAsFixed(2);
      }
      if (prefill != null) {
        _amountController.text = prefill.amount == prefill.amount.truncateToDouble()
            ? prefill.amount.toInt().toString()
            : prefill.amount.toStringAsFixed(2);
        _nameController.text = prefill.personName;
        _notesController.text = prefill.notes ?? '';
        _date = prefill.entryDate ?? DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _nameFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final tone = _type == 'lent' ? HeroAmountTone.expense : HeroAmountTone.income;
    final isIndian = ref.watch(formatterProvider).system == NumberSystem.indian;
    final people = ref.watch(peopleListProvider).valueOrNull ?? [];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? context.l10n.editEntry : context.l10n.newEntry,
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TYPE ─────────────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.typeLabel,
              topGap: 0,
              children: [
                KuberSegmented<String>(
                  groupValue: _type,
                  enabled: !_isEditing, // PRESERVED — locked while editing
                  onChanged: (v) => setState(() => _type = v),
                  segments: [
                    KuberSegment(
                      value: 'lent',
                      label: context.l10n.lentLabel,
                      icon: Icons.arrow_outward_rounded,
                      tone: SegmentTone.expense,
                    ),
                    KuberSegment(
                      value: 'borrowed',
                      label: context.l10n.borrowedLabel,
                      icon: Icons.south_west_rounded,
                      tone: SegmentTone.income,
                    ),
                  ],
                ),
              ],
            ),

            // ── IDENTITY ─────────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.identity,
              children: [
                KuberHeroAmountInput(
                  label: _type == 'lent' ? context.l10n.amountLent : context.l10n.amountBorrowed,
                  currencySymbol: symbol,
                  controller: _amountController,
                  inputFormatters: [CurrencyInputFormatter(isIndian: isIndian)],
                  tone: tone,
                  onChanged: (_) => setState(() {}),
                  onCalculatorTap: () => _openCalculatorFor(_amountController),
                ),
                KuberFieldLabel(context.l10n.personLabel),
                RawAutocomplete<String>(
                  textEditingController: _nameController,
                  focusNode: _nameFocusNode,
                  optionsBuilder: (textEditingValue) {
                    final query = textEditingValue.text.trim().toLowerCase();
                    if (query.isEmpty) {
                      return people.map((p) => p.name).toList();
                    }
                    return people
                        .where((p) => p.name.toLowerCase().contains(query))
                        .map((p) => p.name)
                        .toList();
                  },
                  fieldViewBuilder:
                      (context, controller, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      textCapitalization: TextCapitalization.words,
                      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                      onChanged: (_) => setState(() {}),
                      style: localeFont(color: cs.onSurface, fontSize: 15),
                      decoration: InputDecoration(
                        hintText: context.l10n.whoHint,
                      ),
                    );
                  },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        color: cs.surfaceContainer,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 240),
                          child: ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            itemCount: options.length,
                            separatorBuilder: (_, __) => Divider(
                              height: 1,
                              indent: 56,
                              color: cs.outline,
                            ),
                            itemBuilder: (ctx, i) {
                              final name = options.elementAt(i);
                              return InkWell(
                                onTap: () => onSelected(name),
                                borderRadius: BorderRadius.circular(
                                  KuberRadius.md,
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      BsAvatar(name: name, size: 32),
                                      const SizedBox(width: 12),
                                      Text(
                                        name,
                                        style: localeFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: cs.onSurface,
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
                    );
                  },
                ),
                _DuplicatePersonWarning(
                  personName: _nameController.text,
                  type: _type,
                  isEditing: _isEditing,
                ),
                KuberFieldLabel(_type == 'lent' ? context.l10n.fromAccountLabel : context.l10n.toAccountLabel),
                _accountPickerRow(),
              ],
            ),

            // ── SCHEDULE ─────────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.schedule,
              tinted: true,
              children: [
                KuberFieldLabel(context.l10n.dateLabel),
                _dateRow(
                  label: _type == 'lent' ? context.l10n.lentOn : context.l10n.borrowedOn,
                  date: _date,
                  onTap: _pickDate,
                ),
                KuberFieldLabel(context.l10n.expectedReturn, optional: true),
                _expectedReturnRow(),
              ],
            ),

            KuberFormSection(
              label: context.l10n.notesLabel,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  style: localeFont(color: cs.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.l10n.ledgerNotesHint,
                  ),
                ),
              ],
            ),

          ],
        ),
      ),
    ),
      bottomNavigationBar: KuberSaveButton(
        label: _isEditing ? context.l10n.saveChanges : context.l10n.addToLedger,
        onPressed: _canSave ? _save : null,
      ),
    );
  }

  Widget _accountPickerRow() {
    final accs = ref.watch(accountListProvider).valueOrNull ?? [];
    final acc = _selectedAccountId == null
        ? null
        : accs
            .where((a) => a.id.toString() == _selectedAccountId)
            .firstOrNull;
    return KuberPickerRow(
      leading: acc == null
          ? KuberLeadingSwatch(
              color: Colors.transparent,
              icon: Icons.account_balance_outlined,
              empty: true,
            )
          : KuberLeadingSwatch(
              color: Color(acc.colorValue ?? 0xFF3B82F6),
              icon: IconMapper.fromString(acc.icon ?? 'account_balance'),
            ),
      label: context.l10n.accountTitle,
      value: acc?.name ?? context.l10n.selectAccountTitle,
      valueIsPlaceholder: acc == null,
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => AccountPickerSheet(
            selectedAccountId: int.tryParse(_selectedAccountId ?? ''),
            onSelected: (id) {
              setState(() => _selectedAccountId = id.toString());
              Navigator.pop(context);
            },
          ),
        ).unfocusOnComplete(context);
      },
    );
  }

  Widget _dateRow({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return KuberPickerRow(
      leading: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Icon(Icons.calendar_today_rounded,
            size: 16, color: cs.onSurface),
      ),
      label: label,
      value: DateFormat('d MMM yyyy').format(date),
      onTap: onTap,
    );
  }

  Widget _expectedReturnRow() {
    final cs = Theme.of(context).colorScheme;
    if (_expectedDate == null) {
      return KuberPickerRow(
        leading: KuberLeadingSwatch(
          color: cs.surfaceContainerHigh,
          icon: Icons.event_outlined,
          empty: true,
        ),
        label: context.l10n.expectedOn,
        value: context.l10n.notSetTapToAdd,
        valueIsPlaceholder: true,
        onTap: _pickExpectedDate,
      );
    }
    final daysOut = _expectedDate!.difference(DateTime.now()).inDays;
    final suffix = daysOut > 0 ? ' · ${context.l10n.inDays(daysOut)}' : '';
    return KuberPickerRow(
      leading: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Icon(Icons.event_outlined, size: 16, color: cs.onSurface),
      ),
      label: context.l10n.expectedOn,
      value: '${DateFormat('d MMM yyyy').format(_expectedDate!)}$suffix',
      onTap: _pickExpectedDate,
      clearable: true,
      onClear: () => setState(() => _expectedDate = null),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    ).unfocusOnComplete(context);
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_date),
    ).unfocusOnComplete(context);

    if (!mounted) return;
    setState(() {
      _date = DateTime(
        date.year,
        date.month,
        date.day,
        time?.hour ?? _date.hour,
        time?.minute ?? _date.minute,
      );
    });
  }

  Future<void> _pickExpectedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    ).unfocusOnComplete(context);
    if (picked != null) setState(() => _expectedDate = picked);
  }

  void _openCalculatorFor(TextEditingController controller) {
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
            controller.text = result == result.truncateToDouble()
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

  String _toTitleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  // PRESERVED VERBATIM ─────────────────────────────────────────────
  Future<void> _save() async {
    final personName = _toTitleCase(_nameController.text);

    // Auto-add to the shared Person model if the name is new.
    final existingPeople = ref.read(peopleListProvider).valueOrNull ?? [];
    final alreadyExists = existingPeople.any(
      (p) => p.name.toLowerCase() == personName.toLowerCase(),
    );
    if (!alreadyExists) {
      await ref.read(peopleListProvider.notifier).add(personName);
    }

    // Find the "Lent / Borrow" system category
    final categories =
        ref.read(categoryListProvider).valueOrNull ?? <Category>[];
    final ledgerCategory = categories
        .where((c) => c.name == 'Lent / Borrow')
        .firstOrNull;
    final categoryId = ledgerCategory?.id.toString() ?? '';

    if (_isEditing) {
      await ref
          .read(ledgerListProvider.notifier)
          .updateLedger(
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
      await ref
          .read(ledgerListProvider.notifier)
          .addLedger(
            personName: personName,
            type: _type,
            amount: _amount,
            accountId: _selectedAccountId!,
            categoryId: categoryId,
            notes: _notesController.text.isNotEmpty
                ? _notesController.text
                : null,
            expectedDate: _expectedDate,
            createdAt: _date,
          );
    }
    if (mounted) context.pop();
  }
}

// ─── duplicate-person warning ──────────────────────────────────────
class _DuplicatePersonWarning extends ConsumerWidget {
  final String personName;
  final String type;
  final bool isEditing;
  const _DuplicatePersonWarning({
    required this.personName,
    required this.type,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    if (isEditing) return const SizedBox.shrink();
    if (personName.trim().isEmpty) return const SizedBox.shrink();
    final query = personName.trim().toLowerCase();
    final ledgers = ref.watch(ledgerListProvider).valueOrNull ?? [];
    final hasDuplicate = ledgers.any(
      (l) =>
          l.personNameLower == query &&
          l.type == type &&
          !l.isSettled,
    );
    if (!hasDuplicate) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: KuberCallout(
        child: Text(
          type == 'lent'
              ? context.l10n.ledgerDuplicateWarningLent(personName.trim())
              : context.l10n.ledgerDuplicateWarningBorrow(personName.trim()),
          style: localeFont(
            fontSize: 12.5,
            color: cs.onSurface,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}