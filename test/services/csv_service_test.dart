import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/services/csv_service.dart';
import '../helpers/test_factories.dart';

void main() {
  late CsvService service;

  setUp(() {
    service = CsvService();
  });

  group('generateTemplate', () {
    test('contains all headers', () {
      final template = service.generateTemplate();
      for (final header in CsvService.headers) {
        expect(template, contains(header));
      }
    });

    test('has only one line', () {
      final template = service.generateTemplate();
      final lines = template.trim().split('\n');
      expect(lines.length, 1);
    });
  });

  group('exportTransactions', () {
    test('exports regular transactions', () {
      final txns = [
        makeTransaction(id: 1, name: 'Lunch', amount: 250, type: 'expense', categoryId: '1', accountId: '1'),
      ];
      final csv = service.exportTransactions(
        transactions: txns,
        categoryNames: {'1': 'Food'},
        accountNames: {'1': 'Cash'},
        groupNames: {'1': 'Essentials'},
        transactionTags: {1: ['daily', 'food']},
      );

      expect(csv, contains('Lunch'));
      expect(csv, contains('250'));
      expect(csv, contains('Food'));
      expect(csv, contains('Cash'));
      expect(csv, contains('daily|food'));
      expect(csv, contains('Essentials'));
    });

    test('deduplicates transfer pairs', () {
      final txns = [
        makeTransaction(
          id: 1, name: '', amount: 500, type: 'expense',
          isTransfer: true, transferId: 'tf1', accountId: '1',
        ),
        makeTransaction(
          id: 2, name: '', amount: 500, type: 'income',
          isTransfer: true, transferId: 'tf1', accountId: '2',
        ),
      ];
      final csv = service.exportTransactions(
        transactions: txns,
        categoryNames: {},
        accountNames: {'1': 'Cash', '2': 'Bank'},
        groupNames: {},
        transactionTags: {},
      );

      // Should only have 1 data row (header + 1 transfer row)
      final lines = csv.trim().split('\n');
      expect(lines.length, 2); // header + 1 transfer
      expect(csv, contains('transfer'));
      expect(csv, contains('Cash'));
      expect(csv, contains('Bank'));
    });

    test('transfer row has from_account and to_account', () {
      final txns = [
        makeTransaction(
          id: 1, name: '', amount: 1000, type: 'expense',
          isTransfer: true, transferId: 'tf2', accountId: '1',
        ),
        makeTransaction(
          id: 2, name: '', amount: 1000, type: 'income',
          isTransfer: true, transferId: 'tf2', accountId: '2',
        ),
      ];
      final csv = service.exportTransactions(
        transactions: txns,
        categoryNames: {},
        accountNames: {'1': 'Savings', '2': 'Checking'},
        groupNames: {},
        transactionTags: {},
      );

      expect(csv, contains('Savings'));
      expect(csv, contains('Checking'));
    });
  });

  group('parseCsv', () {
    test('parses CSV content into maps', () {
      final csv = 'id,date,name,amount\n1,2024-03-15,Lunch,250';
      final result = service.parseCsv(csv);
      expect(result.length, 1);
      expect(result.first['name'], 'Lunch');
      expect(result.first['amount'], '250');
    });

    test('returns empty for empty input', () {
      expect(service.parseCsv(''), isEmpty);
    });

    test('lowercases and trims headers', () {
      final csv = ' Name , AMOUNT \n Lunch , 250 ';
      final result = service.parseCsv(csv);
      expect(result.first.containsKey('name'), true);
      expect(result.first.containsKey('amount'), true);
    });

    test('handles multiple rows', () {
      final csv = 'name,amount\nLunch,250\nDinner,500';
      final result = service.parseCsv(csv);
      expect(result.length, 2);
    });
  });

  group('round-trip', () {
    test('export then parse preserves data', () {
      final txns = [
        makeTransaction(
          id: 1, name: 'Coffee', amount: 150, type: 'expense',
          categoryId: '3', accountId: '1',
        ),
      ];
      final csv = service.exportTransactions(
        transactions: txns,
        categoryNames: {'3': 'Food'},
        accountNames: {'1': 'Cash'},
        groupNames: {},
        transactionTags: {},
      );
      final parsed = service.parseCsv(csv);
      expect(parsed.length, 1);
      expect(parsed.first['name'], 'Coffee');
      expect(parsed.first['amount'], '150.0');
      expect(parsed.first['category'], 'Food');
    });
  });
}
