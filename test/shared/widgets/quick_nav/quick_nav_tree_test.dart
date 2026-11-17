// Quick navigation: the tree for each design state, and the drift test that
// keeps it in step with More, Settings and Tools.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/core/router/app_router.dart';
import 'package:kuber/features/more/more_content.dart';
import 'package:kuber/features/settings/settings_index.dart';
import 'package:kuber/features/tools/tool_catalog.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/quick_nav/quick_nav_tree.dart';
import 'package:kuber/shared/widgets/quick_nav/quick_nav_view.dart';

import 'quick_nav_test_utils.dart';

void main() {
  void shows(List<String> rows) {
    for (final r in rows) {
      expect(find.text(r), findsOneWidget, reason: r);
    }
  }

  void hides(List<String> rows) {
    for (final r in rows) {
      expect(find.text(r), findsNothing, reason: r);
    }
  }

  const manage = ['Accounts', 'Categories', 'Tags', 'Budgets', 'Recurring Transactions', 'Lend / Borrow', 'Loans', 'Investments'];
  const signature = [
    'Ask Kuber (Beta)', 'Import from SMS', 'Advanced Analytics', 'Custom Dashboard',
    'Calculators & Tools', 'Kuber Notes', 'Kuber Cards', 'Quick Add', 'Reminders',
  ];

  testWidgets('on Theme: Settings and Look and feel open, More shows the About section', (t) async {
    await pumpQuickNav(t, stack: [
      qnPage('/more/settings'),
      qnPage('/more/settings/look'),
      qnPage('/more/settings/theme'),
    ]);
    shows(['Quick navigation', 'Tap any page to open it', 'Home', 'More', 'Settings', 'Look and feel', 'Theme',
      'Home widgets', 'Analytics widgets', 'Home screen widgets', 'App preferences', 'App drawer',
      'Privacy and security', 'Data and backup', 'Notifications', 'Help', 'Activity', 'About Kuber', 'Why Kuber?',
      'Show remaining 17 pages', 'You are here']);
    hides(['History', 'Analytics', ...manage, ...signature]);
  });

  testWidgets('on Loans: More shows the other Manage pages and Show remaining 12', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/loans')]);
    shows(['Home', 'More', ...manage, 'Show remaining 12 pages', 'You are here']);
    hides(['History', 'Analytics', ...signature, 'Settings']);
  });

  testWidgets('Show remaining expands in More order with no section names, then Show fewer', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/loans')]);
    await t.ensureVisible(find.text('Show remaining 12 pages'));
    await t.tap(find.text('Show remaining 12 pages'));
    await t.pumpAndSettle();
    shows([...manage, ...signature, 'Settings', 'About Kuber', 'Why Kuber?', 'Show fewer pages']);
    expect(find.textContaining('Show remaining'), findsNothing);
    final ys = [for (final s in ['Loans', 'Ask Kuber (Beta)', 'Settings']) t.getTopLeft(find.text(s)).dy];
    expect(ys[0] < ys[1] && ys[1] < ys[2], isTrue);
    await t.ensureVisible(find.text('Show fewer pages'));
    await t.tap(find.text('Show fewer pages'));
    await t.pumpAndSettle();
    shows(['Show remaining 12 pages']);
    hides(['Ask Kuber (Beta)']);
  });

  testWidgets('on Ask Kuber: More shows the Tools section', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/ask-kuber')]);
    shows([...signature, 'Show remaining 11 pages']);
    hides([...manage, 'Settings']);
  });

  testWidgets('on a calculator: Calculators holds the long child list, folders on the path open', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/tools'), qnPage('/more/tools/gst-calculator')]);
    shows(['Calculators & Tools', 'Salary Breakdown', 'GST Calculator', 'HRA Exemption', 'Show remaining 16 pages',
      'Show remaining 11 pages', 'Ask Kuber (Beta)']);
    hides(['EMI Calculator', 'Saved Calculations', 'Goal Planner']);
  });

  testWidgets('a long child list with nothing on the path starts at its first section', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/ask-kuber')]);
    await t.ensureVisible(find.bySemanticsLabel('Expand Calculators & Tools'));
    await t.tap(find.bySemanticsLabel('Expand Calculators & Tools'));
    await t.pumpAndSettle();
    shows(['Saved Calculations', 'EMI Calculator', 'Lumpsum vs SIP', 'Show remaining 10 pages']);
    hides(['GST Calculator']);
  });

  testWidgets('the chevron expands a folder, the rest of the row opens it', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/settings/theme')]);
    shows(['Look and feel', 'Theme']);
    await t.tap(find.bySemanticsLabel('Collapse Look and feel'));
    await t.pumpAndSettle();
    hides(['Home widgets']);
    await t.tap(find.bySemanticsLabel('Expand Look and feel'));
    await t.pumpAndSettle();
    shows(['Home widgets']);
  });

  testWidgets('a loan detail and the Add loan form are leaves under Loans', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/loans'), qnVirtual('SBI Home Loan')]);
    shows(['Loans', 'SBI Home Loan', 'You are here', 'Show remaining 12 pages']);
    final x = [for (final s in ['Loans', 'SBI Home Loan']) t.getTopLeft(find.text(s)).dx];
    expect(x[1], greaterThan(x[0]));
    await pumpQuickNav(t, stack: [qnPage('/more/loans'), qnVirtual('Add loan')]);
    shows(['Add loan', 'You are here']);
  });

  testWidgets('History and Analytics show only when the page is under them', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/history/filter')], tab: 1);
    shows(['Home', 'History', '/history/filter', 'More']);
    hides(['Analytics', 'Accounts']);
    await pumpQuickNav(t, stack: [qnPage('/more/loans')]);
    hides(['History', 'Analytics']);
  });

  testWidgets('a page with no natural parent goes under the page it was opened from', (t) async {
    await pumpQuickNav(t, stack: [qnVirtual('Swiggy Instamart, 4 Nov')], tab: 0);
    shows(['Home', 'Swiggy Instamart, 4 Nov', 'More', 'You are here']);
    hides(['Accounts', 'History']);
  });

  testWidgets('opened from a notification says so above the tree', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/loans'), qnVirtual('SBI Home Loan')], fromNotification: true);
    shows(['Opened from a notification']);
  });

  testWidgets('the tree opens scrolled so the current row is near the top, without animating', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/tools'), qnPage('/more/tools/gst-calculator')], size: const Size(400, 700));
    final here = t.getTopLeft(find.text('GST Calculator')).dy;
    final tree = t.getTopLeft(find.byType(QuickNavTree)).dy;
    expect(here - tree, inInclusiveRange(520 / 3 - 44, 520 / 3 + 44));
  });

  testWidgets('largest font: nothing overflows and long titles wrap', (t) async {
    await pumpQuickNav(t, stack: [qnPage('/more/settings/theme')], textScale: 2, size: const Size(360, 780));
    expect(t.takeException(), isNull);
    shows(['Theme', 'You are here']);
  });

  group('drift', () {
    testWidgets('every More entry, tool and settings page has a node', (t) async {
      late BuildContext ctx;
      late WidgetRef wref;
      await t.pumpWidget(ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Consumer(builder: (c, ref, _) {
            ctx = c;
            wref = ref;
            return const SizedBox();
          }),
        ),
      ));
      final sections = buildMoreSections(ctx, wref);
      final roots = buildQuickNavTree(ctx, wref);
      final more = roots.firstWhere((n) => n.tab == 3);
      final all = quickNavWalk(roots).toList();

      // More: counts and icons per section match, in order; Help us is left out.
      var i = 0;
      for (final s in sections) {
        final routes = quickNavMoreRoutes[s.id];
        if (s.id == MoreSectionId.helpUs) {
          expect(routes, isNull);
          continue;
        }
        expect(s.entries.length, routes!.length, reason: '${s.id}: add the new More entry to quick_nav_tree.dart');
        for (final e in s.entries) {
          expect(more.children[i].icon, e.icon);
          expect(more.children[i].title, e.label);
          i++;
        }
      }
      expect(more.children.length, 20);
      expect(more.sectionEnds, [8, 17, 20]);

      // Tools: all 18 plus Saved calculations, in the hub's section order.
      final calc = more.children.firstWhere((n) => n.route == '/more/tools');
      expect(calc.children.length, 19);
      expect([for (final tl in ToolCatalog.all) '/more/tools/${tl.key}'],
          calc.children.skip(1).map((n) => n.route).toList());
      expect(calc.sectionEnds.last, calc.children.length);

      // Settings: every area page is a node.
      final routes = {for (final n in all) if (n.route != null) n.route};
      for (final a in SettingsArea.values) {
        if (a == SettingsArea.main || a == SettingsArea.pro) continue;
        expect(routes, contains(a.route), reason: 'SettingsArea.${a.name}');
      }
      expect(more.children.firstWhere((n) => n.route == '/more/settings').children.length, 8);
    });

    test('every node route is a real route', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final router = container.read(routerProvider);
      final paths = <String>{};
      void walk(List<dynamic> rs, String base) {
        for (final r in rs) {
          if (r is StatefulShellRoute) continue;
          final p = r.path as String;
          final full = p.startsWith('/') ? p : (base == '/' ? '/$p' : '$base/$p');
          paths.add(full);
          walk((r.routes as List).cast<dynamic>(), full);
        }
      }

      walk(router.configuration.routes.cast<dynamic>(), '/');
      // Shell branches hold the tab routes.
      for (final r in router.configuration.routes) {
        if (r.runtimeType.toString().contains('StatefulShell')) {
          for (final b in (r as dynamic).branches) {
            walk((b.routes as List).cast<dynamic>(), '/');
          }
        }
      }
      const tabRoutes = ['/', '/history', '/analytics', '/more'];
      for (final n in <String>[...quickNavMoreRoutes.values.expand((e) => e), ...tabRoutes]) {
        expect(paths, contains(n), reason: n);
      }
    });
  });
}
