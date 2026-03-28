import 'package:flutter/material.dart';

class IconMapper {
  static const _iconMap = <String, IconData>{
    // Category icons
    'restaurant': Icons.restaurant,
    'local_cafe': Icons.local_cafe,
    'fastfood': Icons.fastfood,
    'local_bar': Icons.local_bar,
    'directions_car': Icons.directions_car,
    'flight': Icons.flight,
    'directions_bus': Icons.directions_bus,
    'local_gas_station': Icons.local_gas_station,
    'two_wheeler': Icons.two_wheeler,
    'shopping_bag': Icons.shopping_bag,
    'shopping_cart': Icons.shopping_cart,
    'storefront': Icons.storefront,
    'home': Icons.home,
    'electrical_services': Icons.electrical_services,
    'water_drop': Icons.water_drop,
    'wifi': Icons.wifi,
    'favorite': Icons.favorite,
    'local_hospital': Icons.local_hospital,
    'fitness_center': Icons.fitness_center,
    'medication': Icons.medication,
    'movie': Icons.movie,
    'sports_esports': Icons.sports_esports,
    'music_note': Icons.music_note,
    'celebration': Icons.celebration,
    'savings': Icons.savings,
    'trending_up': Icons.trending_up,
    'receipt_long': Icons.receipt_long,
    'account_balance': Icons.account_balance,
    'currency_rupee': Icons.currency_rupee,
    'school': Icons.school,
    'work': Icons.work,
    'laptop': Icons.laptop,
    'menu_book': Icons.menu_book,
    'face': Icons.face,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'card_giftcard': Icons.card_giftcard,
    'build': Icons.build,
    'more_horiz': Icons.more_horiz,
    'category': Icons.category,
    // Account icons
    'credit_card': Icons.credit_card,
    'payments': Icons.payments,
    'wallet': Icons.wallet,
    'store': Icons.store,
    'local_atm': Icons.local_atm,
    'account_balance_wallet': Icons.account_balance_wallet,
    'attach_money': Icons.attach_money,
  };

  static IconData fromString(String name) {
    return _iconMap[name] ?? Icons.category;
  }

  static IconData fromCurrencyCode(String code) {
    switch (code) {
      case 'INR':
        return Icons.currency_rupee_rounded;
      case 'USD':
      case 'AUD':
      case 'CAD':
      case 'SGD':
      case 'HKD':
      case 'MXN':
      case 'BRL':
        return Icons.attach_money_rounded;
      case 'EUR':
        return Icons.euro_rounded;
      case 'GBP':
        return Icons.currency_pound_rounded;
      case 'JPY':
      case 'CNY':
        return Icons.currency_yen_rounded;
      case 'KRW':
        return Icons.payments_rounded;
      case 'TRY':
        return Icons.currency_lira_rounded;
      case 'RUB':
        return Icons.currency_ruble_rounded;
      case 'BTC':
        return Icons.currency_bitcoin_rounded;
      case 'THB':
        return Icons.payments_rounded;
      default:
        return Icons.payments_rounded;
    }
  }
}
