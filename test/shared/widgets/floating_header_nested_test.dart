import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `KuberHeaderPage(nested: true)` (Import from SMS): the outer part of a
/// NestedScrollView (header gap + tabs) scrolls away, then the inner list.
/// Inner offsets near 0 must not take the pill back to the header; only the
/// outer part returning to the top does.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<void> pump(WidgetTester t) async {
    t.view.physicalSize = const Size(360, 780) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MediaQuery(
          data: const MediaQueryData(size: Size(360, 780), padding: EdgeInsets.only(top: 24)),
          child: Scaffold(
            body: KuberHeaderPage(
              nested: true,
              header: const KuberAppBar(title: 'SMS', showBack: true),
              body: NestedScrollView(
                headerSliverBuilder: (_, _) => [
                  KuberHeaderPage.sliverGap(),
                  const SliverToBoxAdapter(child: SizedBox(height: 48, child: Text('Tabs'))),
                ],
                body: ListView(
                  children: [for (var i = 0; i < 60; i++) SizedBox(height: 56, child: Text('Row $i'))],
                ),
              ),
            ),
          ),
        ),
      ),
    ));
    await t.pumpAndSettle();
  }

  double backTop(WidgetTester t) => t.getRect(find.bySemanticsLabel('Back').first).top;

  testWidgets('tabs scroll away; inner scrolling keeps the pill until the top', (t) async {
    await pump(t);
    final rest = backTop(t);
    expect(find.text('Tabs').hitTestable(), findsOneWidget);

    await t.dragFrom(const Offset(180, 500), const Offset(0, -500));
    await t.pumpAndSettle();
    expect(find.text('Tabs').hitTestable(), findsNothing);
    expect(backTop(t), rest - 2, reason: 'pill');

    // Back up within the inner list to an inner offset of ~4 dp (inside the
    // 8 dp "back to header" line), the outer part still gone: still a pill.
    final inner = t.state<ScrollableState>(find.descendant(
        of: find.byType(ListView), matching: find.byType(Scrollable)).first).position;
    inner.jumpTo(4);
    await t.pumpAndSettle();
    expect(find.text('Tabs').hitTestable(), findsNothing);
    expect(backTop(t), rest - 2, reason: 'still the pill');

    // All the way to the top: the header lands exactly at rest.
    await t.dragFrom(const Offset(180, 300), const Offset(0, 800));
    await t.pumpAndSettle();
    expect(backTop(t), rest);
    expect(find.text('Tabs').hitTestable(), findsOneWidget);
  });
}
