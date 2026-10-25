// A row in the Recurring hub (components/row-states.md): normal, linked
// (From Loans / From Investments, read-only, opens the source sheet), paused
// and ended. Built on KuberListRow.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/money_widgets.dart';
import '../../categories/providers/category_provider.dart';
import '../../investments/widgets/holding_sheet.dart';
import '../../loans/widgets/loan_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/recurring_hub_provider.dart';
import 'rule_sheet.dart';

class HubRowTile extends ConsumerWidget {
  final HubRow row;
  const HubRowTile({super.key, required this.row});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = ref.watch(formatterProvider);
    final money = context.kuberMoney;
    final s = row.schedule;
    final ended = isEnded(s);
    final muted = s.paused || ended;
    final interval = intervalText(l, s.intervalCount, s.intervalUnit);
    final today = todayKey();
    String sub;
    if (ended) {
      sub = interval;
    } else if (s.paused) {
      sub = l.msRecPausedSince(interval, fmtMonthYear(s.pausedOn ?? DateTime.now()));
    } else if (row.nextDay == today) {
      sub = '$interval · ${l.msWhenFlagToday}';
    } else if (row.nextDay != null) {
      sub = row.kind == HubKind.rule
          ? l.msRecRowSub(interval, fmtDayShort(dayOf(row.nextDay!)))
          : l.msRecNextOnly(fmtDayShort(dayOf(row.nextDay!)));
    } else {
      sub = interval;
    }

    Widget leading;
    if (row.kind == HubKind.rule) {
      final cat = ref
          .watch(categoryMapProvider)
          .valueOrNull?[int.tryParse(row.rule!.categoryId)];
      leading = cat == null
          ? const KuberIconTile(icon: Icons.repeat_rounded)
          : CategoryIcon.square(icon: IconMapper.fromString(cat.icon), rawColor: Color(cat.colorValue));
    } else {
      // Same look as the Loans and Investments screens.
      leading = row.loan != null
          ? LoanIcon(row.loan!)
          : row.investment != null
              ? HoldingIcon(row.investment!)
              : KuberIconTile(
                  icon: row.kind == HubKind.loan ? Icons.account_balance_rounded : Icons.savings_rounded,
                  tone: KuberTone.primary,
                );
    }

    final amountText = '${row.income ? '+' : '-'}${fmt.formatCurrency(row.amount)}';
    final linked = row.kind != HubKind.rule;
    final dueColor = !muted && row.nextDay != null && row.nextDay! <= today
        ? money.warning
        : null;
    return KuberListRow(
      leading: leading,
      title: row.name,
      subtitle: sub,
      subtitleLines: 2,
      below: linked
          ? Row(children: [
              Icon(Icons.link_rounded, size: 14, color: cs.primary),
              const SizedBox(width: 4),
              Text(row.kind == HubKind.loan ? l.msFromLoans : l.msFromInvestments,
                  style: tt.labelMedium!.copyWith(color: cs.primary)),
            ])
          : muted
              ? Align(
                  alignment: Alignment.centerLeft,
                  child: StatePill(ended ? l.msEnded : l.msPaused))
              : (dueColor != null ? const SizedBox.shrink() : null),
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(amountText,
            style: tt.titleMedium!.copyWith(
              color: muted
                  ? cs.onSurfaceVariant
                  : (row.income ? money.income : money.expense),
              fontFeatures: const [FontFeature.tabularFigures()],
            )),
        if (linked) ...[
          const SizedBox(width: 4),
          Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
        ],
      ]),
      onTap: () => switch (row.kind) {
        HubKind.rule => showRuleSheet(context, ref, row.rule!),
        HubKind.loan => showLoanSheet(context, ref, row.loan!),
        HubKind.sip => showHoldingSheet(context, ref, row.investment!),
      },
    );
  }
}
