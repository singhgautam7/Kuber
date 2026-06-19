import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/sms_import/engine/account_matcher.dart';
import 'package:kuber/features/sms_import/engine/sms_parser.dart';

SmsParseResult _result({
  String? suffix,
  String sender = 'HDFCBK',
}) {
  return SmsParseResult(
    rawSms: 'x',
    senderId: sender,
    amount: 100,
    type: 'expense',
    accountSuffix: suffix,
    merchant: null,
    date: DateTime(2026, 6, 1),
    referenceNumber: null,
    patternMatched: 'test',
  );
}

void main() {
  const matcher = AccountMatcher();
  final accounts = [
    const MatchableAccount(id: '1', name: 'HDFC Savings', last4: '4521'),
    const MatchableAccount(id: '2', name: 'ICICI Credit', last4: '9087'),
    const MatchableAccount(id: '3', name: 'HDFC Salary', last4: '7842'),
  ];

  test('suffix: unique hit auto-selects', () {
    final m = matcher.match(_result(suffix: '4521'), accounts);
    expect(m.accountId, '1');
    expect(m.autoSelected, isTrue);
    expect(m.source, AccountMatchSource.suffix);
  });

  test('suffix: ambiguous leaves candidates, no selection', () {
    final dupAccounts = [
      const MatchableAccount(id: '1', name: 'A', last4: '4521'),
      const MatchableAccount(id: '2', name: 'B', last4: '4521'),
    ];
    final m = matcher.match(_result(suffix: '4521'), dupAccounts);
    expect(m.accountId, isNull);
    expect(m.candidateIds, containsAll(['1', '2']));
  });

  test('learned mapping with usageCount >= 3 auto-selects', () {
    final m = matcher.match(
      _result(suffix: null),
      accounts,
      learnedForSender: const LearnedMapping(accountId: '3', usageCount: 4),
    );
    expect(m.accountId, '3');
    expect(m.autoSelected, isTrue);
    expect(m.source, AccountMatchSource.learned);
  });

  test('learned mapping below 3 suggests but does not auto-select', () {
    final m = matcher.match(
      _result(suffix: null),
      accounts,
      learnedForSender: const LearnedMapping(accountId: '3', usageCount: 1),
    );
    expect(m.accountId, '3');
    expect(m.autoSelected, isFalse);
  });

  test('name fuzzy match on sender token', () {
    final m = matcher.match(_result(suffix: null, sender: 'VM-HDFCBK-S'), [
      const MatchableAccount(id: '9', name: 'HDFC Savings', last4: null),
    ]);
    expect(m.accountId, '9');
    expect(m.source, AccountMatchSource.name);
  });

  test('no match returns empty', () {
    final m = matcher.match(_result(suffix: '0000', sender: 'UNKNOWN'), [
      const MatchableAccount(id: '5', name: 'Wallet', last4: '1111'),
    ]);
    expect(m.accountId, isNull);
    expect(m.source, AccountMatchSource.none);
  });
}
