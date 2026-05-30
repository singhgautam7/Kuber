import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/database/isar_service.dart';
import 'core/router/app_router.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/budgets/services/budget_service.dart';
import 'features/history/providers/selection_provider.dart';
import 'features/ledger/data/ledger_reminder_processor.dart';
import 'features/notifications/data/notification_repository.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/tutorial/widgets/tutorial_overlay.dart';
import 'shared/widgets/app_scaffold.dart';

class KuberApp extends ConsumerStatefulWidget {
  const KuberApp({super.key});

  @override
  ConsumerState<KuberApp> createState() => _KuberAppState();
}

class _KuberAppState extends ConsumerState<KuberApp>
    with WidgetsBindingObserver {
  // Built once. AppTheme.light()/dark() construct a fresh ThemeData each call;
  // passing new instances on every KuberApp rebuild makes MaterialApp's internal
  // AnimatedTheme animate a (visually identical) theme transition over ~200ms,
  // rebuilding every Theme.of dependent (the whole tab tree) once per frame —
  // the tab-switch jank. Stable instances make that a no-op.
  final ThemeData _lightTheme = AppTheme.light();
  final ThemeData _darkTheme = AppTheme.dark();

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
    });
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
