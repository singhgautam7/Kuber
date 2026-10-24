// Entry point of the headless Flutter engine that BackgroundTasksWorker.kt
// (WorkManager, expedited) starts. Opens the same Isar database, runs the
// launch task queue and reports back so the worker can finish or retry.

import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/background/background_tasks.dart';
import 'core/database/isar_service.dart';
import 'core/services/notification_service.dart';
import 'core/utils/currency_data.dart';
import 'core/utils/formatters.dart';
import 'core/utils/locale_font.dart' show AppLocale;
import 'core/utils/prefs_keys.dart';
import 'features/settings/providers/settings_provider.dart' show NumberSystem;
import 'l10n/app_localizations.dart';

const _worker = MethodChannel('com.grs.kuber/background_worker');

/// Called from `backgroundMain` in main.dart (the engine entry point must live
/// in the main library to be compiled into the bundle).
Future<void> runBackgroundWorker() async {
  WidgetsFlutterBinding.ensureInitialized();
  var result = <String, Object?>{'status': 'failed', 'retry': true};
  try {
    final trigger = await _worker.invokeMethod<String>('trigger') ?? 'coldStart';
    final prefs = await SharedPreferences.getInstance();
    final locale = Locale(prefs.getString(PrefsKeys.language) ?? 'en');
    AppLocale.current = locale;
    final systemIndex =
        prefs.getInt(PrefsKeys.numberSystem) ?? NumberSystem.automatic.index;
    AppFormatter.current = AppFormatter(
      system: NumberSystem.values[systemIndex.clamp(0, NumberSystem.values.length - 1)],
      currency: currencyFromCode(prefs.getString(PrefsKeys.currency) ?? 'INR'),
      showCode: prefs.getBool(PrefsKeys.showCurrencyCode) ?? false,
    );
    await NotificationService().init();
    final isar = await IsarService.open();
    final l10n = lookupAppLocalizations(locale);
    final run = await BackgroundTasks.runQueue(isar, l10n,
        trigger: trigger, notify: true);
    result = {
      'status': run?.status ?? 'busy',
      'retry': run != null && BackgroundTasks.shouldRetry(run),
    };
  } catch (e) {
    debugPrint('Kuber: background run failed: $e');
  } finally {
    await _worker.invokeMethod('finished', result);
  }
}
