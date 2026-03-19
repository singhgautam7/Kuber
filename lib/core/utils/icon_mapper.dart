import 'package:flutter/material.dart';

class IconMapper {
  static const _iconMap = <String, IconData>{
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_bag': Icons.shopping_bag,
    'receipt_long': Icons.receipt_long,
    'favorite': Icons.favorite,
    'movie': Icons.movie,
    'trending_up': Icons.trending_up,
    'savings': Icons.savings,
    'category': Icons.category,
    // Account icons
    'account_balance': Icons.account_balance,
    'credit_card': Icons.credit_card,
    'payments': Icons.payments,
    'wallet': Icons.wallet,
    'home': Icons.home,
    'work': Icons.work,
    'school': Icons.school,
    'flight': Icons.flight,
    'store': Icons.store,
    'local_atm': Icons.local_atm,
    'account_balance_wallet': Icons.account_balance_wallet,
    'attach_money': Icons.attach_money,
  };

  static IconData fromString(String name) {
    return _iconMap[name] ?? Icons.category;
  }
}
