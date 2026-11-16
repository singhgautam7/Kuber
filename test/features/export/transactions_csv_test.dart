import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/export/providers/export_provider.dart';

import '../../helpers/test_factories.dart';

void main() {
  test('buildTransactionsCsvBytes: BOM, History columns, signed amounts, adjustments skipped', () async {
    final bytes = await buildTransactionsCsvBytes(
      [
        makeTransaction(name: 'Lunch, office', amount: 250, notes: 'a "b"', createdAt: DateTime(2026, 11, 2)),
        makeTransaction(name: 'Pay', amount: 1000, type: 'income', createdAt: DateTime(2026, 11, 3)),
        makeTransaction(name: 'Fix', isBalanceAdjustment: true),
      ],
      accountNames: {'1': 'Bank'},
      categoryMap: {},
      currencyCode: 'INR',
      currencySymbol: '₹',
    );
    expect(bytes.take(3), [0xEF, 0xBB, 0xBF]);
    final lines = utf8.decode(bytes.skip(3).toList()).trim().split('\r\n');
    expect(lines.first, startsWith('Date,Name,Type,Category,Account,Amount (INR),Notes'));
    expect(lines, hasLength(3));
    expect(lines[1], startsWith('2026-11-03,Pay,Income,Unknown,Bank,1000.00'));
    expect(lines[2], contains('"Lunch, office"'));
    expect(lines[2], contains(',-250.00,"a ""b"""'));
  });
}
