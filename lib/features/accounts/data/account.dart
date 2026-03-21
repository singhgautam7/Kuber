import 'package:isar/isar.dart';

part 'account.g.dart';

@collection
class Account {
  Id id = Isar.autoIncrement;

  late String name;
  late String type; // 'cash' | 'bank'
  double initialBalance = 0.0; // for CC: initial credit utilized
  double? creditLimit; // total credit limit (CC only)
  bool isCreditCard = false; // explicit toggle
  String? icon; // icon name string (e.g. 'account_balance')
  int? colorValue; // color as int (e.g. 0xFF5C6BC0)
  String? last4Digits; // last 4 digits for bank/credit accounts
}
