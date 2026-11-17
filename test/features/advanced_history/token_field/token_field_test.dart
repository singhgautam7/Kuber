import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/features/advanced_history/widgets/filter/value_pickers.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/bracket_box.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/token_chips.dart';
import 'package:kuber/features/advanced_history/widgets/token_field/token_filter_controller.dart';

import 'token_field_harness.dart';

void main() {
  testWidgets('space seals a token and adds "and"', (t) async {
    final c = ctl('');
    await pumpField(t, c);
    c.focusNode.requestFocus();
    await t.pump();
    await t.enterText(input, '${s}c');
    expect(c.items, isEmpty); // still typing
    await t.enterText(input, '${s}category:food ');
    await t.pump();
    expect(d(c.items), 'category:food and');
    expect(c.cursor, 2);
    expect(find.byType(TokenChip), findsOneWidget);
  });

  testWidgets('quoted text seals on the closing quote', (t) async {
    final c = ctl('');
    await pumpField(t, c);
    c.focusNode.requestFocus();
    await t.pump();
    await t.enterText(input, '$s"swiggy food"');
    expect(c.items.whereType<TokenItem>().single.text, '"swiggy food"');
  });

  testWidgets('backspace on empty: highlight, then delete with joiner',
      (t) async {
    final c = ctl('category:food and tag:trip');
    await pumpField(t, c);
    c.focusNode.requestFocus();
    await t.pump();
    // The sentinel is the only text; deleting it is the backspace signal.
    await t.enterText(input, '');
    expect(c.selected, 2);
    await t.pump(const Duration(milliseconds: 200));
    await t.enterText(input, '');
    await t.pump(const Duration(milliseconds: 200));
    expect(d(c.items), 'category:food');
    // The input got its sentinel back.
    expect((t.widget(input) as TextField).controller!.text, '$s$e');
  });

  testWidgets('a second backspace removes a trailing joiner then highlights',
      (t) async {
    final c = ctl('category:food and');
    await pumpField(t, c);
    c.focusNode.requestFocus();
    await t.pump();
    await t.enterText(input, '');
    expect(d(c.items), 'category:food');
    await t.enterText(input, '');
    expect(c.selected, 0);
    expect(find.byType(TokenChip), findsOneWidget);
  });

  testWidgets('tap a token to edit it in place', (t) async {
    final c = ctl('category:food and tag:trip');
    await pumpField(t, c);
    await t.tap(find.byType(TokenChip).first);
    await t.pump();
    expect(c.editing, 0);
    expect((t.widget(input) as TextField).controller!.text, '${s}category:food$e');
    await t.enterText(input, '${s}category:travel ');
    await t.pump();
    expect(d(c.items), startsWith('category:travel and'));
    expect(c.editing, isNull);
    expect(d(c.items), contains('tag:trip'));
  });

  testWidgets('leaving an edit re-seals the token unchanged',
      (t) async {
    final c = ctl('category:food and tag:trip');
    await pumpField(t, c);
    await t.tap(find.byType(TokenChip).first);
    await t.pump();
    c.focusNode.unfocus();
    await t.pump();
    // unchanged text re-seals as is
    expect(d(c.items), 'category:food and tag:trip');
  });

  testWidgets('insert at the cursor from outside (field list, operator bar)',
      (t) async {
    final c = ctl('category:food and tag:trip');
    await pumpField(t, c);
    c.moveCursor(2);
    c.insert(itemsOf(const ConditionNode(
        QueryField.type, QueryOp.eq, ['expense'])), trailingAnd: true);
    await t.pump();
    expect(d(c.items), 'category:food and type:expense and tag:trip');
    expect(c.cursor, 4);
    // operator bar: "not" at the cursor, then "(".
    await t.tap(find.byKey(const ValueKey('ahf-op-not')));
    await t.pump();
    expect(d(c.items), contains('not'));
    expect(c.items[4], isA<NotItem>());
    // picked filters from the end get a trailing and
    c.moveCursor(c.items.length);
    c.insert(itemsOf(const ConditionNode(
        QueryField.has, QueryOp.eq, ['attachment'])), trailingAnd: true);
    expect(d(c.items).endsWith('has:attachment and'), isTrue);
    expect(c.text.endsWith('and'), isFalse); // dangling joiner is not applied
  });

  testWidgets('paste of a full query', (t) async {
    final c = ctl('');
    await pumpField(t, c);
    c.focusNode.requestFocus();
    await t.pump();
    await t.enterText(input, '${s}category:food and amount:>500 or tag:trip');
    await t.pump();
    expect(c.text, 'category:food and amount:>500 or tag:trip');
    expect(c.filterCount, 3);
  });

  testWidgets('tap a joiner: flip wraps in brackets (a shaded box)', (t) async {
    final c = ctl('category:food and tag:trip');
    await pumpField(t, c);
    expect(find.byType(BracketBox), findsNothing);
    await t.tap(find.byType(JoinerChip));
    await t.pumpAndSettle();
    expect(c.items.whereType<OpenItem>(), isNotEmpty);
    expect(c.items.whereType<JoinerItem>().single.isOr, isTrue);
    expect(find.byType(BracketBox), findsOneWidget);
    await t.tap(find.byType(JoinerChip));
    await t.pumpAndSettle();
    expect(find.byType(BracketBox), findsNothing);
    expect(d(c.items), 'category:food and tag:trip');
  });

  testWidgets('nested boxes up to 3 levels, the 4th as bracket tokens',
      (t) async {
    final c = ctl('(type:expense and (tag:a or (tag:b and (tag:c or tag:d))))');
    await pumpField(t, c);
    await t.pumpAndSettle();
    expect(find.byType(BracketBox).evaluate().where((e) {
      return !(e.widget as BracketBox).implicit;
    }).length, 3);
    // Every bracket stays visible (4 pairs): 3 at box edges, the 4th level
    // as bare tokens.
    expect(find.byType(BracketToken), findsNWidgets(8));
  });

  testWidgets('keyboard cursor keys step between tokens', (t) async {
    final c = ctl('type:expense and tag:trip');
    await pumpField(t, c);
    await t.showKeyboard(input);
    await t.pumpAndSettle();
    expect(c.cursor, 3);
    TextEditingController ed() => (t.widget(input) as TextField).controller!;
    // Caret past the start marker: one step left.
    ed().selection = const TextSelection.collapsed(offset: 0);
    await t.pump();
    expect(c.cursor, 2);
    expect(ed().selection.baseOffset, 1);
    ed().selection = const TextSelection.collapsed(offset: 0);
    await t.pump();
    expect(c.cursor, 1);
    // Past the end marker: one step right.
    ed().selection = TextSelection.collapsed(offset: ed().text.length);
    await t.pump();
    expect(c.cursor, 2);
  });

  testWidgets('a tap outside the field closes it', (t) async {
    final c = ctl('type:expense');
    await pumpField(t, c);
    await t.showKeyboard(input);
    await t.pumpAndSettle();
    expect(c.focusNode.hasFocus, isTrue);
    await t.tapAt(const Offset(5, 590));
    await t.pumpAndSettle();
    expect(c.focusNode.hasFocus, isFalse);
  });

  testWidgets('unmatched bracket: error line; ghost ")" while inside',
      (t) async {
    final c = ctl('(category:food');
    await pumpField(t, c);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Missing closing bracket'), findsOneWidget);
    expect(find.byKey(const ValueKey('ahf-ghost')), findsNothing);
    // Cursor inside the open bracket with the keyboard up: no error, ghost.
    c.moveCursor(2);
    c.focusNode.requestFocus();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('ahf-ghost')), findsOneWidget);
    expect(find.textContaining('Missing closing bracket'), findsNothing);
    // Keyboard closes: validated, error is back.
    c.focusNode.unfocus();
    await t.pump(const Duration(milliseconds: 400));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Missing closing bracket'), findsOneWidget);
    // A lone ")" is a missing opening bracket.
    c.setItems(tokenize('category:food)'));
    await t.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('Missing opening bracket'), findsOneWidget);
  });

  testWidgets('mixed and/or shows the dashed box note', (t) async {
    final c = ctl('category:food and tag:a or tag:b');
    await pumpField(t, c);
    await t.pump(const Duration(milliseconds: 400));
    expect(find.byKey(const ValueKey('ahf-implicit-note')), findsOneWidget);
  });

  test('operator bar disabled rules', () {
    bool en(String text, QueryOperator op, [int? cursor]) {
      final c = ctl(text);
      if (cursor != null) c.moveCursor(cursor);
      return c.enabled(op);
    }

    // ")" needs an open bracket before the cursor
    expect(en('category:food', QueryOperator.close), isFalse);
    expect(en('(category:food', QueryOperator.close), isTrue);
    expect(en('(category:food', QueryOperator.close, 1), isFalse); // after "("
    expect(en('(category:food )', QueryOperator.close), isFalse);
    // and / or: not at the start, after "(", after a joiner or after not
    expect(en('', QueryOperator.and), isFalse);
    expect(en('(', QueryOperator.or), isFalse);
    expect(en('category:food and', QueryOperator.or), isFalse);
    expect(en('not', QueryOperator.and), isFalse);
    expect(en('category:food', QueryOperator.and), isTrue);
    expect(en('category:food', QueryOperator.or), isTrue);
    expect(en('(category:food)', QueryOperator.and), isTrue);
    // not: not right after not
    expect(en('not', QueryOperator.not), isFalse);
    expect(en('', QueryOperator.not), isTrue);
    expect(en('category:food', QueryOperator.not), isTrue);
  });

  testWidgets('operator bar: disabled buttons do nothing, enabled insert',
      (t) async {
    final c = ctl('');
    await pumpField(t, c);
    await t.tap(find.byKey(const ValueKey('ahf-op-and')));
    await t.pump();
    expect(c.items, isEmpty);
    await t.tap(find.byKey(const ValueKey('ahf-op-open')));
    await t.pump();
    expect(c.items.single, isA<OpenItem>());
  });

  testWidgets('semantics: token, joiner, box, operator', (t) async {
    final h = t.ensureSemantics();
    final c = ctl('(category:food and tag:trip) or amount:>500');
    await pumpField(t, c);
    await t.pumpAndSettle();
    expect(find.bySemanticsLabel(RegExp(r'^category is .*double tap to edit')),
        findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^and, double tap to change to or')),
        findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^Group of 2 filters')),
        findsOneWidget);
    expect(find.bySemanticsLabel('Open bracket'), findsOneWidget);
    h.dispose();
  });
}
