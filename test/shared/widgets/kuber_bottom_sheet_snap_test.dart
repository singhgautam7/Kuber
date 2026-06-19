import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/kuber_bottom_sheet.dart';

void main() {
  Future<void> openSheet(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.dark(const Locale('en')),
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const KuberBottomSheet(
                  title: 'Tea/Coffee',
                  subtitle: 'EXPENSE',
                  child: SizedBox(height: 200, child: Text('sheet body')),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('renders title, subtitle and body content', (tester) async {
    await openSheet(tester);

    expect(find.text('Tea/Coffee'), findsOneWidget);
    expect(find.text('sheet body'), findsOneWidget);
    // The sheet is a static (non-draggable) sheet — no DraggableScrollableSheet.
    expect(find.byType(DraggableScrollableSheet), findsNothing);
  });

  testWidgets('close button pops the sheet', (tester) async {
    await openSheet(tester);
    expect(find.text('Tea/Coffee'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Tea/Coffee'), findsNothing);
  });
}
