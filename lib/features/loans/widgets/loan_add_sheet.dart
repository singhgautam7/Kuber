// Add to loan (nov-release A3): money released, charges added or unpaid
// interest, with the keep EMI / keep end date choice once EMIs have started.
// Also edits and deletes them from their marker in the schedule.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/entity_picker_rows.dart';
import '../data/loan.dart';
import '../domain/loan_engine.dart';
import '../domain/loan_service.dart';
import '../providers/loan_provider.dart';
import 'loan_adjust_sheet.dart';

enum _Added { released, charges, interest }

/// New, or editing [release] / [charge] / [interest].
void showAddToLoanSheet(BuildContext context, Loan loan,
        {LoanRelease? release, LoanEvent? charge, LoanEvent? interest}) =>
    showMoneySheet<void>(
        context, _AddToLoanSheet(loan: loan, release: release, charge: charge, interest: interest));

/// "Delete this part?": a part with a transaction also asks about that.
/// Null = cancelled.
Future<bool?> confirmDeletePart(BuildContext context, {required bool hasTransaction}) {
  final l = context.l10n;
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.msLoansDeletePartTitle, style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(hasTransaction ? l.msLoansDeletePartTxnBody : l.msLoansDeletePartBody,
          style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancelLabel)),
        if (hasTransaction)
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.msLoansKeepTxn)),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(hasTransaction ? l.msLoansDeleteTxn : l.deleteLabel,
                style: TextStyle(color: cs.error))),
      ],
    ),
  );
}

class _AddToLoanSheet extends ConsumerStatefulWidget {
  final Loan loan;
  final LoanRelease? release;
  final LoanEvent? charge, interest;
  const _AddToLoanSheet({required this.loan, this.release, this.charge, this.interest});

  @override
  ConsumerState<_AddToLoanSheet> createState() => _AddToLoanSheetState();
}

class _AddToLoanSheetState extends ConsumerState<_AddToLoanSheet> {
  final _amount = TextEditingController();
  late final _note = TextEditingController(text: _existingNote);
  late _Added _kind = widget.charge != null
      ? _Added.charges
      : (widget.interest != null ? _Added.interest : _Added.released);
  late DateTime _date = widget.release?.date ??
      widget.charge?.date ??
      widget.interest?.date ??
      DateUtils.dateOnly(DateTime.now());
  late LoanAdjust _adjust =
      widget.release?.adjust ?? widget.charge?.adjust ?? widget.interest?.adjust ?? LoanAdjust.tenure;
  late int? _accountId = int.tryParse(widget.release?.accountId ?? '');
  bool _saving = false;

  bool get _editing => widget.release != null || widget.charge != null || widget.interest != null;
  String? get _existingNote =>
      widget.release?.note ?? widget.charge?.note ?? widget.interest?.note;

  @override
  void initState() {
    super.initState();
    final v = widget.release?.amount ?? widget.charge?.amount ?? widget.interest?.amount;
    if (v != null) _amount.text = v.round().toString();
  }

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
    super.dispose();
  }

  double get _value => KuberAmountField.valueOf(_amount);
  String? get _noteText => _note.text.trim().isEmpty ? null : _note.text.trim();

  /// The first day it can be dated: the loan's start.
  DateTime get _first {
    final l = widget.loan;
    final starts = loanReleases(l).first.date ?? l.schedule?.startDate ?? l.startDate;
    return DateUtils.dateOnly(starts);
  }

  LoanRelease _release() => LoanRelease()
    ..date = _date
    ..amount = _value
    ..accountId = _accountId?.toString()
    ..transactionId = widget.release?.transactionId
    ..adjust = _adjust
    ..note = _noteText;

  LoanEvent _event() => LoanEvent()
    ..kind = _kind == _Added.interest ? LoanEventKind.adjustment : LoanEventKind.chargeAdded
    ..reason = _kind == _Added.interest ? LoanAdjustReason.interestAdded : LoanAdjustReason.matchBank
    ..date = _date
    ..amount = _value
    ..adjust = _adjust;

  /// The loan with this entry, for the live preview.
  Loan _after() {
    final c = widget.loan.copy();
    if (_kind == _Added.released) {
      final index = widget.loan.releases.indexOf(widget.release ?? LoanRelease());
      final kept = [
        for (final (i, r) in LoanService.partsOf(widget.loan).indexed)
          if (index < 0 || i != index) r,
      ];
      c
        ..releases = ([...kept, _release()]..sort((a, b) => a.date!.compareTo(b.date!)))
        ..releasedInParts = true;
    } else {
      c.events = [
        for (final e in widget.loan.events)
          if (!identical(e, widget.charge) && !identical(e, widget.interest)) e,
        _event(),
      ];
    }
    return c;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    String m(num v) => fmt.formatCurrency(v.round());
    final loan = widget.loan;
    final rec = ref.watch(loanRecordsProvider(loan.uid));
    final day = dayKey(_date);
    final firstEmi = loanEmiDays(loan).firstOrNull;
    final afterEmis = firstEmi != null && day >= firstEmi && hasLoanNumbers(loan);
    final preview = afterEmis && _value > 0 ? loanAmortizationWith(_after(), rec) : null;
    final next = preview?.rows.where((r) => r.day >= day && !r.recorded).firstOrNull;
    final endDay = preview == null || preview.rows.isEmpty ? null : preview.rows.last.day;
    final neverEnds = preview != null && _adjust == LoanAdjust.tenure && loanNeverEnds(preview);
    final canSave = _value > 0 && !_saving && !neverEnds;

    KuberSelectCard card(_Added k, String title, String sub, MoneyInfo info) => KuberSelectCard(
          title: title,
          subtitle: sub,
          selected: _kind == k,
          onTap: () => setState(() => _kind = k),
          onInfo: () => showMoneyInfo(context, ref, info),
        );

    return KuberBottomSheet(
      title: l.msLoansAddToLoan,
      description: loan.name,
      actions: Column(mainAxisSize: MainAxisSize.min, children: [
        AppButton(
          label: l.saveLabel,
          type: AppButtonType.primary,
          fullWidth: true,
          isLoading: _saving,
          onPressed: canSave ? _save : null,
        ),
        if (_editing) ...[
          const SizedBox(height: 8),
          AppButton(
            label: l.deleteLabel,
            type: AppButtonType.danger,
            fullWidth: true,
            onPressed: _saving ? null : _delete,
          ),
        ],
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (!_editing) ...[
          CapsLabel(l.msLoansWhatAdded),
          const SizedBox(height: 8),
          card(_Added.released, l.msLoansAddReleased, l.msLoansAddReleasedSub, MoneyInfo.addReleased),
          const SizedBox(height: 8),
          card(_Added.charges, l.msLoansAddCharges, l.msLoansAddChargesSub, MoneyInfo.addCharges),
          const SizedBox(height: 8),
          card(_Added.interest, l.msLoansAddInterest, l.msLoansAddInterestSub, MoneyInfo.addInterest),
          const SizedBox(height: 16),
        ],
        KuberAmountField(
          label: l.msRecAmount,
          controller: _amount,
          symbol: fmt.symbol,
          indianGrouping: fmt.system == NumberSystem.indian,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        DatePickerRow(
          label: l.msInvDate,
          value: fmtDayLong(_date),
          initial: _date,
          first: _first,
          last: DateUtils.dateOnly(DateTime.now()),
          onChanged: (d) => setState(() => _date = d),
        ),
        if (_kind == _Added.released) ...[
          const SizedBox(height: 10),
          AccountPickerRow(
            label: l.msLoansReceivedInShort,
            selectedId: _accountId,
            noneLabel: l.msLoansNotRecorded,
            onNone: () => setState(() => _accountId = null),
            onChanged: (id) => setState(() => _accountId = id),
          ),
        ],
        const SizedBox(height: 12),
        KuberTextField(label: l.msLoansNote, controller: _note, optional: true),
        if (afterEmis) ...[
          const SizedBox(height: 16),
          LoanKeepChoice(
            value: _adjust,
            onChanged: (v) => setState(() => _adjust = v),
            emiText: m(next?.payment ?? loan.emiAmount),
            nextEmiText: next == null ? null : m(next.payment),
            endText: endDay == null ? null : fmtMonthYear(dayOf(endDay)),
          ),
          if (neverEnds) ...[
            const SizedBox(height: 8),
            KuberCallout.text(l.msLoansErrNeverEnds, tone: KuberCalloutTone.error),
          ],
        ],
      ]),
    );
  }

  Future<void> _save() async {
    final l = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final nav = Navigator.of(context);
    final fmt = container.read(formatterProvider);
    final loan = widget.loan;
    var grow = false;
    if (_kind == _Added.released) {
      final total = _after().releases.fold(0.0, (s, r) => s + r.amount);
      if (total > loan.principalAmount + 0.005 &&
          loan.startingPoint != LoanStartingPoint.outstandingToday) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            content: Text(l.msLoansAboveSanctioned(fmt.formatCurrency(loan.principalAmount.round())),
                style: localeFont()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msLoansIncrease)),
            ],
          ),
        );
        if (ok != true) return;
        grow = true;
      }
    }
    setState(() => _saving = true);
    final service = LoanService(container.read(isarProvider));
    if (_kind == _Added.released) {
      await service.saveRelease(loan, _release(), replace: widget.release, growSanctioned: grow);
    } else {
      await service.saveAddition(loan,
          interest: _kind == _Added.interest,
          date: _date,
          amount: _value,
          adjust: _adjust,
          note: _noteText,
          replace: widget.charge ?? widget.interest);
    }
    container
      ..invalidate(loanListProvider)
      ..invalidate(transactionListProvider);
    nav.pop();
    final host = nav.context;
    if (!host.mounted) return;
    showKuberSnackBar(host, l.msLoansAddedSaved);
    // Unpaid interest applies after that day's EMI, like Update outstanding.
    final from = _kind == _Added.interest ? addDays(dayKey(_date), 1) : dayKey(_date);
    await askRecalculate(host, container, loan, from);
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final nav = Navigator.of(context);
    final service = LoanService(container.read(isarProvider));
    final r = widget.release;
    if (r != null) {
      final choice = await confirmDeletePart(context, hasTransaction: r.transactionId != null);
      if (choice == null) return;
      await service.deleteRelease(widget.loan, r, deleteTransaction: choice);
    } else {
      final e = (widget.charge ?? widget.interest)!;
      if (!await confirmDeleteEvent(context, e)) return;
      await service.deleteEvent(widget.loan, e);
    }
    container
      ..invalidate(loanListProvider)
      ..invalidate(transactionListProvider);
    nav.pop();
    final host = nav.context;
    if (!host.mounted) return;
    showKuberSnackBar(host, l.msLoansPartDeleted);
    await askRecalculate(host, container, widget.loan, dayKey(_date));
  }
}
