import 'package:flutter/material.dart';
import 'color_palette.dart';

const List<Map<String, dynamic>> kCategoryIcons = [
  // Food & Drink
  {'name': 'restaurant', 'icon': Icons.restaurant_outlined},
  {'name': 'local_cafe', 'icon': Icons.local_cafe_outlined},
  {'name': 'fastfood', 'icon': Icons.fastfood_outlined},
  {'name': 'local_bar', 'icon': Icons.local_bar_outlined},
  // Transport
  {'name': 'directions_car', 'icon': Icons.directions_car_outlined},
  {'name': 'flight', 'icon': Icons.flight_outlined},
  {'name': 'directions_bus', 'icon': Icons.directions_bus_outlined},
  {'name': 'local_gas_station', 'icon': Icons.local_gas_station_outlined},
  {'name': 'two_wheeler', 'icon': Icons.two_wheeler_outlined},
  // Shopping
  {'name': 'shopping_bag', 'icon': Icons.shopping_bag_outlined},
  {'name': 'shopping_cart', 'icon': Icons.shopping_cart_outlined},
  {'name': 'storefront', 'icon': Icons.storefront_outlined},
  // Home & Utilities
  {'name': 'home', 'icon': Icons.home_outlined},
  {'name': 'electrical_services', 'icon': Icons.electrical_services_outlined},
  {'name': 'water_drop', 'icon': Icons.water_drop_outlined},
  {'name': 'wifi', 'icon': Icons.wifi_outlined},
  // Health
  {'name': 'favorite', 'icon': Icons.favorite_outline},
  {'name': 'local_hospital', 'icon': Icons.local_hospital_outlined},
  {'name': 'fitness_center', 'icon': Icons.fitness_center_outlined},
  {'name': 'medication', 'icon': Icons.medication_outlined},
  // Entertainment
  {'name': 'movie', 'icon': Icons.movie_outlined},
  {'name': 'sports_esports', 'icon': Icons.sports_esports_outlined},
  {'name': 'music_note', 'icon': Icons.music_note_outlined},
  {'name': 'celebration', 'icon': Icons.celebration_outlined},
  // Finance
  {'name': 'savings', 'icon': Icons.savings_outlined},
  {'name': 'trending_up', 'icon': Icons.trending_up_rounded},
  {'name': 'receipt_long', 'icon': Icons.receipt_long_outlined},
  {'name': 'account_balance', 'icon': Icons.account_balance_outlined},
  {'name': 'currency_rupee', 'icon': Icons.currency_rupee_rounded},
  // Education & Work
  {'name': 'school', 'icon': Icons.school_outlined},
  {'name': 'work', 'icon': Icons.work_outline},
  {'name': 'laptop', 'icon': Icons.laptop_outlined},
  {'name': 'menu_book', 'icon': Icons.menu_book_outlined},
  // Personal
  {'name': 'face', 'icon': Icons.face_outlined},
  {'name': 'pets', 'icon': Icons.pets_outlined},
  {'name': 'child_care', 'icon': Icons.child_care_outlined},
  {'name': 'card_giftcard', 'icon': Icons.card_giftcard_outlined},
  // Misc
  {'name': 'build', 'icon': Icons.build_outlined},
  {'name': 'more_horiz', 'icon': Icons.more_horiz_rounded},
  {'name': 'category', 'icon': Icons.category_outlined},
];

final List<Color> kCategoryColors = AppColorPalette.colors.map((c) => Color(c)).toList();
