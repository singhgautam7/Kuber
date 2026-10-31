// Loan sheet -> full screen (design L.5), extra payment and rate change
// (L.6), close and delete.

import 'package:flutter/material.dart';

import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/background/background_run_controller.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/money_math/loan_math.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart' show CurrencyInputFormatter;
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/money_bar_chart.dart';
import '../../../shared/widgets/money_info_sheets.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tools/widgets/calculator_line_chart.dart';
import '../../tools/widgets/calculator_support.dart' show CalculatorPrefill;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/entity_picker_rows.dart';
import '../data/loan.dart';
import '../domain/loan_engine.dart';
import '../domain/loan_service.dart';
import '../providers/loan_provider.dart';
import 'loan_adjust_sheet.dart';

void showLoanSheet(BuildContext context, WidgetRef ref, Loan loan) =>
    showMoneySheet<void>(context, LoanSheet(loan: loan));

Future<bool> confirmDeleteLoan(BuildContext context, WidgetRef ref, Loan loan) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  final l = context.l10n;
  final cs = Theme.of(context).colorScheme;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.deleteLoanConfirm, style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(l.deleteLoanBody, style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
        TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
      ],
    ),
  );
  if (ok != true) return false;
  await container.read(loanListProvider.notifier).deleteLoan(loan);
  return true;
}

Future<void> _closeLoan(BuildContext context, WidgetRef ref, Loan loan) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.msLoansCloseTitle(loan.name), style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(l.msLoansCloseBody, style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msLoansCloseLoan)),
      ],
    ),
  );
  if (ok != true) return;
  await LoanService(container.read(isarProvider)).close(loan);
  container.invalidate(loanListProvider);
}

/// Calculator links for every loan. A loan without its numbers fills what
/// it has (principal and rate entered before vNext, the EMI count from its
/// schedule) and leaves the rest for the user.
List<CalculatorLink> loanCalculatorLinks(BuildContext context, Loan loan, LoanStatus st) {
  final l = context.l10n;
  final numbers = hasLoanNumbers(loan);
  final principal = loan.principalAmount > 0 ? loan.principalAmount : null;
  final baseRate = loan.annualRate ?? loan.interestRate;
  final rateNow = numbers
      ? loanAmortization(loan)?.rows.where((r) => r.day > todayKey()).firstOrNull?.rate
      : null;
  final rate = rateNow ?? (baseRate != null && baseRate > 0 ? baseRate : null);
  final months = loan.tenureMonths ?? st.totalEmis;
  final left = st.totalEmis == null ? null : st.totalEmis! - st.emisPaid;
  final outstanding = st.outstanding ?? principal;
  String text(num? v) => v == null ? '' : '$v';
  return [
    CalculatorLink(l.msCalcEmi, () {
      Navigator.of(context, rootNavigator: true).maybePop();
      context.push('/more/tools/emi-calculator',
          extra: CalculatorPrefill(loan.name, {
            'principal': text(principal?.round()),
            'rate': text(baseRate != null && baseRate > 0 ? baseRate : null),
            'tenure': months == null ? '' : (months % 12 == 0 ? '${months ~/ 12}' : '$months'),
            'tenureUnit': months == null || months % 12 == 0 ? 0 : 1,
          }));
    }),
    CalculatorLink(l.msCalcPrepay, () {
      Navigator.of(context, rootNavigator: true).maybePop();
      context.push('/more/tools/loan-prepayment',
          extra: CalculatorPrefill(loan.name, {
            'amount': text(outstanding?.round()),
            'rate': text(rate),
            'tenure': left == null ? '' : '${(left / 12).ceil()}',
            'prepay': '0',
          }));
    }),
  ];
}

Future<void> _reopenLoan(BuildContext context, WidgetRef ref, Loan loan) async {
  // Sheets close before their actions finish: take the container now,
  // not the sheet's ref (disposed after the first await).
  final container = ProviderScope.containerOf(context, listen: false);
  final l = context.l10n;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.msLoansReopenTitle(loan.name), style: localeFont(fontWeight: FontWeight.w600)),
      content: Text(l.msLoansReopenBody, style: localeFont()),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancelLabel)),
        TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.msLoansReopen)),
      ],
    ),
  );
  if (ok != true) return;
  await LoanService(container.read(isarProvider)).reopen(loan);
  container.invalidate(loanListProvider);
}

/// The loan type's icon (same set as the type chips in the loan form).
IconData loanTypeIcon(String t) => switch (t) {
      'home' => Icons.home_rounded,
      'vehicle' => Icons.directions_car_rounded,
      'personal' => Icons.person_rounded,
      'education' => Icons.school_rounded,
      'credit_card' => Icons.credit_card_rounded,
      _ => Icons.account_balance_rounded,
    };

/// A loan's icon, drawn like a category (tinted square, filled glyph) in its
/// category's colour, the same as recurring rows.
class LoanIcon extends ConsumerWidget {
  final Loan loan;
  final double size;
  const LoanIcon(this.loan, {super.key, this.size = 40});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cat = ref.watch(categoryMapProvider).valueOrNull?[int.tryParse(loan.categoryId)];
    return CategoryIcon.square(
        icon: loanTypeIcon(loan.loanType), rawColor: Color(cat?.colorValue ?? 0xFF5C6BC0), size: size);
  }
}

String _loanTypeLabel(BuildContext context, String t) {
  final l = context.l10n;
  return switch (t) {
    'home' => l.loanTypeHome,
    'vehicle' => l.loanTypeVehicle,
    'personal' => l.loanTypePersonal,
    'education' => l.loanTypeEducation,
    'credit_card' => l.creditCardLabel,
    _ => l.loanTypeOther,
  };
}

class LoanSheet extends ConsumerWidget {
  final Loan loan;
  const LoanSheet({super.key, required this.loan});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final rec = ref.watch(loanRecordsProvider(loan.uid));
    final txns = rec.linked;
    final st = loanStatus(loan, txns, deletedDays: rec.deleted);
    String m(num v) => fmt.formatCurrency(v.round());
    final nav = Navigator.of(context);
    final row = st.nextRow;
    return MoneySummarySheet(
      contextLabel: [_loanTypeLabel(context, loan.loanType), if (loan.lenderName.isNotEmpty) loan.lenderName]
          .join(' · '),
      title: loan.name,
      leading: LoanIcon(loan, size: 48),
      body: [
        if (st.outstanding != null)
          MoneyHeadline(label: l.msLoansOutstanding, value: m(st.outstanding!))
        else
          MoneyHeadline(label: l.msLoansEmi, value: m(loan.emiAmount)),
        if (st.totalEmis != null)
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            KuberLinearProgress(value: st.progress),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(
                  child: Text(l.msLoansProgress('${st.emisPaid}', '${st.totalEmis}'),
                      style: Theme.of(context).textTheme.bodySmall)),
              if (st.endDay != null)
                Text(l.msLoansEndsOn(fmtMonthYear(dayOf(st.endDay!))),
                    style: Theme.of(context).textTheme.bodySmall),
            ]),
          ]),
        if (st.nextDay != null && !st.closed)
          MoneyNextBlock(
            caption: l.msLoansNextEmi(fmtDayShort(dayOf(st.nextDay!))),
            child: row == null
                ? Text(m(st.nextAmount ?? loan.emiAmount), style: Theme.of(context).textTheme.titleMedium)
                : EmiSplitBar(
                    principal: row.principal,
                    interest: row.interest,
                    principalText: m(row.principal),
                    interestText: m(row.interest),
                    title: row.interestOnly ? l.msLoansInterestOnly : l.msLoansSplit,
                    totalText: m(row.payment),
                  ),
          ),
        if (st.totalInterest != null)
          KvGrid(items: [
            KvItem(l.msLoansTotalInterest, m(st.totalInterest!)),
            KvItem(l.msLoansInterestPaid, m(st.interestPaid ?? 0)),
            KvItem(l.msLoansPrincipalPaid, m(st.principalPaid ?? 0)),
            if (st.addedInterest > 0) KvItem(l.msLoansInterestAdded, m(st.addedInterest)),
          ]),
        if (loanCalculatorLinks(context, loan, st).isNotEmpty)
          CalculatorLinkChips(links: loanCalculatorLinks(context, loan, st)),
      ],
      // Primary: the EMI schedule. Row: Record extra payment (Re-open loan
      // once closed) + overflow (Edit, Change interest rate, Close loan,
      // Delete; closed: Edit, Delete).
      actions: [
        if (!st.closed)
          SheetAction(
              label: l.msLoansRecordExtra,
              icon: Icons.payments_outlined,
              onPressed: () {
                nav.pop();
                showExtraPaymentSheet(context, ref, loan);
              })
        else
          SheetAction(
              label: l.msLoansReopen,
              icon: Icons.replay_rounded,
              onPressed: () {
                nav.pop();
                _reopenLoan(context, ref, loan);
              }),
        SheetAction(
            label: l.editLabel,
            icon: Icons.edit_outlined,
            overflowOnly: true,
            onPressed: () {
              nav.pop();
              if (blockIfProcessing(context, ref, 'loan:${loan.uid}')) return;
              context.push('/loans/edit', extra: loan);
            }),
        if (!st.closed && hasLoanNumbers(loan))
          SheetAction(
              label: l.msLoansUpdateOutstanding,
              icon: Icons.edit_note_rounded,
              overflowOnly: true,
              onPressed: () {
                nav.pop();
                showUpdateOutstandingSheet(context, loan);
              }),
        if (!st.closed && hasLoanNumbers(loan))
          SheetAction(
              label: l.msLoansChangeRate,
              icon: Icons.percent_rounded,
              overflowOnly: true,
              onPressed: () {
                nav.pop();
                showRateChangeSheet(context, ref, loan);
              }),
        if (!st.closed)
          SheetAction(
              label: l.msLoansCloseLoan,
              icon: Icons.task_alt_rounded,
              overflowOnly: true,
              onPressed: () {
                nav.pop();
                _closeLoan(context, ref, loan);
              }),
        SheetAction(
            label: l.deleteLabel,
            icon: Icons.delete_outline_rounded,
            destructive: true,
            overflowOnly: true,
            onPressed: () {
              nav.pop();
              confirmDeleteLoan(context, ref, loan);
            }),
      ],
      details: (_) => LoanFullScreen(loan: loan),
      detailsLabel: l.msLoansViewSchedule,
      detailsAsPrimary: true,
    );
  }
}

enum _RowState { before, paid, next, upcoming }

class LoanFullScreen extends ConsumerStatefulWidget {
  final Loan loan;
  const LoanFullScreen({super.key, required this.loan});

  @override
  ConsumerState<LoanFullScreen> createState() => _LoanFullScreenState();
}

class _LoanFullScreenState extends ConsumerState<LoanFullScreen> {
  bool _splitChart = false;
  bool _years = false;
  int? _page; // Month view: the calendar year shown (null = next EMI's year)
  final _nextKey = GlobalKey();
  final _pagerKey = GlobalKey();

  void _goTo(int year) {
    setState(() => _page = year);
    // From the bottom pager, start the new year at its first month.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _pagerKey.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 250));
    });
  }
  bool _scrolled = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    // The stored loan (an update from this page adds events to it).
    final loan = ref
            .watch(loanListProvider)
            .valueOrNull
            ?.where((x) => x.uid == widget.loan.uid)
            .firstOrNull ??
        widget.loan;
    final rec = ref.watch(loanRecordsProvider(loan.uid));
    final txns = rec.linked;
    final st = loanStatus(loan, txns, deletedDays: rec.deleted);
    final a = loanAmortization(loan, linked: txns, deletedDays: rec.deleted);
    final today = todayKey();
    final tracking = trackingDay(loan);
    String m(num v) => fmt.formatCurrency(v.round());

    if (!_scrolled) {
      _scrolled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _nextKey.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx, alignment: 0.12);
      });
    }

    final txnByDay = <int, Transaction>{
      for (final t in txns.where(isEmiTransaction)) t.occurrenceDate ?? dayKey(t.createdAt): t,
    };
    _RowState stateOf(int day) {
      if (loan.alreadyRunning && day < tracking) return _RowState.before;
      if (day <= today) return _RowState.paid;
      if (day == st.nextDay) return _RowState.next;
      return _RowState.upcoming;
    }

    // Schedule rows: amortization when the loan has numbers, else the dates.
    final sched = loan.schedule;
    final rows = a?.rows ??
        [
          if (sched != null)
          for (final o in upcomingOccurrences(
              sched.copy()
                ..processedThrough = 0
                ..postedCount = 0,
              limit: 600))
            AmortRow(
                index: 0,
                day: o.day,
                payment: loan.emiAmount,
                principal: 0,
                interest: 0,
                balance: 0,
                rate: 0,
                interestOnly: false),
        ];

    Widget monthRow(AmortRow r) {
      final s = stateOf(r.day);
      final txn = txnByDay[r.day];
      final muted = s == _RowState.before;
      final color = muted ? cs.onSurfaceVariant : cs.onSurface;
      final icon = switch (s) {
        _RowState.before => Icons.history_rounded,
        _RowState.paid => Icons.check_circle_rounded,
        _RowState.next => Icons.radio_button_checked_rounded,
        _RowState.upcoming => Icons.radio_button_unchecked_rounded,
      };
      final iconColor = switch (s) {
        _RowState.before => cs.onSurfaceVariant,
        _RowState.paid => context.kuberMoney.income,
        _RowState.next => cs.primary,
        _RowState.upcoming => cs.outlineVariant,
      };
      return Container(
        key: s == _RowState.next ? _nextKey : null,
        color: s == _RowState.next
            ? cs.primary.withValues(alpha: Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.06)
            : null,
        child: InkWell(
          onTap: s == _RowState.paid && txn != null
              ? () => showTransactionDetailSheet(context, ref, txn)
              : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Text(fmtMonthYear(dayOf(r.day)), style: tt.titleSmall!.copyWith(color: color)),
                      if (s == _RowState.before) ...[
                        const SizedBox(width: 6),
                        Text(l.msLoansBeforeKuber,
                            style: tt.labelSmall!.copyWith(color: cs.onSurfaceVariant)),
                      ],
                      if (s == _RowState.next) ...[
                        const SizedBox(width: 6),
                        KuberPill(label: l.msLoansNext, tone: KuberTone.primary),
                      ],
                      if (r.edited) ...[
                        const SizedBox(width: 6),
                        KuberPill(label: l.msTxnEdited, tone: KuberTone.neutral),
                      ],
                    ]),
                    if (a != null)
                      Text(
                          r.interestOnly
                              ? l.msLoansInterestOnly
                              : l.msLoansRowSplit(m(r.principal), m(r.interest)),
                          style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(m(r.payment), style: tt.titleSmall!.copyWith(color: color)),
                  if (a != null)
                    Text(l.msLoansRowBal(m(r.balance)),
                        style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ]),
                if (s == _RowState.paid && txn != null)
                  Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant)
                else
                  const SizedBox(width: 20),
              ]),
            ),
          ),
        ),
      );
    }

    // Adjustments and extra payments open their edit / delete from here.
    Widget eventRow(IconData icon, String title, String sub, {VoidCallback? onTap}) => Material(
          color: cs.surfaceContainerHigh,
          child: InkWell(
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(minHeight: 56),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                Icon(icon, size: 20, color: cs.secondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(title, style: tt.titleSmall),
                    if (sub.isNotEmpty)
                      Text(sub, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
                if (onTap != null) Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
              ]),
            ),
          ),
        );

    final events = [...loan.events]..sort((x, y) => x.date!.compareTo(y.date!));
    // Month view is paged by calendar year; events sit in their row's year.
    final monthByYear = <int, List<Widget>>{};
    var ev = 0;
    double rateBefore = loan.annualRate ?? 0;
    void addEvent(LoanEvent e, AmortRow r, List<Widget> monthChildren) {
      final d = fmtDayShort(e.date!);
      switch (e.kind) {
        case LoanEventKind.prepayment:
          monthChildren.add(eventRow(
              Icons.payments_rounded,
              l.msLoansEventExtra(m(e.amount), d),
              a == null
                  ? ''
                  : (e.adjust == LoanAdjust.tenure
                      ? l.msLoansEventExtraSubTenure(m(a.balanceOn(dayKey(e.date!))))
                      : l.msLoansEventExtraSubEmi(m(a.balanceOn(dayKey(e.date!))))),
              onTap: st.closed ? null : () => deleteExtraPayment(context, loan, e)));
        case LoanEventKind.rateChange:
          final newRate = e.newRate ?? rateBefore;
          monthChildren.add(eventRow(
              Icons.percent_rounded,
              l.msLoansEventRate(fmt.formatPercentage(rateBefore), fmt.formatPercentage(newRate), d),
              e.adjust == LoanAdjust.tenure
                  ? l.msLoansEventRateSubTenure(m(r.payment))
                  : l.msLoansEventRateSubEmi(m(r.payment))));
          rateBefore = newRate;
        case LoanEventKind.charge:
          monthChildren.add(eventRow(Icons.receipt_long_rounded, l.msLoansEventCharge(m(e.amount), d), ''));
        case LoanEventKind.adjustment:
          final signed = '${e.amount >= 0 ? '+' : '-'}${m(e.amount.abs())}';
          monthChildren.add(eventRow(
              e.reason == LoanAdjustReason.interestAdded
                  ? Icons.add_card_rounded
                  : Icons.edit_note_rounded,
              e.reason == LoanAdjustReason.interestAdded
                  ? l.msLoansEventInterestAdded(m(e.amount), d)
                  : l.msLoansEventAdjusted(signed, d),
              e.adjust == LoanAdjust.tenure ? l.msLoansEventAdjSubTenure : l.msLoansEventAdjSubEmi,
              onTap: st.closed ? null : () => showUpdateOutstandingSheet(context, loan, existing: e)));
      }
    }

    for (final r in rows) {
      final monthChildren = monthByYear.putIfAbsent(r.day ~/ 10000, () => []);
      // Adjustments apply after that day's EMI (loan_engine afterEmi), so
      // their marker goes below the row; other events go above it.
      bool sameDayAdjustment(LoanEvent e) =>
          dayKey(e.date!) == r.day && e.kind == LoanEventKind.adjustment;
      while (ev < events.length &&
          dayKey(events[ev].date!) <= r.day &&
          !sameDayAdjustment(events[ev])) {
        addEvent(events[ev++], r, monthChildren);
      }
      if (loan.interestType == LoanInterestType.interestOnlyFirst &&
          a != null &&
          r.index == loan.interestOnlyMonths + 1) {
        monthChildren.add(eventRow(Icons.play_circle_outline_rounded,
            l.msLoansEventRegular(fmtDayShort(dayOf(r.day))), ''));
      }
      monthChildren.add(monthRow(r));
      while (ev < events.length && dayKey(events[ev].date!) == r.day) {
        addEvent(events[ev++], r, monthChildren);
      }
    }

    // Year rows.
    final byYear = <int, List<AmortRow>>{};
    for (final r in rows) {
      byYear.putIfAbsent(r.day ~/ 10000, () => []).add(r);
    }
    final thisYear = today ~/ 10000;
    final yearChildren = [
      for (final e in byYear.entries)
        Container(
          color: e.key == thisYear ? cs.primary.withValues(alpha: 0.06) : null,
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${e.key}', style: tt.titleSmall),
                  Text(
                      l.msLoansYearSub('${e.value.length}',
                          '${e.value.where((r) => r.day <= today).length}'),
                      style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ]),
              ),
              if (a != null)
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(m(e.value.last.balance), style: tt.titleSmall),
                  Text(l.msLoansYearEnd, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                ]),
            ]),
            if (a != null) ...[
              const SizedBox(height: 8),
              Opacity(
                opacity: loan.alreadyRunning && e.key < tracking ~/ 10000 ? 0.5 : 1,
                child: EmiSplitBar(
                  principal: e.value.fold(0.0, (s, r) => s + r.principal),
                  interest: e.value.fold(0.0, (s, r) => s + r.interest),
                  principalText: m(e.value.fold(0.0, (s, r) => s + r.principal)),
                  interestText: m(e.value.fold(0.0, (s, r) => s + r.interest)),
                ),
              ),
            ],
          ]),
        ),
    ];

    final years = byYear.keys.toList();
    final nextYear = (st.nextDay ?? today) ~/ 10000;
    final pageYear = _page ??
        (years.contains(nextYear) ? nextYear : (nextYear > years.last ? years.last : years.first));
    final pageIndex = years.indexOf(pageYear);
    Widget pager({Key? key}) => Row(key: key, children: [
          AppIconButton(
            icon: Icons.chevron_left_rounded,
            semanticLabel: l.msLoansPrevYear,
            onPressed: pageIndex > 0 ? () => _goTo(years[pageIndex - 1]) : null,
          ),
          // Tap the year to jump to any year.
          Expanded(
            child: Builder(
              builder: (anchor) => InkWell(
                borderRadius: KuberShape.mediumR,
                onTap: () async {
                  final y = await showKuberMenu<int>(
                    context: anchor,
                    minWidth: 140,
                    entries: [
                      for (final y in years)
                        KuberMenuEntry<int>(value: y, label: '$y', selected: y == pageYear),
                    ],
                  );
                  if (y != null && y != pageYear) _goTo(y);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('$pageYear', style: tt.titleSmall),
                      Icon(Icons.arrow_drop_down_rounded, size: 20, color: cs.onSurfaceVariant),
                    ]),
                    Text(l.msLoansPageOf('${pageIndex + 1}', '${years.length}'),
                        style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ),
              ),
            ),
          ),
          AppIconButton(
            icon: Icons.chevron_right_rounded,
            semanticLabel: l.msLoansNextYear,
            onPressed: pageIndex < years.length - 1
                ? () => _goTo(years[pageIndex + 1])
                : null,
          ),
        ]);
    final chart = a == null
        ? null
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            KuberSegmented<bool>(
              groupValue: _splitChart,
              onChanged: (v) => setState(() => _splitChart = v),
              segments: [
                KuberSegment(value: false, label: l.msLoansOutstandingTab),
                KuberSegment(value: true, label: l.msLoansSplitTab),
              ],
            ),
            const SizedBox(height: 16),
            if (!_splitChart)
              ToolLineChart(
                height: 132,
                xLabels: [for (final y in years) "'${y % 100}"],
                series: [
                  ChartSeries(
                    name: l.msLoansOutstanding,
                    points: [for (final y in years) byYear[y]!.last.balance],
                    color: cs.primary,
                    fill: true,
                  ),
                ],
              )
            else
              MoneyBarChart(
                bars: [
                  for (final y in years)
                    MoneyBar("'${y % 100}", [
                      byYear[y]!.fold(0.0, (s, r) => s + r.principal),
                      byYear[y]!.fold(0.0, (s, r) => s + r.interest),
                    ])
                ],
                colors: [cs.primary, interestColor(context)],
                fadeFrom: years.indexOf(thisYear) + 1,
              ),
          ]);

    return MoneyFullScreen(
      title: loan.name,
      overflow: [
        PopupMenuItem(
            value: () => context.push('/loans/edit', extra: loan), child: Text(l.editLabel)),
        if (!st.closed)
          PopupMenuItem(value: () => _closeLoan(context, ref, loan), child: Text(l.msLoansCloseLoan)),
        PopupMenuItem(
            value: () => confirmDeleteLoan(context, ref, loan).then((ok) {
                  if (ok && context.mounted) Navigator.of(context).pop();
                }),
            child: Text(l.deleteLabel, style: TextStyle(color: cs.error))),
      ],
      identity: MoneyIdentity(
        tile: LoanIcon(loan, size: 48),
        contextLabel: _loanTypeLabel(context, loan.loanType),
        headline: st.outstanding != null ? m(st.outstanding!) : m(loan.emiAmount),
        caption: st.totalEmis == null ? null : l.msLoansProgress('${st.emisPaid}', '${st.totalEmis}'),
        below: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (st.totalEmis != null) KuberLinearProgress(value: st.progress),
          if (st.totalInterest != null) ...[
            const SizedBox(height: 16),
            KvGrid(items: [
              KvItem(l.msLoansTotalInterest, m(st.totalInterest!)),
              KvItem(l.msLoansInterestPaid, m(st.interestPaid ?? 0)),
              KvItem(l.msLoansPrincipalPaid, m(st.principalPaid ?? 0)),
              if (st.addedInterest > 0) KvItem(l.msLoansInterestAdded, m(st.addedInterest)),
            ]),
          ],
        ]),
      ),
      chart: chart,
      list: [
        KuberSegmented<bool>(
          groupValue: _years,
          onChanged: (v) => setState(() => _years = v),
          segments: [
            KuberSegment(value: false, label: l.msLoansMonth),
            KuberSegment(value: true, label: l.msLoansYear),
          ],
        ),
        const SizedBox(height: 12),
        if (_years)
          KuberGroup(children: yearChildren)
        else ...[
          if (years.length > 1) pager(key: _pagerKey),
          const SizedBox(height: 8),
          KuberGroup(children: monthByYear[pageYear] ?? const []),
          if (years.length > 1) ...[const SizedBox(height: 8), pager()],
        ],
      ],
    );
  }
}

// ── Extra payment (L.6) ────────────────────────────────────────────────

void showExtraPaymentSheet(BuildContext context, WidgetRef ref, Loan loan) =>
    showMoneySheet<void>(context, _ExtraPaymentSheet(loan: loan));

class _ExtraPaymentSheet extends ConsumerStatefulWidget {
  final Loan loan;
  const _ExtraPaymentSheet({required this.loan});

  @override
  ConsumerState<_ExtraPaymentSheet> createState() => _ExtraPaymentSheetState();
}

class _ExtraPaymentSheetState extends ConsumerState<_ExtraPaymentSheet> {
  final _amount = TextEditingController();
  final _charge = TextEditingController();
  bool _principal = true;
  bool _chargePct = false;
  LoanAdjust _reduce = LoanAdjust.tenure;
  late int? _accountId = int.tryParse(widget.loan.accountId);
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  bool _saving = false;

  @override
  void dispose() {
    _amount.dispose();
    _charge.dispose();
    super.dispose();
  }

  double get _amountValue => KuberAmountField.valueOf(_amount);
  double get _chargeValue {
    final v = double.tryParse(_charge.text.replaceAll(',', '')) ?? 0;
    return _chargePct ? _amountValue * v / 100 : v;
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    final indian = fmt.system == NumberSystem.indian;
    String m(num v) => fmt.formatCurrency(v.round());
    final loan = widget.loan;
    final rec = ref.watch(loanRecordsProvider(loan.uid));
    final tenurePreview =
        LoanService.extraPaymentPreview(loan, _amountValue, LoanAdjust.tenure, _date, records: rec);
    final emiPreview =
        LoanService.extraPaymentPreview(loan, _amountValue, LoanAdjust.emi, _date, records: rec);
    final preview = !_principal ? null : (_reduce == LoanAdjust.tenure ? tenurePreview : emiPreview);
    final st = loanStatus(loan, rec.linked, deletedDays: rec.deleted);
    final emiNow = st.nextAmount ?? loan.emiAmount;
    final motion = KuberMotion.reduced(context) ? Duration.zero : const Duration(milliseconds: 250);
    return KuberBottomSheet(
      title: l.msLoansExtraTitle,
      description: loan.name,
      actions: AppButton(
        label: l.saveLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        isLoading: _saving,
        onPressed: _amountValue <= 0 || _accountId == null
            ? null
            : () async {
                setState(() => _saving = true);
                await LoanService(ref.read(isarProvider)).recordExtraPayment(loan,
                    amount: _amountValue,
                    towardPrincipal: _principal,
                    reduce: _reduce,
                    charge: _principal ? _chargeValue : 0,
                    accountId: '$_accountId',
                    date: _date);
                ref.invalidate(loanListProvider);
                ref.invalidate(transactionListProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showKuberSnackBar(context, l.msLoansExtraSaved);
                }
              },
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        KuberAmountField(
          label: l.msRecAmount,
          controller: _amount,
          symbol: fmt.symbol,
          indianGrouping: indian,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 16),
        CapsLabel(l.msLoansExtraQ),
        const SizedBox(height: 8),
        KuberSegmented<bool>(
          groupValue: _principal,
          onChanged: (v) => setState(() => _principal = v),
          segments: [
            KuberSegment(value: true, label: l.msLoansExtraYes),
            KuberSegment(value: false, label: l.msLoansExtraNo),
          ],
        ),
        const SizedBox(height: 16),
        // Principal options fade and resize in; the fee notice replaces them.
        AnimatedSize(
          duration: motion,
          curve: Curves.easeInOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: motion,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: _principal
                ? Column(
                    key: const ValueKey(true),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      CapsLabel(l.msLoansExtraChoose),
                      Text(l.msLoansExtraHelp, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      KuberSelectCard(
                        title: l.msLoansReduceTenure,
                        subtitle: tenurePreview == null
                            ? l.msLoansReduceTenureHow(m(emiNow))
                            : l.msLoansReduceTenureResult(m(emiNow),
                                fmtMonthYear(dayOf(tenurePreview.endDay)), '${tenurePreview.monthsSooner}'),
                        pill: l.msLoansSavesMore,
                        selected: _reduce == LoanAdjust.tenure,
                        onTap: () => setState(() => _reduce = LoanAdjust.tenure),
                        onInfo: () => showMoneyInfo(context, ref, MoneyInfo.tenureEmi),
                      ),
                      const SizedBox(height: 8),
                      KuberSelectCard(
                        title: l.msLoansReduceEmi,
                        subtitle: emiPreview == null
                            ? l.msLoansReduceEmiHow
                            : l.msLoansReduceEmiResult(
                                fmtMonthYear(dayOf(emiPreview.endDay)), m(emiPreview.newEmi)),
                        selected: _reduce == LoanAdjust.emi,
                        onTap: () => setState(() => _reduce = LoanAdjust.emi),
                        onInfo: () => showMoneyInfo(context, ref, MoneyInfo.tenureEmi),
                      ),
                      const SizedBox(height: 12),
                      if (_amountValue > 0)
                        KuberCallout.text(
                          preview == null
                              ? l.msLoansNoNumbersPreview
                              : (_reduce == LoanAdjust.tenure
                                  ? l.msLoansExtraPreviewTenure(m(preview.saved), '${preview.monthsSooner}')
                                  : l.msLoansExtraPreviewEmi(m(preview.saved), m(preview.newEmi))),
                          tone: preview == null ? KuberCalloutTone.info : KuberCalloutTone.ok,
                        ),
                      const SizedBox(height: 12),
                      Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        Expanded(
                          child: KuberTextField.number(
                            label: l.msLoansPrepayCharge,
                            controller: _charge,
                            inputFormatters: _chargePct
                                ? null
                                : [CurrencyInputFormatter(isIndian: indian)],
                            hint: l.msLoansPrepayChargeHint,
                            onInfo: () => showMoneyInfo(context, ref, MoneyInfo.prepayCharge),
                            onChanged: (_) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 120,
                          child: KuberSegmented<bool>(
                            groupValue: _chargePct,
                            onChanged: (v) => setState(() {
                              _chargePct = v;
                              if (v) _charge.text = _charge.text.replaceAll(',', '');
                            }),
                            segments: [
                              KuberSegment(value: false, label: fmt.currency.narrow),
                              const KuberSegment(value: true, label: '%'),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  )
                : KuberCallout.text(
                    key: const ValueKey(false),
                    l.msLoansFeeNotice(m(st.outstanding ?? 0)),
                    tone: KuberCalloutTone.info,
                  ),
          ),
        ),
        const SizedBox(height: 16),
        AccountPickerRow(
          selectedId: _accountId,
          onChanged: (id) => setState(() => _accountId = id),
        ),
        const SizedBox(height: 10),
        DatePickerRow(
          label: l.msInvDate,
          value: fmtDayLong(_date),
          initial: _date,
          onChanged: (d) => setState(() => _date = d),
        ),
      ]),
    );
  }
}

// ── Change interest rate (L.6) ─────────────────────────────────────────

void showRateChangeSheet(BuildContext context, WidgetRef ref, Loan loan) =>
    showMoneySheet<void>(context, _RateChangeSheet(loan: loan));

class _RateChangeSheet extends ConsumerStatefulWidget {
  final Loan loan;
  const _RateChangeSheet({required this.loan});

  @override
  ConsumerState<_RateChangeSheet> createState() => _RateChangeSheetState();
}

class _RateChangeSheetState extends ConsumerState<_RateChangeSheet> {
  final _rate = TextEditingController();
  DateTime _from = DateUtils.dateOnly(DateTime.now());
  LoanAdjust _adjust = LoanAdjust.tenure;

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final fmt = ref.watch(formatterProvider);
    String m(num v) => fmt.formatCurrency(v.round());
    final rate = double.tryParse(_rate.text.trim());
    final p = rate == null
        ? null
        : LoanService.ratePreview(widget.loan, rate, _from, _adjust,
            records: ref.watch(loanRecordsProvider(widget.loan.uid)));
    String? preview, sub;
    if (p != null) {
      final end = p.endDay == null ? '' : fmtMonthYear(dayOf(p.endDay!));
      if (_adjust == LoanAdjust.emi) {
        preview = l.msLoansRatePreviewEmi(m(p.newEmi), fmtDayShort(_from));
        sub = l.msLoansRatePreviewEmiSub(end, m(p.interestDelta.abs()));
      } else {
        preview = l.msLoansRatePreviewTenure(m(p.newEmi), end);
        sub = p.monthsDelta >= 0
            ? l.msLoansRatePreviewTenureSub('${p.monthsDelta}', m(p.interestDelta.abs()))
            : l.msLoansRatePreviewTenureSubLater('${-p.monthsDelta}', m(p.interestDelta.abs()));
      }
    }
    return KuberBottomSheet(
      title: l.msLoansChangeRate,
      description: widget.loan.name,
      actions: AppButton(
        label: l.saveLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: rate == null || rate < 0
            ? null
            : () async {
                await LoanService(ref.read(isarProvider))
                    .changeRate(widget.loan, newRate: rate, from: _from, adjust: _adjust);
                ref.invalidate(loanListProvider);
                if (context.mounted) {
                  Navigator.of(context).pop();
                  showKuberSnackBar(context, l.msLoansRateSaved);
                }
              },
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        KuberTextField.number(
          label: l.msLoansNewRate,
          controller: _rate,
          suffixText: '%',
          onInfo: () => showMoneyInfo(context, ref, MoneyInfo.floating),
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 12),
        DatePickerRow(
          label: l.msLoansEffectiveFrom,
          value: fmtDayLong(_from),
          initial: _from,
          onChanged: (d) => setState(() => _from = d),
        ),
        const SizedBox(height: 16),
        CapsLabel(l.msLoansThen),
        const SizedBox(height: 8),
        KuberSegmented<LoanAdjust>(
          groupValue: _adjust,
          onChanged: (v) => setState(() => _adjust = v),
          segments: [
            KuberSegment(value: LoanAdjust.emi, label: l.msLoansAdjustEmi),
            KuberSegment(value: LoanAdjust.tenure, label: l.msLoansAdjustTenure),
          ],
        ),
        if (preview != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: KuberShape.largeR),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(preview, style: Theme.of(context).textTheme.titleSmall),
              if (sub != null) Text(sub, style: Theme.of(context).textTheme.bodySmall),
            ]),
          ),
        ],
        const SizedBox(height: 12),
        Text(l.msLoansFloatingHelp, style: Theme.of(context).textTheme.bodySmall),
      ]),
    );
  }
}
