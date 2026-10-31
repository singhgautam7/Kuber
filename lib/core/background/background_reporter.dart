// One in-app snackbar for every background job (loan accuracy D3): the
// launch run (recurring, EMIs, SIPs, FD maturity, automatic backup), Back up
// now, a retry from the failure notification, and past EMIs (Part B).
//
//   - Running: the existing M3 progress snackbar, after 400 ms, "Adding
//     transactions… 40%". Updates at most 4 times a second and only when the
//     percentage (or the text) changes, so a job never rebuilds more than the
//     snackbar.
//   - Done: one message for every job that finished close together ("Added
//     5 transactions · Backup saved"), with View (History filtered to them)
//     or Details for an error.
//   - Nothing for a job that did nothing, and nothing when the app was in the
//     background as it finished (Android shows its notification as before;
//     the result is not replayed on reopen).

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/widgets/timed_snackbar.dart';
import '../router/app_router.dart';
import '../utils/locale_font.dart' show AppLocale, localeFont;

/// What a finished job reports. An empty [text] means nothing happened.
class BgOutcome {
  final String text;
  final List<int> transactionIds;
  final bool error;

  /// Error: the longer reason shown by Details.
  final String? details;

  /// Opened by View when the job added no transactions (backup → backups).
  final String? route;

  /// Error: a retry for the action button instead of Details.
  final VoidCallback? retry;

  const BgOutcome(this.text,
      {this.transactionIds = const [], this.error = false, this.details, this.route, this.retry});

  static const none = BgOutcome('');
}

class _Job {
  String text;
  int done = 0, total = 0;
  String? detail;
  bool dismissible = false;
  VoidCallback? onSwiped;
  _Job(this.text);
}

class BackgroundReporter {
  BackgroundReporter._();
  static final BackgroundReporter instance = BackgroundReporter._();

  static const showDelay = Duration(milliseconds: 400);
  static const combineWindow = Duration(milliseconds: 900);
  static const minUpdateGap = Duration(milliseconds: 250); // 4 per second

  final _jobs = <int, _Job>{};
  final _finished = <BgOutcome>[];
  int _seq = 0;
  Timer? _showTimer, _flushTimer, _pendingUpdate;
  bool _shown = false;
  KuberProgressState? _lastState;
  DateTime _lastUpdate = DateTime(0);

  /// Overridable in tests: the app is in front (a result can be shown).
  @visibleForTesting
  bool Function() inForeground = () {
    final s = WidgetsBinding.instance.lifecycleState;
    return s == null || s == AppLifecycleState.resumed;
  };

  /// Shown snackbars, for tests.
  @visibleForTesting
  final List<String> log = [];

  AppLocalizations get _l => lookupAppLocalizations(AppLocale.current);

  bool get isBusy => _jobs.isNotEmpty;

  /// Starts a job; returns its id for [progress] / [finish].
  int begin(String text, {VoidCallback? onSwiped}) {
    final id = ++_seq;
    _jobs[id] = _Job(text)..onSwiped = onSwiped;
    _flushTimer?.cancel();
    if (_shown) {
      _push(force: true);
    } else {
      _showTimer ??= Timer(showDelay, _showProgress);
    }
    return id;
  }

  /// Progress of a running job ([total] 0 = unknown).
  void progress(int id, {int? done, int? total, String? text, String? detail, bool? dismissible}) {
    final j = _jobs[id];
    if (j == null) return;
    if (done != null) j.done = done;
    if (total != null) j.total = total;
    if (text != null) j.text = text;
    if (detail != null || dismissible != null) j.detail = detail;
    if (dismissible != null) j.dismissible = dismissible;
    if (_shown) _push();
  }

  /// A job ended. Its outcome joins any other that finishes close by.
  void finish(int id, BgOutcome outcome) {
    if (_jobs.remove(id) == null) return;
    if (outcome.text.isNotEmpty) _finished.add(outcome);
    if (_jobs.isNotEmpty) {
      if (_shown) _push(force: true);
      return;
    }
    _showTimer?.cancel();
    _showTimer = null;
    _flushTimer?.cancel();
    _flushTimer = Timer(_finished.isEmpty ? Duration.zero : combineWindow, _flush);
  }

  /// Runs [work] as a job. [work] gets a progress callback (done, total).
  Future<T> run<T>(
    String text,
    Future<T> Function(void Function(int done, int total) progress) work, {
    required BgOutcome Function(T result) outcome,
    BgOutcome Function(Object error)? onError,
  }) async {
    final id = begin(text);
    try {
      final r = await work((d, t) => progress(id, done: d, total: t));
      finish(id, outcome(r));
      return r;
    } catch (e) {
      finish(id, onError?.call(e) ?? BgOutcome(_l.bgJobFailed, error: true, details: '$e'));
      rethrow;
    }
  }

  // ── Snackbar ────────────────────────────────────────────────────────

  KuberProgressState _state() {
    final jobs = _jobs.values.toList();
    final first = jobs.first;
    var done = 0, total = 0;
    for (final j in jobs) {
      done += j.done;
      total += j.total;
    }
    final pct = total > 0 ? (done * 100 ~/ total).clamp(0, 100) : null;
    final text = pct == null ? first.text : _l.bgJobPercent(first.text, pct);
    return KuberProgressState(
      jobs.length > 1 ? _l.bgJobsRunning(text, jobs.length) : text,
      detail: first.detail,
      dismissible: jobs.every((j) => j.dismissible),
      value: pct == null ? null : pct / 100,
    );
  }

  void _showProgress() {
    _showTimer = null;
    if (_jobs.isEmpty) return;
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null || !inForeground()) return;
    _shown = true;
    _lastState = _state();
    _lastUpdate = DateTime.now();
    log.add('progress: ${_lastState!.message}');
    KuberProgressSnackBar.show(overlay, _lastState!, onSwiped: () {
      for (final j in _jobs.values) {
        j.onSwiped?.call();
      }
    });
  }

  void _push({bool force = false}) {
    if (_jobs.isEmpty) return;
    final next = _state();
    final last = _lastState;
    // Only a different percentage, text or swipe state is worth a frame.
    if (!force &&
        last != null &&
        last.message == next.message &&
        last.detail == next.detail &&
        last.dismissible == next.dismissible) {
      return;
    }
    final wait = minUpdateGap - DateTime.now().difference(_lastUpdate);
    if (!force && wait > Duration.zero) {
      _pendingUpdate ??= Timer(wait, () {
        _pendingUpdate = null;
        _push(force: true);
      });
      return;
    }
    _pendingUpdate?.cancel();
    _pendingUpdate = null;
    _lastState = next;
    _lastUpdate = DateTime.now();
    log.add('progress: ${next.message}');
    KuberProgressSnackBar.update(next);
  }

  void _flush() {
    _flushTimer = null;
    _pendingUpdate?.cancel();
    _pendingUpdate = null;
    final outcomes = [..._finished];
    _finished.clear();
    final wasShown = _shown;
    _shown = false;
    _lastState = null;
    final context = rootNavigatorKey.currentContext;
    if (outcomes.isEmpty || context == null || !inForeground()) {
      if (wasShown) KuberProgressSnackBar.hide();
      return;
    }
    final l = _l;
    final text = outcomes.map((o) => o.text).join(' · ');
    final error = outcomes.where((o) => o.error).firstOrNull;
    final ids = [for (final o in outcomes) ...o.transactionIds];
    final route = outcomes.map((o) => o.route).whereType<String>().firstOrNull;
    String? label;
    VoidCallback? action;
    if (error != null && error.retry != null) {
      label = l.bgRetry;
      action = error.retry;
    } else if (error != null && error.details != null) {
      label = l.bgDetails;
      action = () => _showDetails(error.details!);
    } else if (ids.isNotEmpty) {
      label = l.bgView;
      action = () => openAdded(ids);
    } else if (route != null) {
      label = l.bgView;
      action = () {
        final ctx = rootNavigatorKey.currentContext;
        if (ctx != null) GoRouter.of(ctx).go(route);
      };
    }
    log.add('done: $text');
    KuberProgressSnackBar.finish(context, text,
        isError: error != null, actionLabel: label, onAction: action);
  }

  /// History filtered to [ids]. Set by the app (it owns the filter).
  void Function(List<int> ids) openAdded = (_) {};

  void _showDetails(String details) {
    final ctx = rootNavigatorKey.currentContext;
    if (ctx == null) return;
    final l = _l;
    showDialog<void>(
      context: ctx,
      builder: (c) => AlertDialog(
        title: Text(l.bgDetailsTitle, style: localeFont(fontWeight: FontWeight.w600)),
        content: SingleChildScrollView(child: Text(details, style: localeFont())),
        actions: [TextButton(onPressed: () => Navigator.pop(c), child: Text(l.gotIt))],
      ),
    );
  }

  @visibleForTesting
  void reset() {
    _showTimer?.cancel();
    _flushTimer?.cancel();
    _pendingUpdate?.cancel();
    _showTimer = _flushTimer = _pendingUpdate = null;
    _jobs.clear();
    _finished.clear();
    _shown = false;
    _lastState = null;
    log.clear();
  }
}
