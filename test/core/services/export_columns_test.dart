import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/models/export_data.dart';
import 'package:kuber/core/services/export_service.dart';

void main() {
  test('CSV carries currency code, sub type, source and EMI split', () {
    final csv = ExportService.exportTransactionsCsv(TransactionExportData(
      rows: [
        TransactionRow(
            date: DateTime(2026, 5, 5),
            name: 'EMI - Home',
            amount: 10000,
            type: 'expense',
            categoryName: 'Loan EMI',
            accountName: 'HDFC',
            subType: 'loan_repayment',
            source: 'Loan: Home',
            principalPart: 8000,
            interestPart: 2000),
        TransactionRow(
            date: DateTime(2026, 5, 6),
            name: 'Tea',
            amount: 20,
            type: 'expense',
            categoryName: 'Food',
            accountName: 'Cash'),
      ],
      userName: 'Demo',
      currencyCode: 'KES',
      currencySymbol: 'KSh',
      periodLabel: '',
      totalCount: 2,
    ));
    final lines = csv.split('\r\n');
    expect(lines[0], 'Date,Name,Type,Category,Account,Amount (KES),Notes,Sub type,Source,Principal,Interest,Split edited,Past EMI');
    expect(lines[1], '2026-05-05,EMI - Home,Expense,Loan EMI,HDFC,-10000.00,,loan_repayment,Loan: Home,8000.00,2000.00,,');
    expect(lines[2], '2026-05-06,Tea,Expense,Food,Cash,-20.00,,,,,,,');
  });
}
