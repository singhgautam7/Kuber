import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `KuberHeaderPage.ensureVisible` (More sections, Recurring "Processed"):
/// the target lands below the overlay header, not under it.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('reveals a row below the header', (t) async {
    t.view.physicalSize = const Size(360, 780) * 3;
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final key = GlobalKey();
    await t.pumpWidget(ProviderScope(
      child: MaterialApp(
        theme: AppTheme.light(const Locale('en')),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: KuberHeaderPage(
            header: const KuberAppBar(title: 'Page', showBack: true),
            body: ListView(
              children: [
                KuberHeaderPage.gap(),
                for (var i = 0; i < 40; i++)
                  SizedBox(key: i == 14 ? key : null, height: 56, child: Text('Row $i')),
              ],
            ),
          ),
        ),
      ),
    ));
    await t.pumpAndSettle();
    final headerBottom = t.getRect(find.bySemanticsLabel('Back').first).bottom;

    await KuberHeaderPage.ensureVisible(key.currentContext!);
    await t.pumpAndSettle();
    expect(t.getRect(find.byKey(key)).top, greaterThan(headerBottom));
  });
}
