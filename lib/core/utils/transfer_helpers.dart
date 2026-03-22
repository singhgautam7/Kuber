import '../../features/accounts/data/account.dart';

enum TransferSubtype {
  normalTransfer,
  creditCardPayment,
  creditCardWithdrawal,
  creditCardTransfer,
}

TransferSubtype getTransferSubtype(Account from, Account to) {
  if (from.isCreditCard && to.isCreditCard) {
    return TransferSubtype.creditCardTransfer;
  } else if (from.isCreditCard) {
    return TransferSubtype.creditCardWithdrawal;
  } else if (to.isCreditCard) {
    return TransferSubtype.creditCardPayment;
  }
  return TransferSubtype.normalTransfer;
}

String transferSubtypeLabel(TransferSubtype subtype) {
  switch (subtype) {
    case TransferSubtype.normalTransfer:
      return 'Transfer';
    case TransferSubtype.creditCardPayment:
      return 'Credit Card Payment';
    case TransferSubtype.creditCardWithdrawal:
      return 'Credit Card Withdrawal';
    case TransferSubtype.creditCardTransfer:
      return 'Credit Card Transfer';
  }
}

class InsufficientBalanceException implements Exception {
  final double available;
  final double required_;

  InsufficientBalanceException({
    required this.available,
    required this.required_,
  });

  @override
  String toString() =>
      'Insufficient balance: available ${available.toStringAsFixed(2)}, '
      'required ${required_.toStringAsFixed(2)}';
}
