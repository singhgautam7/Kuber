import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';
import 'package:kuber/shared/widgets/quick_nav/quick_nav_model.dart';

/// A page found by its route.
QuickNavStackEntry qnPage(String location) =>
    QuickNavStackEntry(location: location, title: location, icon: Icons.article_outlined);

/// A page the tree does not list (a loan, a form), by its own title.
QuickNavStackEntry qnVirtual(String title) =>
    QuickNavStackEntry(title: title, icon: Icons.article_outlined);

Future<void> pumpQuickNav(
  WidgetTester t, {
  required List<QuickNavStackEntry> stack,
  int tab = 3,
  bool fromNotification = false,
  ThemeData? theme,
  Size size = const Size(400, 900),
  double textScale = 1,
}) async {
  await t.binding.setSurfaceSize(size);
  addTearDown(() => t.binding.setSurfaceSize(null));
  t.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(t.platformDispatcher.clearTextScaleFactorTestValue);
  await t.pumpWidget(ProviderScope(
    child: MaterialApp(
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: KuberPathSheet(
            key: UniqueKey(),
            stack: stack,
            tab: tab,
            router: GoRouter(routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox())]),
            fromNotification: fromNotification,
          ),
        ),
      ),
    ),
  ));
  await t.pumpAndSettle();
}
