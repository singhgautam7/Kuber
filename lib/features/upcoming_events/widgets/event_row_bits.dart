import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../ledger/widgets/ledger_detail_sheet.dart';
import '../../loans/widgets/loan_sheet.dart';
import '../../investments/widgets/holding_sheet.dart';
import '../../recurring/widgets/rule_sheet.dart';
import '../../reminders/widgets/reminder_view_sheet.dart';
import '../engine/event_aggregator.dart';

/// Type label, colour and icon (upcoming-calendar-v1 §2, decision 7). The
/// colours are fixed categorical tokens (same in every theme family), shared
/// by the List pills, the calendar dots and the type tiles. [fd] picks the FD
/// label for an FD maturity under the SIPs type.
({String label, Color color, IconData icon}) eventSourceStyle(
  BuildContext context,
  String sourceType, {
  bool fd = false,
}) {
  final c = context.kuberChart.categorical;
  final l = context.l10n;
  return switch (sourceType) {
    'reminder' => (label: l.uePillReminder, color: c[0], icon: Icons.notifications_outlined),
    'emi' => (label: l.uePillEmi, color: c[6], icon: Icons.account_balance_outlined),
    'sip' => (label: fd ? l.uePillFd : l.uePillSip, color: c[4], icon: Icons.savings_outlined),
    'recurring' => (label: l.uePillRecurring, color: c[2], icon: Icons.repeat_rounded),
    'creditCard' => (label: l.uePillCard, color: c[3], icon: Icons.credit_card_outlined),
    _ => (label: l.uePillLedger, color: c[1], icon: Icons.handshake_outlined),
  };
}

/// The six filter / legend types, in day-list order.
const kUpcomingTypes = ['reminder', 'emi', 'sip', 'recurring', 'ledger', 'creditCard'];

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
      showLoanSheet(context, ref, loan);
    case InvestmentSipEvent(:final investment):
      showHoldingSheet(context, ref, investment);
    case InvestmentMaturityEvent(:final investment):
      showHoldingSheet(context, ref, investment);
    case RecurringEvent(:final rule):
      showRuleSheet(context, ref, rule);
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
  final bool fd;

  const EventSourcePill({super.key, required this.sourceType, this.fd = false});

  @override
  Widget build(BuildContext context) {
    final style = eventSourceStyle(context, sourceType, fd: fd);
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

/// 40 dp type tile: the type colour as a light container with its icon
/// (calendar day list leading slot, filter and legend rows).
class EventTypeTile extends StatelessWidget {
  final String sourceType;
  final double size;
  const EventTypeTile({super.key, required this.sourceType, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final style = eventSourceStyle(context, sourceType);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.16),
        borderRadius: KuberShape.mediumR,
      ),
      child: Icon(style.icon, size: size * 0.5, color: style.color),
    );
  }
}
