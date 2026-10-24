// Add / edit recurring (design R.3): Expense | Income · Amount · Name ·
// Category · Account · When · (edit) Skip next and Pause · Save. Saving a
// change to amount, account, category or schedule on a rule that has run asks
// "Apply changes to future occurrences only?". Past transactions are never
// edited.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/when_picker.dart';
import '../../../core/utils/formatters.dart' show CurrencyInputFormatter;
import '../../settings/providers/settings_provider.dart'
    show NumberSystem, currencyProvider, formatterProvider;
import '../../transactions/widgets/entity_picker_rows.dart';
import '../data/recurring_rule.dart';
import '../domain/recurring_service.dart';
import '../providers/recurring_provider.dart';
import '../widgets/rule_sheet.dart';

class AddRecurringScreen extends ConsumerStatefulWidget {
  final RecurringRule? existingRule;

  /// Pre-fill support for Kuber Notes tap-to-convert (create mode only).
  final double? amountPrefill;
  final int? categoryPrefill;

  /// Optional name prefill (Home v2 recurring suggestion).
  final String? namePrefill;

  const AddRecurringScreen({
    super.key,
    this.existingRule,
    this.amountPrefill,
    this.categoryPrefill,
    this.namePrefill,
  });

  @override
  ConsumerState<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends ConsumerState<AddRecurringScreen> {
  final _name = TextEditingController();
  final _amount = TextEditingController();
  final _notes = TextEditingController();
  String _type = 'expense';
  int? _categoryId;
  int? _accountId;
  late WhenValue _when;
  bool _saving = false;

  RecurringRule? get _rule => widget.existingRule;
  bool get _isEdit => _rule != null;

  @override
  void initState() {
    super.initState();
    final r = _rule;
    if (r != null) {
      _name.text = r.name;
      _amount.text = r.amount % 1 == 0 ? r.amount.toStringAsFixed(0) : '${r.amount}';
      _notes.text = r.notes ?? '';
      _type = r.type;
      _categoryId = int.tryParse(r.categoryId);
      _accountId = int.tryParse(r.accountId);
      _when = WhenValue.fromSchedule(r.schedule!);
    } else {
      _when = WhenValue(start: DateUtils.dateOnly(DateTime.now()));
      final a = widget.amountPrefill;
      if (a != null && a > 0) _amount.text = a % 1 == 0 ? a.toStringAsFixed(0) : '$a';
      _categoryId = widget.categoryPrefill;
      if (widget.namePrefill?.isNotEmpty ?? false) _name.text = widget.namePrefill!;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _notes.dispose();
    super.dispose();
  }

  double get _amountValue => KuberAmountField.valueOf(_amount);

  bool get _canSave =>
      !_saving &&
      _name.text.trim().isNotEmpty &&
      _amountValue > 0 &&
      _categoryId != null &&
      _accountId != null &&
      _when.error(context.l10n) == null;

  Future<void> _save() async {
    final l = context.l10n;
    setState(() => _saving = true);
    final service = RecurringService(ref.read(isarProvider));
    final schedule = _when.toSchedule();
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();
    try {
      final r = _rule;
      if (r == null) {
        await service.create(
          RecurringRule()
            ..name = _name.text.trim()
            ..amount = _amountValue
            ..type = _type
            ..categoryId = '$_categoryId'
            ..accountId = '$_accountId'
            ..notes = notes,
          schedule,
        );
      } else {
        final termsChanged = _amountValue != r.amount ||
            '$_categoryId' != r.categoryId ||
            '$_accountId' != r.accountId ||
            !RecurringService.sameRule(r.schedule!, schedule);
        if (termsChanged && r.schedule!.postedCount > 0) {
          final ok = await _confirmFuture(r);
          if (ok != true) return;
        }
        await service.edit(r,
            name: _name.text.trim(),
            amount: _amountValue,
            type: _type,
            categoryId: '$_categoryId',
            accountId: '$_accountId',
            notes: notes,
            schedule: schedule);
      }
      ref.invalidate(recurringListProvider);
      if (mounted) {
        showKuberSnackBar(context, l.msRecSaved);
        context.pop();
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<bool?> _confirmFuture(RecurringRule r) {
    final l = context.l10n;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.msRecFutureTitle, style: localeFont(fontWeight: FontWeight.w600)),
        content: Text(l.msRecFutureBody(r.name, '${r.schedule!.postedCount}'), style: localeFont()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msRecFutureCta)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(formatterProvider).symbol;
    ref.watch(currencyProvider);
    final r = _rule;
    final next = r == null ? null : nextDate(r.schedule!);
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        onBack: () => context.pop(),
        title: _isEdit ? l.msRecEdit : l.msRecNew,
        actions: [
          if (r != null)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: cs.error),
              onPressed: () async {
                await confirmDeleteRule(context, ref, r);
                if (context.mounted) context.pop();
              },
            ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 140),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KuberSegmented<String>(
                groupValue: _type,
                onChanged: (v) => setState(() {
                  _type = v;
                  _categoryId = null;
                }),
                segments: [
                  KuberSegment(
                      value: 'expense',
                      label: l.msRecExpense,
                      icon: Icons.arrow_outward_rounded,
                      tone: SegmentTone.expense),
                  KuberSegment(
                      value: 'income',
                      label: l.msRecIncomeType,
                      icon: Icons.south_west_rounded,
                      tone: SegmentTone.income),
                ],
              ),
              const SizedBox(height: 16),
              KuberHeroAmountInput(
                label: l.msRecAmount,
                currencySymbol: symbol,
                controller: _amount,
                tone: _type == 'income' ? HeroAmountTone.income : HeroAmountTone.expense,
                inputFormatters: [
                  CurrencyInputFormatter(
                      isIndian: ref.watch(formatterProvider).system == NumberSystem.indian)
                ],
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              KuberTextField(
                label: l.msRecName,
                controller: _name,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              CategoryPickerRow(
                selectedId: _categoryId,
                type: _type,
                onChanged: (id) => setState(() => _categoryId = id),
              ),
              const SizedBox(height: 10),
              AccountPickerRow(
                selectedId: _accountId,
                onChanged: (id) => setState(() => _accountId = id),
              ),
              const SizedBox(height: 24),
              KuberWhenPicker(value: _when, onChanged: (v) => setState(() => _when = v)),
              if (r != null && !r.schedule!.paused && next != null) ...[
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(
                    child: AppButton(
                      label: l.msRecSkipNext(fmtDayShort(dayOf(next))),
                      type: AppButtonType.normal,
                      onPressed: () async {
                        await skipNextOccurrence(context, ref, r);
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      label: l.msRecPause,
                      type: AppButtonType.outline,
                      onPressed: () async {
                        await togglePauseRule(context, ref, r);
                        if (context.mounted) context.pop();
                      },
                    ),
                  ),
                ]),
              ],
              if (r != null && r.schedule!.paused) ...[
                const SizedBox(height: 16),
                AppButton(
                  label: l.msRecResume,
                  type: AppButtonType.outline,
                  fullWidth: true,
                  onPressed: () async {
                    await togglePauseRule(context, ref, r);
                    if (context.mounted) context.pop();
                  },
                ),
              ],
              const SizedBox(height: 24),
              KuberTextField(
                label: l.notesLabel,
                optional: true,
                controller: _notes,
                hint: l.recurringNotesHint,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KuberSaveButton(
        label: _isEdit ? l.msRecSaveChanges : l.msRecSave,
        loading: _saving,
        onPressed: _canSave ? _save : null,
      ),
    );
  }
}
