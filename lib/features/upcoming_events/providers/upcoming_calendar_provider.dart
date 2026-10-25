// Calendar data (upcoming-calendar-v1): one occurrencesBetween call per shown
// month, cached while the screen is open and refreshed when a source changes.

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/processed_occurrence.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../accounts/data/account.dart';
import '../../investments/data/investment.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../reminders/data/reminder.dart';
import '../../transactions/data/transaction.dart';
import '../engine/occurrences.dart';

/// List or Calendar, saved on tap and restored on open. Default Calendar
/// (user review; the design's default was List).
class UpcomingViewNotifier extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(PrefsKeys.upcomingEventsView) != 'list';
  }

  Future<void> setCalendar(bool calendar) async {
    state = AsyncData(calendar);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.upcomingEventsView, calendar ? 'calendar' : 'list');
  }
}

final upcomingCalendarViewProvider =
    AsyncNotifierProvider<UpcomingViewNotifier, bool>(UpcomingViewNotifier.new);

/// Bumps when anything the calendar reads changes (sources, posted
/// transactions for actual amounts and card bills). Lives while the calendar
/// is on screen.
final upcomingDataVersionProvider = StreamProvider.autoDispose<int>((ref) {
  final isar = ref.watch(isarProvider);
  final controller = StreamController<int>();
  var v = 0;
  Timer? debounce;
  void bump() {
    debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 150), () => controller.add(++v));
  }

  controller.add(v);
  final subs = [
    isar.reminders.watchLazy().listen((_) => bump()),
    isar.loans.watchLazy().listen((_) => bump()),
    isar.investments.watchLazy().listen((_) => bump()),
    isar.recurringRules.watchLazy().listen((_) => bump()),
    isar.ledgers.watchLazy().listen((_) => bump()),
    isar.accounts.watchLazy().listen((_) => bump()),
    isar.transactions.watchLazy().listen((_) => bump()),
    isar.processedOccurrences.watchLazy().listen((_) => bump()),
  ];
  ref.onDispose(() {
    debounce?.cancel();
    for (final s in subs) {
      s.cancel();
    }
    controller.close();
  });
  return controller.stream;
});

/// The calendar's clock (tests pin it).
final upcomingClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Month key yyyymm.
int monthKeyOf(DateTime d) => d.year * 100 + d.month;
DateTime monthOf(int key) => DateTime(key ~/ 100, key % 100);

/// A shown month's occurrences, calendar order. The calendar keeps every
/// month it has shown subscribed (a lazy per-month cache) until it closes;
/// recomputed only when [upcomingDataVersionProvider] bumps.
final calendarMonthProvider =
    FutureProvider.autoDispose.family<List<CalendarOccurrence>, int>((ref, key) async {
  // The number only: loading -> 0 is no change, so a month computes once.
  ref.watch(upcomingDataVersionProvider.select((v) => v.valueOrNull ?? 0));
  final isar = ref.watch(isarProvider);
  final start = monthOf(key);
  final end = DateTime(start.year, start.month + 1, 0);
  final list = await OccurrenceEngine(isar).between(start, end, at: ref.watch(upcomingClockProvider)());
  return list..sort(compareOccurrences);
});

/// First month the calendar can show: the month of the first transaction,
/// at most 24 months back.
final calendarFirstMonthProvider = FutureProvider.autoDispose<int>((ref) async {
  final isar = ref.watch(isarProvider);
  final now = ref.watch(upcomingClockProvider)();
  final cap = DateTime(now.year, now.month - 24);
  final first = await isar.transactions.where().anyCreatedAt().findFirst();
  final from = first == null || first.createdAt.isAfter(now) ? now : first.createdAt;
  return monthKeyOf(from.isBefore(cap) ? cap : from);
});
