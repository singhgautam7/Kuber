import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;

import 'core/database/isar_service.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_sync_service.dart';
import 'core/theme/app_theme.dart';
import 'features/analytics/providers/analytics_provider.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/backups/providers/backup_provider.dart';
import 'features/budgets/services/budget_service.dart';
import 'features/history/providers/history_view_provider.dart';
import 'features/history/providers/selection_provider.dart';
import 'features/transactions/providers/transaction_provider.dart';
import 'features/ledger/data/ledger_reminder_processor.dart';
import 'features/notifications/data/notification_repository.dart';
import 'features/pro/paywall/billing_ui_state.dart';
import 'features/pro/paywall/pro_state.dart';
import 'features/pro/services/promo_config_service.dart';
import 'features/pro/services/purchase_service.dart';
import 'features/reminders/data/reminders_repository.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/sms_import/providers/sms_import_provider.dart';
import 'features/tutorial/widgets/tutorial_overlay.dart';
import 'shared/widgets/app_scaffold.dart';

class KuberApp extends ConsumerStatefulWidget {
  const KuberApp({super.key});

  @override
  ConsumerState<KuberApp> createState() => _KuberAppState();
}

class _KuberAppState extends ConsumerState<KuberApp>
    with WidgetsBindingObserver {
  // Stable cached instances of theme to prevent tab-switch rebuild animations/jank,
  // refreshed only when the active Locale is updated.
  Locale? _cachedLocale;
  ThemeData? _lightTheme;
  ThemeData? _darkTheme;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // On-open processing deferred to after the first frame so it never delays
    // cold start. Uses ProviderScope's overrides (Isar etc), so it must run
    // after the scope is in place.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetServiceProvider).checkAllOnAppOpen();
      _runOnOpenLedgerReminders();
      _runDueBackup();
      _runSmsCleanup();
      _runReminderMaintenance();
      _runWidgetSync();
      _initPurchases();
      _initPromoConfig();
      // Warm the non-Home tabs' providers ~1.5s after first frame — late
      // enough that Home has finished its own hydration, early enough that
      // a user tapping Analytics or History hits cached data.
      Future.delayed(const Duration(milliseconds: 1500), _warmTabProviders);
    });
  }

  /// Warms the providers that the Analytics and History tabs consume on first
  /// build, so tapping either tab doesn't trigger an O(N) synchronous compute
  /// in the middle of the tab-switch animation. Deliberately delayed (not
  /// run immediately post-frame) so Home's own first-paint hydration is not
  /// competing with this warm-up for the UI thread.
  void _warmTabProviders() {
    if (!mounted) return;
    try {
      ref.read(analyticsFilterProvider);
      ref.read(analyticsTransactionsProvider);
      ref.read(analyticsComputedProvider);
      ref.read(historyViewProvider.future).ignore();
      ref.read(transferPairAccountIdsProvider.future).ignore();
    } catch (e, stack) {
      debugPrint('Kuber: tab provider warm-up failed (non-fatal): $e\n$stack');
    }
  }

  /// Connects to Google Play Billing and reconciles entitlement on cold start.
  /// Deferred to after first frame and fully guarded — a device with no Play
  /// services, or any billing error, must never affect launch. Once connected,
  /// PurchaseService listens to the purchase stream for the app's lifetime.
  Future<void> _initPurchases() async {
    try {
      // Offline-fallback prices for the paywall, before the live query lands.
      await ref.read(cachedProductPricesProvider.notifier).hydrate();
      // The entitlement row was created in main()'s bootstrap; force a read so
      // the notifier hydrates from Isar (synchronous), then clear the
      // Pro-bootstrap gate that keeps the Settings card skeleton and the
      // hidden trial pill in their loading state.
      ref.read(kuberProStateProvider);
      ref.read(proBootstrapLoadingProvider.notifier).state = false;

      await ref.read(purchaseServiceProvider).initialize();
    } catch (e, stack) {
      debugPrint('Kuber: purchase init failed (non-fatal): $e\n$stack');
      // Never strand the UI on skeletons if billing init throws.
      ref.read(proBootstrapLoadingProvider.notifier).state = false;
    }
  }

  /// Refreshes the remote promo campaign (best-effort, TTL-gated) and hydrates
  /// the in-memory config so promo surfaces can read it synchronously. Fully
  /// guarded — a promo is a nice-to-have and must never affect launch.
  Future<void> _initPromoConfig() async {
    try {
      await const PromoConfigService().refreshIfStale();
      await ref.read(promoConfigProvider.notifier).hydrate();
    } catch (e, stack) {
      debugPrint('Kuber: promo config init failed (non-fatal): $e\n$stack');
    }
  }

  /// Refreshes all native home-screen widgets. Best-effort and post-first-frame
  /// so it never delays cold start; internally isolated so it can't crash the app.
  Future<void> _runWidgetSync() async {
    try {
      await ref.read(widgetSyncServiceProvider).syncAll();
    } catch (e, stack) {
      debugPrint('Kuber: widget sync failed (non-fatal): $e\n$stack');
    }
  }

  // Date (y/m/d) of the last scheduled-backup check, so resume doesn't re-check
  // on every foreground. The shortest backup interval is 1 day, so checking at
  // most once per calendar day is sufficient and cheap.
  DateTime? _lastBackupCheckDay;

  /// Runs a scheduled backup if one is due. Called on first frame (cold start)
  /// and on the first resume of each new day, because Android usually keeps the
  /// process warm — the cold-start loader path alone almost never fires
  /// day-to-day, so "daily" would never trigger. Silent + best-effort +
  /// internally guarded against concurrent runs (can't double-fire with the
  /// cold-start loader).
  Future<void> _runDueBackup() async {
    final now = DateTime.now();
    _lastBackupCheckDay = DateTime(now.year, now.month, now.day);
    try {
      await ref.read(backupSettingsProvider.notifier).runDueBackup();
    } catch (e, stack) {
      debugPrint('Kuber: on-open backup check failed (non-fatal): $e\n$stack');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When leaving the app (e.g. pressing Home), push the latest data to the
    // home-screen widgets so they reflect any change made this session before
    // the user looks at them.
    if (state == AppLifecycleState.paused) {
      _runWidgetSync();
      return;
    }
    if (state != AppLifecycleState.resumed) return;
    // A reminder notification may have fired while we were backgrounded —
    // mirror any newly-due reminders into the in-app inbox and heal alarms.
    _runReminderMaintenance();
    // Refresh home-screen widgets so a change made this session (then a jump to
    // the launcher) reflects within seconds of returning.
    _runWidgetSync();
    // The user may have granted SMS permission via system settings while we
    // were backgrounded — invalidate the lightweight home-tab provider so
    // the SMS card picks up the new permission on the next frame.
    ref.invalidate(smsHomeInfoProvider);
    // Already checked backup today? A daily (or longer) backup can't be due
    // again, so skip — avoids a DB read on every foreground.
    final now = DateTime.now();
    final last = _lastBackupCheckDay;
    if (last != null &&
        last.year == now.year &&
        last.month == now.month &&
        last.day == now.day) {
      return;
    }
    _runDueBackup();
  }

  /// Prunes reviewed (imported / dismissed) SMS staging rows older than 90
  /// days. Unreviewed rows are kept regardless of age. Best-effort and
  /// post-first-frame so it never blocks the home render.
  Future<void> _runSmsCleanup() async {
    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 90));
      await ref.read(smsImportRepositoryProvider).cleanupOlderThan(cutoff);
    } catch (e, stack) {
      debugPrint('Kuber: on-open SMS cleanup failed (non-fatal): $e\n$stack');
    }
  }

  /// On-open ledger reminder pass (in-app records + dedupe-gated OS
  /// notifications). Best-effort and post-first-frame — a failure here must
  /// never affect launch or block the UI.
  Future<void> _runOnOpenLedgerReminders() async {
    try {
      final isar = ref.read(isarProvider);
      await LedgerReminderProcessor(
        isar: isar,
        notificationRepo: NotificationRepository(isar),
        showOs: NotificationService().showAppNotification,
      ).checkAll();
    } catch (e, stack) {
      debugPrint('Kuber: on-open ledger reminders failed (non-fatal): $e\n$stack');
    }
  }

  /// On-open reminder pass: 7-day completed cleanup, inbox mirroring of due
  /// reminders, and re-registering upcoming notification alarms. Best-effort
  /// and post-first-frame so it never delays cold start.
  Future<void> _runReminderMaintenance() async {
    try {
      final isar = ref.read(isarProvider);
      await RemindersRepository(isar).onAppOpenMaintenance();
    } catch (e, stack) {
      debugPrint(
          'Kuber: on-open reminder maintenance failed (non-fatal): $e\n$stack');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Central back-button handler. Cascades through navigators, then custom
  /// app-level actions (selection clear, tab switching, exit).
  @override
  Future<bool> didPopRoute() async {
    // 1. Pop from root navigator (bottom sheets, full-screen sub-pages).
    if (await _maybePop(rootNavigatorKey.currentState)) return true;

    // 2. Pop from the active shell branch navigator.
    final currentIndex = ref.read(currentShellTabIndexProvider);
    if (currentIndex >= 0 && currentIndex < shellNavigatorKeys.length) {
      if (await _maybePop(shellNavigatorKeys[currentIndex].currentState)) {
        return true;
      }
    }

    // 3. Clear selection mode (typically on the History tab).
    if (ref.read(isSelectionModeProvider)) {
      ref.read(transactionSelectionProvider.notifier).clear();
      return true;
    }

    // 4. Non-Home tab: switch to Home.
    if (currentIndex != 0) {
      ref.read(routerProvider).go('/');
      ref.read(currentShellTabIndexProvider.notifier).state = 0;
      return true;
    }

    // 5. Home tab with nothing to pop: exit the app.
    await SystemNavigator.pop();
    return true;
  }

  Future<bool> _maybePop(NavigatorState? navigator) async {
    if (navigator == null || !navigator.canPop()) return false;
    return navigator.maybePop();
  }

  /// Intercepts NavigationNotification from the Router subtree and ensures
  /// setFrameworkHandlesBack(true) is called when we need custom back
  /// handling (non-Home tab or selection mode active).
  ///
  /// On Android 13+ (API 33+), the OS only routes back events to Flutter
  /// when setFrameworkHandlesBack(true) has been called. The Router's own
  /// NavigationNotification may not always propagate correctly to the
  /// framework's _WidgetsAppState (which is responsible for this call)
  /// when only a PopScope changes without an actual route push/pop.
  ///
  /// By intercepting the notification here and calling
  /// setFrameworkHandlesBack ourselves, we ensure the platform always
  /// knows Flutter handles back when needed.
  bool _handleNavigationNotification(NavigationNotification notification) {
    final idx = ref.read(currentShellTabIndexProvider);
    final sel = ref.read(isSelectionModeProvider);
    // We handle back if: the child navigator reports it can handle pop,
    // OR we have custom handling (non-Home tab, selection mode).
    final shouldHandle = notification.canHandlePop || idx != 0 || sel;
    SystemNavigator.setFrameworkHandlesBack(shouldHandle);
    // Stop propagation — we've already called setFrameworkHandlesBack,
    // so _WidgetsAppState doesn't need to (and can't override us).
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);
    final locale = ref.watch(localeProvider);

    if (_cachedLocale != locale || _lightTheme == null || _darkTheme == null) {
      _cachedLocale = locale;
      _lightTheme = AppTheme.light(locale);
      _darkTheme = AppTheme.dark(locale);
    }

    // Watch these so the widget rebuilds (and the notification listener
    // re-evaluates) when tab or selection state changes.
    ref.watch(currentShellTabIndexProvider);
    ref.watch(isSelectionModeProvider);

    return MaterialApp.router(
      title: 'Kuber',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme,
      darkTheme: _darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        ...AppLocalizations.localizationsDelegates,
        // Required by the flutter_quill editor used in Kuber Notes.
        FlutterQuillLocalizations.delegate,
      ],
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        // NotificationListener intercepts NavigationNotification from the
        // Router (child) and calls setFrameworkHandlesBack() directly.
        // This sits between the Router and _WidgetsAppState, ensuring
        // we control when the platform registers Flutter's back callback.
        return NotificationListener<NavigationNotification>(
          onNotification: _handleNavigationNotification,
          child: AnnotatedRegion<SystemUiOverlayStyle>(
            // Edge-to-edge: set only icon brightness (applied via the modern
            // WindowInsetsController path). Do NOT set bar colors — those route
            // through the deprecated Window.setStatusBarColor /
            // setNavigationBarColor APIs and are no-ops on Android 15. The bars
            // are transparent for free in edge-to-edge mode.
            value: SystemUiOverlayStyle(
              statusBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
              statusBarBrightness:
                  isDark ? Brightness.dark : Brightness.light,
              systemNavigationBarIconBrightness:
                  isDark ? Brightness.light : Brightness.dark,
            ),
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: TutorialOverlay(
                child: SafeArea(
                  bottom: false,
                  left: false,
                  right: false,
                  child: LockScreen(child: child!),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
