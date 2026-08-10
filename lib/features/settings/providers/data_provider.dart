import 'dart:io';
import 'dart:async';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/core/utils/locale_font.dart' show AppLocale;
import 'package:kuber/l10n/app_localizations.dart' show lookupAppLocalizations;
import 'package:isar_community/isar.dart';
import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../features/transactions/services/suggestion_service.dart';
import '../../kuber_cards/data/card_keystore.dart';
import '../../kuber_cards/providers/kuber_cards_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../stories/providers/story_providers.dart';
import '../../stories/services/welcome_story.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/prefs_keys.dart';

enum DataOpStatus { initial, loading, success, error }

class DataState {
  final DataOpStatus status;
  final String? message;
  final int? successCount;
  final int? failureCount;
  final String? filePath; // Main file for "Open"
  final List<String>? filePaths; // All files for "Share"
  final String? loadingMessage;

  /// True when a JSON import just restored encrypted Kuber Cards that are locked
  /// (they need the PIN from the backup's device). Drives the post-import
  /// "Encrypted cards found" prompt. Reset by [reset].
  final bool lockedCardsFound;

  DataState({
    this.status = DataOpStatus.initial,
    this.message,
    this.successCount,
    this.failureCount,
    this.filePath,
    this.filePaths,
    this.loadingMessage,
    this.lockedCardsFound = false,
  });

  DataState copyWith({
    DataOpStatus? status,
    String? message,
    int? successCount,
    int? failureCount,
    String? filePath,
    List<String>? filePaths,
    String? loadingMessage,
    bool? lockedCardsFound,
  }) {
    return DataState(
      status: status ?? this.status,
      message: message, // Allow nulling out
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      filePath: filePath ?? this.filePath,
      filePaths: filePaths ?? this.filePaths,
      loadingMessage: loadingMessage ?? this.loadingMessage,
      lockedCardsFound: lockedCardsFound ?? this.lockedCardsFound,
    );
  }
}

final dataServiceProvider = Provider<DataService>((ref) {
  final isar = ref.watch(tutorialAwareIsarProvider);
  return DataService(isar);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final dataControllerProvider = StateNotifierProvider<DataController, DataState>(
  (ref) {
    final service = ref.watch(dataServiceProvider);
    final notificationService = ref.watch(notificationServiceProvider);
    return DataController(service, notificationService, ref);
  },
);

class DataController extends StateNotifier<DataState> {
  final DataService _service;
  final NotificationService _notificationService;
  final Ref _ref;

  static const notificationId = 1001;
  DataController(this._service, this._notificationService, this._ref)
    : super(DataState());

  Future<void> exportData() async {
    state = state.copyWith(status: DataOpStatus.loading, filePath: null);

    try {
      await _notificationService.init();
      await _notificationService.requestPermission();

      // Non-awaited to avoid blocking the main flow
      final l = lookupAppLocalizations(AppLocale.current);
      _notificationService.showExportNotification(
        id: notificationId,
        title: l.exportingData,
        body: l.preparingFile,
        isProgress: true,
      );

      final exports = await _service.exportData();
      final entry = exports.entries.first;
      final timestamp = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());
      final fileName = 'kuber_backup_$timestamp.csv';

      final path = await _saveFile(entry.value, fileName);

      if (path != null) {
        state = state.copyWith(
          status: DataOpStatus.success,
          message: l.dataExportedSuccess,
          filePath: path,
          filePaths: [path],
        );

        _notificationService.showExportNotification(
          id: notificationId,
          title: l.exportComplete,
          body: l.savedToDownloads(fileName),
          isSuccess: true,
          payload: path,
        );
      }
    } catch (e) {
      final l = lookupAppLocalizations(AppLocale.current);
      state = state.copyWith(
        status: DataOpStatus.error,
        message: l.exportFailedMsg(e.toString()),
      );

      _notificationService.showExportNotification(
        id: notificationId,
        title: l.exportFailed,
        body: e.toString(),
      );
    }
  }

  Future<String?> _saveFile(String content, String fileName) async {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = Directory('/storage/emulated/0/Download');
      if (!await directory.exists()) {
        try {
          await directory.create(recursive: true);
        } catch (_) {}
      }
    } else {
      directory = await getDownloadsDirectory();
    }

    directory ??= await getExternalStorageDirectory();
    directory ??= await getApplicationDocumentsDirectory();

    final file = File('${directory.path}/$fileName');
    await file.writeAsString(content);
    return file.path;
  }

  Future<void> downloadTemplate() async {
    state = state.copyWith(status: DataOpStatus.loading, filePath: null);

    await _notificationService.init();
    await _notificationService.requestPermission();

    const notificationId = 1002;
    final l = lookupAppLocalizations(AppLocale.current);
    await _notificationService.showExportNotification(
      id: notificationId,
      title: l.downloadingTemplate,
      body: l.preparingCsvTemplate,
      isProgress: true,
    );

    try {
      final path = await _service.downloadTemplate();
      state = state.copyWith(
        status: DataOpStatus.success,
        message: l.templateDownloadedSuccess,
        filePath: path,
      );

      final fileName = path?.split('/').last ?? 'template.csv';
      await _notificationService.showExportNotification(
        id: notificationId,
        title: l.downloadComplete,
        body: l.savedToDownloads(fileName),
        isSuccess: true,
        payload: path,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataOpStatus.error,
        message: l.downloadFailedMsg(e.toString()),
      );
      await _notificationService.showExportNotification(
        id: notificationId,
        title: l.downloadFailedTitle,
        body: e.toString(),
      );
    }
  }

  Future<void> importData() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      state = state.copyWith(
        status: DataOpStatus.loading,
        loadingMessage: 'Importing data...',
      );

      int totalSuccess = 0;
      int totalFailure = 0;

      for (final fileData in result.files) {
        final file = File(fileData.path!);
        final csvContent = await file.readAsString();
        final importResult = await _service.importData(csvContent);

        if (importResult.error != null) {
          // Skip or handle individual file error
        } else {
          totalSuccess += importResult.successCount;
          totalFailure += importResult.failureCount;
        }
      }

      await _refreshData();
      final msg = totalFailure > 0
          ? 'Imported $totalSuccess records, $totalFailure failed'
          : 'Imported $totalSuccess records successfully';

      state = state.copyWith(
        status: DataOpStatus.success,
        message: msg,
        successCount: totalSuccess,
        failureCount: totalFailure,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataOpStatus.error,
        message: lookupAppLocalizations(AppLocale.current).importFailedMsg(e.toString()),
      );
    }
  }

  Future<void> generateMockData() async {
    state = state.copyWith(
      status: DataOpStatus.loading,
      loadingMessage: 'Generating mock data...',
    );
    try {
      await _service.generateMockData();
      await _refreshData();
      state = state.copyWith(
        status: DataOpStatus.success,
        message: lookupAppLocalizations(AppLocale.current).mockDataGenerated,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataOpStatus.error,
        message: lookupAppLocalizations(AppLocale.current).generationFailedMsg(e.toString()),
      );
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(
      status: DataOpStatus.loading,
      loadingMessage: 'Clearing all data...',
    );
    try {
      await _service.clearAllData();
      // isar.clear() drops the storedCards + cardVaultMetas collections, but the
      // derived key lives in the hardware Keystore and the in-memory session
      // holds a stale key + cached card list. Wipe the Keystore and reset the
      // card providers so "clear all" truly leaves no card residue behind.
      await CardKeystore.clear();
      _ref.read(cardSessionProvider.notifier).lock();
      _ref.invalidate(cardVaultMetaProvider);
      _ref.invalidate(storedCardsProvider);
      // A full wipe resets the user to a fresh state, so the Welcome bubble
      // should appear again.
      await _refreshData(freshStart: true);
      state = state.copyWith(
        status: DataOpStatus.success,
        message: lookupAppLocalizations(AppLocale.current).allDataCleared,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataOpStatus.error,
        message: lookupAppLocalizations(AppLocale.current).clearFailedMsg(e.toString()),
      );
    }
  }

  Future<void> runImport(
    String content, {
    required bool isJson,
    bool override = false,
  }) async {
    state = state.copyWith(
      status: DataOpStatus.loading,
      loadingMessage: 'Importing data…',
    );
    try {
      ImportResult result;
      if (isJson) {
        result = await _service.importJson(
          content,
          onProgress: (label, current, total) {
            if (!mounted) return;
            final String msg;
            if (label == 'suggestions') {
              msg = 'Rebuilding suggestions…';
            } else if (total >= 20) {
              msg = 'Importing $current/$total $label…';
            } else {
              msg = 'Importing $label…';
            }
            state = state.copyWith(loadingMessage: msg);
          },
        );
      } else {
        result = await _service.importData(content, override: override);
      }
      if (result.error != null) throw Exception(result.error);
      await _refreshData();

      // A JSON restore may carry encrypted Kuber Cards. They come in locked
      // (they need the PIN from the backup's device). Reset the card session so
      // the stale unlocked vault can't bypass the unlock gate, then surface
      // whether any locked cards exist so the screen can prompt for that PIN.
      var lockedCards = false;
      if (isJson) {
        final cardService = _ref.read(cardVaultServiceProvider);
        final meta = await cardService.readMeta();
        if (meta?.hasLockedImport == true) {
          lockedCards = (await cardService.allCards()).isNotEmpty;
        }
        _ref.read(cardSessionProvider.notifier).lock();
        _ref.invalidate(cardVaultMetaProvider);
        _ref.invalidate(storedCardsProvider);
      }

      final msg = result.failureCount > 0
          ? 'Imported ${result.successCount} records, ${result.failureCount} failed'
          : 'Imported ${result.successCount} records successfully';
      state = state.copyWith(
          status: DataOpStatus.success,
          message: msg,
          lockedCardsFound: lockedCards);
    } catch (e) {
      state = state.copyWith(
        status: DataOpStatus.error,
        message: lookupAppLocalizations(AppLocale.current).importFailedMsg(e.toString()),
      );
    }
  }

  Future<void> rebuildSuggestions() async {
    state = state.copyWith(
      status: DataOpStatus.loading,
      loadingMessage: 'Rebuilding suggestions…',
    );
    try {
      final suggestionService = SuggestionService(_service.isar);
      await suggestionService.clearAll();
      final txns = await _service.isar.transactions.where().findAll();
      for (final tx in txns) {
        if (!tx.isTransfer) {
          await suggestionService.upsertSuggestion(tx);
        }
      }
      state = state.copyWith(
        status: DataOpStatus.success,
        message: lookupAppLocalizations(AppLocale.current).suggestionsRebuilt,
      );
    } catch (e) {
      state = state.copyWith(
        status: DataOpStatus.error,
        message: lookupAppLocalizations(AppLocale.current).rebuildFailedMsg(e.toString()),
      );
    }
  }

  Future<void> _refreshData({bool freshStart = false}) async {
    final prefs = await SharedPreferences.getInstance();
    // Clear the once-per-day gate so a forced regeneration below actually runs.
    await prefs.remove(PrefsKeys.lastStoryGenerationDate);
    // On a full wipe, treat the user as fresh so Welcome can be re-seeded.
    if (freshStart) {
      await prefs.remove(PrefsKeys.welcomeStoryGenerated);
    }

    _ref.invalidate(transactionListProvider);
    _ref.invalidate(allAccountsProvider);
    _ref.invalidate(categoryListProvider);
    _ref.invalidate(recurringListProvider);
    // These derived providers will automatically update because they watch transactionListProvider

    // Refresh stories now so the ring reflects the new data without an app
    // restart. A full wipe is a fresh start, so force the Welcome bubble back.
    // Best-effort — failures must not break the data operation.
    try {
      if (freshStart) {
        await reseedWelcomeStory(_service.isar);
      }
      // Run unawaited so background isolate work doesn't block the UI loading indicator
      unawaited(_ref.read(storyGenerationProvider.notifier).regenerate());
    } catch (_) {
      // Swallowed: stories are non-critical to the data operation result.
    }
    _ref.invalidate(storiesProvider);
  }

  void refreshAfterImport() {
    _refreshData();
  }

  void reset() {
    state = DataState();
  }
}
