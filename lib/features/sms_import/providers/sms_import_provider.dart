import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/services/suggestion_service.dart';
import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../data/sms_import_repository.dart';
import '../data/sms_transaction.dart';
import '../engine/account_matcher.dart';
import '../engine/category_keyword_map.dart';
import '../engine/scan_progress.dart';
import '../engine/sms_parser.dart';
import '../services/sms_inbox_service.dart';
import '../services/sms_scan_runner.dart';
import 'sms_account_mapping_provider.dart';

/// Shared-prefs key for the last completed scan timestamp (ISO string).
const _kLastScannedAtKey = 'sms_import_last_scanned_at';

/// Sentinel so [SmsImportState.copyWith] can set `scanProgress` back to null.
const Object _unchanged = Object();

final smsImportRepositoryProvider = Provider<SmsImportRepository>((ref) {
  return SmsImportRepository(ref.watch(tutorialAwareIsarProvider));
});

final smsInboxServiceProvider = Provider<SmsInboxService>(
  (ref) => const SmsInboxService(),
);

/// Snapshot of the staging collection, split by review status, plus scan and
/// permission flags.
class SmsImportState {
  final List<SmsTransaction> unreviewed;
  final List<SmsTransaction> imported;
  final List<SmsTransaction> dismissed;
  final bool hasPermission;

  /// Non-null while a scan is in flight (or briefly after, on success). Drives
  /// the first-load screen, the refresh strip and the widget's State D.
  final ScanProgress? scanProgress;

  /// When the last scan completed. Used to gate background refreshes.
  final DateTime? lastScannedAt;

  const SmsImportState({
    this.unreviewed = const [],
    this.imported = const [],
    this.dismissed = const [],
    this.hasPermission = false,
    this.scanProgress,
    this.lastScannedAt,
  });

  int get unreviewedCount => unreviewed.length;

  bool get isScanning => scanProgress != null && !scanProgress!.isComplete;

  /// All reviewed rows (imported + dismissed), newest first by sms date, for
  /// the muted "below separator" section.
  List<SmsTransaction> get reviewed {
    final all = [...imported, ...dismissed]
      ..sort((a, b) => b.smsDate.compareTo(a.smsDate));
    return all;
  }

  SmsImportState copyWith({
    List<SmsTransaction>? unreviewed,
    List<SmsTransaction>? imported,
    List<SmsTransaction>? dismissed,
    bool? hasPermission,
    Object? scanProgress = _unchanged,
    DateTime? lastScannedAt,
  }) {
    return SmsImportState(
      unreviewed: unreviewed ?? this.unreviewed,
      imported: imported ?? this.imported,
      dismissed: dismissed ?? this.dismissed,
      hasPermission: hasPermission ?? this.hasPermission,
      scanProgress: identical(scanProgress, _unchanged)
          ? this.scanProgress
          : scanProgress as ScanProgress?,
      lastScannedAt: lastScannedAt ?? this.lastScannedAt,
    );
  }
}

final smsImportProvider =
    AsyncNotifierProvider<SmsImportNotifier, SmsImportState>(
      SmsImportNotifier.new,
    );

class SmsImportNotifier extends AsyncNotifier<SmsImportState> {
  SmsScanController? _controller;
  DateTime? _lastScannedAt;
  bool _scanInProgress = false;

  @override
  FutureOr<SmsImportState> build() async {
    ref.keepAlive();
    ref.onDispose(() => _controller?.cancel());
    _lastScannedAt = await _readLastScannedAt();
    return _load();
  }

  Future<SmsImportState> _load({ScanProgress? scanProgress}) async {
    final repo = ref.read(smsImportRepositoryProvider);
    final unreviewed = await repo.getByStatus(SmsReviewStatus.unreviewed);
    final imported = await repo.getByStatus(SmsReviewStatus.imported);
    final dismissed = await repo.getByStatus(SmsReviewStatus.dismissed);
    final hasPermission = await _checkPermission();
    return SmsImportState(
      unreviewed: unreviewed,
      imported: imported,
      dismissed: dismissed,
      hasPermission: hasPermission,
      scanProgress: scanProgress,
      lastScannedAt: _lastScannedAt,
    );
  }

  Future<bool> _checkPermission() async {
    final service = ref.read(smsInboxServiceProvider);
    return service.checkPermission();
  }

  Future<int> getUnreviewedCount() {
    return ref.read(smsImportRepositoryProvider).countUnreviewed();
  }

  // ── Scan orchestration ────────────────────────────────────────────────────

  bool get isScanning => _scanInProgress;

  /// Whether a fresh first-load scan is warranted: granted, supported, the
  /// staging collection is empty and no scan has ever run.
  bool shouldFirstLoad() {
    final s = state.valueOrNull;
    if (s == null) return false;
    final empty = s.unreviewed.isEmpty &&
        s.imported.isEmpty &&
        s.dismissed.isEmpty;
    return s.hasPermission && empty && _lastScannedAt == null;
  }

  /// True if a background refresh is due (a prior scan exists and it was more
  /// than [minInterval] ago).
  bool backgroundRefreshDue({Duration minInterval = const Duration(minutes: 30)}) {
    if (_lastScannedAt == null) return false;
    return DateTime.now().difference(_lastScannedAt!) > minInterval;
  }

  /// Full-screen first-load scan (Scenario A).
  Future<void> startFirstLoadScan() => _runScan(ScanTrigger.firstLoad);

  /// Non-blocking background refresh (Scenario B).
  Future<void> startBackgroundScan() {
    if (isScanning) return Future.value();
    return _runScan(ScanTrigger.backgroundRefresh);
  }

  /// Cancels an in-flight scan, discarding partial work.
  void cancelScan() => _controller?.cancel();

  /// Clears a completed scanProgress (called by the first-load screen once it
  /// has transitioned to the list).
  void clearScanProgress() {
    final s = state.valueOrNull;
    if (s != null) state = AsyncData(s.copyWith(scanProgress: null));
  }

  Future<void> _runScan(ScanTrigger trigger) async {
    if (_scanInProgress) return;
    _scanInProgress = true;

    try {
      final service = ref.read(smsInboxServiceProvider);
      if (!service.isSupported || !await service.checkPermission()) {
        state = AsyncData(await _load());
        return;
      }
      if (_controller != null) return;

      // Indeterminate "preparing" state while we read the inbox.
      _emit(ScanProgress(
        totalMessages: 0,
        scannedMessages: 0,
        bankMessagesFound: 0,
        isComplete: false,
        trigger: trigger,
      ));

      List<RawInboxSms> raw;
      try {
        if (trigger == ScanTrigger.backgroundRefresh && _lastScannedAt != null) {
          final since = _lastScannedAt!.subtract(const Duration(hours: 1));
          raw = await service.readRawInbox(since: since);
        } else {
          raw = await service.readRawInbox(days: 90);
        }
      } catch (_) {
        state = AsyncData(await _load());
        return;
      }

      // Total is known now; bar becomes determinate.
      _emit(ScanProgress(
        totalMessages: raw.length,
        scannedMessages: 0,
        bankMessagesFound: 0,
        isComplete: false,
        trigger: trigger,
      ));

      final controller = SmsScanController();
      _controller = controller;
      final sub = controller.progress.listen(_emit);
      final results = await controller.run(raw, trigger);
      await sub.cancel();
      _controller = null;

      if (results == null) {
        // Cancelled — discard partial work, clear progress.
        state = AsyncData(await _load());
        return;
      }

      var inserted = 0;
      try {
        final rows = await _toStagingRows(results);
        inserted = await ref.read(smsImportRepositoryProvider).insertNew(rows);
      } catch (_) {
        // Persist failure is non-fatal; the scan simply adds nothing.
      }

      _lastScannedAt = DateTime.now();
      await _writeLastScannedAt(_lastScannedAt!);

      // Final state: bankMessagesFound carries the count of *new* rows added.
      final done = ScanProgress(
        totalMessages: raw.length,
        scannedMessages: raw.length,
        bankMessagesFound: inserted,
        isComplete: true,
        trigger: trigger,
      );
      state = AsyncData((await _load()).copyWith(scanProgress: done));

      // The background strip fades itself out after 2s; the first-load screen
      // clears progress itself once it transitions.
      if (trigger == ScanTrigger.backgroundRefresh) {
        Future.delayed(const Duration(seconds: 2), () {
          final s = state.valueOrNull;
          if (s != null && identical(s.scanProgress, done)) {
            state = AsyncData(s.copyWith(scanProgress: null));
          }
        });
      }
    } finally {
      _scanInProgress = false;
    }
  }

  /// Pushes a new scanProgress without disturbing the rest of the state.
  void _emit(ScanProgress p) {
    final base = state.valueOrNull ?? const SmsImportState();
    state = AsyncData(base.copyWith(scanProgress: p));
  }

  Future<DateTime?> _readLastScannedAt() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final iso = prefs.getString(_kLastScannedAtKey);
      return iso == null ? null : DateTime.tryParse(iso);
    } catch (_) {
      return null;
    }
  }

  Future<void> _writeLastScannedAt(DateTime when) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kLastScannedAtKey, when.toIso8601String());
    } catch (_) {
      // Non-fatal.
    }
  }

  /// Converts parse results into staging rows with account/category
  /// suggestions resolved against the user's real data.
  Future<List<SmsTransaction>> _toStagingRows(
    List<SmsParseResult> results,
  ) async {
    const matcher = AccountMatcher();
    final accounts = await ref.read(allAccountsProvider.future);
    final categories = await ref.read(categoryListProvider.future);
    final mappingRepo = ref.read(smsAccountMappingRepositoryProvider);

    // Only enabled accounts are valid import targets.
    final matchable = [
      for (final a in accounts.where((a) => !a.isDisabled))
        MatchableAccount(
          id: a.id.toString(),
          name: a.name,
          last4: a.last4Digits,
        ),
    ];

    final rows = <SmsTransaction>[];
    for (final r in results) {
      final learned = await mappingRepo.getForSender(r.senderId);
      final match = matcher.match(
        r,
        matchable,
        learnedForSender: learned == null
            ? null
            : LearnedMapping(
                accountId: learned.accountId,
                usageCount: learned.usageCount,
              ),
      );

      // Resolve suggested category name -> a real category id.
      String? categoryId;
      final suggestedName = suggestCategoryName(r.merchant);
      if (suggestedName != null) {
        for (final c in categories) {
          if (c.name.toLowerCase() == suggestedName.toLowerCase()) {
            categoryId = c.id.toString();
            break;
          }
        }
      }

      rows.add(
        SmsTransaction()
          ..rawSms = r.rawSms
          ..senderId = r.senderId
          ..rawSmsHash = smsHash(r.rawSms, r.senderId)
          ..parsedDate = r.date
          ..parsedAmount = r.amount
          ..parsedType = r.type
          ..parsedMerchant = r.merchant
          ..parsedAccountSuffix = r.accountSuffix
          ..suggestedAccountId = match.accountId
          ..suggestedCategoryId = categoryId
          ..reviewStatus = SmsReviewStatus.unreviewed
          ..smsDate = r.date
          ..patternMatched = r.patternMatched,
      );
    }
    return rows;
  }

  /// Stages a single parsed result coming from the paste flow (sender unknown).
  /// Returns the staged row id.
  Future<SmsTransaction> stageFromPaste(SmsParseResult result) async {
    final rows = await _toStagingRows([result]);
    final row = rows.first;
    final repo = ref.read(smsImportRepositoryProvider);
    final existing = await repo.getByHash(row.rawSmsHash);
    if (existing != null) {
      state = AsyncData(await _load());
      return existing;
    }
    final id = await repo.put(row);
    row.id = id;
    state = AsyncData(await _load());
    return row;
  }

  /// Creates a real [Transaction] from a staged SMS using the user's confirmed
  /// field values, then links the staging row. Returns the new transaction id.
  Future<int> importSingle(
    SmsTransaction sms, {
    required String name,
    required double amount,
    required String type,
    required String accountId,
    String? categoryId,
    required DateTime date,
  }) async {
    final id = await _doImport(
      sms,
      name: name,
      amount: amount,
      type: type,
      accountId: accountId,
      categoryId: categoryId,
      date: date,
    );
    state = AsyncData(await _load());
    return id;
  }

  /// Performs one import without touching provider state, so a batch can reload
  /// the staging list just once instead of per row.
  Future<int> _doImport(
    SmsTransaction sms, {
    required String name,
    required double amount,
    required String type,
    required String accountId,
    String? categoryId,
    required DateTime date,
  }) async {
    final t = Transaction()
      ..name = name
      ..amount = amount
      ..type = type
      ..accountId = accountId
      ..categoryId = categoryId ?? ''
      ..createdAt = date
      ..updatedAt = DateTime.now()
      ..nameLower = name.toLowerCase()
      ..importSource = 'sms'
      ..importedFromSms = sms.rawSms;

    final id = await ref.read(transactionListProvider.notifier).add(t);
    // Mirror the manual-add path: feed the autocomplete suggestion store.
    ref.read(suggestionServiceProvider).upsertSuggestion(t).ignore();
    // Learn the sender -> account association for next time.
    await ref
        .read(smsAccountMappingProvider.notifier)
        .recordMapping(sms.senderId, accountId);
    final repo = ref.read(smsImportRepositoryProvider);
    await repo.markImported(
      sms.id,
      '$id',
      accountId: accountId,
      categoryId: categoryId,
    );
    // Pre-fill the same account on the sender's remaining unreviewed rows so
    // the user does not pick it again for every message from that bank.
    await repo.applyAccountToUnreviewedSender(sms.senderId, accountId);
    return id;
  }

  /// Batch import. Each entry carries its confirmed field values. The staging
  /// list is reloaded once, after all rows are written.
  Future<void> importBatch(List<SmsImportDraft> drafts) async {
    for (final d in drafts) {
      await _doImport(
        d.sms,
        name: d.name,
        amount: d.amount,
        type: d.type,
        accountId: d.accountId,
        categoryId: d.categoryId,
        date: d.date,
      );
    }
    state = AsyncData(await _load());
  }

  Future<void> dismiss(SmsTransaction sms) async {
    await ref.read(smsImportRepositoryProvider).markDismissed(sms.id);
    state = AsyncData(await _load());
  }

  Future<void> dismissBatch(List<int> ids) async {
    await ref.read(smsImportRepositoryProvider).markDismissedBatch(ids);
    state = AsyncData(await _load());
  }

  Future<void> undoDismissBatch(List<int> ids) async {
    await ref.read(smsImportRepositoryProvider).markUnreviewedBatch(ids);
    state = AsyncData(await _load());
  }

  /// Returns an existing transaction that looks like a duplicate of the given
  /// values (same amount, same account, date within +/- 1 day), or null.
  Transaction? findDuplicate({
    required double amount,
    required String accountId,
    required DateTime date,
  }) {
    final txns = ref.read(transactionListProvider).valueOrNull;
    if (txns == null) return null;
    for (final t in txns) {
      if (t.accountId != accountId) continue;
      if ((t.amount - amount).abs() > 0.001) continue;
      if (t.createdAt.difference(date).inHours.abs() <= 24) return t;
    }
    return null;
  }

  /// Prunes reviewed rows older than 90 days. Fire-and-forget on app open.
  Future<void> cleanupOld() async {
    final cutoff = DateTime.now().subtract(const Duration(days: 90));
    try {
      await ref.read(smsImportRepositoryProvider).cleanupOlderThan(cutoff);
      state = AsyncData(await _load());
    } catch (_) {
      // Non-fatal maintenance.
    }
  }
}

/// Confirmed values for a single transaction in a batch import.
class SmsImportDraft {
  final SmsTransaction sms;
  final String name;
  final double amount;
  final String type;
  final String accountId;
  final String? categoryId;
  final DateTime date;

  const SmsImportDraft({
    required this.sms,
    required this.name,
    required this.amount,
    required this.type,
    required this.accountId,
    this.categoryId,
    required this.date,
  });
}

/// Cheap unreviewed-count provider for the home widget badge. Selects just the
/// count so a scan's per-batch progress emissions (which leave the unreviewed
/// list untouched) never re-run this provider or its listeners.
final smsUnreviewedCountProvider = Provider<int>((ref) {
  return ref.watch(
    smsImportProvider.select((s) => s.valueOrNull?.unreviewedCount ?? 0),
  );
});
