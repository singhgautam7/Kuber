import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../ledger/widgets/ledger_detail_sheet.dart';
import '../../loans/widgets/loan_detail_sheet.dart';
import '../../recurring/widgets/recurring_detail_sheet.dart';
import '../../reminders/widgets/reminder_view_sheet.dart';
import '../engine/event_aggregator.dart';

/// Pill label + accent color for a source type, consistent across the home
/// widget and the full screen (3a/3d).
({String label, Color color}) eventSourceStyle(
  BuildContext context,
  String sourceType,
) {
  final cs = Theme.of(context).colorScheme;
  return switch (sourceType) {
    'reminder' => (label: 'REMINDER', color: cs.primary),
    'emi' => (label: 'EMI', color: context.kuberChart.eventEmi),
    'sip' => (label: 'SIP', color: context.kuberMoney.income),
    'recurring' => (label: 'RECURRING', color: context.kuberMoney.warning),
    'creditCard' => (label: 'CREDIT CARD', color: cs.primary),
    _ => (label: 'LEDGER', color: context.kuberChart.eventLedger),
  };
}

/// Opens the tapped event's source detail. Read-only navigation — never
/// mutates the source records.
void openUpcomingEventSource(
  BuildContext context,
  WidgetRef ref,
  UpcomingEvent event,
) {
  switch (event) {
    case ReminderEvent(:final reminder):
      showReminderViewSheet(context, reminder);
    case LoanEmiEvent(:final loan):
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LoanDetailSheet(loan: loan),
      );
    case InvestmentSipEvent():
      context.push('/more/investments');
    case RecurringEvent(:final rule):
      showRecurringDetailSheet(context, ref, rule);
    case LedgerEvent(:final ledger):
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => LedgerDetailSheet(ledger: ledger),
      );
    case CreditCardEvent(:final account):
      showModalBottomSheet(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AccountDetailSheet(account: account),
      );
  }
}

/// Small tinted source-type pill.
class EventSourcePill extends StatelessWidget {
  final String sourceType;

  const EventSourcePill({super.key, required this.sourceType});

  @override
  Widget build(BuildContext context) {
    final style = eventSourceStyle(context, sourceType);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.14),
        borderRadius: KuberShape.fullR,
      ),
      child: Text(
        style.label,
        style: localeFont(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: style.color,
        ),
      ),
    );
  }
}
