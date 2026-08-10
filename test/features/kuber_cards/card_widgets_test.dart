import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/card_palette.dart';
import 'package:kuber/features/kuber_cards/widgets/kuber_pin_pad.dart';
import 'package:kuber/features/kuber_cards/widgets/stored_card_visual.dart';
import 'package:kuber/shared/widgets/card_color_gradient_picker.dart';

Widget _host(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: SizedBox(width: 340, child: child))),
    );

void main() {
  testWidgets('StoredCardVisual renders a solid card without overflow',
      (tester) async {
    await tester.pumpWidget(_host(
      StoredCardVisual(
        nickname: 'HDFC Regalia',
        last4: '1234',
        bankIcon: null,
        network: 'visa',
        colorValue: CardPalette.solids.first,
        isGradient: false,
      ),
    ));
    expect(find.text('HDFC Regalia'), findsOneWidget);
    expect(find.text('•••• •••• •••• 1234'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('StoredCardVisual renders a gradient card + reveal',
      (tester) async {
    await tester.pumpWidget(_host(
      StoredCardVisual(
        nickname: 'Amazon Pay',
        last4: '8842',
        bankIcon: null,
        network: 'mastercard',
        colorValue: 0, // gradient index
        isGradient: true,
        cardholder: 'Asha Mehta',
        expiry: '08/28',
        revealedNumber: '4111111111118842',
      ),
    ));
    expect(find.text('Amazon Pay'), findsOneWidget);
    expect(find.text('4111 1111 1111 8842'), findsOneWidget);
    expect(find.text('Asha Mehta'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('KuberPinPad reports digits and auto-submits on the last one',
      (tester) async {
    final value = ValueNotifier<String>('');
    String? submitted;
    await tester.pumpWidget(_host(
      KuberPinPad(
        length: 4,
        value: value,
        onChanged: (v) => value.value = v,
        onSubmit: (v) => submitted = v,
      ),
    ));

    for (final d in ['1', '2', '3', '4']) {
      await tester.tap(find.text(d));
      await tester.pump();
    }
    expect(value.value, '1234');
    expect(submitted, '1234');
    value.dispose();
  });

  testWidgets('showCardColorPicker opens and selects a swatch', (tester) async {
    int? selectedValue;
    bool? selectedIsGradient;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => showCardColorPicker(
                context: context,
                selectedValue: CardPalette.solids.first,
                selectedIsGradient: false,
                onSelected: (v, g) {
                  selectedValue = v;
                  selectedIsGradient = g;
                },
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Choose color'), findsOneWidget);
    // Tap the first solid swatch inside the (first) grid.
    final firstSwatch = find
        .descendant(of: find.byType(GridView).first, matching: find.byType(InkWell))
        .first;
    await tester.tap(firstSwatch);
    await tester.pumpAndSettle();
    expect(selectedValue, CardPalette.solids.first);
    expect(selectedIsGradient, false);
  });
}
