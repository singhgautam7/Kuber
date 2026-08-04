import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
// Imported for the generated Isar collection accessors (isar.reminders, etc).
import '../../accounts/data/account.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../reminders/data/reminder.dart';
import '../engine/event_aggregator.dart';

/// Widest window we ever show. The full screen and home widget both read this
/// single stream and filter to their own window CLIENT-SIDE — so changing the
/// range chip never re-subscribes the provider (no frame lag).
const int kUpcomingEventsMaxDays = 90;

/// Live upcoming events for the next [kUpcomingEventsMaxDays] days.
/// Re-aggregates when any of the 6 source collections changes.
final upcomingEventsProvider =
    StreamProvider<List<UpcomingEvent>>((ref) {
  final isar = ref.watch(isarProvider);
  final aggregator = UpcomingEventsAggregator(isar);

  final controller = StreamController<List<UpcomingEvent>>();
  var disposed = false;

  Future<void> emit() async {
    if (disposed) return;
    final events = await aggregator.getUpcomingEvents(
      window: const Duration(days: kUpcomingEventsMaxDays),
    );
    if (!disposed) controller.add(events);
  }

  // Only the credit-card billing fields affect the event list. Editing a bank
  // account, or toggling a card's reminder flags (which change notifications,
  // not events), must NOT trigger a full re-aggregation. The accounts table is
  // tiny, so recomputing this signature per account write is far cheaper than
  // re-querying all six sources.
  String creditSignature(List<Account> accounts) {
    final sb = StringBuffer();
    for (final a in accounts) {
      if (!a.isCreditCard) continue;
      sb
        ..write(a.id)
        ..write(':')
        ..write(a.isDisabled ? 1 : 0)
        ..write(':')
        ..write(a.billGenerationDay ?? '-')
        ..write(':')
        ..write(a.paymentDueDay ?? '-')
        ..write('|');
    }
    return sb.toString();
  }

  String? lastCreditSig;
  // Seed the baseline so the first account change compares against reality.
  isar.accounts.where().findAll().then((a) {
    if (!disposed) lastCreditSig = creditSignature(a);
  });

  Future<void> onAccountsChanged() async {
    if (disposed) return;
    final accounts = await isar.accounts.where().findAll();
    final sig = creditSignature(accounts);
    if (sig == lastCreditSig) return; // no credit-event-relevant change
    lastCreditSig = sig;
    await emit();
  }

  emit();
  final subs = <StreamSubscription>[
    isar.reminders.watchLazy().listen((_) => emit()),
    isar.loans.watchLazy().listen((_) => emit()),
    isar.investments.watchLazy().listen((_) => emit()),
    isar.recurringRules.watchLazy().listen((_) => emit()),
    isar.ledgers.watchLazy().listen((_) => emit()),
    isar.accounts.watchLazy().listen((_) => onAccountsChanged()),
  ];

  ref.onDispose(() {
    disposed = true;
    for (final s in subs) {
      s.cancel();
    }
    controller.close();
  });

  return controller.stream;
});

/// Client-side window filter (days from now). Pure, cheap — no re-query.
List<UpcomingEvent> eventsWithinDays(List<UpcomingEvent> events, int days) {
  final cutoff = DateTime.now().add(Duration(days: days));
  return events.where((e) => !e.date.isAfter(cutoff)).toList();
}

/// Source-type filter selection for the full screen ('all' = no filter).
final upcomingEventsSourceFilterProvider =
    StateProvider<String>((ref) => 'all');

/// Time-range selection for the full screen, in days.
final upcomingEventsRangeProvider = StateProvider<int>((ref) => 30);
