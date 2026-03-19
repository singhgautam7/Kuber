import 'package:flutter/material.dart';

IconData accountIcon(String type) {
  return switch (type) {
    'bank' => Icons.account_balance,
    'card' => Icons.credit_card,
    'upi' => Icons.phone_android,
    'cash' => Icons.account_balance_wallet,
    _ => Icons.savings,
  };
}

Color accountColor(String type) {
  return switch (type) {
    'bank' => Colors.indigo,
    'card' => const Color(0xFFAB47BC),
    'upi' => Colors.purple,
    'cash' => Colors.grey,
    _ => Colors.teal,
  };
}
