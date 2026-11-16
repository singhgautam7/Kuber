import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/advanced_history/query/query_ast.dart';
import 'package:kuber/features/advanced_history/query/query_labels.dart';
import 'package:kuber/features/advanced_history/query/query_parser.dart';
import 'package:kuber/l10n/app_localizations.dart';

String money(double v) {
  final s = v.round().toString();
  if (s.length <= 3) return '₹$s';
  final head = s.substring(0, s.length - 3);
  final g = head.replaceAllMapped(RegExp(r'(\d)(?=(\d\d)+$)'), (m) => '${m[1]},');
  return '₹$g,${s.substring(s.length - 3)}';
}

void main() {
  final l = lookupAppLocalizations(const Locale('en'));
  String disp(String t) {
    final c = (tokenize(t).single as TokenItem).condition!;
    final d = tokenDisplay(c, l, money);
    return '${d.field} ${d.value}'.trim();
  }

  String rb(String t) => readbackOf(parseItems(tokenize(t)).node!, l, money);

  test('token display values (design list)', () {
    expect(disp('type:expense'), 'type: Expense');
    expect(disp('amount:>500'), 'amount: over ₹500');
    expect(disp('amount:<500'), 'amount: under ₹500');
    expect(disp('amount:500..2000'), 'amount: ₹500 to ₹2,000');
    expect(disp('amount:500'), 'amount: ₹500');
    expect(disp('category:food,travel'), 'category: food or travel');
    expect(disp('account:"HDFC Millennia"'), 'account: HDFC Millennia');
    expect(disp('tag:trip'), 'tag: #trip');
    expect(disp('tag:none'), 'tag: none');
    expect(disp('date:thisyear'), 'date: This year');
    expect(disp('date:2026-03'), 'date: Mar 2026');
    expect(disp('date:2026-09-01..2026-11-15'), 'date: 1 Sep to 15 Nov 2026');
    expect(disp('date:last30d'), 'date: Last 30 days');
    expect(disp('has:attachment'), 'has: Attachment');
    expect(disp('source:sms'), 'source: SMS');
    expect(disp('swiggy'), '"swiggy"');
  });

  test('readback examples', () {
    expect(rb('type:expense date:thisyear'), 'Expenses this year');
    expect(rb('type:expense category:Food,Travel'), 'Expenses in Food or Travel');
    expect(rb('swiggy amount:>500'),
        'Transactions with “swiggy” in the title or note, over ₹500');
    expect(rb('type:expense not tag:reimbursed has:attachment'),
        'Expenses not tagged #reimbursed, with an attachment');
    expect(rb('type:expense amount:>500 and (category:Food or tag:trip) not tag:reimbursed'),
        'Expenses over ₹500, (in Food or tagged #trip), not tagged #reimbursed');
    expect(rb('date:2026-03'), 'Transactions in March 2026');
    expect(rb('tag:none'), 'Transactions with no tags');
  });

  test('error messages', () {
    String m(String t) => queryErrorMessage(parseItems(tokenize(t)).errors.first, l);
    expect(m('a and (b'), 'Missing closing bracket. Add ) after "b".');
    expect(m('a)'), 'Missing opening bracket');
    expect(m('catgory:x'), 'Unknown field “catgory”. Did you mean category?');
    expect(m('amount:x'), 'Amount needs a number, like amount:>500');
    expect(m('date:x'), 'Date needs a year, month or day, like date:2026-03');
    expect(m('or a'), 'OR needs something on both sides.');
    expect(m('type:expens'), 'No type called “expens”. Did you mean expense?');
  });

}

