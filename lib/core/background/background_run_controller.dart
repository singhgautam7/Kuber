// Follows a background run (BackgroundTaskRun rows, written by the worker
// isolate or in-process) and drives the one progress snackbar:
//   - nothing for the first 400 ms; a run that finishes by then goes straight
//     to its result,
//   - progress (step text, no timer, no swipe; during backup a swipe is
//     allowed after 5 s with "Continues in the background"),
//   - result / failure as the normal snackbar, or nothing when nothing
//     needed doing.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../features/budgets/providers/budget_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/investments/providers/investment_provider.dart';
import '../../features/loans/providers/loan_provider.dart';
import '../../features/recurring/providers/recurring_provider.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/timed_snackbar.dart';
import '../database/isar_service.dart';
import '../router/app_router.dart';
import '../utils/locale_font.dart' show AppLocale;
import 'background_task_run.dart';
import 'background_tasks.dart';

class BackgroundRunWatch extends Notifier<BackgroundTaskRun?> {
  static const showDelay = Duration(milliseconds: 400);
  static const swipeAfter = Duration(seconds: 5);
  static const giveUp = Duration(minutes: 2);

  DateTime? _since;
  StreamSubscription<void>? _sub;
  Timer? _poll, _delay, _swipe, _deadline;
  bool _progressShown = false;
  bool _finished = false;
  DateTime? _backupStartedAt;

  @override
  BackgroundTaskRun? build() {
    ref.onDispose(_stop);
    return null;
  }

  Isar get _isar => ref.read(isarProvider);
  AppLocalizations get _l10n => lookupAppLocalizations(AppLocale.current);

  /// Starts following the run that begins at or after [since].
  void watchFrom(DateTime since) {
    _stop();
    _since = since.subtract(const Duration(seconds: 2));
    _progressShown = false;
    _finished = false;
    _backupStartedAt = null;
    state = null;
    _sub = _isar.backgroundTaskRuns.watchLazy().listen((_) => _refresh());
    // Cross-isolate safety net while a run is active (cheap single query).
    _poll = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
    _delay = Timer(showDelay, _showProgressIfRunning);
    _deadline = Timer(giveUp, () {
      if (!_finished) {
        KuberProgressSnackBar.hide();
        _stop();
      }
    });
    _refresh();
  }

  // Sync read: runs are pruned to 30 rows, so well under a millisecond, and
  // Isar readers never wait on the worker isolate's write transactions.
  void _refresh() {
    if (_finished || _since == null) return;
    final run = _isar.backgroundTaskRuns
        .filter()
        .startedAtGreaterThan(_since!)
        .sortByStartedAtDesc()
        .findFirstSync();
    if (run == null) return;
    state = run;
    if (run.status == 'running') {
      if (run.step == 'backup') {
        _backupStartedAt ??= DateTime.now();
        _swipe ??= Timer(swipeAfter, _allowSwipe);
      }
      if (_progressShown) KuberProgressSnackBar.update(_progressState(run));
    } else {
      _finish(run);
    }
  }

  KuberProgressState _progressState(BackgroundTaskRun? run) {
    final text = run == null ? _l10n.bgStepStarting : BackgroundTasks.stepText(run, _l10n);
    final swipeable = run?.step == 'backup' &&
        _backupStartedAt != null &&
        DateTime.now().difference(_backupStartedAt!) >= swipeAfter;
    return KuberProgressState(text,
        detail: swipeable ? _l10n.bgContinues : null, dismissible: swipeable);
  }

  void _showProgressIfRunning() {
    if (_finished) return;
    final overlay = rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;
    _progressShown = true;
    KuberProgressSnackBar.show(overlay, _progressState(state), onSwiped: () async {
      final r = state;
      if (r == null) return;
      r.snackbarDismissed = true;
      await _isar.writeTxn(() => _isar.backgroundTaskRuns.put(r));
    });
  }

  void _allowSwipe() {
    if (_finished || !_progressShown) return;
    KuberProgressSnackBar.update(_progressState(state));
  }

  void _finish(BackgroundTaskRun run) {
    _finished = true;
    _stop();
    // The worker isolate wrote these; the lists only reload on their own writes.
    if (run.postedRecurring + run.postedEmis + run.postedSips + run.maturedCount > 0) {
      for (final ProviderOrFamily p in [
        transactionListProvider,
        categoryListProvider,
        budgetListProvider,
        recurringListProvider,
        loanListProvider,
        investmentListProvider,
      ]) {
        ref.invalidate(p);
      }
    }
    final context = rootNavigatorKey.currentContext;
    if (context == null || run.resultShown) {
      KuberProgressSnackBar.hide();
      return;
    }
    final l = _l10n;
    final text = BackgroundTasks.resultText(run, l);
    final backupFailed = run.backupStatus == 'failed';
    final failed = backupFailed || run.failedOccurrences > 0;
    final posted = run.postedRecurring + run.postedEmis + run.postedSips;
    if (text.isEmpty) {
      KuberProgressSnackBar.hide();
      return;
    }
    KuberProgressSnackBar.finish(
      context,
      text,
      isError: failed,
      actionLabel: backupFailed && run.failedOccurrences == 0 ? l.bgRetry : l.bgView,
      onAction: () {
        if (backupFailed && run.failedOccurrences == 0) {
          BackgroundTasks.start(_isar, l, trigger: 'retry', force: true)
              .then((started) {
            if (started) watchFrom(DateTime.now());
          });
          return;
        }
        final ctx = rootNavigatorKey.currentContext;
        if (ctx == null) return;
        if (posted == 0 && run.failedOccurrences == 0 && run.backupStatus == 'done') {
          GoRouter.of(ctx).go('/more/data/automatic-backups');
        } else {
          GoRouter.of(ctx).go('/more/recurring', extra: 'processed');
        }
      },
    );
    run.resultShown = true;
    _isar.writeTxn(() => _isar.backgroundTaskRuns.put(run));
  }

  void _stop() {
    _sub?.cancel();
    _poll?.cancel();
    _delay?.cancel();
    _swipe?.cancel();
    _deadline?.cancel();
    _sub = null;
    _poll = _delay = _swipe = _deadline = null;
  }
}

final backgroundRunWatchProvider =
    NotifierProvider<BackgroundRunWatch, BackgroundTaskRun?>(BackgroundRunWatch.new);

/// '{sourceType}:{sourceId}' of the items being processed right now.
final backgroundBusyProvider = Provider<Set<String>>((ref) {
  final run = ref.watch(backgroundRunWatchProvider);
  if (run == null || run.status != 'running') return const {};
  return run.busySourceKeys.toSet();
});

/// True (and shows "Processing, try again in a moment") when [sourceKey]
/// is being processed by a background run: editors check this first.
bool blockIfProcessing(BuildContext context, WidgetRef ref, String sourceKey) {
  if (!ref.read(backgroundBusyProvider).contains(sourceKey)) return false;
  showKuberSnackBar(context, AppLocalizations.of(context)!.msBusy);
  return true;
}
