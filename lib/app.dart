import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/budgets/services/budget_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/tutorial/widgets/tutorial_overlay.dart';

class KuberApp extends ConsumerStatefulWidget {
  const KuberApp({super.key});

  @override
  ConsumerState<KuberApp> createState() => _KuberAppState();
}

class _KuberAppState extends ConsumerState<KuberApp> {
  @override
  void initState() {
    super.initState();
    // Run on-open budget alert check once. Uses ProviderScope's overrides
    // (Isar etc), so must be deferred until after the scope is in place.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(budgetServiceProvider).checkAllOnAppOpen();
    });
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
          onGenerateRoute: (settings) => PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                AnnotatedRegion<SystemUiOverlayStyle>(
              value: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    isDark ? Brightness.light : Brightness.dark,
                statusBarBrightness:
                    isDark ? Brightness.dark : Brightness.light,
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
