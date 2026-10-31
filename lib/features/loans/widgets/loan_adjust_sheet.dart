// Loan accuracy: Update outstanding (A3), the "recalculate later EMIs?"
// question for changes dated in the past (A4), and deleting an adjustment or
// an extra payment from its marker in the schedule.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/info_table.dart';
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

void showUpdateOutstandingSheet(BuildContext context, Loan loan, {LoanEvent? existing}) =>
    showMoneySheet<void>(context, _UpdateOutstandingSheet(loan: loan, existing: existing));

/// Kuber's outstanding on [day] from the loan's records: after the EMI and
/// every event on or before it (today: what is owed now).
double outstandingOn(Loan l, LoanRecords r, int day) {
  final a = loanAmortizationWith(l, r);
  if (a == null) return 0;
  final today = todayKey();
  if (day >= today) return loanStatus(l, r.linked, deletedDays: r.deleted).outstanding ?? 0;
  return a.balanceOn(day);
}

class _UpdateOutstandingSheet extends ConsumerStatefulWidget {
  final Loan loan;
  final LoanEvent? existing;
  const _UpdateOutstandingSheet({required this.loan, this.existing});

  @override
  ConsumerState<_UpdateOutstandingSheet> createState() => _UpdateOutstandingSheetState();
}

class _UpdateOutstandingSheetState extends ConsumerState<_UpdateOutstandingSheet> {
  final _amount = TextEditingController();
  late DateTime _date = widget.existing?.date ?? DateUtils.dateOnly(DateTime.now());
  late LoanAdjustReason _reason = widget.existing?.reason ?? LoanAdjustReason.matchBank;
  late LoanAdjust _adjust = widget.existing?.adjust ?? LoanAdjust.tenure;
  bool _saving = false;
  bool _filled = false;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  /// The loan without the adjustment being edited (Kuber's own figures).
  Loan get _base => widget.existing == null
      ? widget.loan
      : (widget.loan.copy()
        ..events = [for (final e in widget.loan.events) if (!identical(e, widget.existing)) e]);

  DateTime get _first {
    final s = widget.loan.loanStartDate ?? widget.loan.schedule?.startDate ?? widget.loan.startDate;
    return DateUtils.dateOnly(s);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final cs = Theme.of(context).colorScheme;
    String m(num v) => fmt.formatCurrency(v.round());
    final rec = ref.watch(loanRecordsProvider(widget.loan.uid));
    final base = _base;
    final day = dayKey(_date);
    final kuber = outstandingOn(base, rec, day);
    if (!_filled && widget.existing != null) {
      _filled = true;
      _amount.text = (kuber + widget.existing!.amount).round().toString();
    }
    final entered = _amount.text.trim().isEmpty ? null : KuberAmountField.valueOf(_amount);
    final check = entered == null ? null : outstandingError(entered);
    final diff = entered == null ? 0.0 : entered - kuber;

    // Preview: the loan with this adjustment.
    final after = entered == null || check == OutstandingCheck.negative
        ? null
        : (base.copy()
          ..events = [
            ...base.events,
            LoanEvent()
              ..kind = LoanEventKind.adjustment
              ..date = _date
              ..amount = diff
              ..reason = _reason
              ..adjust = _adjust,
          ]);
    final a = after == null ? null : loanAmortizationWith(after, rec);
    final next = a?.rows.where((r) => r.day >= day && !r.recorded).firstOrNull;
    final endDay = a == null || a.rows.isEmpty ? null : a.rows.last.day;
    final remaining = a?.rows.where((r) => r.day >= day).fold(0.0, (s, r) => s + r.interest);
    // Keep EMI: the EMI has to cover the month's interest on the new balance.
    final neverEnds = check == OutstandingCheck.ok &&
        _adjust == LoanAdjust.tenure &&
        entered != null &&
        hasLoanNumbers(base) &&
        (next?.principal ?? 1) <= 0 &&
        !(next?.interestOnly ?? false);
    final error = check == OutstandingCheck.negative
        ? l.msLoansAdjErrNegative
        : (neverEnds ? l.msLoansErrNeverEnds : null);
    final canSave = entered != null && error == null && !_saving && diff.abs() >= 0.005;

    return KuberBottomSheet(
      title: l.msLoansUpdateOutstanding,
      description: widget.loan.name,
      actions: Column(mainAxisSize: MainAxisSize.min, children: [
        AppButton(
          label: l.saveLabel,
          type: AppButtonType.primary,
          fullWidth: true,
          isLoading: _saving,
          onPressed: canSave ? () => _save(entered, diff) : null,
        ),
        if (widget.existing != null) ...[
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
        KuberAmountField(
          label: l.msLoansOutstandingPrincipal,
          controller: _amount,
          symbol: fmt.symbol,
          indianGrouping: fmt.system == NumberSystem.indian,
          errorText: error,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DatePickerRow(
          label: l.msLoansAsOn,
          value: fmtDayLong(_date),
          initial: _date,
          first: _first,
          last: DateUtils.dateOnly(DateTime.now()),
          onChanged: (d) => setState(() => _date = d),
        ),
        const SizedBox(height: 16),
        CapsLabel(l.msLoansAdjReason),
        const SizedBox(height: 8),
        KuberSelectCard(
          title: l.msLoansAdjMatchBank,
          subtitle: l.msLoansAdjMatchBankSub,
          selected: _reason == LoanAdjustReason.matchBank,
          onTap: () => setState(() => _reason = LoanAdjustReason.matchBank),
          onInfo: () => showMoneyInfo(context, ref, MoneyInfo.adjustBank),
        ),
        const SizedBox(height: 8),
        KuberSelectCard(
          title: l.msLoansAdjInterestAdded,
          subtitle: l.msLoansAdjInterestAddedSub,
          selected: _reason == LoanAdjustReason.interestAdded,
          onTap: () => setState(() => _reason = LoanAdjustReason.interestAdded),
          onInfo: () => showMoneyInfo(context, ref, MoneyInfo.adjustInterest),
        ),
        const SizedBox(height: 16),
        InfoTable(rows: [
          InfoTableDataRow(label: l.msLoansKuberOutstandingOn(fmtDayShort(_date)), value: m(kuber)),
          InfoTableDataRow(
            label: l.msLoansAdjDifference,
            value: entered == null ? '-' : '${diff >= 0 ? '+' : '-'}${m(diff.abs())}',
          ),
        ]),
        if (hasLoanNumbers(base)) ...[
          const SizedBox(height: 16),
          CapsLabel(l.msLoansExtraChoose),
          const SizedBox(height: 8),
          KuberSelectCard(
            title: l.msLoansKeepEmiChangeEnd,
            subtitle: _adjust == LoanAdjust.tenure && endDay != null
                ? l.msLoansKeepEmiResult(m(next?.payment ?? widget.loan.emiAmount),
                    fmtMonthYear(dayOf(endDay)))
                : l.msLoansEventAdjSubTenure,
            selected: _adjust == LoanAdjust.tenure,
            onTap: () => setState(() => _adjust = LoanAdjust.tenure),
            onInfo: () => showMoneyInfo(context, ref, MoneyInfo.tenureEmi),
          ),
          const SizedBox(height: 8),
          KuberSelectCard(
            title: l.msLoansKeepEndChangeEmi,
            subtitle: _adjust == LoanAdjust.emi && endDay != null && next != null
                ? l.msLoansKeepEndResult(fmtMonthYear(dayOf(endDay)), m(next.payment))
                : l.msLoansEventAdjSubEmi,
            selected: _adjust == LoanAdjust.emi,
            onTap: () => setState(() => _adjust = LoanAdjust.emi),
            onInfo: () => showMoneyInfo(context, ref, MoneyInfo.tenureEmi),
          ),
          if (remaining != null && error == null) ...[
            const SizedBox(height: 16),
            Row(children: [
              // Wraps at large font sizes instead of overflowing.
              Expanded(
                child: Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                  Text(l.msLoansRemainingInterest,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  KuberCalculatedPill(l.msCalculated),
                  KuberInfoGlyph(onTap: () => showMoneyInfo(context, ref, MoneyInfo.remainingInterest)),
                ]),
              ),
              const SizedBox(width: 12),
              Text(m(remaining), style: Theme.of(context).textTheme.titleMedium),
            ]),
          ],
        ],
      ]),
    );
  }

  Future<void> _save(double entered, double diff) async {
    final l = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final nav = Navigator.of(context);
    final loan = widget.loan;
    var close = false;
    if (outstandingError(entered) == OutstandingCheck.closes) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.msLoansAdjZeroTitle, style: localeFont(fontWeight: FontWeight.w600)),
          content: Text(l.msLoansAdjZeroBody, style: localeFont()),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.msLoansAdjSaveOnly)),
            TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msLoansCloseLoan)),
          ],
        ),
      );
      if (ok == null) return;
      close = ok;
    }
    setState(() => _saving = true);
    final service = LoanService(container.read(isarProvider));
    await service.saveAdjustment(loan,
        date: _date, amount: diff, reason: _reason, adjust: _adjust, replace: widget.existing);
    if (close) await service.close(loan);
    container.invalidate(loanListProvider);
    nav.pop();
    final host = nav.context;
    if (!host.mounted) return;
    showKuberSnackBar(host, l.msLoansAdjSaved);
    // An update applies after that day's EMI: EMIs strictly after it.
    await askRecalculate(host, container, loan, addDays(dayKey(_date), 1));
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final container = ProviderScope.containerOf(context, listen: false);
    final nav = Navigator.of(context);
    final ok = await confirmDeleteEvent(context, widget.existing!);
    if (!ok) return;
    await LoanService(container.read(isarProvider)).deleteEvent(widget.loan, widget.existing!);
    container
      ..invalidate(loanListProvider)
      ..invalidate(transactionListProvider);
    nav.pop();
    final host = nav.context;
    if (!host.mounted) return;
    showKuberSnackBar(host, l.msLoansEventDeleted);
    await askRecalculate(host, container, widget.loan, addDays(dayKey(widget.existing!.date!), 1));
  }
}

/// "Delete this update / extra payment?"
Future<bool> confirmDeleteEvent(BuildContext context, LoanEvent e) async {
  final l = context.l10n;
  final cs = Theme.of(context).colorScheme;
  final extra = e.kind == LoanEventKind.prepayment;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(extra ? l.msLoansDeleteExtraTitle : l.msLoansDeleteAdjTitle,
          style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(extra ? l.msLoansDeleteExtraBody : l.msLoansDeleteAdjBody, style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
      ],
    ),
  );
  return ok == true;
}

/// Deletes an extra payment from its marker, then asks A4.
Future<void> deleteExtraPayment(BuildContext context, Loan loan, LoanEvent e) async {
  final l = context.l10n;
  final container = ProviderScope.containerOf(context, listen: false);
  if (!await confirmDeleteEvent(context, e)) return;
  await LoanService(container.read(isarProvider)).deleteEvent(loan, e);
  container
    ..invalidate(loanListProvider)
    ..invalidate(transactionListProvider);
  if (!context.mounted) return;
  showKuberSnackBar(context, l.msLoansEventDeleted);
  await askRecalculate(context, container, loan, dayKey(e.date!));
}

/// A4: after a change dated before EMIs Kuber recorded and the user hasn't
/// edited, offer to split those EMIs again from the new outstanding.
Future<void> askRecalculate(
    BuildContext context, ProviderContainer container, Loan loan, int fromDay) async {
  if (fromDay > todayKey() || !hasLoanNumbers(loan)) return;
  final fresh =
      (await container.read(loanListProvider.future)).where((x) => x.uid == loan.uid).firstOrNull;
  if (fresh == null || !context.mounted) return;
  final isar = container.read(isarProvider);
  final rec = await LoanService.records(isar, fresh.uid);
  final p = LoanService.recalculatePreview(fresh, rec, fromDay);
  if (p.count == 0 || (p.newInterest - p.oldInterest).abs() < 0.01 || !context.mounted) return;
  final l = context.l10n;
  final fmt = container.read(formatterProvider);
  String m(num v) => fmt.formatCurrency(v.round());
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.msLoansRecalcTitle(p.count), style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(l.msLoansRecalcBody(m(p.oldInterest), m(p.newInterest)), style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.msLoansKeepAsIs)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msLoansRecalc)),
      ],
    ),
  );
  if (ok != true) return;
  final n = await LoanService(isar)
      .recalculateSplits(fresh, fromDay, decimals: fmt.currency.decimals);
  container.invalidate(transactionListProvider);
  if (context.mounted) showKuberSnackBar(context, l.msLoansRecalcDone(n));
}
