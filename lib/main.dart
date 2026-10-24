import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'features/settings/providers/theme_options_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'background_main.dart';
import 'core/background/background_tasks.dart';
import 'core/utils/locale_font.dart' show AppLocale;
import 'l10n/app_localizations.dart';
import 'core/router/app_router.dart' show initialLocationProvider;
import 'core/utils/frame_budget_monitor.dart';
import 'core/utils/currency_data.dart';
import 'core/utils/formatters.dart';
import 'core/utils/prefs_keys.dart';
import 'features/settings/providers/settings_provider.dart';
import 'core/database/isar_service.dart';
import 'core/database/migrations.dart';
import 'core/database/seed_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home_v2/data/home_v2_state.dart';
import 'features/home_v2/data/home_v2_widgets.dart';
import 'features/home_v2/providers/has_transactions_provider.dart';
import 'features/transactions/data/transaction.dart';
import 'features/home_v2/providers/home_v2_provider.dart';
import 'core/theme/theme_families.dart' show resolveVariant;
import 'features/notifications/providers/notification_provider.dart';
import 'features/reminders/data/reminder_action_handler.dart';
import 'features/stories/services/welcome_story.dart';
import 'features/pro/paywall/pro_state.dart';


/// "The app is interactive": the cold-start splash has finished fading. KuberApp
/// runs its on-open maintenance batch (backup, widget sync, ledger/reminder
/// passes, billing, tab warm-up) only once this is true, and any other
/// on-app-open work (e.g. the Home SMS background scan) must gate on it too.
/// Measured: running the batch in the first post-frame callback put a 31 ms
/// widget-sync stall and a 25 ms tab warm-up stall inside the splash animation.
final onOpenBatchReadyProvider = StateProvider<bool>((ref) {
  return false;
});


class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}

/// Entry point of the WorkManager worker's headless engine
/// (BackgroundTasksWorker.kt): runs the launch task queue.
@pragma('vm:entry-point')
Future<void> backgroundMain() => runBackgroundWorker();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android 15 (SDK 35) enforces edge-to-edge. Opt in explicitly so Flutter
  // draws behind the system bars and drives bar appearance via the modern
  // WindowInsetsController path (not the deprecated Window.setStatusBarColor /
  // setNavigationBarColor APIs). Inset-aware layouts (SafeArea /
  // MediaQuery.viewPadding) keep content clear of the bars.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  // Guardrail: logs frames whose build phase overruns the display budget, so a
  // future slow widget doesn't get silently absorbed by the home/analytics
  // progressive-reveal ramp. No-op in release; see FrameBudgetMonitor docs.
  FrameBudgetMonitor.attach();
  // Bundled JetBrains Mono (pubspec fonts:) is OFL; surface its license in
  // the licenses page like google_fonts does for the fonts it loads.
  LicenseRegistry.addLicense(() async* {
    final text = await rootBundle.loadString('assets/fonts/JetBrainsMono-OFL.txt');
    yield LicenseEntryWithLineBreaks(const ['JetBrains Mono'], text);
  });
  await _bootstrap();
}

/// Opens the database, runs migrations and on-open processing, then launches
/// the app. A failure in the critical phase (database open / seed / migrate)
/// shows a recoverable error screen instead of crashing to a blank window —
/// real users have real data, so a corrupt DB or a throwing migration must not
/// be a dead end. On-open processing (notifications, recurring, reminders) is
/// best-effort and never blocks launch.
Future<void> _bootstrap() async {
  // Critical phase — the app cannot run without this.
  late final Isar isar;
  try {
    isar = await IsarService.open();
    await SeedService().seedInitialData(isar);
    await MigrationService.runAll(isar);
    // First-install: create the Kuber Pro entitlement row with the 14-day
    // trial window. No-op on subsequent launches. Must run before the first
    // frame so no widget flashes free UI while the row is being materialised.
    await ensureEntitlementBootstrap(isar);
  } catch (e, stack) {
    debugPrint('Kuber: fatal startup failure (database): $e\n$stack');
    runApp(KuberStartupErrorApp(onRetry: _bootstrap));
    return;
  }

  // Read the persisted theme before the first frame so the app never flashes
  // the wrong palette while the async settings provider hydrates. Best-effort:
  // a prefs failure falls back to system mode + Signature.
  var bootTheme = (ThemeMode.system, ThemeVariant.signature);
  var onboarded = false;
  var bootThemeOptions = const ThemeOptions();
  var bootTextSizeLevel = 3;
  var bootNumberFormat = ('INR', NumberSystem.automatic);
  var bootShowCurrencyCode = false;
  try {
    final prefs = await SharedPreferences.getInstance();
    bootThemeOptions = ThemeOptions(
      amoled: prefs.getBool(PrefsKeys.themeAmoled) ?? false,
      dynamicColor: prefs.getBool(PrefsKeys.themeDynamicColor) ?? false,
    );
    // Fresh install: light until onboarding saves a choice (the setup page
    // preselects Light too). Existing installs without a saved mode keep
    // System.
    final modeIndex = prefs.getInt(PrefsKeys.themeMode) ??
        (prefs.getBool(PrefsKeys.onboarded) ?? false
            ? ThemeMode.system.index
            : ThemeMode.light.index);
    final variantIndex = prefs.getInt(PrefsKeys.themeVariant) ?? 0;
    bootTheme = (
      ThemeMode.values[modeIndex.clamp(0, ThemeMode.values.length - 1)],
      resolveVariant(ThemeVariant
          .values[variantIndex.clamp(0, ThemeVariant.values.length - 1)]),
    );
    bootTextSizeLevel = prefs.getInt(PrefsKeys.textSizeLevel) ?? 3;
    onboarded = prefs.getBool(PrefsKeys.onboarded) ?? false;
    final systemIndex =
        prefs.getInt(PrefsKeys.numberSystem) ?? NumberSystem.automatic.index;
    bootNumberFormat = (
      prefs.getString(PrefsKeys.currency) ?? 'INR',
      NumberSystem
          .values[systemIndex.clamp(0, NumberSystem.values.length - 1)],
    );
    bootShowCurrencyCode = prefs.getBool(PrefsKeys.showCurrencyCode) ?? false;
    // Amounts formatted before the provider tree exists (reminder action
    // notifications below) use the user's currency, not the INR default.
    AppFormatter.current = AppFormatter(
      system: bootNumberFormat.$2,
      currency: currencyFromCode(bootNumberFormat.$1),
      showCode: bootShowCurrencyCode,
    );
  } catch (e) {
    debugPrint('Kuber: boot theme read failed (non-fatal): $e');
  }

  // Home v2 cohort (specs/home-v2/plan.md §1). Decided once, on the first
  // launch of this build, because it picks the first Home layout. Later
  // launches: one prefs read. Best-effort: a failure keeps today's Home (v1).
  var homeV2 = HomeV2Snapshot.v1;
  try {
    homeV2 = await resolveHomeCohort(isar, onboarded: onboarded);
  } catch (e) {
    debugPrint('Kuber: home cohort read failed (non-fatal): $e');
  }
  // Transaction gate seed: one count() so the first frame already hides
  // transaction-based widgets on an empty install.
  var hasTransactions = true;
  try {
    hasTransactions = await isar.transactions.count() > 0;
  } catch (_) {}

  // Best-effort on-open processing. A failure here must not prevent launch.
  String? coldStartPayload;
  try {
    // NotificationService captures a cold-start payload internally; the
    // foreground-tap callback is wired below. Both eventually land in
    // `pendingDeeplinkProvider` which the dashboard consumes after first frame.
    String? capturedPayload;
    await NotificationService().init(
      onTap: (payload) {
        capturedPayload = payload;
        notificationTaps.add(payload);
      },
      // Reminder notification action buttons (Mark done / Snooze 1 hour)
      // apply directly, matching quick-action semantics.
      onAction: (actionId, payload) {
        if (actionId == NotificationService.backgroundRetryAction) {
          BackgroundTasks.start(isar, lookupAppLocalizations(AppLocale.current),
                  trigger: 'retry', force: true)
              .ignore();
          return;
        }
        handleReminderNotificationAction(isar, actionId, payload)
            .catchError((Object e) {
          debugPrint('Kuber: reminder action failed (non-fatal): $e');
        });
      },
    );
    // Prefer cold-start payload (set during init) over any captured later.
    coldStartPayload =
        NotificationService().consumeColdStartPayload() ?? capturedPayload;

    // If the app was LAUNCHED from a reminder action button, apply it now.
    final coldAction = NotificationService().consumeColdStartAction();
    if (coldAction?.actionId == NotificationService.backgroundRetryAction) {
      // Retry from the failure notification: the on-open batch starts the
      // queue anyway; force it in case nothing looks due (backup failed).
      BackgroundTasks.start(isar, lookupAppLocalizations(AppLocale.current),
              trigger: 'retry', force: true)
          .ignore();
    } else if (coldAction != null) {
      await handleReminderNotificationAction(
        isar,
        coldAction.actionId,
        coldAction.payload,
      );
    }

    // Recurring, EMIs, SIPs and the automatic backup no longer run here:
    // the on-open batch starts them in the background (BackgroundTasks), so
    // the app always opens straight to Home.
    // First-launch Welcome story: a single pre-built Isar write (no aggregation)
    // so a fresh install shows a bubble immediately. All other stories generate
    // post-first-frame. Existing users just get the flag set, no Welcome.
    await maybeSeedWelcomeStory(isar);
    // The on-open ledger reminder pass is deferred to after the first frame
    // (see KuberApp) so it never delays cold start.
  } catch (e, stack) {
    debugPrint('Kuber: on-open processing failed (non-fatal): $e\n$stack');
  }

  // Decide the boot destination up front (same logic the router's redirect
  // would apply for '/'), so the app opens directly on Home / Onboarding.
  final initialLocation = onboarded ? '/' : '/onboarding';

  runApp(
    RestartWidget(
      child: ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          bootThemeProvider.overrideWithValue(bootTheme),
          bootThemeOptionsProvider.overrideWithValue(bootThemeOptions),
          bootTextSizeLevelProvider.overrideWithValue(bootTextSizeLevel),
          bootNumberFormatProvider.overrideWithValue(bootNumberFormat),
          bootShowCurrencyCodeProvider.overrideWithValue(bootShowCurrencyCode),
          homeV2BootProvider.overrideWithValue(homeV2),
          hasTransactionsBootProvider.overrideWithValue(hasTransactions),
          initialLocationProvider.overrideWithValue(initialLocation),
          if (coldStartPayload != null)
            pendingDeeplinkProvider.overrideWith((ref) => coldStartPayload),
        ],
        child: const KuberApp(),
      ),
    ),
  );
}

/// Shown when the database cannot be opened/migrated. Offers a retry that
/// re-runs the full startup sequence (handles transient locks), and stays on
/// the Vault theme so the failure still looks like Kuber.
class KuberStartupErrorApp extends StatelessWidget {
  final Future<void> Function() onRetry;

  const KuberStartupErrorApp({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(const Locale('en')),
      darkTheme: AppTheme.dark(const Locale('en')),
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final tt = theme.textTheme;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(KuberSpace.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: cs.error,
                    ),
                    const SizedBox(height: KuberSpace.lg),
                    Text(
                      "Couldn't open Kuber",
                      textAlign: TextAlign.center,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: KuberSpace.sm),
                    Text(
                      'Something went wrong while loading your data. '
                      'Your data is still on this device — please try again, '
                      'or reopen the app.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: KuberSpace.xl),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
