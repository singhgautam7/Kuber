import 'dart:async';
import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/backups/providers/backup_provider.dart';
import 'package:kuber/features/backups/screens/automatic_backups_screen.dart';
import 'package:kuber/features/more/screens/tags_screen.dart';
import 'package:kuber/features/tags/providers/tag_providers.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:kuber/shared/widgets/kuber_shape_loader.dart';
import 'package:kuber/shared/widgets/money_bar_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget child, List<Override> overrides, {bool noAnim = false}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: ThemeData(colorScheme: const ColorScheme.light()),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, c) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: noAnim),
          child: c!,
        ),
        home: child,
      ),
    );

class _NeverBackup extends BackupSettingsNotifier {
  @override
  Future<BackupSettings> build() => Completer<BackupSettings>().future;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('loading states use KuberShapeLoader', () {
    testWidgets('Tags screen', (tester) async {
      await tester.pumpWidget(_app(const TagsScreen(), [
        tagListProvider.overrideWith((ref) => const Stream.empty()),
      ]));
      await tester.pump();
      expect(find.byType(KuberShapeLoader), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('Automatic backups screen', (tester) async {
      await tester.pumpWidget(_app(const AutomaticBackupsScreen(), [
        backupSettingsProvider.overrideWith(_NeverBackup.new),
      ]));
      await tester.pump();
      expect(find.byType(KuberShapeLoader), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  testWidgets('chart builds at Off with zero animation duration', (tester) async {
    await tester.pumpWidget(_app(
      const Scaffold(
        body: MoneyBarChart(
          bars: [
            MoneyBar('a', [10, 5]),
            MoneyBar('b', [20, 5]),
          ],
          colors: [Colors.red, Colors.blue],
        ),
      ),
      const [],
      noAnim: true,
    ));
    await tester.pump();
    final chart = tester.widget<BarChart>(find.byType(BarChart));
    expect(chart.duration, Duration.zero);
    // Fully drawn on the first frame (no draw-in at Off).
    final g = chart.data.barGroups;
    expect(g[1].barRods.first.toY, 25);
  });

  test('no direct HapticFeedback calls outside KuberHaptics', () {
    final offenders = <String>[];
    for (final e in Directory('lib').listSync(recursive: true)) {
      if (e is! File || !e.path.endsWith('.dart')) continue;
      if (e.path.endsWith('core/motion/kuber_haptics.dart')) continue;
      if (e.readAsStringSync().contains('HapticFeedback.')) {
        offenders.add(e.path);
      }
    }
    expect(offenders, isEmpty);
  });
}
