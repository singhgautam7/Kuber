import 'dart:io';
import 'dart:typed_data';

import 'package:csv/csv.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/export_data.dart';

class ExportService {
  // ---------------------------------------------------------------------------
  // PDF color constants (always light theme)
  // ---------------------------------------------------------------------------

  static final _pdfSurface = PdfColor.fromHex('#FAFAFA');
  static final _pdfBorder = PdfColor.fromHex('#E4E4E7');
  static final _pdfTextPrimary = PdfColor.fromHex('#09090B');
  static final _pdfTextMuted = PdfColor.fromHex('#71717A');
  static final _pdfIncome = PdfColor.fromHex('#16A34A');
  static final _pdfExpense = PdfColor.fromHex('#DC2626');
  static final _pdfPrimary = PdfColor.fromHex('#3B82F6');
  static final _pdfTransfer = PdfColor.fromHex('#71717A');

  // ---------------------------------------------------------------------------
  // File naming & saving
  // ---------------------------------------------------------------------------

  static String buildFileName(ExportType type, ExportFormat format, DateTime refDate) {
    final monthStr = DateFormat('MMMyyyy').format(refDate);
    final prefix = type == ExportType.transactions ? 'Transactions' : 'Report';
    final ext = format == ExportFormat.csv ? 'csv' : 'pdf';
    return 'Kuber_${prefix}_$monthStr.$ext';
  }

  static Future<File> saveExportFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    Directory? dir = await getExternalStorageDirectory();
    dir ??= await getApplicationDocumentsDirectory();

    final exportDir = Directory('${dir.path}/Kuber');
    if (!exportDir.existsSync()) {
      exportDir.createSync(recursive: true);
    }

    final file = File('${exportDir.path}/$fileName');
    return file.writeAsBytes(bytes);
  }

  // ---------------------------------------------------------------------------
  // Transaction CSV
  // ---------------------------------------------------------------------------

  static String exportTransactionsCsv(TransactionExportData data) {
  final lines = <String>[];

  // Comment header
  lines.add('# Kuber Export');
  if (data.userName.isNotEmpty) {
    lines.add('# Exported by: ${data.userName}');
  }
  lines.add('# Period: ${data.periodLabel}');
  if (data.accountFilter != null) {
    lines.add('# Account: ${data.accountFilter}');
  }
  if (data.categoryFilter != null) {
    lines.add('# Category: ${data.categoryFilter}');
  }
  if (data.searchFilter != null) {
    lines.add('# Search: ${data.searchFilter}');
  }
  lines.add('# Transactions: ${data.totalCount}');
  lines.add('#');

  // CSV data
  final csvRows = <List<dynamic>>[
    ['Date', 'Name', 'Type', 'Category', 'Account', 'Amount (${data.currencyCode})', 'Notes'],
  ];

  for (final row in data.rows) {
    final typeLabel = row.isTransfer
        ? 'Transfer'
        : row.type == 'income'
            ? 'Income'
            : 'Expense';

    final signedAmount = row.type == 'expense' || (row.isTransfer && row.type == 'expense')
        ? -row.amount
        : row.amount;

    csvRows.add([
      DateFormat('yyyy-MM-dd').format(row.date),
      row.name,
      typeLabel,
      row.isTransfer ? 'Transfer' : row.categoryName,
      row.accountName,
      signedAmount.toStringAsFixed(2),
      row.notes ?? '',
    ]);
  }

  final csvString = Csv().encode(csvRows);
  lines.add(csvString);
  return lines.join('\n');
}

  // ---------------------------------------------------------------------------
  // Analytics CSV
  // ---------------------------------------------------------------------------

  static String exportAnalyticsCsv(AnalyticsExportData data) {
  final lines = <String>[];

  lines.add('# Kuber Analytics Export');
  lines.add('# Period: ${data.periodLabel}');
  if (data.userName.isNotEmpty) {
    lines.add('# Exported by: ${data.userName}');
  }
  lines.add('');

  // Summary
  lines.add('SUMMARY');
  lines.add('Total Income,${data.totalIncome.toStringAsFixed(2)}');
  lines.add('Total Expenses,${data.totalExpense.toStringAsFixed(2)}');
  lines.add('Net,${data.netAmount.toStringAsFixed(2)}');
  lines.add('Savings Rate,${data.savingsRate.toStringAsFixed(1)}%');
  lines.add('');

  // Category Breakdown
  final catRows = <List<dynamic>>[
    ['Category', 'Type', 'Amount (${data.currencyCode})', '% of Total', 'Transactions'],
  ];
  for (final c in data.categoryBreakdown) {
    catRows.add([
      c.name,
      c.type == 'income' ? 'Income' : 'Expense',
      c.amount.toStringAsFixed(2),
      '${c.percentage.toStringAsFixed(1)}%',
      c.txnCount,
    ]);
  }
  lines.add('CATEGORY BREAKDOWN');
  lines.add(Csv().encode(catRows));
  lines.add('');

  // Daily Totals
  final dailyRows = <List<dynamic>>[
    ['Date', 'Income (${data.currencyCode})', 'Expense (${data.currencyCode})', 'Net (${data.currencyCode})'],
  ];
  for (final d in data.dailyTotals) {
    dailyRows.add([
      DateFormat('yyyy-MM-dd').format(d.date),
      d.income.toStringAsFixed(2),
      d.expense.toStringAsFixed(2),
      d.net.toStringAsFixed(2),
    ]);
  }
  lines.add('DAILY TOTALS');
  lines.add(Csv().encode(dailyRows));

  return lines.join('\n');
}

  // ---------------------------------------------------------------------------
  // Transaction PDF
  // ---------------------------------------------------------------------------

  static Future<Uint8List> exportTransactionsPdf(TransactionExportData data) async {
  final doc = pw.Document();
  final headerFont = pw.Font.helveticaBold();
  final bodyFont = pw.Font.helvetica();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      header: (context) => _buildTxnPdfHeader(data, headerFont, bodyFont),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(font: bodyFont, fontSize: 9, color: _pdfTextMuted),
        ),
      ),
      build: (context) {
        final rows = <pw.TableRow>[];

        // Header row
        rows.add(pw.TableRow(
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: _pdfBorder, width: 1)),
          ),
          children: ['Date', 'Name', 'Type', 'Category', 'Account', 'Amount']
              .map((h) => pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                    child: pw.Text(h,
                        style: pw.TextStyle(
                            font: headerFont, fontSize: 9, color: _pdfTextPrimary)),
                  ))
              .toList(),
        ));

        // Data rows
        for (var i = 0; i < data.rows.length; i++) {
          final row = data.rows[i];
          final isEven = i % 2 == 0;
          final isTransfer = row.isTransfer;
          final isIncome = row.type == 'income';

          PdfColor amountColor;
          if (isTransfer) {
            amountColor = _pdfTransfer;
          } else if (isIncome) {
            amountColor = _pdfIncome;
          } else {
            amountColor = _pdfExpense;
          }

          final textColor = isTransfer ? _pdfTransfer : _pdfTextPrimary;
          final signedAmount = isTransfer
              ? (row.type == 'expense' ? -row.amount : row.amount)
              : (isIncome ? row.amount : -row.amount);
          final amountStr =
              '${signedAmount >= 0 ? '+' : ''}${data.currencySymbol}${signedAmount.abs().toStringAsFixed(2)}';

          final typeLabel = isTransfer
              ? 'Transfer'
              : isIncome
                  ? 'Income'
                  : 'Expense';

          rows.add(pw.TableRow(
            decoration: pw.BoxDecoration(
              color: isEven ? PdfColors.white : _pdfSurface,
              border: isTransfer
                  ? pw.Border(left: pw.BorderSide(color: _pdfTransfer, width: 2))
                  : null,
            ),
            children: [
              _pdfCell(DateFormat('dd MMM').format(row.date), bodyFont, textColor),
              _pdfCell(row.name, bodyFont, textColor, flex: true),
              _pdfCell(typeLabel, bodyFont, textColor),
              _pdfCell(isTransfer ? 'Transfer' : row.categoryName, bodyFont, textColor),
              _pdfCell(row.accountName, bodyFont, textColor),
              _pdfCell(amountStr, bodyFont, amountColor, align: pw.TextAlign.right),
            ],
          ));
        }

        return [
          pw.Table(
            columnWidths: {
              0: const pw.FixedColumnWidth(55),
              1: const pw.FlexColumnWidth(2),
              2: const pw.FixedColumnWidth(50),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(1.2),
              5: const pw.FixedColumnWidth(75),
            },
            children: rows,
          ),
          pw.SizedBox(height: 20),
          _buildTxnPdfSummary(data, headerFont, bodyFont),
        ];
      },
    ),
  );

  return doc.save();
}

  static pw.Widget _pdfCell(String text, pw.Font font, PdfColor color,
      {bool flex = false, pw.TextAlign align = pw.TextAlign.left}) {
  final child = pw.Text(
    text,
    style: pw.TextStyle(font: font, fontSize: 8, color: color),
    textAlign: align,
    maxLines: 1,
  );
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
    child: child,
  );
}

  static pw.Widget _buildTxnPdfHeader(
      TransactionExportData data, pw.Font headerFont, pw.Font bodyFont) {
  final filterParts = <String>[];
  if (data.accountFilter != null) filterParts.add('Account: ${data.accountFilter}');
  if (data.categoryFilter != null) filterParts.add('Category: ${data.categoryFilter}');

  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 16),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Kuber \u2014 Transaction Statement',
            style: pw.TextStyle(font: headerFont, fontSize: 16, color: _pdfTextPrimary)),
        pw.SizedBox(height: 4),
        pw.Text(
          [
            if (data.userName.isNotEmpty) 'Exported by: ${data.userName}',
            'Period: ${data.periodLabel}',
          ].join('  |  '),
          style: pw.TextStyle(font: bodyFont, fontSize: 9, color: _pdfTextMuted),
        ),
        if (filterParts.isNotEmpty) ...[
          pw.SizedBox(height: 2),
          pw.Text(filterParts.join('  |  '),
              style: pw.TextStyle(font: bodyFont, fontSize: 9, color: _pdfTextMuted)),
        ],
        pw.SizedBox(height: 2),
        pw.Text('${data.totalCount} transactions',
            style: pw.TextStyle(font: bodyFont, fontSize: 9, color: _pdfTextMuted)),
        pw.SizedBox(height: 8),
        pw.Divider(color: _pdfBorder, thickness: 0.5),
      ],
    ),
  );
}

  static pw.Widget _buildTxnPdfSummary(
      TransactionExportData data, pw.Font headerFont, pw.Font bodyFont) {
  double totalIncome = 0, totalExpense = 0;
  for (final row in data.rows) {
    if (row.isTransfer) continue;
    if (row.type == 'income') {
      totalIncome += row.amount;
    } else {
      totalExpense += row.amount;
    }
  }
  final net = totalIncome - totalExpense;

  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: _pdfBorder, width: 0.5),
      borderRadius: pw.BorderRadius.circular(4),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
      children: [
        _summaryItem('Total Income', '+${data.currencySymbol}${totalIncome.toStringAsFixed(2)}',
            _pdfIncome, headerFont, bodyFont),
        _summaryItem('Total Expenses', '-${data.currencySymbol}${totalExpense.toStringAsFixed(2)}',
            _pdfExpense, headerFont, bodyFont),
        _summaryItem(
            'Net',
            '${net >= 0 ? '+' : '-'}${data.currencySymbol}${net.abs().toStringAsFixed(2)}',
            net >= 0 ? _pdfIncome : _pdfExpense,
            headerFont,
            bodyFont),
      ],
    ),
  );
}

  static pw.Widget _summaryItem(
      String label, String value, PdfColor color, pw.Font bold, pw.Font regular) {
  return pw.Column(
    children: [
      pw.Text(label, style: pw.TextStyle(font: regular, fontSize: 9, color: _pdfTextMuted)),
      pw.SizedBox(height: 4),
      pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 12, color: color)),
    ],
  );
}

  // ---------------------------------------------------------------------------
  // Analytics PDF
  // ---------------------------------------------------------------------------

  static Future<Uint8List> exportAnalyticsPdf(AnalyticsExportData data) async {
  final doc = pw.Document();
  final headerFont = pw.Font.helveticaBold();
  final bodyFont = pw.Font.helvetica();

  // Page 1 — Overview + bar chart
  doc.addPage(pw.Page(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.all(32),
    build: (context) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Kuber Report \u2014 ${data.periodLabel}',
            style: pw.TextStyle(font: headerFont, fontSize: 18, color: _pdfTextPrimary)),
        if (data.userName.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text('Exported by ${data.userName}',
              style: pw.TextStyle(font: bodyFont, fontSize: 10, color: _pdfTextMuted)),
        ],
        pw.SizedBox(height: 20),

        // Three stat boxes
        pw.Row(
          children: [
            _statBox('Total Income',
                '+${data.currencySymbol}${data.totalIncome.toStringAsFixed(2)}',
                _pdfIncome, headerFont, bodyFont),
            pw.SizedBox(width: 12),
            _statBox('Total Expenses',
                '-${data.currencySymbol}${data.totalExpense.toStringAsFixed(2)}',
                _pdfExpense, headerFont, bodyFont),
            pw.SizedBox(width: 12),
            _statBox('Savings Rate', '${data.savingsRate.toStringAsFixed(1)}%',
                _pdfPrimary, headerFont, bodyFont),
          ],
        ),
        pw.SizedBox(height: 24),

        // Bar chart
        pw.Text('Spending Trend',
            style: pw.TextStyle(font: headerFont, fontSize: 12, color: _pdfTextPrimary)),
        pw.SizedBox(height: 12),
        _buildBarChart(data.barBuckets, data.currencySymbol, bodyFont),
      ],
    ),
  ));

  // Page 2 — Category Breakdown
  if (data.categoryBreakdown.isNotEmpty) {
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text('Category Breakdown',
            style: pw.TextStyle(font: headerFont, fontSize: 14, color: _pdfTextPrimary)),
        pw.SizedBox(height: 12),
        _buildCategoryTable(data, headerFont, bodyFont),
      ],
    ));
  }

  // Page 3 — Smart Insights
  if (data.insights.isNotEmpty) {
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        pw.Text('Smart Insights',
            style: pw.TextStyle(font: headerFont, fontSize: 14, color: _pdfTextPrimary)),
        pw.SizedBox(height: 12),
        ...data.insights.map((insight) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: _pdfSurface,
                border: pw.Border(
                    left: pw.BorderSide(color: _pdfPrimary, width: 3)),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('${insight.emoji} ${insight.typeLabel}',
                      style: pw.TextStyle(
                          font: headerFont, fontSize: 9, color: _pdfPrimary)),
                  pw.SizedBox(height: 4),
                  pw.Text(insight.message,
                      style: pw.TextStyle(
                          font: bodyFont, fontSize: 10, color: _pdfTextPrimary)),
                ],
              ),
            )),
      ],
    ));
  }

  // Page 4 — Daily Totals
  if (data.dailyTotals.isNotEmpty) {
    doc.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) {
        final rows = <pw.TableRow>[
          pw.TableRow(
            decoration: pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(color: _pdfBorder, width: 1)),
            ),
            children: ['Date', 'Income', 'Expense', 'Net']
                .map((h) => pw.Padding(
                      padding: const pw.EdgeInsets.symmetric(
                          vertical: 6, horizontal: 4),
                      child: pw.Text(h,
                          style: pw.TextStyle(
                              font: headerFont, fontSize: 9, color: _pdfTextPrimary)),
                    ))
                .toList(),
          ),
        ];

        for (var i = 0; i < data.dailyTotals.length; i++) {
          final d = data.dailyTotals[i];
          final netColor = d.net >= 0 ? _pdfIncome : _pdfExpense;
          rows.add(pw.TableRow(
            decoration: pw.BoxDecoration(
                color: i % 2 == 0 ? PdfColors.white : _pdfSurface),
            children: [
              _pdfCell(DateFormat('dd MMM').format(d.date), bodyFont, _pdfTextPrimary),
              _pdfCell('${data.currencySymbol}${d.income.toStringAsFixed(2)}', bodyFont,
                  _pdfIncome,
                  align: pw.TextAlign.right),
              _pdfCell('${data.currencySymbol}${d.expense.toStringAsFixed(2)}', bodyFont,
                  _pdfExpense,
                  align: pw.TextAlign.right),
              _pdfCell(
                  '${d.net >= 0 ? '+' : '-'}${data.currencySymbol}${d.net.abs().toStringAsFixed(2)}',
                  bodyFont,
                  netColor,
                  align: pw.TextAlign.right),
            ],
          ));
        }

        return [
          pw.Text('Daily Totals',
              style: pw.TextStyle(font: headerFont, fontSize: 14, color: _pdfTextPrimary)),
          pw.SizedBox(height: 12),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1.5),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1),
            },
            children: rows,
          ),
        ];
      },
    ));
  }

  return doc.save();
}

  static pw.Widget _statBox(
      String label, String value, PdfColor accent, pw.Font bold, pw.Font regular) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: _pdfSurface,
        border: pw.Border(top: pw.BorderSide(color: accent, width: 3)),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(label,
              style: pw.TextStyle(font: regular, fontSize: 9, color: _pdfTextMuted)),
          pw.SizedBox(height: 4),
          pw.Text(value, style: pw.TextStyle(font: bold, fontSize: 14, color: accent)),
        ],
      ),
    ),
  );
}

  static pw.Widget _buildBarChart(
      List<BarBucketRow> buckets, String symbol, pw.Font font) {
  if (buckets.isEmpty) {
    return pw.Text('No data',
        style: pw.TextStyle(font: font, fontSize: 10, color: _pdfTextMuted));
  }

  const chartHeight = 150.0;
  const barWidth = 8.0;
  const groupGap = 4.0;

  double maxVal = 0;
  for (final b in buckets) {
    if (b.income > maxVal) maxVal = b.income;
    if (b.expense > maxVal) maxVal = b.expense;
  }
  if (maxVal == 0) maxVal = 1;

  return pw.Column(
    children: [
      pw.SizedBox(
        height: chartHeight,
        child: pw.CustomPaint(
          size: const PdfPoint(500, chartHeight),
          painter: (canvas, size) {
            final groupWidth =
                size.x / buckets.length;

            for (var i = 0; i < buckets.length; i++) {
              final b = buckets[i];
              final x = i * groupWidth + (groupWidth - barWidth * 2 - groupGap) / 2;

              // Income bar
              final incomeH = (b.income / maxVal) * (size.y - 20);
              canvas
                ..setFillColor(_pdfIncome)
                ..drawRect(x, 0, barWidth, incomeH)
                ..fillPath();

              // Expense bar
              final expenseH = (b.expense / maxVal) * (size.y - 20);
              canvas
                ..setFillColor(_pdfExpense)
                ..drawRect(x + barWidth + groupGap, 0, barWidth, expenseH)
                ..fillPath();
            }
          },
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: buckets
            .map((b) => pw.Text(b.label,
                style: pw.TextStyle(font: font, fontSize: 7, color: _pdfTextMuted)))
            .toList(),
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          _legendDot(_pdfIncome, 'Income', font),
          pw.SizedBox(width: 16),
          _legendDot(_pdfExpense, 'Expense', font),
        ],
      ),
    ],
  );
}

  static pw.Widget _legendDot(PdfColor color, String label, pw.Font font) {
  return pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Container(width: 8, height: 8, color: color),
      pw.SizedBox(width: 4),
      pw.Text(label,
          style: pw.TextStyle(font: font, fontSize: 8, color: _pdfTextMuted)),
    ],
  );
}

  static pw.Widget _buildCategoryTable(
      AnalyticsExportData data, pw.Font headerFont, pw.Font bodyFont) {
  final maxPct =
      data.categoryBreakdown.fold<double>(0, (m, c) => c.percentage > m ? c.percentage : m);

  final rows = <pw.TableRow>[
    pw.TableRow(
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: _pdfBorder, width: 1)),
      ),
      children: ['Category', 'Type', 'Amount', '% of Total', 'Txns']
          .map((h) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: pw.Text(h,
                    style: pw.TextStyle(
                        font: headerFont, fontSize: 9, color: _pdfTextPrimary)),
              ))
          .toList(),
    ),
  ];

  for (var i = 0; i < data.categoryBreakdown.length; i++) {
    final c = data.categoryBreakdown[i];
    final barColor = c.type == 'income' ? _pdfIncome : _pdfExpense;
    final barWidthFraction = maxPct > 0 ? c.percentage / maxPct : 0.0;

    rows.add(pw.TableRow(
      decoration:
          pw.BoxDecoration(color: i % 2 == 0 ? PdfColors.white : _pdfSurface),
      children: [
        _pdfCell(c.name, bodyFont, _pdfTextPrimary),
        _pdfCell(c.type == 'income' ? 'Income' : 'Expense', bodyFont, _pdfTextMuted),
        _pdfCell(
            '${data.currencySymbol}${c.amount.toStringAsFixed(2)}', bodyFont, _pdfTextPrimary,
            align: pw.TextAlign.right),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
          child: pw.Row(
            children: [
              pw.Container(
                width: 40 * barWidthFraction,
                height: 8,
                decoration: pw.BoxDecoration(
                    color: barColor, borderRadius: pw.BorderRadius.circular(2)),
              ),
              pw.SizedBox(width: 4),
              pw.Text('${c.percentage.toStringAsFixed(1)}%',
                  style: pw.TextStyle(font: bodyFont, fontSize: 8, color: _pdfTextMuted)),
            ],
          ),
        ),
        _pdfCell('${c.txnCount}', bodyFont, _pdfTextMuted, align: pw.TextAlign.right),
      ],
    ));
  }

  return pw.Table(
    columnWidths: {
      0: const pw.FlexColumnWidth(1.5),
      1: const pw.FixedColumnWidth(50),
      2: const pw.FlexColumnWidth(1),
      3: const pw.FlexColumnWidth(1.2),
      4: const pw.FixedColumnWidth(35),
    },
    children: rows,
  );
}
}
