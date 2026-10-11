import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/home_v2/engine/suggestion_engine.dart';
import 'package:kuber/features/home_v2/engine/suggestion_scheduler.dart';

final day1 = DateTime(2026, 10, 15, 9);
DateTime plusDays(int d) => day1.add(Duration(days: d));

const loans = SgCandidate(type: SgType.loans, key: 'loans');
const budgetA = SgCandidate(type: SgType.budget, key: 'budget:a', rank: 900);
const budgetB = SgCandidate(type: SgType.budget, key: 'budget:b', rank: 5000);
const ask = SgCandidate(type: SgType.askKuber, key: 'ask_kuber');

void main() {
  group('eligibility', () {
    bool e({
      bool v2 = true,
      DateTime? grad,
      bool setting = true,
      bool promo = false,
      bool locked = false,
    }) => SgScheduler.eligible(
      isV2: v2,
      gsGraduatedAt: grad,
      setting: setting,
      promoVisible: promo,
      sessionLocked: locked,
      now: day1,
    );

    final graduated = day1.subtract(const Duration(hours: 25));
    test('needs v2, graduation 24h ago, setting on, no promo, no lock', () {
      expect(e(grad: graduated), isTrue);
      expect(e(v2: false, grad: graduated), isFalse);
      expect(e(), isFalse); // not graduated
      expect(e(grad: day1.subtract(const Duration(hours: 23))), isFalse);
      expect(e(grad: graduated, setting: false), isFalse);
      expect(e(grad: graduated, promo: true), isFalse);
      expect(e(grad: graduated, locked: true), isFalse);
    });
  });

  group('selection and priority', () {
    test('data type beats discovery; lowest priority number wins', () {
      final r = SgScheduler.select(const SgStore(), [
        ask,
        budgetA,
        loans,
      ], day1);
      expect(r.shown!.key, 'loans');
      expect(r.isNew, isTrue);
      expect(r.store.instances['loans']!.state, SgState.active);
      expect(r.store.lastNewShownDay, SgScheduler.dayStamp(day1));
    });
    test('tie-break within a type: highest rank', () {
      final r = SgScheduler.select(const SgStore(), [budgetA, budgetB], day1);
      expect(r.shown!.key, 'budget:b');
    });
    test('discovery only when no data candidate', () {
      final r = SgScheduler.select(const SgStore(), [ask], day1);
      expect(r.shown!.key, 'ask_kuber');
    });
    test('one new suggestion per day; the active one re-shows', () {
      final first = SgScheduler.select(const SgStore(), [loans, budgetB], day1);
      // Same day, next session: the active card again, not a new one.
      final again = SgScheduler.select(first.store, [loans, budgetB], day1);
      expect(again.shown!.key, 'loans');
      expect(again.isNew, isFalse);
      // Active resolved, same day: nothing new.
      final accepted = SgScheduler.accept(again.store, 'loans', day1);
      expect(SgScheduler.select(accepted, [budgetB], day1).shown, isNull);
      // Next day: the next one.
      expect(
        SgScheduler.select(accepted, [budgetB], plusDays(1)).shown!.key,
        'budget:b',
      );
    });
    test('trigger becomes false while active: removed at the next build', () {
      final first = SgScheduler.select(const SgStore(), [loans], day1);
      final next = SgScheduler.select(first.store, const [], plusDays(1));
      expect(next.shown, isNull);
      expect(next.store.instances['loans']!.state, SgState.candidate);
    });
    test('shown on 3 different days with no interaction counts as Not now', () {
      var s = SgScheduler.select(const SgStore(), [loans], day1).store;
      s = SgScheduler.select(s, [loans], plusDays(1)).store;
      final third = SgScheduler.select(s, [loans], plusDays(2));
      final i = third.store.instances['loans']!;
      expect(i.state, SgState.snoozed);
      expect(i.snoozeCount, 1);
    });
  });

  group('Not now (snooze)', () {
    test('14 days, then 30 days, third becomes dismissed', () {
      var s = SgScheduler.select(const SgStore(), [loans], day1).store;
      s = SgScheduler.notNow(s, 'loans', day1);
      expect(s.instances['loans']!.snoozedUntil, plusDays(14));
      // Not available before the snooze ends.
      expect(SgScheduler.select(s, [loans], plusDays(13)).shown, isNull);
      final back = SgScheduler.select(s, [loans], plusDays(14));
      expect(back.shown!.key, 'loans');
      s = SgScheduler.notNow(back.store, 'loans', plusDays(14));
      expect(s.instances['loans']!.snoozedUntil, plusDays(44));
      s = SgScheduler.select(s, [loans], plusDays(44)).store;
      s = SgScheduler.notNow(s, 'loans', plusDays(44));
      expect(s.instances['loans']!.state, SgState.dismissed);
    });
  });

  group('dismiss', () {
    test('permanent for the instance, with a 2-day cooldown', () {
      var s = SgScheduler.select(const SgStore(), [loans, budgetB], day1).store;
      s = SgScheduler.dismiss(s, 'loans', day1);
      expect(s.instances['loans']!.state, SgState.dismissed);
      // Day+1: still cooling down. Day+2: allowed, and loans never returns.
      expect(
        SgScheduler.select(s, [loans, budgetB], plusDays(1)).shown,
        isNull,
      );
      final r = SgScheduler.select(s, [loans, budgetB], plusDays(2));
      expect(r.shown!.key, 'budget:b');
    });
    test('two dismisses of one type within 90 days suppress it 90 days', () {
      var s = SgScheduler.select(const SgStore(), [budgetB], day1).store;
      s = SgScheduler.dismiss(s, 'budget:b', day1);
      s = SgScheduler.select(s, [budgetA], plusDays(3)).store;
      s = SgScheduler.dismiss(s, 'budget:a', plusDays(3));
      expect(s.suppressedUntil[SgType.budget], plusDays(93));
      const budgetC = SgCandidate(type: SgType.budget, key: 'budget:c');
      expect(SgScheduler.select(s, [budgetC], plusDays(10)).shown, isNull);
      expect(
        SgScheduler.select(s, [budgetC], plusDays(94)).shown!.key,
        'budget:c',
      );
    });
    test('undo restores the pre-dismiss state (caller keeps a snapshot)', () {
      final before = SgScheduler.select(const SgStore(), [loans], day1).store;
      final after = SgScheduler.dismiss(before, 'loans', day1);
      expect(after.lastDismissAt, day1);
      // Undo = put `before` back: active again, no cooldown.
      expect(before.instances['loans']!.state, SgState.active);
      expect(before.lastDismissAt, isNull);
    });
  });

  test('next suggestion after accept only when today is unused', () {
    final yesterday = SgScheduler.select(const SgStore(), [loans], day1).store;
    // Carried over to the next day and accepted there: allowed.
    expect(SgScheduler.canShowNextAfterAccept(yesterday, plusDays(1)), isTrue);
    // Shown today and accepted today: not allowed.
    expect(SgScheduler.canShowNextAfterAccept(yesterday, day1), isFalse);
  });

  test('JSON round trip keeps every field', () {
    var s = SgScheduler.select(const SgStore(), [loans], day1).store;
    s = SgScheduler.notNow(s, 'loans', day1);
    s = SgScheduler.dismiss(
      SgScheduler.select(s, [budgetB], plusDays(1)).store,
      'budget:b',
      plusDays(1),
    );
    final back = SgStore.decode(
      instances: s.encodeInstances(),
      lastNewShownDay: s.lastNewShownDay,
      lastDismissAt: s.lastDismissAt!.toIso8601String(),
      suppressed: s.encodeSuppressed(),
    );
    expect(back.instances['loans']!.snoozedUntil, plusDays(14));
    expect(back.instances['budget:b']!.state, SgState.dismissed);
    expect(back.lastDismissAt, plusDays(1));
    expect(SgStore.decode(instances: '{bad').instances, isEmpty);
  });
}
