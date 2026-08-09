import 'package:isar_community/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;
  late String type; // 'bank'
  double initialBalance = 0.0; // for CC: initial credit utilized
  double? creditLimit; // total credit limit (CC only)
  bool isCreditCard = false; // explicit toggle
  String? icon; // icon name string (e.g. 'account_balance')
  int? colorValue; // color as int (e.g. 0xFF5C6BC0)
  String? last4Digits; // last 4 digits for bank/credit accounts

  /// Hidden (archived) accounts are excluded from pickers, home cards, and net
  /// worth but kept in the database so they can be re-enabled. Defaults to
  /// false, so existing rows migrate safely.
  bool isDisabled = false;

  // ── Credit-card billing cycle (credit cards only) ────────────────────────
  // Optional day-of-month (1-31) fields. Adding optional/defaulted properties
  // to an existing collection is a safe Isar migration: existing rows read
  // null for the ints and false for the bools with no migration step (same
  // pattern as [isDisabled] above).

  /// Day of month (1-31) the card's statement is generated. null = unset.
  int? billGenerationDay;

  /// Day of month (1-31) the card payment is due. null = unset.
  int? paymentDueDay;

  /// Fire a reminder on the bill-generation day.
  bool billGenerationReminderEnabled = false;

  /// Fire a reminder on the payment-due day.
  bool paymentDueReminderEnabled = false;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'type': type,
    'initialBalance': initialBalance,
    'creditLimit': creditLimit,
    'isCreditCard': isCreditCard,
    'icon': icon,
    'colorValue': colorValue,
    'last4Digits': last4Digits,
    'isDisabled': isDisabled,
    'billGenerationDay': billGenerationDay,
    'paymentDueDay': paymentDueDay,
    'billGenerationReminderEnabled': billGenerationReminderEnabled,
    'paymentDueReminderEnabled': paymentDueReminderEnabled,
  };
}
