import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/utils/currency_data.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/dashboard/providers/dashboard_provider.dart';
import 'package:kuber/features/dashboard/widgets/balance_hero_card.dart';
import 'package:kuber/features/home_v2/providers/home_v2_provider.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/l10n/app_localizations.dart';

/// Source of truth the fake `monthlySummaryProvider` reads, so a test can
/// "add a transaction" by writing it.
final balSrc = StateProvider<MonthlySummary>((_) => balSummary());

/// How many times the (fake) `monthlySummaryProvider` was evaluated.
int balEvals = 0;

int balTaps = 0;

MonthlySummary balSummary({
  double income = 11000,
  double expense = 44014,
  double prevIncome = 15000,
  double prevExpense = 37814,
  bool hasEarlier = true,
}) => MonthlySummary(
  totalIncome: income,
  totalExpense: expense,
  net: income - expense,
  categorySpending: const {},
  prevIncome: prevIncome,
  prevExpense: prevExpense,
  hasEarlier: hasEarlier,
);

/// The same wiring as Home's `_BalanceHeroSection`.
class _Section extends ConsumerWidget {
  const _Section();
  @override
  Widget build(BuildContext context, WidgetRef ref) => ref
      .watch(monthlySummaryProvider)
      .when(
        skipLoadingOnReload: true,
        loading: () => const SizedBox(key: Key('balSkeleton')),
        error: (e, _) => Text('$e'),
        data: (s) => BalanceHeroCard(summary: s),
      );
}

Widget balanceApp({
  MonthlySummary? summary,
  bool privacy = false,
  ThemeData? theme,
  double textScale = 1,
  MotionLevel level = MotionLevel.expressive,
  bool scroll = true,
}) {
  balEvals = 0;
  balTaps = 0;
  return ProviderScope(
    key: UniqueKey(),
    overrides: [
      balSrc.overrideWith((_) => summary ?? balSummary()),
      monthlySummaryProvider.overrideWith((ref) async {
        balEvals++;
        return ref.watch(balSrc);
      }),
      formatterProvider.overrideWithValue(AppFormatter()),
      currencyProvider.overrideWithValue(kCurrencies.first),
      privacyModeProvider.overrideWithValue(privacy),
      isHomeV2Provider.overrideWithValue(false),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
        child: MotionScope(level: level, systemOff: false, child: child!),
      ),
      home: Scaffold(
        body: ListView(
          physics: scroll ? null : const NeverScrollableScrollPhysics(),
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: RepaintBoundary(key: Key('balCapture'), child: _Section()),
            ),
            TextButton(onPressed: () => balTaps++, child: const Text('other')),
            const SizedBox(height: 2000),
          ],
        ),
      ),
    ),
  );
}

Future<void> pumpBalance(WidgetTester t, Widget app, {Size size = const Size(412, 892)}) async {
  t.view.physicalSize = size;
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(app);
  await t.pumpAndSettle();
}
