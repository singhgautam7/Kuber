// Quick navigation as a navigator: opening, jumping to an ancestor (pop, with
// unsaved-changes prompts), and rebuilding the back stack to the tree path.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:kuber/shared/widgets/kuber_path.dart';

final rootKey = GlobalKey<NavigatorState>();

class Pg extends StatelessWidget {
  final String title;
  final bool guarded;
  const Pg(this.title, {super.key, this.guarded = false});
  static int builds = 0;
  static bool guardLook = false;

  @override
  Widget build(BuildContext context) {
    builds++;
    final page = Scaffold(appBar: KuberAppBar(showBack: true, title: title));
    if (!guarded || !guardLook) return page;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (did, _) {
        if (did) return;
        showDialog<void>(
          context: context,
          builder: (d) => AlertDialog(
            title: const Text('Discard?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(d), child: const Text('Cancel')),
              TextButton(
                onPressed: () {
                  Navigator.pop(d);
                  Navigator.pop(context);
                },
                child: const Text('Discard'),
              ),
            ],
          ),
        );
      },
      child: page,
    );
  }
}

class Shell extends StatelessWidget {
  final StatefulNavigationShell shell;
  const Shell(this.shell, {super.key});
  @override
  Widget build(BuildContext context) => KuberPathShell(tab: shell.currentIndex, child: shell);
}

GoRoute root(String path, String title, {bool guarded = false, List<RouteBase> routes = const []}) => GoRoute(
      path: path,
      parentNavigatorKey: rootKey,
      builder: (_, _) => Pg(title, guarded: guarded),
      routes: routes,
    );

GoRouter router() => GoRouter(
      navigatorKey: rootKey,
      observers: [KuberPath.observer],
      initialLocation: '/more',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, s) => Shell(s),
          branches: [
            StatefulShellBranch(routes: [GoRoute(path: '/', builder: (_, _) => const Text('DashPage'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/history', builder: (_, _) => const Text('HistPage'))]),
            StatefulShellBranch(routes: [GoRoute(path: '/analytics', builder: (_, _) => const Text('AnaPage'))]),
            StatefulShellBranch(routes: [
              GoRoute(
                path: '/more',
                builder: (_, _) => const Text('MorePage'),
                routes: [
                  root('loans', 'Loans'),
                  root('settings', 'Settings', routes: [
                    root('look', 'Look and feel', guarded: true),
                    root('theme', 'Theme'),
                  ]),
                  root('tools', 'Calculators & Tools'),
                  root('tools/gst-calculator', 'GST Calculator'),
                ],
              ),
            ]),
          ],
        ),
        root('/history/filter', 'History filter'),
      ],
    );

void main() {
  late GoRouter r;

  setUp(() {
    KuberPath.observer.routes.clear();
    Pg.builds = 0;
    Pg.guardLook = false;
  });

  Future<void> run(WidgetTester t, [int ms = 1500]) async {
    for (var i = 0; i < ms ~/ 16; i++) {
      await t.pump(const Duration(milliseconds: 16));
    }
  }

  Future<void> app(WidgetTester t, List<String> pushes) async {
    await t.binding.setSurfaceSize(const Size(400, 900));
    addTearDown(() => t.binding.setSurfaceSize(null));
    r = router();
    await t.pumpWidget(ProviderScope(
      child: MaterialApp.router(
        routerConfig: r,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    ));
    await t.pumpAndSettle();
    for (final p in pushes) {
      r.push(p);
      await t.pumpAndSettle();
    }
  }

  Finder row(String title) {
    final f = find.descendant(of: find.byType(KuberPathSheet), matching: find.text(title));
    return f;
  }

  /// Opens the More section's "Show remaining" row (the last one on screen).
  Future<void> showAll(WidgetTester t) async {
    final more = find.descendant(of: find.byType(KuberPathSheet), matching: find.textContaining('Show remaining')).last;
    await t.ensureVisible(more);
    await t.tap(more, warnIfMissed: false);
    await t.pumpAndSettle();
  }

  Future<void> tapRow(WidgetTester t, String title) async {
    await t.ensureVisible(row(title));
    await t.tap(row(title), warnIfMissed: false);
    await run(t);
  }

  Finder inBar(String title) => find.descendant(of: find.byType(KuberAppBar), matching: find.text(title));

  const toTheme = ['/more/settings', '/more/settings/look', '/more/settings/theme'];

  testWidgets('long press on back opens it, with no "Show path" tooltip', (t) async {
    await app(t, toTheme);
    await t.longPress(find.byIcon(Icons.arrow_back_rounded).last);
    await t.pumpAndSettle();
    expect(find.byType(KuberPathSheet), findsOneWidget);
    expect(find.text('Show path'), findsNothing);
    expect(find.byWidgetPredicate((w) => w is Tooltip && w.message == 'Back'), findsNothing);
  });

  testWidgets('tapping the header title opens it', (t) async {
    await app(t, toTheme);
    await t.tap(inBar('Theme'));
    await t.pumpAndSettle();
    expect(find.byType(KuberPathSheet), findsOneWidget);
    expect(find.text('You are here'), findsOneWidget);
  });

  testWidgets('an ancestor on the stack is popped back to without rebuilding', (t) async {
    await app(t, toTheme);
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    final builds = Pg.builds;
    await tapRow(t, 'Settings');
    expect(find.byType(KuberPathSheet), findsNothing);
    expect(inBar('Settings'), findsOneWidget);
    expect(inBar('Theme'), findsNothing);
    expect(KuberPath.stack(r).length, 1);
    expect(Pg.builds - builds, lessThanOrEqualTo(1), reason: 'only the route coming back into view');
  });

  testWidgets('a page off the stack rebuilds it: Theme to Loans leaves Back going to More', (t) async {
    await app(t, toTheme);
    expect(KuberPath.stack(r).length, 3);
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    await showAll(t);
    await tapRow(t, 'Loans');
    expect(find.byType(KuberPathSheet), findsNothing);
    expect(inBar('Loans'), findsOneWidget);
    // depth = shell + Loans = the tree's More > Loans
    expect(KuberPath.stack(r).length + 1, 2);
    await rootKey.currentState!.maybePop();
    await t.pumpAndSettle();
    expect(find.text('MorePage'), findsOneWidget);
  });

  testWidgets('a deep target pushes its parents: the stack is as deep as the tree', (t) async {
    await app(t, ['/more/loans']);
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    await t.ensureVisible(row('Show remaining 12 pages'));
    await t.tap(row('Show remaining 12 pages'), warnIfMissed: false);
    await t.pumpAndSettle();
    await t.ensureVisible(find.bySemanticsLabel('Expand Settings'));
    await t.tap(find.bySemanticsLabel('Expand Settings'), warnIfMissed: false);
    await t.pumpAndSettle();
    await tapRow(t, 'Look and feel');
    // More > Settings > Look and feel: shell + 2 pages, Back walks the tree.
    expect(KuberPath.stack(r).map((e) => e.location), ['/more/settings', '/more/settings/look']);
    await rootKey.currentState!.maybePop();
    await t.pumpAndSettle();
    expect(inBar('Settings'), findsOneWidget);
    await rootKey.currentState!.maybePop();
    await t.pumpAndSettle();
    expect(find.text('MorePage'), findsOneWidget);
  });

  testWidgets('the Home tab row pops everything and shows the tab', (t) async {
    await app(t, ['/more/tools', '/more/tools/gst-calculator']);
    expect(KuberPath.stack(r).length, 2);
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    await tapRow(t, 'Home');
    expect(find.text('DashPage'), findsOneWidget);
    expect(KuberPath.stack(r).length, 0);
  });

  testWidgets('from Home, a deep link to a calculator jumps with its parent under it', (t) async {
    await app(t, ['/more/tools/gst-calculator']);
    // only the calculator is on the stack; the tree says More > Calculators > GST
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    await showAll(t);
    await tapRow(t, 'Loans');
    expect(inBar('Loans'), findsOneWidget);
    expect(KuberPath.stack(r).length, 1);
  });

  testWidgets('a page with unsaved changes asks during a jump; cancel stops it there', (t) async {
    Pg.guardLook = true;
    await app(t, toTheme);
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    await tapRow(t, 'Home');
    expect(find.text('Discard?'), findsOneWidget);
    await t.tap(find.text('Cancel'));
    await run(t);
    expect(inBar('Look and feel'), findsOneWidget);
    expect(find.text('DashPage'), findsNothing);
    expect(KuberPath.stack(r).length, 2);
  });

  testWidgets('answering Discard lets the jump finish', (t) async {
    Pg.guardLook = true;
    await app(t, toTheme);
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    await tapRow(t, 'Home');
    await t.tap(find.text('Discard'));
    await run(t);
    expect(find.text('DashPage'), findsOneWidget);
    expect(KuberPath.stack(r).length, 0);
  });

  testWidgets('popUntil skips a pop guard, which is why a jump pops route by route', (t) async {
    Pg.guardLook = true;
    await app(t, toTheme);
    rootKey.currentState!.popUntil((r) => r.isFirst);
    await t.pumpAndSettle();
    expect(find.text('Discard?'), findsNothing);
    expect(KuberPath.stack(r).length, 0);
  });

  testWidgets('History filter keeps History in the tree, under its tab', (t) async {
    await app(t, []);
    r.go('/history');
    await t.pumpAndSettle();
    r.push('/history/filter');
    await t.pumpAndSettle();
    KuberPath.open(rootKey.currentContext!);
    await t.pumpAndSettle();
    expect(row('History'), findsOneWidget);
    expect(row('Analytics'), findsNothing);
    await tapRow(t, 'History');
    expect(find.text('HistPage'), findsOneWidget);
  });

  testWidgets('a virtual page registered by a sheet shows as a leaf and goes with the sheet', (t) async {
    await app(t, ['/more/loans']);
    showModalBottomSheet<void>(
      context: rootKey.currentContext!,
      useRootNavigator: true,
      builder: (c) => Builder(builder: (c) {
        KuberPath.pushVirtual(c, title: 'SBI Home Loan', icon: Icons.account_balance_outlined);
        return const SizedBox(height: 100, child: Text('sheet'));
      }),
    );
    await t.pumpAndSettle();
    expect(KuberPath.stack(r).map((e) => e.title), ['Loans', 'SBI Home Loan']);
    await rootKey.currentState!.maybePop();
    await t.pumpAndSettle();
    expect(KuberPath.stack(r).length, 1);
  });
}
