import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/home_v2/engine/suggestion_engine.dart';

final now = DateTime(2026, 10, 15, 12);

SgTxn exp(
  String name,
  double amount,
  DateTime at, {
  String cat = 'food',
  String acc = '1',
  bool sms = false,
  String? smsText,
  String? note,
}) => SgTxn(
  at: at,
  amount: amount,
  isExpense: true,
  name: name,
  categoryId: cat,
  accountId: acc,
  fromSms: sms,
  smsText: smsText,
  note: note,
);

List<SgCandidate> run(SgInput i) => SuggestionEngine.evaluate(i);
Iterable<String> keys(SgInput i) => run(i).map((c) => c.key);

void main() {
  group('helpers', () {
    test('merchantKey strips digits, punctuation and UPI handles', () {
      expect(SuggestionEngine.merchantKey('Netflix.com 1234'), 'netflix com');
      expect(SuggestionEngine.merchantKey('netflix@ybl'), 'netflix');
      expect(SuggestionEngine.merchantKey('ZOMATO*Order#88'), 'zomato order');
    });

    test('lender from sender id', () {
      expect(SuggestionEngine.lenderFromSender('AX-HDFCBK'), 'HDFC');
      expect(SuggestionEngine.lenderFromSender('VM-ICICIB'), 'ICICIB');
    });

    test('person payee heuristic', () {
      expect(SuggestionEngine.isPersonPayee('Rahul Sharma'), isTrue);
      expect(SuggestionEngine.isPersonPayee('Swiggy Foods'), isFalse);
      expect(SuggestionEngine.isPersonPayee('A B C D'), isFalse);
    });
  });

  group('1 loans', () {
    test('EMI SMS in 60 days and no loans triggers, with prefill', () {
      final i = SgInput(
        now: now,
        txns: [
          exp(
            'HDFC Bank',
            12000,
            now.subtract(const Duration(days: 10)),
            sms: true,
            smsText: 'EMI of Rs 12000 debited',
          ),
        ],
      );
      final c = run(i).single;
      expect(c.key, 'loans');
      expect(c.data['amount'], 12000);
    });
    test('a loan already exists: no suggestion', () {
      final i = SgInput(
        now: now,
        loanCount: 1,
        staged: [
          SgStagedSms(
            at: now.subtract(const Duration(days: 3)),
            text: 'Your EMI is due',
            sender: 'AX-HDFCBK',
            amount: 9000,
          ),
        ],
      );
      expect(keys(i), isNot(contains('loans')));
    });
    test('staged EMI SMS older than 60 days does not trigger', () {
      final i = SgInput(
        now: now,
        staged: [
          SgStagedSms(
            at: now.subtract(const Duration(days: 61)),
            text: 'EMI debited',
            sender: 'AX-HDFCBK',
            amount: 9000,
          ),
        ],
      );
      expect(keys(i), isEmpty);
    });
  });

  group('2 credit card', () {
    const card = SgAccount(id: 7, name: 'Amazon Pay', isCreditCard: true);
    test('card with an SMS in 60 days and no billing day triggers', () {
      final i = SgInput(
        now: now,
        accounts: const [card],
        txns: [
          exp(
            'Amazon',
            500,
            now.subtract(const Duration(days: 5)),
            acc: '7',
            sms: true,
          ),
        ],
      );
      expect(keys(i), contains('cc:7'));
    });
    test('billing day already set: no suggestion', () {
      final i = SgInput(
        now: now,
        accounts: const [
          SgAccount(id: 7, name: 'x', isCreditCard: true, billingDay: 12),
        ],
        txns: [exp('Amazon', 500, now, acc: '7', sms: true)],
      );
      expect(keys(i), isNot(contains('cc:7')));
    });
  });

  group('3 recurring', () {
    List<SgTxn> monthly(String name, List<double> amounts, List<int> days) => [
      for (var k = 0; k < amounts.length; k++)
        exp(name, amounts[k], DateTime(2026, 10 - k, days[k]), cat: 'subs'),
    ];

    test('3 consecutive months, steady amount and day: triggers', () {
      final i = SgInput(
        now: now,
        txns: monthly('Netflix', [649, 649, 649], [5, 5, 6]),
      );
      final c = run(i).singleWhere((c) => c.type == SgType.recurring);
      expect(c.key, 'recurring:netflix');
      expect(c.data['amount'], 649);
      expect(c.data['nextDate'], DateTime(2026, 11, 5));
      expect(c.data['months'], 3);
    });
    test('amount outside ±10% (and ±20) fails', () {
      final i = SgInput(
        now: now,
        txns: monthly('Gym', [1000, 1300, 1000], [5, 5, 5]),
      );
      expect(keys(i), isEmpty);
    });
    test('day outside ±3 fails; month ends fold together', () {
      final far = SgInput(
        now: now,
        txns: monthly('Gym', [999, 999, 999], [5, 12, 5]),
      );
      expect(keys(far), isEmpty);
      final ends = SgInput(
        now: DateTime(2026, 11, 2),
        txns: [
          exp('Rentals', 999, DateTime(2026, 10, 31)),
          exp('Rentals', 999, DateTime(2026, 9, 30)),
          exp('Rentals', 999, DateTime(2026, 8, 31)),
        ],
      );
      expect(keys(ends), contains('recurring:rentals'));
    });
    test('median below ₹50 fails; latest older than 40 days fails', () {
      expect(
        keys(SgInput(now: now, txns: monthly('Tea', [40, 40, 40], [5, 5, 5]))),
        isEmpty,
      );
      expect(
        keys(
          SgInput(
            now: DateTime(2026, 12, 20),
            txns: monthly('Netflix', [649, 649, 649], [5, 5, 5]),
          ),
        ),
        isEmpty,
      );
    });
    test('an active recurring rule for the merchant suppresses it', () {
      final i = SgInput(
        now: now,
        txns: monthly('Netflix', [649, 649, 649], [5, 5, 5]),
        rules: const [SgRule(name: 'Netflix', categoryId: 'x', amount: 1)],
      );
      expect(keys(i), isEmpty);
    });
    test('subscription services: spellings group, 2 months is enough', () {
      final i = SgInput(
        now: now,
        txns: [
          exp('NETFLIX.COM', 649, DateTime(2026, 10, 5), cat: 'subs'),
          exp('Netflix Entertainment', 649, DateTime(2026, 9, 5), cat: 'subs'),
          exp('GOOGLE *YouTubePremium', 129, DateTime(2026, 10, 9)),
          exp('Google YouTube', 129, DateTime(2026, 9, 8)),
          // Not a known service: 2 months is not enough.
          ...monthly('Gym', [999, 999], [5, 5]),
        ],
      );
      final rec = {
        for (final c in run(i).where((c) => c.type == SgType.recurring))
          c.key: '${c.data['merchant']} ${c.data['months']}',
      };
      expect(rec, {
        'recurring:netflix': 'Netflix 2',
        'recurring:youtube premium': 'YouTube Premium 2',
      });
      expect(SuggestionEngine.subscriptionOf('zee'), 'ZEE5');
      expect(SuggestionEngine.subscriptionOf('zeeshan store'), isNull);
      expect(SuggestionEngine.subscriptionOf('spotify india'), 'Spotify');
    });
    test('a rule with another spelling of the service suppresses it', () {
      final i = SgInput(
        now: now,
        txns: monthly('Spotify AB', [119, 119], [3, 3]),
        rules: const [
          SgRule(name: 'Spotify subscription', categoryId: 'x', amount: 1),
        ],
      );
      expect(keys(i), isEmpty);
    });
    test('tie-break: highest median amount ranks higher', () {
      final i = SgInput(
        now: now,
        txns: [
          ...monthly('Netflix', [649, 649, 649], [5, 5, 5]),
          ...monthly('Rent house', [2000, 2000, 2000], [1, 1, 1]),
        ],
      );
      final rec = run(i).where((c) => c.type == SgType.recurring).toList()
        ..sort((a, b) => b.rank.compareTo(a.rank));
      expect(rec.first.key, 'recurring:rent house');
    });
  });

  group('4 investments', () {
    test('SIP SMS and no investments triggers', () {
      final i = SgInput(
        now: now,
        txns: [
          exp(
            'Groww',
            5000,
            now.subtract(const Duration(days: 3)),
            sms: true,
            smsText: 'SIP of Rs 5000 processed',
          ),
        ],
      );
      expect(keys(i), contains('investments'));
    });
    test('an investment exists: no suggestion', () {
      final i = SgInput(
        now: now,
        investmentCount: 1,
        txns: [exp('SIP mutual fund', 5000, now)],
      );
      expect(keys(i), isNot(contains('investments')));
    });
  });

  group('5 budget', () {
    List<SgTxn> spread(String cat, double each, int n) => [
      for (var k = 0; k < n; k++)
        exp('Shop', each, now.subtract(Duration(days: k * 7 + 1)), cat: cat),
    ];

    test('4+ txns, 3+ weeks, ≥ ₹1,000, no budget: triggers, rounded up', () {
      final i = SgInput(
        now: now,
        categoryNames: const {'food': 'Food'},
        txns: spread('food', 300, 4),
      );
      final c = run(i).singleWhere((c) => c.type == SgType.budget);
      expect(c.key, 'budget:food');
      expect(c.data['total'], 1200);
      expect(c.data['amount'], 1500);
    });
    test('under ₹1,000, too few weeks, or an existing budget: no', () {
      expect(keys(SgInput(now: now, txns: spread('food', 200, 4))), isEmpty);
      final sameWeek = SgInput(
        now: now,
        txns: [
          for (var k = 0; k < 5; k++)
            exp('x', 400, now.subtract(Duration(hours: k + 1))),
        ],
      );
      expect(keys(sameWeek), isEmpty);
      expect(
        keys(
          SgInput(
            now: now,
            txns: spread('food', 300, 4),
            activeBudgetCategoryIds: const {'food'},
          ),
        ),
        isEmpty,
      );
    });
    test('rent / EMI / investment / transfer categories are excluded', () {
      final i = SgInput(
        now: now,
        categoryNames: const {'r': 'House Rent'},
        txns: spread('r', 5000, 4),
      );
      expect(keys(i), isEmpty);
    });
  });

  group('6 lend and borrow', () {
    test('UPI payments to one person totalling ≥ ₹1,000 trigger', () {
      final i = SgInput(
        now: now,
        txns: [
          exp(
            'Rahul Sharma',
            700,
            now.subtract(const Duration(days: 2)),
            sms: true,
            smsText: 'UPI debit',
          ),
          exp(
            'Rahul Sharma',
            500,
            now.subtract(const Duration(days: 9)),
            sms: true,
            smsText: 'UPI debit',
          ),
        ],
      );
      final c = run(i).single;
      expect(c.key, 'ledger');
      expect(c.data['variant'], 'transfer');
      expect(c.data['amount'], 1200);
    });
    test('note variant uses the keyword list; existing ledger blocks', () {
      final note = SgInput(
        now: now,
        notes: [SgNote(at: now, title: 'Lent to Amit', body: '')],
      );
      expect(run(note).single.data['variant'], 'note');
      final hindi = SgInput(
        now: now,
        languageCode: 'hi',
        notes: [SgNote(at: now, title: 'अमित', body: 'उधार 500')],
      );
      expect(keys(hindi), contains('ledger'));
      final noList = SgInput(
        now: now,
        languageCode: 'ta',
        notes: [SgNote(at: now, title: 'lent', body: '')],
      );
      expect(keys(noList), isEmpty);
      final blocked = SgInput(
        now: now,
        ledgerCount: 1,
        notes: [SgNote(at: now, title: 'lent', body: '')],
      );
      expect(keys(blocked), isEmpty);
    });
    test('"flower" does not match the keyword "owe"', () {
      final i = SgInput(
        now: now,
        notes: [SgNote(at: now, title: 'flower shop', body: '')],
      );
      expect(keys(i), isEmpty);
    });
  });

  group('discovery', () {
    test('D1 Ask Kuber at 20 transactions, never opened', () {
      expect(keys(SgInput(now: now, totalTxnCount: 20)), contains('ask_kuber'));
      expect(keys(SgInput(now: now, totalTxnCount: 19)), isEmpty);
      expect(
        keys(SgInput(now: now, totalTxnCount: 40, askOpened: true)),
        isEmpty,
      );
    });
    test('D2 voice needs Quick Add on Home and a recognizer', () {
      final i = SgInput(
        now: now,
        totalTxnCount: 10,
        askOpened: true,
        quickAddOnHome: true,
        speechAvailable: true,
      );
      expect(keys(i), ['voice']);
    });
    test('D3 home widget: Android, pin supported, none placed, 7 days, 15', () {
      final i = SgInput(
        now: now,
        totalTxnCount: 15,
        askOpened: true,
        isAndroid: true,
        pinWidgetSupported: true,
        hasHomeWidget: false,
        installAgeDays: 7,
      );
      expect(keys(i), ['home_widget']);
    });
    test('D4 Kuber Cards: bank account, no cards, 14 days', () {
      final i = SgInput(
        now: now,
        accounts: const [SgAccount(id: 1, name: 'Bank', isBank: true)],
        installAgeDays: 14,
      );
      expect(keys(i), ['kuber_cards']);
    });
  });

  test('evaluation stays well under 50 ms on 6,000 transactions', () {
    final txns = <SgTxn>[
      for (var k = 0; k < 6000; k++)
        exp(
          'Merchant ${k % 300}',
          100 + (k % 50) * 10,
          now.subtract(Duration(hours: k ~/ 2)),
          cat: 'c${k % 25}',
          acc: '${k % 4}',
          sms: k.isEven,
          smsText: k % 7 == 0 ? 'UPI debit to Rahul Sharma' : 'debited',
        ),
    ];
    final i = SgInput(
      now: now,
      txns: txns,
      totalTxnCount: 6000,
      accounts: const [SgAccount(id: 1, name: 'Card', isCreditCard: true)],
    );
    SuggestionEngine.evaluate(i); // warm-up (JIT)
    final sw = Stopwatch()..start();
    const runs = 10;
    for (var r = 0; r < runs; r++) {
      SuggestionEngine.evaluate(i);
    }
    final perRun = sw.elapsedMicroseconds / runs / 1000;
    // ignore: avoid_print
    print(
      'Home v2 rules on 6000 transactions: ${perRun.toStringAsFixed(1)} ms',
    );
    expect(perRun, lessThan(50));
  });
}
