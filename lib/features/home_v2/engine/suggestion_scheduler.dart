/// Which suggestion to show, and what each card action does to the stored
/// state (suggestion-rules.md §3: Selection, Instance lifecycle, Frequency
/// caps and cooldowns). Pure Dart over plain values; persistence and the
/// session lock live in the provider.
library;

import 'dart:convert';

import 'suggestion_engine.dart';

enum SgState { candidate, active, snoozed, accepted, dismissed }

/// `HomeSuggestionState` from the spec, stored as JSON in prefs.
class SgInstance {
  final String key;
  final SgType type;
  final SgState state;
  final int snoozeCount;
  final DateTime? snoozedUntil;
  final DateTime? firstShownAt;

  /// Day stamps (yyyymmdd) the instance was on screen without a decision.
  final List<int> shownDays;
  final DateTime? resolvedAt;

  const SgInstance({
    required this.key,
    required this.type,
    this.state = SgState.candidate,
    this.snoozeCount = 0,
    this.snoozedUntil,
    this.firstShownAt,
    this.shownDays = const [],
    this.resolvedAt,
  });

  SgInstance copyWith({
    SgState? state,
    int? snoozeCount,
    DateTime? Function()? snoozedUntil,
    DateTime? firstShownAt,
    List<int>? shownDays,
    DateTime? Function()? resolvedAt,
  }) => SgInstance(
    key: key,
    type: type,
    state: state ?? this.state,
    snoozeCount: snoozeCount ?? this.snoozeCount,
    snoozedUntil: snoozedUntil != null ? snoozedUntil() : this.snoozedUntil,
    firstShownAt: firstShownAt ?? this.firstShownAt,
    shownDays: shownDays ?? this.shownDays,
    resolvedAt: resolvedAt != null ? resolvedAt() : this.resolvedAt,
  );

  Map<String, dynamic> toJson() => {
    't': type.name,
    's': state.name,
    if (snoozeCount != 0) 'n': snoozeCount,
    if (snoozedUntil != null) 'su': snoozedUntil!.toIso8601String(),
    if (firstShownAt != null) 'f': firstShownAt!.toIso8601String(),
    if (shownDays.isNotEmpty) 'd': shownDays,
    if (resolvedAt != null) 'r': resolvedAt!.toIso8601String(),
  };

  static SgInstance? fromJson(String key, Map<String, dynamic> m) {
    final type = SgType.values.asNameMap()[m['t']];
    if (type == null) return null;
    DateTime? d(String k) =>
        m[k] == null ? null : DateTime.tryParse(m[k] as String);
    return SgInstance(
      key: key,
      type: type,
      state: SgState.values.asNameMap()[m['s']] ?? SgState.candidate,
      snoozeCount: (m['n'] as num?)?.toInt() ?? 0,
      snoozedUntil: d('su'),
      firstShownAt: d('f'),
      shownDays: [for (final x in (m['d'] as List?) ?? const []) x as int],
      resolvedAt: d('r'),
    );
  }
}

/// All persisted suggestion state.
class SgStore {
  final Map<String, SgInstance> instances;
  final int? lastNewShownDay;
  final DateTime? lastDismissAt;
  final Map<SgType, DateTime> suppressedUntil;

  const SgStore({
    this.instances = const {},
    this.lastNewShownDay,
    this.lastDismissAt,
    this.suppressedUntil = const {},
  });

  SgStore copyWith({
    Map<String, SgInstance>? instances,
    int? Function()? lastNewShownDay,
    DateTime? Function()? lastDismissAt,
    Map<SgType, DateTime>? suppressedUntil,
  }) => SgStore(
    instances: instances ?? this.instances,
    lastNewShownDay: lastNewShownDay != null
        ? lastNewShownDay()
        : this.lastNewShownDay,
    lastDismissAt: lastDismissAt != null ? lastDismissAt() : this.lastDismissAt,
    suppressedUntil: suppressedUntil ?? this.suppressedUntil,
  );

  SgStore withInstance(SgInstance i) =>
      copyWith(instances: {...instances, i.key: i});

  String encodeInstances() =>
      jsonEncode({for (final e in instances.entries) e.key: e.value.toJson()});

  String encodeSuppressed() => jsonEncode({
    for (final e in suppressedUntil.entries)
      e.key.name: e.value.toIso8601String(),
  });

  static SgStore decode({
    String? instances,
    int? lastNewShownDay,
    String? lastDismissAt,
    String? suppressed,
  }) {
    final map = <String, SgInstance>{};
    final sup = <SgType, DateTime>{};
    try {
      if (instances != null) {
        (jsonDecode(instances) as Map<String, dynamic>).forEach((k, v) {
          final i = SgInstance.fromJson(k, v as Map<String, dynamic>);
          if (i != null) map[k] = i;
        });
      }
      if (suppressed != null) {
        (jsonDecode(suppressed) as Map<String, dynamic>).forEach((k, v) {
          final t = SgType.values.asNameMap()[k];
          final d = DateTime.tryParse(v as String);
          if (t != null && d != null) sup[t] = d;
        });
      }
    } catch (_) {
      // Corrupt JSON: start clean rather than break Home.
    }
    return SgStore(
      instances: map,
      lastNewShownDay: lastNewShownDay,
      lastDismissAt: lastDismissAt == null
          ? null
          : DateTime.tryParse(lastDismissAt),
      suppressedUntil: sup,
    );
  }
}

/// Result of [SgScheduler.select].
class SgSelection {
  final SgStore store;
  final SgCandidate? shown;

  /// True when [shown] is a new suggestion (not the carried-over active one).
  final bool isNew;
  const SgSelection(this.store, this.shown, {this.isNew = false});
}

class SgScheduler {
  const SgScheduler._();

  static int dayStamp(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

  static DateTime _dayStart(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Global eligibility checks that need no data (suggestion-rules.md §3.1
  /// to 3.5). The provider runs these first, so the rules never run for an
  /// ineligible install or session.
  /// Why Kuber card (specs/home-v3.3/plan.md §4): every install on the
  /// widget model, once Get started has graduated (no 24 h wait), until the
  /// tour is seen or the card is closed. Shown before any other suggestion
  /// and outside the daily allowance.
  static bool whyKuberEligible({
    required bool isV2,
    required bool gsGraduated,
    required bool setting,
    required bool promoVisible,
    required bool sessionLocked,
    required bool tourSeen,
    required bool cardDismissed,
  }) =>
      isV2 &&
      gsGraduated &&
      setting &&
      !promoVisible &&
      !sessionLocked &&
      !tourSeen &&
      !cardDismissed;

  static bool eligible({
    required bool isV2,
    required DateTime? gsGraduatedAt,
    required bool setting,
    required bool promoVisible,
    required bool sessionLocked,
    required DateTime now,
  }) =>
      isV2 &&
      gsGraduatedAt != null &&
      now.difference(gsGraduatedAt) >= const Duration(hours: 24) &&
      setting &&
      !promoVisible &&
      !sessionLocked;

  /// True when nothing *new* can be shown today: the daily cap is used or
  /// the dismiss cooldown runs. A carried-over active instance may still
  /// show, so the provider only skips the rules when there is none.
  static bool newBlocked(SgStore s, DateTime now) {
    if (s.lastNewShownDay == dayStamp(now)) return true;
    final d = s.lastDismissAt;
    if (d != null &&
        _dayStart(now).isBefore(_dayStart(d).add(const Duration(days: 2)))) {
      return true;
    }
    return false;
  }

  static SgInstance? activeInstance(SgStore s) {
    for (final i in s.instances.values) {
      if (i.state == SgState.active) return i;
    }
    return null;
  }

  /// Picks the card for the first Home build of a session from the engine's
  /// [candidates] (instances whose trigger is true now).
  ///
  /// [movedBack]: types matching a "What do you want to track?" choice sort
  /// after every other data type, still before discovery types (v3 §6).
  static SgSelection select(
    SgStore store,
    List<SgCandidate> candidates,
    DateTime now, {
    Set<SgType> movedBack = const {},
  }) {
    var s = store;
    final today = dayStamp(now);
    final byKey = {for (final c in candidates) c.key: c};

    // 1. The active instance, if its trigger still holds.
    final active = activeInstance(s);
    if (active != null) {
      final c = byKey[active.key];
      if (c == null) {
        // Trigger became false: removed (it may come back as a candidate).
        s = s.withInstance(
          active.copyWith(state: SgState.candidate, shownDays: const []),
        );
      } else {
        final days = {...active.shownDays, today}.toList()..sort();
        if (days.length >= 3) {
          // Shown on 3 different days with no interaction: one Not now,
          // without the session lock.
          s = notNow(s, active.key, now);
        } else {
          s = s.withInstance(active.copyWith(shownDays: days));
          return SgSelection(s, c);
        }
      }
    }

    // 2. One new suggestion per day; 2 days quiet after a dismiss.
    if (newBlocked(s, now)) return SgSelection(s, null);

    // 3. Candidates: fresh, or snoozed and due; type not suppressed.
    bool available(SgCandidate c) {
      final until = s.suppressedUntil[c.type];
      if (until != null && now.isBefore(until)) return false;
      final i = s.instances[c.key];
      if (i == null || i.state == SgState.candidate) return true;
      if (i.state == SgState.snoozed) {
        return !(i.snoozedUntil?.isAfter(now) ?? false);
      }
      return false; // accepted, dismissed, or (already handled) active
    }

    final pool = candidates.where(available).toList();
    if (pool.isEmpty) return SgSelection(s, null);

    // 4. Data types first, lowest priority number, then the tie-break.
    final data = pool.where((c) => !c.type.isDiscovery).toList();
    final from = data.isNotEmpty ? data : pool;
    from.sort((a, b) {
      final m = (movedBack.contains(a.type) ? 1 : 0).compareTo(
        movedBack.contains(b.type) ? 1 : 0,
      );
      if (m != 0) return m;
      final p = a.type.priority.compareTo(b.type.priority);
      return p != 0 ? p : b.rank.compareTo(a.rank);
    });
    final pick = from.first;

    // 5. Mark active.
    final prev = s.instances[pick.key];
    s = s
        .withInstance(
          (prev ?? SgInstance(key: pick.key, type: pick.type)).copyWith(
            state: SgState.active,
            firstShownAt: prev?.firstShownAt ?? now,
            shownDays: [today],
            snoozedUntil: () => null,
          ),
        )
        .copyWith(lastNewShownDay: () => today);
    return SgSelection(s, pick, isNew: true);
  }

  /// Not now: snooze 14 days, then 30; the third becomes dismissed.
  static SgStore notNow(SgStore s, String key, DateTime now) {
    final i = s.instances[key];
    if (i == null) return s;
    final n = i.snoozeCount + 1;
    if (n >= 3) {
      return s.withInstance(
        i.copyWith(
          state: SgState.dismissed,
          snoozeCount: n,
          resolvedAt: () => now,
          snoozedUntil: () => null,
        ),
      );
    }
    return s.withInstance(
      i.copyWith(
        state: SgState.snoozed,
        snoozeCount: n,
        snoozedUntil: () => now.add(Duration(days: n == 1 ? 14 : 30)),
        shownDays: const [],
      ),
    );
  }

  /// Dismiss: permanent for the instance; 2-day cooldown; two dismissed
  /// instances of one type within 90 days suppress the type for 90 days.
  static SgStore dismiss(SgStore s, String key, DateTime now) {
    final i = s.instances[key];
    if (i == null) return s;
    var out = s
        .withInstance(
          i.copyWith(state: SgState.dismissed, resolvedAt: () => now),
        )
        .copyWith(lastDismissAt: () => now);
    final recent = out.instances.values.where(
      (x) =>
          x.type == i.type &&
          x.state == SgState.dismissed &&
          x.resolvedAt != null &&
          now.difference(x.resolvedAt!) <= const Duration(days: 90),
    );
    if (recent.length >= 2) {
      out = out.copyWith(
        suppressedUntil: {
          ...out.suppressedUntil,
          i.type: now.add(const Duration(days: 90)),
        },
      );
    }
    return out;
  }

  /// Main action saved (data types) or tapped (discovery types).
  static SgStore accept(SgStore s, String key, DateTime now) {
    final i = s.instances[key];
    if (i == null) return s;
    return s.withInstance(
      i.copyWith(state: SgState.accepted, resolvedAt: () => now),
    );
  }

  /// "Next suggestion after accept" is allowed only when today's new
  /// allowance is unused (the accepted card was carried over).
  static bool canShowNextAfterAccept(SgStore before, DateTime now) =>
      before.lastNewShownDay != dayStamp(now);
}
