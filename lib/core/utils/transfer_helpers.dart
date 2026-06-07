import '../../features/accounts/data/account.dart';
import 'l10n_ext.dart';

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

String transferSubtypeLabel(AppLocalizations l10n, TransferSubtype subtype) {
  switch (subtype) {
    case TransferSubtype.normalTransfer:
      return l10n.transferLabel;
    case TransferSubtype.creditCardPayment:
      return l10n.creditCardPayment;
    case TransferSubtype.creditCardWithdrawal:
      return l10n.creditCardWithdrawal;
    case TransferSubtype.creditCardTransfer:
      return l10n.creditCardTransfer;
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
      'Insufficient balance: available $available, required $required_';
}
