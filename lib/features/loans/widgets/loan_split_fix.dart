// Fix EMI splits (advanced history v1.2, board AH.L): the notice at the top
// of the loan sheet, the fix sheet, and "Recheck EMI splits".
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/loan.dart';
import '../domain/loan_engine.dart';
import '../domain/loan_service.dart';
import '../providers/loan_provider.dart';

/// Warning card after the pre-EMI notice (the sheet adds it only while
/// [loanSplitNoticeCountProvider] is above 0).
class LoanSplitNotice extends ConsumerWidget {
  final Loan loan;
  final int count;
  const LoanSplitNotice({super.key, required this.loan, required this.count});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final m = context.kuberMoney;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      decoration: BoxDecoration(color: m.warningContainer, borderRadius: KuberShape.largeR),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.only(top: 2, right: 12),
          child: Icon(Icons.error_outline_rounded, size: 20, color: m.onWarningContainer),
        ),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(l.loanSplitNotice(count),
                style: tt.titleSmall?.copyWith(color: m.onWarningContainer)),
            const SizedBox(height: 4),
            Text(l.loanSplitNoticeSub, style: tt.bodySmall?.copyWith(color: m.onWarningContainer)),
            const SizedBox(height: 12),
            AppButton(
                label: l.loanSplitFix,
                type: AppButtonType.primary,
                height: 40,
                onPressed: () async {
                  final container = ProviderScope.containerOf(context, listen: false);
                  final check = await container.read(loanSplitCheckProvider(loan.uid).future);
                  if (context.mounted && check.count > 0) {
                    showLoanSplitFixSheet(context, container, loan, check);
                  }
                }),
          ]),
        ),
        IconButton(
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          icon: Icon(Icons.close_rounded, size: 20, color: m.onWarningContainer),
          onPressed: () => dismissLoanSplitNotice(ref, loan.uid, count),
        ),
      ]),
    );
  }
}

Future<void> showLoanSplitFixSheet(
    BuildContext context, ProviderContainer container, Loan loan, SplitCheck check) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => UncontrolledProviderScope(
        container: container, child: _LoanSplitFixSheet(loan: loan, check: check)),
  );
}

/// "Recheck EMI splits": the fix sheet when anything is off, else a snackbar.
Future<void> recheckLoanSplits(BuildContext context, ProviderContainer container, Loan loan) async {
  final l = context.l10n;
  final check = await container.read(loanSplitCheckProvider(loan.uid).future);
  if (!context.mounted) return;
  if (check.count == 0) {
    showKuberSnackBar(context, l.loanAllMatch(check.checked));
    return;
  }
  await showLoanSplitFixSheet(context, container, loan, check);
}

class _LoanSplitFixSheet extends ConsumerStatefulWidget {
  final Loan loan;
  final SplitCheck check;
  const _LoanSplitFixSheet({required this.loan, required this.check});

  @override
  ConsumerState<_LoanSplitFixSheet> createState() => _LoanSplitFixSheetState();
}

class _LoanSplitFixSheetState extends ConsumerState<_LoanSplitFixSheet> {
  bool _busy = false;

  Future<void> _fix() async {
    setState(() => _busy = true);
    final container = ProviderScope.containerOf(context, listen: false);
    final root = Navigator.of(context, rootNavigator: true).context;
    final l = context.l10n;
    final fmt = ref.read(formatterProvider);
    final service = LoanService(container.read(isarProvider));
    final c = widget.check;
    final undo = await service.fixSplits(c);
    container.invalidate(transactionListProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
    if (!root.mounted) return;
    showKuberSnackBar(
      root,
      l.loanFixedSnack(undo.length, fmt.formatCurrency((c.outstandingAfter ?? 0).round())),
      actionLabel: l.loanFixUndo,
      duration: const Duration(seconds: 10),
      onAction: () async {
        await service.undoSplitFix(undo);
        container.invalidate(transactionListProvider);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    String m(num v) => fmt.formatCurrency(v.round());
    final c = widget.check;
    final first = c.firstDay, last = c.lastDay;

    Widget cell(String t, {bool bold = false, Color? color, TextAlign align = TextAlign.end}) =>
        Expanded(
            child: Text(t,
                textAlign: align,
                style: localeFont(
                    fontSize: 14,
                    fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                    color: color ?? cs.onSurface)));

    Widget line(String label, double now, double after) {
      final d = (after - now).round();
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(children: [
          cell(label, align: TextAlign.start, color: cs.onSurfaceVariant),
          cell(m(now)),
          cell(m(after), bold: true),
          cell(d == 0 ? l.loanFixSame : '${d > 0 ? '+' : '−'}${m(d.abs())}',
              color: d == 0 ? cs.onSurfaceVariant : (d > 0 ? cs.tertiary : cs.error)),
        ]),
      );
    }

    return PopScope(
      canPop: !_busy,
      child: KuberBottomSheet(
        title: l.loanFixTitle,
        subtitle: widget.loan.name,
        showClose: false,
        actions: Row(children: [
          Expanded(
              child: AppButton(
                  label: l.cancelLabel,
                  type: AppButtonType.outline,
                  onPressed: _busy ? null : () => Navigator.of(context).pop())),
          const SizedBox(width: 12),
          Expanded(
              child: AppButton(
                  label: _busy ? l.loanFixing : l.loanSplitFix,
                  type: AppButtonType.primary,
                  isLoading: _busy,
                  onPressed: _busy ? null : _fix)),
        ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Icon(Icons.event_repeat_rounded, size: 20, color: cs.onSurfaceVariant),
            const SizedBox(width: 12),
            Text(l.loanFixCount(c.count), style: tt.titleMedium),
            const SizedBox(width: 8),
            if (first != null && last != null)
              Expanded(
                  child: Text(
                      l.loanFixRange(fmtMonthYear(dayOf(first)), fmtMonthYear(dayOf(last))),
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            cell('', align: TextAlign.start),
            cell(l.loanFixNow, color: cs.onSurfaceVariant),
            cell(l.loanFixAfter, color: cs.onSurfaceVariant),
            cell(''),
          ]),
          Divider(height: 1, color: cs.outlineVariant),
          line(l.loanFixInterest, c.nowInterest, c.afterInterest),
          line(l.loanFixPrincipal, c.nowPrincipal, c.afterPrincipal),
          line(l.loanFixTotalPaid, c.totalPaid, c.totalPaid),
          Divider(height: 1, color: cs.outlineVariant),
          if (c.kept > 0) ...[
            const SizedBox(height: 16),
            Row(children: [
              Icon(Icons.lock_outline_rounded, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: 12),
              Expanded(
                  child: Text(l.loanFixKept(c.kept),
                      style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
            ]),
          ],
          const SizedBox(height: 16),
          KuberCallout.text(l.loanFixInfo(m(c.outstandingAfter ?? 0))),
        ]),
      ),
    );
  }
}
