import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
// Imported for the generated Isar collection accessors (isar.reminders, etc).
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
/// Re-aggregates when any of the 5 source collections changes.
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

  emit();
  final subs = <StreamSubscription>[
    isar.reminders.watchLazy().listen((_) => emit()),
    isar.loans.watchLazy().listen((_) => emit()),
    isar.investments.watchLazy().listen((_) => emit()),
    isar.recurringRules.watchLazy().listen((_) => emit()),
    isar.ledgers.watchLazy().listen((_) => emit()),
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
