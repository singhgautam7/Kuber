import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/budgets/services/budget_service.dart';
import 'features/history/providers/selection_provider.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/tutorial/widgets/tutorial_overlay.dart';
import 'shared/widgets/app_scaffold.dart';

final appOverlayNavigatorKey = GlobalKey<NavigatorState>();

class KuberApp extends ConsumerStatefulWidget {
  const KuberApp({super.key});

  @override
  ConsumerState<KuberApp> createState() => _KuberAppState();
}

class _KuberAppState extends ConsumerState<KuberApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run on-open budget alert check once. Uses ProviderScope's overrides
    // (Isar etc), so must be deferred until after the scope is in place.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetServiceProvider).checkAllOnAppOpen();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPopRoute() async {
    if (await _maybePop(appOverlayNavigatorKey.currentState)) return true;
    if (await _maybePop(rootNavigatorKey.currentState)) return true;

    final currentIndex = ref.read(currentShellTabIndexProvider);
    if (currentIndex >= 0 && currentIndex < shellNavigatorKeys.length) {
      if (await _maybePop(shellNavigatorKeys[currentIndex].currentState)) {
        return true;
      }
    }

    if (ref.read(isSelectionModeProvider)) {
      ref.read(transactionSelectionProvider.notifier).clear();
      return true;
    }

    if (currentIndex != 0) {
      ref.read(routerProvider).go('/');
      ref.read(currentShellTabIndexProvider.notifier).state = 0;
      return true;
    }

    await SystemNavigator.pop();
    return true;
  }

  Future<bool> _maybePop(NavigatorState? navigator) async {
    if (navigator == null || !navigator.canPop()) return false;
    return navigator.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Kuber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        return Navigator(
          key: appOverlayNavigatorKey,
          onGenerateRoute: (settings) => PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AnnotatedRegion<SystemUiOverlayStyle>(
                  value: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: isDark
                        ? Brightness.light
                        : Brightness.dark,
                    statusBarBrightness: isDark
                        ? Brightness.dark
                        : Brightness.light,
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
          ),
        );
      },
    );
  }
}
