// Regressions (specs/vcal/regressions.md G1, G3): Get started stamped its
// first-shown time by changing a provider inside initState, which Riverpod
// rejects in debug builds (it broke the smoke suite on a fresh install).
// Ask Kuber marked itself opened the same way.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/home_v2/data/home_v2_state.dart';
import 'package:kuber/features/home_v2/providers/get_started_provider.dart';
import 'package:kuber/features/home_v2/providers/home_v2_provider.dart';
import 'package:kuber/features/home_v2/widgets/get_started_card.dart';
import 'package:kuber/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('first show stamps gsFirstShownAt after the frame, no assert', (t) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(overrides: [
      homeV2BootProvider.overrideWithValue(const HomeV2Snapshot(cohort: HomeCohort.v2)),
      getStartedProvider.overrideWith((ref) async => null),
    ]);
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: GetStartedCard()),
      ),
    ));
    expect(t.takeException(), isNull);
    await t.pump();
    expect(container.read(homeV2Provider).gsFirstShownAt, isNotNull);
  });

  testWidgets('a discovery flag set from initState is applied, no assert', (t) async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(overrides: [
      homeV2BootProvider.overrideWithValue(const HomeV2Snapshot(cohort: HomeCohort.v2)),
    ]);
    addTearDown(container.dispose);
    await t.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: _MarksOnInit()),
    ));
    await t.pump();
    expect(t.takeException(), isNull);
    expect(container.read(homeV2Provider).askOpened, isTrue);
  });
}

class _MarksOnInit extends ConsumerStatefulWidget {
  const _MarksOnInit();
  @override
  ConsumerState<_MarksOnInit> createState() => _MarksOnInitState();
}

class _MarksOnInitState extends ConsumerState<_MarksOnInit> {
  @override
  void initState() {
    super.initState();
    ref.read(homeV2Provider.notifier).markAskOpened(); // as AskKuberScreen does
  }

  @override
  Widget build(BuildContext context) => const SizedBox();
}
