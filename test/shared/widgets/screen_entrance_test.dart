import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/shared/widgets/screen_entrance.dart';

void main() {
  setUp(ScreenEntrance.resetForTest);

  Widget wrap(String id) => Directionality(
    textDirection: TextDirection.ltr,
    child: ScreenEntrance(id: id, child: const Text('content')),
  );

  testWidgets('shows its child after the entrance settles', (tester) async {
    await tester.pumpWidget(wrap('home'));
    await tester.pumpAndSettle();
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('animates on first mount, passthrough on later mounts', (
    tester,
  ) async {
    // First mount for this id runs an entrance animation.
    await tester.pumpWidget(wrap('history'));
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pumpAndSettle();
    expect(find.text('content'), findsOneWidget);

    // Re-mounting the same id is a passthrough — no entrance controller runs.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(wrap('history'));
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('content'), findsOneWidget);
  });
}
