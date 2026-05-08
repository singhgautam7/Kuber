import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/lock_screen.dart';
import 'features/settings/providers/settings_provider.dart';

class KuberApp extends ConsumerWidget {
  const KuberApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final materialYou = ref.watch(materialYouProvider);
    final seed = ref.watch(materialYouSeedProvider);
    final router = ref.watch(routerProvider);

    final seedColor = materialYou ? seed.color : null;

    return MaterialApp.router(
      title: 'Kuber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(seedColor: seedColor),
      darkTheme: AppTheme.dark(seedColor: seedColor),
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final brightness = Theme.of(context).brightness;
        final isDark = brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness:
                isDark ? Brightness.light : Brightness.dark,
            statusBarBrightness:
                isDark ? Brightness.dark : Brightness.light,
          ),
          child: ColoredBox(
            color: Theme.of(context).colorScheme.surface,
            child: SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: LockScreen(child: child!),
            ),
          ),
        );
      },
    );
  }
}
