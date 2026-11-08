import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/formatters.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/utils/prefs_keys.dart';
import '../../l10n/app_localizations.dart';
import '../accounts/data/account.dart';
import '../categories/data/category.dart';
import '../categories/data/category_group.dart';
import '../investments/data/investment.dart';
import '../kuber_cards/data/stored_card.dart';
import '../ledger/data/ledger.dart';
import '../loans/data/loan.dart';
import '../notes/data/kuber_note.dart';
import '../recurring/data/recurring_rule.dart';
import '../reminders/data/reminder.dart';
import '../tags/data/tag.dart';

/// Result groups, in the order they always appear.
enum MoreSearchKind {
  settings,
  accounts,
  categories,
  tags,
  recurring,
  loans,
  investments,
  people,
  reminders,
  cards,
  notes,
  calculators,
  features,
}

enum MoreSearchTone { neutral, income, expense }

/// One thing search can find. Holds names and titles only, never a card number
/// or a note's text: what isn't here can't be matched or shown.
class MoreSearchItem {
  final MoreSearchKind kind;
  final String title;
  final String subtitle;

  /// [subtitle] with any amount hidden, for privacy mode.
  final String? maskedSubtitle;
  final IconData icon;

  /// The trailing amount, hidden in privacy mode.
  final String? amount;
  final MoreSearchTone tone;

  /// Raw category colour.
  final Color? color;

  /// What opening this result needs: the entity, a route or an action.
  final Object? target;

  /// "Matches:" line of a keyword hit.
  final String? matches;

  final String lower;

  MoreSearchItem({
    required this.kind,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.maskedSubtitle,
    this.amount,
    this.tone = MoreSearchTone.neutral,
    this.color,
    this.target,
    this.matches,
  }) : lower = title.toLowerCase();
}

/// One line of data for [MoreSearchItems.build], so the pure part needs no
/// Riverpod.
class MoreSearchData {
  final List<Account> accounts;
  final Map<int, double> balances;
  final List<Category> categories;
  final List<CategoryGroup> groups;
  final List<Tag> tags;
  final Map<int, int> tagCounts;
  final List<RecurringRule> rules;
  final List<Loan> loans;

  /// By loan uid: outstanding and next EMI's day label.
  final Map<String, ({double? outstanding, String? next})> loanInfo;
  final List<Investment> investments;
  final List<Ledger> ledgers;
  final Map<String, double> remaining;
  final List<Reminder> reminders;
  final List<StoredCard> cards;
  final List<KuberNote> notes;

  const MoreSearchData({
    this.accounts = const [],
    this.balances = const {},
    this.categories = const [],
    this.groups = const [],
    this.tags = const [],
    this.tagCounts = const {},
    this.rules = const [],
    this.loans = const [],
    this.loanInfo = const {},
    this.investments = const [],
    this.ledgers = const [],
    this.remaining = const {},
    this.reminders = const [],
    this.cards = const [],
    this.notes = const [],
  });
}

class MoreSearchItems {
  MoreSearchItems._();

  /// Turns the loaded data into rows, once when search opens. [mask] is the
  /// hidden amount ("₹ ••••"), [typeOf] an investment's type in words.
  static List<MoreSearchItem> build(
    MoreSearchData d, {
    required AppLocalizations l,
    required AppFormatter fmt,
    required String mask,
    required String Function(Investment) typeOf,
    required String locale,
  }) {
    String money(num v) => fmt.formatCurrency(v.round());
    final day = DateFormat('d MMM', locale);
    final time = DateFormat('d MMM, h:mm a', locale);
    final groupName = {for (final g in d.groups) g.id: g.name};
    final out = <MoreSearchItem>[];

    for (final a in d.accounts) {
      final b = d.balances[a.id] ?? a.initialBalance;
      out.add(MoreSearchItem(
        kind: MoreSearchKind.accounts,
        title: a.name,
        subtitle: a.isCreditCard
            ? l.accountTypeCreditCard
            : a.isOverdraft
                ? l.accountTypeOverdraft
                : a.type == 'cash'
                    ? l.accountTypeCash
                    : l.accountTypeBank,
        icon: a.icon != null ? IconMapper.fromString(a.icon!) : Icons.account_balance_rounded,
        amount: money(b.abs()),
        tone: b < 0 || (a.isLiability && b != 0) ? MoreSearchTone.expense : MoreSearchTone.neutral,
        target: a,
      ));
    }
    for (final c in d.categories) {
      out.add(MoreSearchItem(
        kind: MoreSearchKind.categories,
        title: c.name,
        subtitle: groupName[c.groupId] ?? (c.effectiveType == 'income' ? l.incomeLabel : l.expenseLabel),
        icon: IconMapper.fromString(c.icon),
        color: Color(c.colorValue),
        target: c,
      ));
    }
    for (final t in d.tags) {
      out.add(MoreSearchItem(
        kind: MoreSearchKind.tags,
        title: t.name,
        subtitle: l.searchTagSub(d.tagCounts[t.id] ?? 0),
        icon: Icons.sell_outlined,
        target: t,
      ));
    }
    for (final r in d.rules) {
      String sub(String amount) => '${l.menuRecurring} · ${switch (r.frequency) {
            'daily' => l.searchEveryDay(amount),
            'weekly' => l.searchEveryWeek(amount),
            'monthly' => l.searchEveryMonth(amount),
            'yearly' => l.searchEveryYear(amount),
            _ => amount,
          }}';
      out.add(MoreSearchItem(
        kind: MoreSearchKind.recurring,
        title: r.name,
        subtitle: sub(money(r.amount)),
        maskedSubtitle: sub(mask),
        icon: Icons.event_repeat_rounded,
        target: r,
      ));
    }
    for (final loan in d.loans) {
      final info = d.loanInfo[loan.uid];
      String sub(String amount) => info?.next == null
          ? '${l.searchLoan} · $amount ${l.msLoansEmi}'
          : '${l.searchLoan} · ${l.msLoansRowSub(amount, info!.next!)}';
      out.add(MoreSearchItem(
        kind: MoreSearchKind.loans,
        title: loan.name,
        subtitle: sub(money(loan.emiAmount)),
        maskedSubtitle: sub(mask),
        icon: Icons.account_balance_outlined,
        amount: info?.outstanding == null ? null : money(info!.outstanding!),
        target: loan,
      ));
    }
    for (final i in d.investments) {
      final v = i.currentValue ?? i.investedAmount;
      out.add(MoreSearchItem(
        kind: MoreSearchKind.investments,
        title: i.name,
        subtitle: '${l.searchInvestment} · ${typeOf(i)}',
        icon: Icons.trending_up_rounded,
        amount: v == null ? null : money(v),
        target: i,
      ));
    }
    for (final p in d.ledgers) {
      final lent = p.type == 'lent';
      final due = p.expectedDate;
      out.add(MoreSearchItem(
        kind: MoreSearchKind.people,
        title: p.personName,
        subtitle: p.isSettled
            ? l.searchSettled
            : due == null
                ? (lent ? l.searchYouLent : l.searchYouBorrowed)
                : '${lent ? l.searchYouLent : l.searchYouBorrowed} · ${l.searchDue(day.format(due))}',
        icon: Icons.handshake_outlined,
        amount: p.isSettled ? null : money(d.remaining[p.uid] ?? p.originalAmount),
        tone: lent ? MoreSearchTone.income : MoreSearchTone.expense,
        target: p,
      ));
    }
    for (final r in d.reminders) {
      out.add(MoreSearchItem(
        kind: MoreSearchKind.reminders,
        title: r.title,
        subtitle: '${l.searchReminder} · ${time.format(r.dueAt).replaceAll('AM', 'am').replaceAll('PM', 'pm')}',
        icon: Icons.alarm_rounded,
        target: r,
      ));
    }
    for (final c in d.cards) {
      out.add(MoreSearchItem(
        kind: MoreSearchKind.cards,
        title: c.nickname,
        subtitle: l.appDrawerCards,
        icon: Icons.credit_card_rounded,
        target: c.id,
      ));
    }
    for (final n in d.notes) {
      if (n.title.trim().isEmpty) continue;
      out.add(MoreSearchItem(
        kind: MoreSearchKind.notes,
        title: n.title,
        subtitle: '${l.appDrawerNotes} · ${l.searchEdited(day.format(n.updatedAt))}',
        icon: Icons.sticky_note_2_outlined,
        target: n.id,
      ));
    }
    return out;
  }

  /// Titles containing [query], one list per kind, kinds in order. Runs over
  /// lists already in memory: no query per keystroke.
  static Map<MoreSearchKind, List<MoreSearchItem>> match(List<MoreSearchItem> items, String query) {
    final q = query.trim().toLowerCase();
    final out = <MoreSearchKind, List<MoreSearchItem>>{};
    if (q.isEmpty) return out;
    for (final i in items) {
      if (i.lower.contains(q)) (out[i.kind] ??= []).add(i);
    }
    return out;
  }
}

/// Recent searches, on this phone only.
class MoreSearchRecents {
  MoreSearchRecents._();
  static const max = 5;

  static Future<List<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    // Lists saved before the cap went from 10 to 5 are cut on read.
    return (prefs.getStringList(PrefsKeys.moreSearchRecent) ?? const []).take(max).toList();
  }

  /// Newest first, no repeats, at most [max].
  static List<String> added(List<String> list, String query) {
    final q = query.trim();
    if (q.isEmpty) return list;
    return [
      q,
      ...list.where((x) => x.toLowerCase() != q.toLowerCase()),
    ].take(max).toList();
  }

  static Future<void> save(List<String> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(PrefsKeys.moreSearchRecent, list);
  }
}
