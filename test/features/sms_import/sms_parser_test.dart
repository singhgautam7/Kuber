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
      expect(r.date, DateTime(2026, 6, 5, ts.hour, ts.minute));
      expect(r.merchant?.toLowerCase(), 'swiggy');
    });

    test('credit parses income type and suffix', () {
      const body = 'INR 65,000.00 credited to A/c XX7842 on 01-Jun-26. - HDFC Bank';
      final r = parser.parse(body, 'HDFCBK', ts)!;
      expect(r.type, 'income');
      expect(r.amount, 65000.0);
      expect(r.accountSuffix, '7842');
      expect(r.date, DateTime(2026, 6, 1, ts.hour, ts.minute));
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

  group('ignore filter vs real transactions', () {
    test('completed debit mentioning mandate/autopay still parses', () {
      const body =
          'Rs 799 debited from ICICI Bank Savings Account XX510 on 17-Jun-26 '
          'towards Zee5 for UPI Mandate AutoPay Retrieval Ref No.653401485421';
      final r = parser.parse(body, 'VM-ICICIT-S', ts)!;
      expect(r.type, 'expense');
      expect(r.amount, 799.0);
    });

    test('bill / statement notices are ignored', () {
      expect(
        parser.parse(
          'Total amount due Rs 12,500 for HDFC Card XX1234. Payment due by '
          '20-Jun-26.',
          'HDFCBK',
          ts,
        ),
        isNull,
      );
      expect(
        parser.parse(
          'Your e-statement for ICICI Bank A/c XX510 is now ready.',
          'ICICIB',
          ts,
        ),
        isNull,
      );
    });

    test('mandate setup notice (no completed verb) is ignored', () {
      expect(
        parser.parse(
          'UPI Mandate of Rs 799 to Zee5 has been successfully registered.',
          'ICICIB',
          ts,
        ),
        isNull,
      );
    });
  });

  group('unparseable', () {
    test('statement-ready message returns null', () {
      const body =
          'Dear customer, your statement is now ready. Login to net-banking '
          'to view. - HDFC Bank';
      expect(parser.parse(body, 'HDFCBK', ts), isNull);
    });

    test('statement/bill notification messages return null', () {
      // User's exact SBI Credit Card statement SMS
      const sbiStatement =
          'E-statement of SBI Credit Card ending XX97 dated 16/06/2026 has been mailed. '
          'If not received, SMS ENRS to 5676791. Total Amt Due Rs 1313; Min Amt Due Rs 200; '
          'Payable by 06/07/2026. Click https://sbicard.com/';
      expect(parser.parse(sbiStatement, 'JM-MYSBIC-S', ts), isNull);

      // ICICI Credit Card bill generation alert
      const iciciStatement =
          'Dear Customer, the statement for your ICICI Bank Credit Card ending XX1005 '
          'is generated. Total amount due: INR 5,432.00, Minimum amount due: INR 500.00, '
          'payment due date is 25-Jun-26.';
      expect(parser.parse(iciciStatement, 'ICICIB', ts), isNull);
    });

    test('standing instruction and auto-debit alerts return null', () {
      // User's exact standing instruction SMS
      const iciciStandingInstruction =
          'We have successfully processed payment of INR 299.00 to Merchant Google Play, '
          'as per Standing Instruction XzgUd1n7mv on 18/06/2026 for ICICI Bank Credit Card 6004. '
          'To manage your Standing Instructions, visit www.icici.bank.in - Personal - Cards - '
          'Manage Standing Instructions. Call 1800 1080 for queries.';
      expect(parser.parse(iciciStandingInstruction, 'JM-ICICIT-T', ts), isNull);

      // Generic UPI Autopay / Mandate execution alert
      const upiMandate =
          'UPI AutoPay Mandate of Rs. 199.00 executed successfully to Spotify India. '
          'Ref: UPI123456789.';
      expect(parser.parse(upiMandate, 'PAYTM', ts), isNull);
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
