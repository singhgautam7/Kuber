import 'package:csv/csv.dart';
import '../../features/transactions/data/transaction.dart';

class CsvService {
  static const List<String> headers = [
    'date',
    'name',
    'amount',
    'type',
    'category',
    'account',
    'notes',
    'from_account',
    'to_account',
    'frequency',
  ];

  /// Generates a CSV template with only headers.
  String generateTemplate() {
    return Csv().encode([headers]);
  }

  /// Exports a list of transactions to a CSV string.
  String exportTransactions({
    required List<Transaction> transactions,
    required Map<String, String> categoryNames, // id -> name
    required Map<String, String> accountNames,  // id -> name
  }) {
    final List<List<dynamic>> rows = [headers];

    for (final tx in transactions) {
      rows.add([
        tx.createdAt.toIso8601String(),
        tx.name,
        tx.amount,
        tx.type,
        categoryNames[tx.categoryId] ?? '',
        accountNames[tx.accountId] ?? '',
        tx.notes ?? '',
        tx.fromAccountId != null ? accountNames[tx.fromAccountId] ?? '' : '',
        tx.toAccountId != null ? accountNames[tx.toAccountId] ?? '' : '',
        '', // frequency - for now, standard transactions don't have it in this export
      ]);
    }

    return Csv().encode(rows);
  }

  /// Parses CSV content into a list of maps.
  List<Map<String, String>> parseCsv(String csvContent) {
    final List<List<dynamic>> rows = Csv().decode(csvContent);
    if (rows.isEmpty) return [];

    final headerRow = rows.first.map((e) => e.toString().toLowerCase().trim()).toList();
    final List<Map<String, String>> data = [];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      final Map<String, String> entry = {};
      for (var j = 0; j < headerRow.length; j++) {
        if (j < row.length) {
          entry[headerRow[j]] = row[j].toString().trim();
        }
      }
      if (entry.isNotEmpty) data.add(entry);
    }

    return data;
  }
}
