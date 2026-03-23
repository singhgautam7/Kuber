import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';

class KuberApp extends ConsumerStatefulWidget {
  const KuberApp({super.key});

  @override
  ConsumerState<KuberApp> createState() => _KuberAppState();
}

class _KuberAppState extends ConsumerState<KuberApp> {
  late final _router = createRouter();

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Kuber',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
