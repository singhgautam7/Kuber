import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';

String canon(String t) => serializeItems(tokenize(t));
String flip(String t, int j) => serializeItems(flipJoiner(tokenize(t), j));
ParseResult parse(String t) => parseItems(tokenize(t));
Map<String, dynamic> j(String t) => parse(t).node!.toJson();

String kinds(List<QueryItem> items) => items
    .map((i) => switch (i) {
          TokenItem() => 'T',
          JoinerItem() => i.isOr ? 'or' : 'and',
          NotItem() => 'N',
          OpenItem() => '(',
          CloseItem() => ')',
        })
    .join(' ');

void main() {
  group('tokenize / serialize', () {
    test('space is and, joiners normalised', () {
      expect(canon('type:expense  amount:>500 OR tag:trip'),
          'type:expense and amount:>500 or tag:trip');
      expect(canon('a AND b'), '"a" and "b"');
      expect(canon('-tag:x NOT type:income'),
          'not tag:x and not type:income');
      expect(kinds(tokenize('a -b')), 'T and N T');
    });

    test('round trips are stable', () {
      for (final t in [
        'category:(food OR travel) amount:500..2000 date:2026-01..2026-03',
        'category:"Food & Dining",travel not (a or b) and -c',
        'date:last30d date:>=2026-03-14 date:thismonth amount:<=100',
        'words:"he said \\"hi\\"" "swiggy" tag:#trip tag:none',
        '((a and (b or c)) or d)',
        'subtype:loan_repayment source:SMS has:Note type:Transfer',
      ]) {
        final c = canon(t);
        expect(canon(c), c, reason: t);
        final items = tokenize(c);
        final again = tokenize(serializeItems(items));
        expect(kinds(again), kinds(items));
        expect(serializeItems(again), c);
      }
    });

    test('values', () {
      expect(canon('category:food,travel'), 'category:food,travel');
      expect(canon('category:(food OR travel)'), 'category:food,travel');
      expect(canon('category:"Food & Dining"'), 'category:"Food & Dining"');
      expect(canon('amount:₹1500.50'), 'amount:1500.5');
      expect(canon('amount:2000..500'), 'amount:500..2000');
      expect(canon('date:2026-3'), 'date:2026-03');
      expect(canon('tag:#Trip'), 'tag:Trip');
      expect(canon('swiggy'), '"swiggy"');
      expect(canon('"two words"'), '"two words"');
      final c = (tokenize('category:food,travel').single as TokenItem).condition!;
      expect(c.values, ['food', 'travel']);
    });

    test('invalid text becomes a null-condition token', () {
      for (final t in [
        'foo:bar',
        'amount:abc',
        'date:2026-13',
        'type:foo',
        'amount:',
        'category:>5',
        '"unterminated',
      ]) {
        final items = tokenize(t);
        expect((items.single as TokenItem).condition, isNull, reason: t);
        expect(parseItems(items).isValid, isFalse, reason: t);
      }
    });
  });

  group('errors', () {
    QueryError e1(String t) => parse(t).errors.single;
    test('codes and positions', () {
      expect(e1('foo:bar').code, QueryErrorCode.unknownField);
      expect(e1('catgory:food').args, ['catgory', 'category']);
      expect(e1('amount:x').code, QueryErrorCode.badAmount);
      expect(e1('date:x').code, QueryErrorCode.badDate);
      expect(e1('type:expens').args, ['type', 'expens', 'expense']);
      final a = e1('a and (b');
      expect(a.code, QueryErrorCode.missingClose);
      expect(a.itemIndex, 2);
      expect(a.args, ['"b"']);
      expect(parse('a and (b').node, isNull);
      final b = e1('a) and b');
      expect(b.code, QueryErrorCode.missingOpen);
      expect(b.itemIndex, 1);
      expect(e1('or a').code, QueryErrorCode.joinerNeedsBothSides);
      expect(e1('a or').itemIndex, 1);
      expect(e1('a and or b').code, QueryErrorCode.joinerNeedsBothSides);
      expect(e1('a and ()').code, QueryErrorCode.emptyGroup);
      expect(e1('a not').code, QueryErrorCode.badToken);
    });

    test('validateValues suggests closest', () {
      final items = tokenize('category:fod tag:trip account:hdfc tag:none');
      final errs = validateValues(
          items,
          const AhLookup(
              categories: ['Food', 'Travel'],
              accounts: ['HDFC Millennia'],
              tags: ['trips']));
      expect(errs.length, 2);
      expect(errs[0].args, ['category', 'fod', 'Food']);
      expect(errs[1].args, ['tag', 'trip', 'trips']);
    });
  });

  group('parse', () {
    test('precedence NOT > AND > OR', () {
      expect(j('a or b and c'), {
        'k': 'or',
        'c': [
          {'k': 'cond', 'f': 'words', 'o': 'eq', 'v': ['a']},
          {
            'k': 'and',
            'c': [
              {'k': 'cond', 'f': 'words', 'o': 'eq', 'v': ['b']},
              {'k': 'cond', 'f': 'words', 'o': 'eq', 'v': ['c']},
            ]
          }
        ]
      });
      final n = parse('not a and b').node as AndNode;
      expect(n.children.first, isA<NotNode>());
      expect(parse('not not a').node, isA<NotNode>());
      final o = parse('not (a or b)').node as NotNode;
      expect(o.child, isA<OrNode>());
    });

    test('brackets override, deep nesting (5 levels)', () {
      final r = parse('(a or b) and c');
      expect(r.node, isA<AndNode>());
      final deep = parse('(1 and (2 or (3 and (4 or (5 and 6)))))');
      expect(deep.isValid, isTrue);
      final depths = deep.boxes.where((b) => !b.implicit).map((b) => b.depth);
      expect(depths.toList()..sort(), [1, 2, 3, 4, 5]);
    });

    test('boxes: explicit and implicit', () {
      final r = parse('a and b or c and d');
      expect(r.boxes.length, 2);
      expect(r.boxes.every((b) => b.implicit && b.depth == 1), isTrue);
      expect((r.boxes[0].start, r.boxes[0].end), (0, 2));
      expect((r.boxes[1].start, r.boxes[1].end), (4, 6));
      // pure and / pure or: nothing implicit
      expect(parse('a and b and c').boxes, isEmpty);
      expect(parse('a or b').boxes, isEmpty);
      // implicit box inside an explicit one is deeper
      final n = parse('(a and b or c)');
      final exp = n.boxes.firstWhere((b) => !b.implicit);
      final imp = n.boxes.firstWhere((b) => b.implicit);
      expect((exp.depth, imp.depth), (1, 2));
    });

    test('serializeNode / itemsFromNode agree with parse', () {
      for (final t in [
        'a and (b or c)',
        '(a or b) and (c or d)',
        'a and b or c and d',
        'not (a or b) and not c',
        '(a and b) and c',
        '(a or (b or c))',
        'type:expense and not (tag:x or tag:y)',
      ]) {
        final n = parse(t).node!;
        final s = serializeNode(n);
        expect(parse(s).node!.toJson(), n.toJson(), reason: t);
        expect(serializeItems(itemsFromNode(n)), s);
      }
      expect(serializeNode(parse('(a and b) or c').node!), '"a" and "b" or "c"');
    });

    test('empty and tokenCount', () {
      expect(parse('').node, isNull);
      expect(parse('').isValid, isTrue);
      expect(tokenCount(tokenize('a and (b or c) not d')), 4);
    });
  });

  group('flipJoiner', () {
    test('and to or wraps both neighbours', () {
      expect(flip('a and b and c', 1), '("a" or "b") and "c"');
      expect(flip('a and b and c', 3), '"a" and ("b" or "c")');
      expect(flip('not a and b', 2), '(not "a" or "b")');
    });

    test('joins an adjacent or group and flattens', () {
      expect(flip('(a or b) and c', 5), '("a" or "b" or "c")');
      expect(flip('a and (b or c)', 1), '("a" or "b" or "c")');
      expect(flip('(a or b) and (c or d)', 5),
          '("a" or "b" or "c" or "d")');
      // inside an or chain the brackets vanish
      expect(flip('a or b and c', 3), '"a" or "b" or "c"');
      expect(flip('a and b or c', 1), '"a" or "b" or "c"');
      // a group under and keeps its brackets
      expect(flip('x and a and b', 3), '"x" and ("a" or "b")');
    });

    test('or to and removes brackets no longer needed', () {
      expect(flip('("a" or "b") and c', 2), '"a" and "b" and "c"');
      expect(flip('a and (b or c) and d', 4), '"a" and "b" and "c" and "d"');
      // still an or inside: stays
      expect(flip('(a or b or c)', 2), '("a" and "b" or "c")');
      // not group keeps its bracket
      expect(flip('not (a or b)', 3), 'not ("a" and "b")');
      // top level or chain has no bracket to remove
      expect(flip('a or b', 1), '"a" and "b"');
    });

    test('flip and back is the original; boxes match evaluation', () {
      final items = tokenize('a and b and c and d');
      for (var jx = 1; jx < items.length; jx += 2) {
        final f = flipJoiner(items, jx);
        final flipped = parseItems(f);
        expect(flipped.isValid, isTrue);
        final back = flipJoiner(f, f.indexWhere((i) => i is JoinerItem && i.isOr));
        expect(serializeItems(back), serializeItems(items));
      }
    });

    test('ignores non joiners and unmatched', () {
      final items = tokenize('a and (b');
      expect(flipJoiner(items, 0), same(items));
      expect(flipJoiner(items, 1), same(items));
    });
  });
}
