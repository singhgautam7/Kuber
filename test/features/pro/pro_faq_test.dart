// November release E: the FAQ is collapsed by default, expands on tap, and
// its copy stays free of long dashes in every language.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/pro/paywall/pro_faq_section.dart';
import 'package:kuber/l10n/app_localizations.dart';

void main() {
  Widget host() => const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: SingleChildScrollView(child: ProFaqSection())),
      );

  testWidgets('every question is collapsed, and expands and collapses on tap', (t) async {
    await t.pumpWidget(host());
    await t.pumpAndSettle();
    final l = lookupAppLocalizations(const Locale('en'));
    expect(find.byType(ExpansionTile), findsNWidgets(10));
    final answer = find.text(l.proFaqLifetimeA, skipOffstage: true);
    expect(answer.hitTestable(), findsNothing);
    await t.tap(find.text(l.proFaqLifetimeQ));
    await t.pumpAndSettle();
    expect(answer.hitTestable(), findsOneWidget);
    await t.tap(find.text(l.proFaqLifetimeQ));
    await t.pumpAndSettle();
    expect(answer.hitTestable(), findsNothing);
    expect(find.text(l.obTermsPrivacy), findsOneWidget);
  });

  test('no long dashes in any language', () {
    for (final code in ['en', 'hi', 'mr', 'bn', 'pa', 'ta', 'te', 'ml', 'kn']) {
      final l = lookupAppLocalizations(Locale(code));
      for (final s in [
        l.proFaqLifetimeA, l.proFaqIncludedA, l.proFaqDevicesA, l.proFaqCancelA, l.proFaqEndsA,
        l.proFaqPhoneA, l.proFaqPromoA, l.proFaqSecureA, l.proFaqPaymentA, l.proFaqRefundA,
        l.obTermsBody, l.obNotifPromise, l.msInfoPreEmiCalcLine,
      ]) {
        expect(s.contains('—') || s.contains('–'), isFalse, reason: '$code: $s');
      }
    }
  });
}
