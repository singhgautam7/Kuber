import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/transfer_helpers.dart';
import 'package:kuber/features/accounts/data/account.dart';

void main() {
  Account makeTestAccount({bool isCreditCard = false}) {
    return Account()
      ..name = 'Test'
      ..type = 'bank'
      ..isCreditCard = isCreditCard;
  }

  group('getTransferSubtype', () {
    test('normal transfer between non-CC accounts', () {
      expect(
        getTransferSubtype(makeTestAccount(), makeTestAccount()),
        TransferSubtype.normalTransfer,
      );
    });

    test('credit card payment: regular → CC', () {
      expect(
        getTransferSubtype(makeTestAccount(), makeTestAccount(isCreditCard: true)),
        TransferSubtype.creditCardPayment,
      );
    });

    test('credit card withdrawal: CC → regular', () {
      expect(
        getTransferSubtype(makeTestAccount(isCreditCard: true), makeTestAccount()),
        TransferSubtype.creditCardWithdrawal,
      );
    });

    test('credit card transfer: CC → CC', () {
      expect(
        getTransferSubtype(
          makeTestAccount(isCreditCard: true),
          makeTestAccount(isCreditCard: true),
        ),
        TransferSubtype.creditCardTransfer,
      );
    });
  });

  group('transferSubtypeLabel', () {
    test('returns correct labels', () {
      expect(transferSubtypeLabel(TransferSubtype.normalTransfer), 'Transfer');
      expect(
        transferSubtypeLabel(TransferSubtype.creditCardPayment),
        'Credit Card Payment',
      );
      expect(
        transferSubtypeLabel(TransferSubtype.creditCardWithdrawal),
        'Credit Card Withdrawal',
      );
      expect(
        transferSubtypeLabel(TransferSubtype.creditCardTransfer),
        'Credit Card Transfer',
      );
    });
  });

  group('InsufficientBalanceException', () {
    test('stores available and required values', () {
      final ex = InsufficientBalanceException(available: 100, required_: 200);
      expect(ex.available, 100);
      expect(ex.required_, 200);
    });

    test('toString includes amounts', () {
      final ex = InsufficientBalanceException(available: 50, required_: 100);
      expect(ex.toString(), contains('50'));
      expect(ex.toString(), contains('100'));
    });
  });
}
