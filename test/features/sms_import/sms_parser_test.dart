import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/sms_import/engine/sms_parser.dart';
import 'package:kuber/features/sms_import/engine/bank_patterns.dart';
import 'package:kuber/features/sms_import/engine/sender_ids.dart';

void main() {
  const parser = SmsParser();
  final ts = DateTime(2026, 6, 17, 9, 0);

  group('OTP guard', () {
    final otpSamples = [
      ('847291 is your OTP for transaction. DO NOT SHARE. - HDFC Bank', 'HDFCBK'),
      ('Your one time password is 123456', 'SBIINB'),
      ('Use verification code 9981 to login', 'ICICIB'),
      ('OTP for txn is 5521. Do not share this with anyone.', 'AXISBK'),
    ];
    for (final (body, sender) in otpSamples) {
      test('returns null for: $body', () {
        expect(parser.parse(body, sender, ts), isNull);
      });
    }
  });

  group('HDFC', () {
    test('debit (UPI) parses amount, suffix, date, merchant', () {
      const body =
          'INR 648.50 debited from A/c XX4521 on 05-Jun-26 to VPA swiggy@hdfc. '
          'Avl bal: INR 24,108.50. Not you? Call 18002586161 - HDFC Bank';
      final r = parser.parse(body, 'HDFCBK', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 648.50);
      expect(r.accountSuffix, '4521');
      expect(r.date, DateTime(2026, 6, 5));
      expect(r.merchant?.toLowerCase(), 'swiggy');
    });

    test('credit parses income type and suffix', () {
      const body = 'INR 65,000.00 credited to A/c XX7842 on 01-Jun-26. - HDFC Bank';
      final r = parser.parse(body, 'HDFCBK', ts)!;
      expect(r.type, 'income');
      expect(r.amount, 65000.0);
      expect(r.accountSuffix, '7842');
      expect(r.date, DateTime(2026, 6, 1));
    });
  });

  group('SBI', () {
    test('debit', () {
      const body = 'Rs.412 debited from SBI A/c X3321 on 04Jun26. - SBI';
      final r = parser.parse(body, 'SBIINB', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 412.0);
      expect(r.accountSuffix, '3321');
    });

    test('credit', () {
      const body = 'Rs.25000 credited to SBI A/c X3321. - SBI';
      final r = parser.parse(body, 'SBIINB', ts)!;
      expect(r.type, 'income');
      expect(r.amount, 25000.0);
      expect(r.accountSuffix, '3321');
    });
  });

  group('ICICI', () {
    test('debit', () {
      const body =
          'ICICI Bank A/c XX9087: Rs 2,899.00 debited on 04-Jun-26. Info: Amazon.';
      final r = parser.parse(body, 'ICICIB', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 2899.0);
      expect(r.accountSuffix, '9087');
    });

    test('credit', () {
      const body = 'ICICI Bank A/c XX9087: Rs 5000 credited on 04-Jun-26.';
      final r = parser.parse(body, 'ICICIB', ts)!;
      expect(r.type, 'income');
      expect(r.amount, 5000.0);
      expect(r.accountSuffix, '9087');
    });
  });

  group('amount formats', () {
    test('handles symbols, words and commas', () {
      expect(parseAmount('INR 2,800.00'), 2800.0);
      expect(parseAmount('Rs.649'), 649.0);
      expect(parseAmount('Rs 25000'), 25000.0);
      expect(parseAmount('₹2800'), 2800.0);
      expect(parseAmount('2,800.00'), 2800.0);
    });
  });

  group('date formats', () {
    test('various', () {
      expect(parseSmsDate('28-May-26'), DateTime(2026, 5, 28));
      expect(parseSmsDate('28-May-2026'), DateTime(2026, 5, 28));
      expect(parseSmsDate('01/06/2026'), DateTime(2026, 6, 1));
      expect(parseSmsDate('01 Jun 2026'), DateTime(2026, 6, 1));
      expect(
        parseSmsDate('Jun 01', now: DateTime(2026, 1, 1)),
        DateTime(2026, 6, 1),
      );
      expect(parseSmsDate('garbage'), isNull);
    });
  });

  group('UPI', () {
    test('debit via PhonePe', () {
      const body = 'Paid Rs.250 to john@okhdfc via PhonePe. Ref 123456789.';
      final r = parser.parse(body, 'PHONEPE', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 250.0);
    });

    test('credit received', () {
      const body = 'Received Rs.1500 from RAHUL KUMAR via UPI.';
      final r = parser.parse(body, 'PYTMBNK', ts)!;
      expect(r.type, 'income');
      expect(r.amount, 1500.0);
    });
  });

  group('sender recognition (substring, DLT headers)', () {
    final recognized = [
      'VM-ICICIT-S', 'JM-ICICIT-S', 'AD-HDFCBK-S', 'VK-SBIINB', 'JD-AXISBK-S',
      'BP-KOTAKB-T', 'ICICIBANK',
    ];
    for (final s in recognized) {
      test('recognizes $s', () => expect(isKnownBankSender(s), isTrue));
    }
    test('rejects a personal contact', () {
      expect(isKnownBankSender('+919876543210'), isFalse);
      expect(isKnownBankSender('MOM'), isFalse);
    });
  });

  group('debit/credit precedence', () {
    test('debit wins when it appears before credit', () {
      // Real ICICI format: debit txn that also mentions the payee was credited.
      const body =
          'ICICI Bank Acct XX510 debited for Rs 25.00 on 17-Jun-26; '
          'Birendra Kumar credited. UPI:120240010757. Call 18002662 for dispute.';
      final r = parser.parse(body, 'JM-ICICIT-S', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 25.0);
    });

    test('credit wins when it appears first', () {
      const body = 'Rs 5000 credited to your A/c. Avl bal updated.';
      final r = parser.parse(body, 'XX-ICICI', ts)!;
      expect(r.type, 'income');
    });
  });

  group('broadened keywords', () {
    test('"spent using ... Card" parses as expense', () {
      const body =
          'INR 1,004.00 spent using ICICI Bank Card XX6004 on 18-Jun-26 on '
          'AMAZON PAY IN E. Avl Limit: INR 2,44,371.78. If not you, call 1800 '
          '2662.';
      final r = parser.parse(body, 'VM-ICICIT-S', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 1004.0); // first amount, not the available limit
    });
  });

  group('unparseable', () {
    test('statement-ready message returns null', () {
      const body =
          'Dear customer, your statement is now ready. Login to net-banking '
          'to view. - HDFC Bank';
      expect(parser.parse(body, 'HDFCBK', ts), isNull);
    });

    test('date fallback to sms timestamp when no date in body', () {
      const body = 'Rs.100 debited from A/c X1234.';
      final r = parser.parse(body, 'SBIINB', ts)!;
      expect(r.date, ts);
    });
  });

  group('smsHash', () {
    test('is stable and sender-sensitive', () {
      expect(smsHash('abc', 'HDFCBK'), smsHash('abc', 'HDFCBK'));
      expect(smsHash('abc', 'HDFCBK') == smsHash('abc', 'SBIINB'), isFalse);
    });
  });
}
