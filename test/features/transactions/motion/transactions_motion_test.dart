import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';
import 'package:kuber/core/utils/formatters.dart';
import 'package:kuber/features/settings/providers/settings_provider.dart';
import 'package:kuber/features/transactions/data/transaction.dart';
import 'package:kuber/features/transactions/widgets/transaction_row.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/transaction_detail_sheet.dart';

import '../../../helpers/test_factories.dart';

class _LoadingSettings extends SettingsNotifier {
  @override
  Future<SettingsState> build() => Completer<SettingsState>().future;
}

Transaction tx(int id) =>
    makeTransaction(id: id, name: 'Txn $id', createdAt: DateTime(2026, 11, 1, 10));

final _fmt = AppFormatter();

Widget host(MotionLevel level, List<Transaction> list,
    {bool animate = true}) {
  return ProviderScope(
    overrides: [settingsProvider.overrideWith(_LoadingSettings.new)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MotionScope(
        level: level,
        systemOff: level == MotionLevel.off,
        child: Scaffold(
          body: SingleChildScrollView(
            child: TransactionDayCard(
              transactions: list,
              animateChanges: animate,
              onDelete: (_) {},
              onTap: (_) {},
              onEdit: (_) {},
              formatter: _fmt,
              categoryMap: const {},
              accountMap: const {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('first build does not animate; a new id grows in', (t) async {
    final a = tx(1), b = tx(2);
    await t.pumpWidget(host(MotionLevel.expressive, [a]));
    expect(find.byType(KuberAnimatedListItem), findsNothing);
    await t.pumpWidget(host(MotionLevel.expressive, [b, a]));
    expect(find.byType(KuberAnimatedListItem), findsOneWidget);
    await t.pump(const Duration(milliseconds: 40));
    expect(find.text('Txn 2'), findsOneWidget);
    await t.pumpAndSettle();
  });

  testWidgets('bulk change (pagination / import) does not animate', (t) async {
    await t.pumpWidget(host(MotionLevel.expressive, [tx(1)]));
    await t.pumpWidget(
        host(MotionLevel.expressive, [tx(2), tx(3), tx(4), tx(5), tx(1)]));
    expect(find.byType(KuberAnimatedListItem), findsNothing);
  });

  testWidgets('animateChanges false (filtering) does not animate', (t) async {
    await t.pumpWidget(host(MotionLevel.expressive, [tx(1)], animate: false));
    await t.pumpWidget(
        host(MotionLevel.expressive, [tx(2), tx(1)], animate: false));
    expect(find.byType(KuberAnimatedListItem), findsNothing);
  });

  testWidgets('delete keeps the row during exit, then removes; undo re-inserts',
      (t) async {
    final a = tx(1), b = tx(2);
    await t.pumpWidget(host(MotionLevel.expressive, [a, b]));
    await t.pumpWidget(host(MotionLevel.expressive, [a]));
    expect(find.text('Txn 2'), findsOneWidget, reason: 'kept for exit');
    await t.pump(const Duration(milliseconds: 30));
    expect(find.text('Txn 2'), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('Txn 2'), findsNothing);
    // Undo.
    await t.pumpWidget(host(MotionLevel.expressive, [a, b]));
    expect(find.byType(KuberAnimatedListItem), findsOneWidget);
    await t.pumpAndSettle();
    expect(find.text('Txn 2'), findsOneWidget);
  });

  testWidgets('Off: insert and exit use no scale transform', (t) async {
    final a = tx(1), b = tx(2);
    await t.pumpWidget(host(MotionLevel.off, [a]));
    await t.pumpWidget(host(MotionLevel.off, [b, a]));
    await t.pump(const Duration(milliseconds: 30));
    final item = find.byType(KuberAnimatedListItem);
    for (final tr in t.widgetList<Transform>(
        find.descendant(of: item, matching: find.byType(Transform)))) {
      if (tr.transform.storage[0] != 1.0) fail('scaled at Off');
    }
    await t.pumpAndSettle();
  });

  for (final l in MotionLevel.values) {
    testWidgets('detail opens and closes as a standard sheet at ${l.name}',
        (t) async {
      late WidgetRef wref;
      await t.pumpWidget(ProviderScope(
        overrides: [settingsProvider.overrideWith(_LoadingSettings.new)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MotionScope(
            level: l,
            systemOff: l == MotionLevel.off,
            child: Consumer(builder: (c, ref, _) {
              wref = ref;
              return Scaffold(
                body: Center(
                  child: TextButton(
                    onPressed: () => showTransactionDetailSheet(c, ref, tx(1)),
                    child: const Text('open'),
                  ),
                ),
              );
            }),
          ),
        ),
      ));
      expect(wref, isNotNull);
      await t.tap(find.text('open'));
      await t.pump();
      await t.pump(const Duration(milliseconds: 100));
      await t.pumpAndSettle();
      expect(find.byType(TransactionDetailSheet), findsOneWidget);
      // Close via the scrim.
      await t.tapAt(const Offset(10, 10));
      await t.pumpAndSettle();
      expect(find.byType(TransactionDetailSheet), findsNothing);
    });
  }
}
