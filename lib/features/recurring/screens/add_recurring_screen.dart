// =============================================================================
// add_recurring_screen.dart  — POLISHED
//
// Drop-in replacement for
//   lib/features/recurring/screens/add_recurring_screen.dart
// =============================================================================

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider;
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
  final _endAfterController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _startDate = DateTime.now();
  String _frequency = 'monthly';
  String _endType = 'never';
  DateTime? _endDate;

  bool get _isEdit => widget.existingRule != null;

  bool get _canSave =>
      _nameController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      double.tryParse(
              _amountController.text.trim().replaceAll(',', '')) !=
          null &&
      _selectedCategoryId != null &&
      _selectedAccountId != null;

  // PRESERVED ── frequencies tuple identical to today
  static const _frequencies = <(String, String)>[
    ('daily', 'Daily'),
    ('weekly', 'Weekly'),
    ('monthly', 'Monthly'),
    ('biweekly', 'Biweekly'),
    ('yearly', 'Yearly'),
    ('custom', 'Custom'),
  ];

  @override
  void initState() {
    super.initState();
    final rule = widget.existingRule;
    if (rule != null) {
      _nameController.text = rule.name;
      _amountController.text = rule.amount % 1 == 0
          ? rule.amount.toStringAsFixed(0)
          : rule.amount.toStringAsFixed(2);
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;

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
          _isEdit ? context.l10n.editRecurring : context.l10n.newRecurring,
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
            // ── TRANSACTION ──────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.transactionLabel,
              topGap: 0,
              children: [
                KuberSegmented<String>(
                  groupValue: _type,
                  onChanged: (v) => setState(() {
                    _type = v;
                    // PRESERVED: nulling category when type flips
                    _selectedCategoryId = null;
                  }),
                  segments: [
                    KuberSegment(
                      value: 'expense',
                      label: context.l10n.expenseLabel,
                      icon: Icons.arrow_outward_rounded,
                      tone: SegmentTone.expense,
                    ),
                    KuberSegment(
                      value: 'income',
                      label: context.l10n.incomeLabel,
                      icon: Icons.south_west_rounded,
                      tone: SegmentTone.income,
                    ),
                  ],
                ),
                KuberHeroAmountInput(
                  label: context.l10n.amountTitle,
                  currencySymbol: symbol,
                  controller: _amountController,
                  tone: _type == 'income'
                      ? HeroAmountTone.income
                      : HeroAmountTone.expense,
                  onChanged: (_) => setState(() {}),
                ),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  onChanged: (_) => setState(() {}),
                  style: localeFont(color: cs.onSurface, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: context.l10n.recurringNameHint,
                  ),
                ),
              ],
            ),

            // ── WHERE ────────────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.whereLabel,
              children: [
                _categoryRow(context, ref),
                _accountRow(context, ref),
              ],
            ),

            // ── SCHEDULE (tinted) ────────────────────────────────────
            KuberFormSection(
              label: context.l10n.schedule,
              sublabel: context.l10n.scheduleSublabel,
              tinted: true,
              children: [
                KuberFieldLabel(context.l10n.frequencyLabel),
                KuberChipGrid<String>(
                  columns: 3,
                  selected: _frequency,
                  onChanged: (v) => setState(() => _frequency = v),
                  options: [
                    for (final (val, _) in _frequencies)
                      KuberChipOption(value: val, label: _freqTitle(context, val)),
                  ],
                ),
                // PRESERVED — Every-X-days only when frequency == 'custom'
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: _frequency != 'custom'
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Row(
                            children: [
                              Text(context.l10n.everyLabel,
                                  style: localeFont(
                                      color: cs.onSurfaceVariant)),
                              const SizedBox(width: 10),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _customDaysController,
                                  keyboardType: TextInputType.number,
                                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  textAlign: TextAlign.center,
                                  style: localeFont(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(context.l10n.daysLabel,
                                  style: localeFont(
                                      color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                ),
                KuberFieldLabel(context.l10n.startsOn),
                _dateRow(
                  label: context.l10n.startDate,
                  date: _startDate,
                  onTap: _pickStartDate,
                ),
                KuberFieldLabel(context.l10n.endsLabel),
                KuberSegmented<String>(
                  groupValue: _endType,
                  onChanged: (v) => setState(() => _endType = v),
                  segments: [
                    KuberSegment(value: 'never', label: context.l10n.neverLabel),
                    KuberSegment(value: 'occurrences', label: context.l10n.afterN),
                    KuberSegment(value: 'date', label: context.l10n.onDate),
                  ],
                ),
                // PRESERVED — conditional end-type fields
                AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: switch (_endType) {
                    'occurrences' => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Row(
                          children: [
                            Text(context.l10n.afterLabel,
                                style: localeFont(
                                    color: cs.onSurfaceVariant)),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: _endAfterController,
                                keyboardType: TextInputType.number,
                                onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                textAlign: TextAlign.center,
                                style: localeFont(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(context.l10n.occurrencesLabel,
                                style: localeFont(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    'date' => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _dateRow(
                          label: context.l10n.endDate,
                          date: _endDate ?? _startDate,
                          onTap: _pickEndDate,
                        ),
                      ),
                    _ => const SizedBox.shrink(),
                  },
                ),
                const SizedBox(height: 4),
                _NextOccurrencePreview(
                  startDate: _startDate,
                  frequency: _frequency,
                  endType: _endType,
                ),
              ],
            ),

            // ── NOTES ────────────────────────────────────────────────
            KuberFormSection(
              label: context.l10n.notesLabel,
              children: [
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  style:
                      localeFont(color: cs.onSurface, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: context.l10n.recurringNotesHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
      bottomNavigationBar: KuberSaveButton(
        label: _isEdit ? context.l10n.saveChanges : context.l10n.saveRecurring,
        onPressed: _canSave ? _save : null,
      ),
    );
  }

  // ── Category row (reads picker + renders the chosen cat) ─────────
  Widget _categoryRow(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoryListProvider).valueOrNull ?? [];
    final cat = _selectedCategoryId == null
        ? null
        : cats.where((c) => c.id == _selectedCategoryId).firstOrNull;
    return KuberPickerRow(
      leading: cat == null
          ? KuberLeadingSwatch(
              color: Colors.transparent,
              icon: Icons.bookmark_border_rounded,
              empty: true,
            )
          : KuberLeadingSwatch(
              color: Color(cat.colorValue),
              icon: IconMapper.fromString(cat.icon),
            ),
      label: context.l10n.categoryLabel,
      value: cat?.name ?? context.l10n.selectCategoryTitle,
      valueIsPlaceholder: cat == null,
      onTap: _openCategoryPicker,
    );
  }

  // ── Account row ─────────────────────────────────────────────────
  Widget _accountRow(BuildContext context, WidgetRef ref) {
    final accs = ref.watch(accountListProvider).valueOrNull ?? [];
    final acc = _selectedAccountId == null
        ? null
        : accs.where((a) => a.id == _selectedAccountId).firstOrNull;
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
      onTap: _openAccountPicker,
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

  // ── PRESERVED handlers ──────────────────────────────────────────
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
    ).unfocusOnComplete(context);
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
    ).unfocusOnComplete(context);
  }

  Future<void> _pickStartDate() async {
    final now = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate.isBefore(now) ? now : _startDate,
      firstDate: now,
      lastDate: DateTime(2100),
    ).unfocusOnComplete(context);
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
    ).unfocusOnComplete(context);
    if (picked != null) setState(() => _endDate = picked);
  }

  // PRESERVED VERBATIM ─────────────────────────────────────────────
  Future<void> _save() async {
    final rule = widget.existingRule ?? RecurringRule();
    rule
      ..name = _nameController.text.trim()
      ..amount = double.parse(
          _amountController.text.trim().replaceAll(',', ''))
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
}

// Localized title-case frequency label by value.
String _freqTitle(BuildContext context, String value) {
  final l = context.l10n;
  return switch (value) {
    'daily' => l.freqDaily,
    'weekly' => l.freqWeekly,
    'biweekly' => l.freqBiweekly,
    'yearly' => l.freqYearly,
    'quarterly' => l.freqQuarterly,
    'custom' => l.freqCustom,
    _ => l.freqMonthly,
  };
}

// ─── Next-occurrence preview strip ──────────────────────────────────
class _NextOccurrencePreview extends StatelessWidget {
  final DateTime startDate;
  final String frequency;
  final String endType;
  const _NextOccurrencePreview({
    required this.startDate,
    required this.frequency,
    required this.endType,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final next = DateFormat('d MMM yyyy').format(startDate);
    final cadence = switch (frequency) {
      'daily' => l.cadenceDaily,
      'weekly' => l.cadenceWeekly,
      'biweekly' => l.cadenceBiweekly,
      'monthly' => l.cadenceMonthly,
      'yearly' => l.cadenceYearly,
      'custom' => l.cadenceCustom,
      _ => '',
    };
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.40),
          style: BorderStyle.solid,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.event_repeat_rounded, size: 16, color: cs.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${l.nextOccurrenceLabel} ',
                    style: localeFont(
                        fontSize: 12, color: cs.onSurface),
                  ),
                  TextSpan(
                    text: next,
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: cs.primary,
                    ),
                  ),
                  TextSpan(
                    text: ' · $cadence',
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}