// November release F: the path sheet reads the real navigation stack: a 4-level
// stack, a deep link, a root page, and popping straight back.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';

final rootKey = GlobalKey<NavigatorState>();

class Page extends StatefulWidget {
  final String title;
  final String? next;
  final bool back;
  final bool close;
  const Page(this.title, {super.key, this.next, this.back = true, this.close = false});
  static int builds = 0;

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> {
  @override
  Widget build(BuildContext context) {
    Page.builds++;
    return Scaffold(
      appBar: KuberAppBar(showBack: widget.back, closeIcon: widget.close, title: widget.title),
      body: widget.next == null
          ? null
          : TextButton(onPressed: () => context.push(widget.next!), child: const Text('next')),
    );
  }
}

class Shell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const Shell(this.shell, {super.key});
  @override
  Widget build(BuildContext context) => KuberPathShell(tab: shell.currentIndex, child: shell);
}

GoRouter router(String initial) => GoRouter(
      navigatorKey: rootKey,
      observers: [KuberPath.observer],
      initialLocation: initial,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, s) => Shell(s),
          branches: [
            StatefulShellBranch(routes: [
              GoRoute(path: '/', builder: (_, _) => const Page('Dash', back: false)),
            ]),
            StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, _) => const Page('Hist', back: false))]),
            StatefulShellBranch(routes: [GoRoute(path: '/analytics', builder: (_, _) => const Page('Ana', back: false))]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/more',
                builder: (_, _) => const Page('MoreTab', back: false, next: '/more/settings'),
                routes: [
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: rootKey,
                    builder: (_, _) => const Page('Settings', next: '/more/settings/look'),
                    routes: [
                      GoRoute(
                        path: 'look',
                        parentNavigatorKey: rootKey,
                        builder: (_, _) => const Page('Look and feel', next: '/more/settings/theme'),
                      ),
                      GoRoute(
                        path: 'theme',
                        parentNavigatorKey: rootKey,
                        builder: (_, _) => const Page('Theme', next: '/form'),
                      ),
                    ],
                  ),
                ],
              ),
            ]),
          ],
        ),
        GoRoute(path: '/form', parentNavigatorKey: rootKey, builder: (_, _) => const Page('Form', close: true)),
      ],
    );

void main() {
  setUp(() => KuberPath.observer.routes.clear());

  Future<GoRouter> app(WidgetTester t, String initial) async {
    final r = router(initial);
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: r,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await t.pumpAndSettle();
    return r;
  }

  Future<void> deep(WidgetTester t) async {
    for (var i = 0; i < 3; i++) {
      await t.tap(find.text('next').last);
      await t.pumpAndSettle();
    }
  }

  Finder sheetRow(String title) => find.descendant(of: find.byType(KuberPathSheet), matching: find.text(title));

  testWidgets('a 4-level stack shows the path and marks the current page', (t) async {
    await app(t, '/more');
    await deep(t);
    await t.tap(find.text('Theme').last);
    await t.pumpAndSettle();
    expect(find.byType(KuberPathSheet), findsOneWidget);
    for (final s in ['Home', 'More', 'Settings', 'Look and feel', 'Theme']) {
      expect(sheetRow(s), findsOneWidget, reason: s);
    }
    expect(find.text('You are here'), findsOneWidget);
    final titles = KuberPath.read(t.element(find.byType(KuberPathSheet))).map((e) => e.title).toList();
    expect(titles, ['Home', 'More', 'Settings', 'Look and feel', 'Theme']);
  });

  testWidgets('long-press back opens it too', (t) async {
    await app(t, '/more');
    await deep(t);
    await t.longPress(find.byIcon(Icons.arrow_back_rounded).last);
    await t.pumpAndSettle();
    expect(find.byType(KuberPathSheet), findsOneWidget);
  });

  testWidgets('tapping an earlier page pops straight to it without a rebuild', (t) async {
    await app(t, '/more');
    await deep(t);
    await t.tap(find.text('Theme').last);
    await t.pumpAndSettle();
    final builds = Page.builds;
    await t.tap(sheetRow('Settings'));
    await t.pumpAndSettle();
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Theme'), findsNothing);
    expect(find.text('Look and feel'), findsNothing);
    expect(find.byType(KuberPathSheet), findsNothing);
    expect(Page.builds - builds, lessThanOrEqualTo(1), reason: 'only the route coming back into view');
  });

  testWidgets('a tab entry goes back to the tab', (t) async {
    await app(t, '/more');
    await deep(t);
    await t.tap(find.text('Theme').last);
    await t.pumpAndSettle();
    await t.tap(sheetRow('Home'));
    await t.pumpAndSettle();
    expect(find.text('Dash'), findsOneWidget);
    expect(find.text('Theme'), findsNothing);
  });

  testWidgets('a deep link shows the stack as it really is', (t) async {
    await app(t, '/more/settings/look');
    await t.tap(find.text('Look and feel').last);
    await t.pumpAndSettle();
    final titles = KuberPath.read(t.element(find.byType(KuberPathSheet))).map((e) => e.title).toList();
    expect(titles, ['Home', 'More', 'Settings', 'Look and feel']);
  });

  testWidgets('no sheet on a root tab page, or on a form that closes', (t) async {
    await app(t, '/more');
    await t.tap(find.text('MoreTab'));
    await t.pumpAndSettle();
    expect(find.byType(KuberPathSheet), findsNothing);
    await deep(t);
    await t.tap(find.text('next').last);
    await t.pumpAndSettle();
    await t.tap(find.text('Form').last);
    await t.pumpAndSettle();
    expect(find.byType(KuberPathSheet), findsNothing);
  });

  testWidgets('a dialog or sheet on top is left out of the path', (t) async {
    await app(t, '/more');
    await deep(t);
    showDialog<void>(context: rootKey.currentContext!, builder: (_) => const AlertDialog(title: Text('hi')));
    await t.pumpAndSettle();
    final titles = KuberPath.read(rootKey.currentContext!).map((e) => e.title).toList();
    expect(titles, ['Home', 'More', 'Settings', 'Look and feel', 'Theme']);
  });
}
