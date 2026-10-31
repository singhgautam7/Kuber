// Follows a background run (BackgroundTaskRun rows, written by the worker
// isolate or in-process) and drives the one progress snackbar:
// reports through the one BackgroundReporter (loan accuracy D3):
//   - nothing for the first 400 ms; a run that finishes by then goes straight
//     to its result,
//   - progress (step text and percentage; during backup a swipe is allowed
//     after 5 s with "Continues in the background"),
//   - result / failure as the normal snackbar (View opens History filtered
//     to what the run added), or nothing when nothing needed doing.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../utils/locale_font.dart' show AppLocale;
import '../schedule/processed_occurrence.dart';
import 'background_reporter.dart';
import 'background_task_run.dart';
import 'background_tasks.dart';

class BackgroundRunWatch extends Notifier<BackgroundTaskRun?> {
  static const swipeAfter = Duration(seconds: 5);
  static const giveUp = Duration(minutes: 2);

  DateTime? _since;
  StreamSubscription<void>? _sub;
  Timer? _poll, _swipe, _deadline;
  bool _finished = false;
  DateTime? _backupStartedAt;
  int? _job;

  BackgroundReporter get _reporter => BackgroundReporter.instance;

  @override
  BackgroundTaskRun? build() {
    ref.onDispose(_stop);
    return null;
  }

  Isar get _isar => ref.read(isarProvider);
  AppLocalizations get _l10n => lookupAppLocalizations(AppLocale.current);

  /// Starts following the run that begins at or after [since]. Its progress
  /// and result go through the one background reporter.
  void watchFrom(DateTime since) {
    _stop();
    if (_job != null) _reporter.finish(_job!, BgOutcome.none);
    _since = since.subtract(const Duration(seconds: 2));
    _finished = false;
    _backupStartedAt = null;
    state = null;
    _job = _reporter.begin(_l10n.bgStepStarting, onSwiped: () async {
      final r = state;
      if (r == null) return;
      r.snackbarDismissed = true;
      await _isar.writeTxn(() => _isar.backgroundTaskRuns.put(r));
    });
    _sub = _isar.backgroundTaskRuns.watchLazy().listen((_) => _refresh());
    // Cross-isolate safety net while a run is active (cheap single query).
    _poll = Timer.periodic(const Duration(seconds: 1), (_) => _refresh());
    _deadline = Timer(giveUp, () {
      if (!_finished) _end(BgOutcome.none);
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
        _swipe ??= Timer(swipeAfter, () => _progress(state));
      }
      _progress(run);
    } else {
      _finish(run);
    }
  }

  void _progress(BackgroundTaskRun? run) {
    final job = _job;
    if (job == null || _finished) return;
    final swipeable = run?.step == 'backup' &&
        _backupStartedAt != null &&
        DateTime.now().difference(_backupStartedAt!) >= swipeAfter;
    _reporter.progress(job,
        text: run == null ? _l10n.bgStepStarting : BackgroundTasks.stepText(run, _l10n),
        // Backup has no count; the occurrence step does.
        done: run?.step == 'processing' ? run!.stepDone : 0,
        total: run?.step == 'processing' ? run!.stepTotal : 0,
        detail: swipeable ? _l10n.bgContinues : null,
        dismissible: swipeable);
  }

  void _finish(BackgroundTaskRun run) {
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
    if (run.resultShown) {
      _end(BgOutcome.none);
      return;
    }
    final l = _l10n;
    final text = BackgroundTasks.resultText(run, l);
    final backupFailed = run.backupStatus == 'failed';
    final ids = [
      for (final p in _isar.processedOccurrences.filter().runIdEqualTo(run.runId).findAllSync())
        if (p.transactionId != null && p.status == 'posted') p.transactionId!,
    ];
    final posted = run.postedRecurring + run.postedEmis + run.postedSips;
    _end(text.isEmpty
        ? BgOutcome.none
        : BgOutcome(
            text,
            error: backupFailed || run.failedOccurrences > 0,
            transactionIds: ids,
            details: run.failedOccurrences > 0 ? run.log.where((e) => e.startsWith('Failed')).join('\n') : null,
            retry: backupFailed && run.failedOccurrences == 0
                ? () => BackgroundTasks.start(_isar, l, trigger: 'retry', force: true).then((started) {
                      if (started) watchFrom(DateTime.now());
                    })
                : null,
            route: posted == 0 && run.backupStatus == 'done'
                ? '/more/data/automatic-backups'
                : (ids.isEmpty ? '/more/recurring' : null),
          ));
    run.resultShown = true;
    _isar.writeTxn(() => _isar.backgroundTaskRuns.put(run));
  }

  void _end(BgOutcome outcome) {
    _finished = true;
    _stop();
    final job = _job;
    _job = null;
    if (job != null) _reporter.finish(job, outcome);
  }

  void _stop() {
    _sub?.cancel();
    _poll?.cancel();
    _swipe?.cancel();
    _deadline?.cancel();
    _sub = null;
    _poll = _swipe = _deadline = null;
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
