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
  };
}
