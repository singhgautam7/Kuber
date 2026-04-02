import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/models/export_data.dart';
import '../../../core/services/export_service.dart';
import '../../accounts/providers/account_provider.dart';
import '../../analytics/providers/analytics_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../history/utils/filter_utils.dart';
import '../../insights/providers/insight_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';

class ExportResult {
  /// The temp file written to app cache — has a real POSIX path, can be opened.
  final File tempFile;
  final Uint8List bytes;

  ExportResult({required this.tempFile, required this.bytes});
}

// ---------------------------------------------------------------------------
// Build transaction export data from Riverpod state
// ---------------------------------------------------------------------------

TransactionExportData buildTransactionExportData(
  WidgetRef ref, {
  required bool applyFilters,
}) {
  final allTransactions = ref.read(transactionListProvider).valueOrNull ?? [];
  final filter = ref.read(historyFilterProvider);
  final categoryMap = ref.read(categoryMapProvider).valueOrNull ?? {};
  final accounts = ref.read(accountListProvider).valueOrNull ?? [];
  final txnTagsMap = ref.read(transactionTagsMapProvider).valueOrNull ?? {};
  final settings = ref.read(settingsProvider).valueOrNull;
  final currency = ref.read(currencyProvider);

  final userName = settings?.userName ?? '';

  // Build lookup maps
  final accountNames = <String, String>{};
  for (final a in accounts) {
    accountNames[a.id.toString()] = a.name;
  }

  // Filter transactions
  List<Transaction> transactions;
  if (applyFilters && !filter.isEmpty) {
    transactions = applyHistoryFilters(allTransactions, filter, txnTagsMap: txnTagsMap);
  } else {
    transactions = allTransactions;
  }

  // Exclude balance adjustments
  transactions = transactions.where((t) => !t.isBalanceAdjustment).toList();

  // Sort by date descending
  transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // Pre-compute transfer lookup map for O(1) matching later
  final transferLegsMap = <String, List<Transaction>>{};
  for (final t in allTransactions) {
    if (t.isTransfer && t.transferId != null) {
      transferLegsMap.putIfAbsent(t.transferId!, () => []).add(t);
    }
  }

  // Build rows — include both legs of transfers
  final rows = <TransactionRow>[];
  final seenTransferIds = <String>{};

  for (final tx in transactions) {
    if (tx.isTransfer) {
      if (tx.transferId == null || seenTransferIds.contains(tx.transferId)) continue;
      seenTransferIds.add(tx.transferId!);

      // Find legs in O(1) from map instead of O(N^2) list search
      final legs = transferLegsMap[tx.transferId] ?? [];
      final expenseLeg = legs.firstWhereOrNull((t) => t.type == 'expense');
      final incomeLeg = legs.firstWhereOrNull((t) => t.type == 'income');

      final fromName = expenseLeg != null
          ? accountNames[expenseLeg.accountId] ?? 'Unknown'
          : 'Unknown';
      final toName = incomeLeg != null
          ? accountNames[incomeLeg.accountId] ?? 'Unknown'
          : 'Unknown';
      final transferName = '$fromName -> $toName';

      // FROM leg (expense)
      if (expenseLeg != null) {
        rows.add(TransactionRow(
          date: expenseLeg.createdAt,
          name: transferName,
          amount: expenseLeg.amount,
          type: 'expense',
          categoryName: 'Transfer',
          accountName: fromName,
          notes: expenseLeg.notes,
          isTransfer: true,
          fromAccountName: fromName,
          toAccountName: toName,
        ));
      }

      // TO leg (income)
      if (incomeLeg != null) {
        rows.add(TransactionRow(
          date: incomeLeg.createdAt,
          name: transferName,
          amount: incomeLeg.amount,
          type: 'income',
          categoryName: 'Transfer',
          accountName: toName,
          notes: incomeLeg.notes,
          isTransfer: true,
          fromAccountName: fromName,
          toAccountName: toName,
        ));
      }
      continue;
    }

    final catId = int.tryParse(tx.categoryId);
    final catName = catId != null ? (categoryMap[catId]?.name ?? 'Unknown') : 'Unknown';

    rows.add(TransactionRow(
      date: tx.createdAt,
      name: tx.name,
      amount: tx.amount,
      type: tx.type,
      categoryName: catName,
      accountName: accountNames[tx.accountId] ?? 'Unknown',
      notes: tx.notes,
    ));
  }

  // Build period label
  String periodLabel;
  if (applyFilters && filter.from != null && filter.to != null) {
    periodLabel =
        '${DateFormat('dd MMM yyyy').format(filter.from!)} - ${DateFormat('dd MMM yyyy').format(filter.to!)}';
  } else if (transactions.isNotEmpty) {
    final earliest = transactions.last.createdAt;
    final latest = transactions.first.createdAt;
    periodLabel =
        '${DateFormat('dd MMM yyyy').format(earliest)} - ${DateFormat('dd MMM yyyy').format(latest)}';
  } else {
    periodLabel = 'All Time';
  }

  // Filter labels
  String? accountFilter;
  if (applyFilters && filter.accountIds.isNotEmpty) {
    final names = filter.accountIds
        .map((id) => accountNames[id] ?? 'Unknown')
        .toList();
    accountFilter = names.join(', ');
  }

  String? categoryFilter;
  if (applyFilters && filter.categoryIds.isNotEmpty) {
    final names = filter.categoryIds
        .map((id) {
          final catId = int.tryParse(id);
          return catId != null ? (categoryMap[catId]?.name ?? 'Unknown') : 'Unknown';
        })
        .toList();
    categoryFilter = names.join(', ');
  }

  String? searchFilter;
  if (applyFilters &&
      filter.searchQuery != null &&
      filter.searchQuery!.isNotEmpty) {
    searchFilter = filter.searchQuery;
  }

  return TransactionExportData(
    rows: rows,
    userName: userName,
    currencyCode: currency.code,
    currencySymbol: currency.symbol,
    periodLabel: periodLabel,
    totalCount: rows.length,
    accountFilter: accountFilter,
    categoryFilter: categoryFilter,
    searchFilter: searchFilter,
  );
}

// ---------------------------------------------------------------------------
// Build analytics export data from Riverpod state
// ---------------------------------------------------------------------------

AnalyticsExportData buildAnalyticsExportData(WidgetRef ref) {
  final filter = ref.read(analyticsFilterProvider);
  final periodTxns = ref.read(analyticsTransactionsProvider);
  final categoryMap = ref.read(categoryMapProvider).valueOrNull ?? {};
  final settings = ref.read(settingsProvider).valueOrNull;
  final currency = ref.read(currencyProvider);
  final insights = ref.read(smartInsightsProvider);

  final userName = settings?.userName ?? '';

  // Period label
  final periodLabel = _analyticsFilterLabel(filter);

  // Totals
  double totalIncome = 0, totalExpense = 0;
  for (final t in periodTxns) {
    if (t.type == 'income') {
      totalIncome += t.amount;
    } else {
      totalExpense += t.amount;
    }
  }
  final netAmount = totalIncome - totalExpense;
  final savingsRate = totalIncome > 0 ? (netAmount / totalIncome) * 100 : 0.0;

  // Category breakdown
  final catTotals = <int, _CatAccumulator>{};
  for (final t in periodTxns) {
    final catId = int.tryParse(t.categoryId) ?? -1;
    final acc = catTotals.putIfAbsent(catId, () => _CatAccumulator());
    acc.amount += t.amount;
    acc.count++;
    acc.type = t.type;
  }

  final totalForType = <String, double>{'income': totalIncome, 'expense': totalExpense};
  final categoryBreakdown = catTotals.entries.map((e) {
    final cat = categoryMap[e.key];
    final total = totalForType[e.value.type] ?? 1;
    return CategoryBreakdownRow(
      name: cat?.name ?? 'Unknown',
      type: e.value.type,
      amount: e.value.amount,
      percentage: total > 0 ? (e.value.amount / total) * 100 : 0,
      txnCount: e.value.count,
    );
  }).toList()
    ..sort((a, b) => b.amount.compareTo(a.amount));

  // Daily totals
  final dayMap = <String, _DayAccumulator>{};
  for (final t in periodTxns) {
    final key = DateFormat('yyyy-MM-dd').format(t.createdAt);
    final acc = dayMap.putIfAbsent(key, () => _DayAccumulator(t.createdAt));
    if (t.type == 'income') {
      acc.income += t.amount;
    } else {
      acc.expense += t.amount;
    }
  }
  final dailyTotals = dayMap.values
      .map((d) => DailyTotalRow(
            date: d.date,
            income: d.income,
            expense: d.expense,
            net: d.income - d.expense,
          ))
      .toList()
    ..sort((a, b) => a.date.compareTo(b.date));

  // Insights
  final insightRows = insights
      .where((i) => i.message.isNotEmpty)
      .map((i) => InsightRow(
            emoji: i.emoji,
            message: i.message,
            typeLabel: i.typeLabel,
          ))
      .toList();

  // Bar buckets — simplified: one per day (or aggregate for longer periods)
  final barBuckets = dailyTotals
      .map((d) => BarBucketRow(
            label: DateFormat('dd').format(d.date),
            income: d.income,
            expense: d.expense,
          ))
      .toList();

  return AnalyticsExportData(
    userName: userName,
    currencyCode: currency.code,
    currencySymbol: currency.symbol,
    periodLabel: periodLabel,
    totalIncome: totalIncome,
    totalExpense: totalExpense,
    netAmount: netAmount,
    savingsRate: savingsRate,
    categoryBreakdown: categoryBreakdown,
    dailyTotals: dailyTotals,
    insights: insightRows,
    barBuckets: barBuckets,
  );
}

String _analyticsFilterLabel(AnalyticsFilter filter) {
  switch (filter.type) {
    case FilterType.today:
      return 'Today - ${DateFormat('dd MMM yyyy').format(filter.from)}';
    case FilterType.thisWeek:
      return 'This Week';
    case FilterType.lastWeek:
      return 'Last Week';
    case FilterType.thisMonth:
      return DateFormat('MMMM yyyy').format(filter.from);
    case FilterType.lastMonth:
      return DateFormat('MMMM yyyy').format(filter.from);
    case FilterType.thisYear:
      return 'Year ${filter.from.year}';
    case FilterType.all:
      return 'All Time';
    case FilterType.custom:
      return '${DateFormat('dd MMM yyyy').format(filter.from)} - ${DateFormat('dd MMM yyyy').format(filter.to)}';
  }
}

// ---------------------------------------------------------------------------
// Perform export (compute + file save)
// ---------------------------------------------------------------------------

/// Generate the export bytes and save them to the app's temp cache directory.
/// Returns an [ExportResult] with a real POSIX path — no permissions needed.
/// The temp file is auto-cleared by Android when storage is low, and we also
/// delete it explicitly when the export bottom sheet is dismissed.
Future<ExportResult> performExport({
  required ExportType type,
  required ExportFormat format,
  required dynamic data, // TransactionExportData or AnalyticsExportData
}) async {
  Uint8List bytes;

  // Pick a reference date for file naming
  DateTime refDate;
  if (type == ExportType.transactions) {
    final txnData = data as TransactionExportData;
    refDate = txnData.rows.isNotEmpty ? txnData.rows.first.date : DateTime.now();
  } else {
    refDate = DateTime.now();
  }

  final fileName = ExportService.buildFileName(type, format, refDate);

  if (format == ExportFormat.csv) {
    final csvString = await compute(ExportService.exportTransactionsCsv, data as TransactionExportData);
    // Prepend UTF-8 BOM (EF BB BF) — required by Google Sheets (and Excel) to
    // correctly detect encoding when a file is opened directly via a content URI.
    // Without it, Sheets reports the file as "corrupted".
    const utf8Bom = [0xEF, 0xBB, 0xBF];
    bytes = Uint8List.fromList([...utf8Bom, ...utf8.encode(csvString)]);
  } else {
    final fontRegularData = await rootBundle.load('assets/fonts/Inter-Regular.ttf');
    final fontRegular = fontRegularData.buffer.asUint8List(
        fontRegularData.offsetInBytes, fontRegularData.lengthInBytes);

    final fontBoldData = await rootBundle.load('assets/fonts/Inter-Bold.ttf');
    final fontBold = fontBoldData.buffer.asByteData().buffer.asUint8List(
        fontBoldData.offsetInBytes, fontBoldData.lengthInBytes);

    if (type == ExportType.transactions) {
      bytes = await compute(
        _exportTransactionsPdfWrapper,
        _PdfExportParams(data as TransactionExportData, fontRegular, fontBold),
      );
    } else {
      bytes = await compute(
        _exportAnalyticsPdfWrapper,
        _PdfExportParams(data as AnalyticsExportData, fontRegular, fontBold),
      );
    }
  }

  // Write to app cache — real POSIX path, zero permissions needed.
  // Android clears this automatically under storage pressure.
  final cacheDir = await getTemporaryDirectory();
  final tempFile = File('${cacheDir.path}/$fileName');
  await tempFile.writeAsBytes(bytes, flush: true);

  return ExportResult(tempFile: tempFile, bytes: bytes);
}

/// Opens the system file-picker (SAF) so the user can choose where to save
/// a permanent copy. Does NOT return a usable path (SAF limitation on Android).
/// Returns true if the user confirmed, false if they cancelled.
Future<bool> saveToFolder({
  required ExportResult result,
  required ExportFormat format,
}) async {
  final fileName = result.tempFile.path.split('/').last;
  final savedPath = await FilePicker.platform.saveFile(
    dialogTitle: 'Save a copy',
    fileName: fileName,
    bytes: result.bytes,
    type: format == ExportFormat.csv ? FileType.custom : FileType.any,
    allowedExtensions: format == ExportFormat.csv ? ['csv'] : ['pdf'],
  );
  return savedPath != null;
}

/// Deletes the temp export file. Called when the export sheet is dismissed.
void deleteTempExportFile(ExportResult? result) {
  try {
    final file = result?.tempFile;
    if (file != null && file.existsSync()) {
      file.deleteSync();
    }
  } catch (_) {}
}

// ---------------------------------------------------------------------------
// Private helpers for compute
// ---------------------------------------------------------------------------

class _PdfExportParams {
  final dynamic data;
  final Uint8List fontRegular;
  final Uint8List fontBold;
  _PdfExportParams(this.data, this.fontRegular, this.fontBold);
}

Future<Uint8List> _exportTransactionsPdfWrapper(_PdfExportParams params) {
  return ExportService.exportTransactionsPdf(
    params.data as TransactionExportData,
    fontRegular: params.fontRegular,
    fontBold: params.fontBold,
  );
}

Future<Uint8List> _exportAnalyticsPdfWrapper(_PdfExportParams params) {
  return ExportService.exportAnalyticsPdf(
    params.data as AnalyticsExportData,
    fontRegular: params.fontRegular,
    fontBold: params.fontBold,
  );
}

// ---------------------------------------------------------------------------
// Private helpers
// ---------------------------------------------------------------------------

class _CatAccumulator {
  double amount = 0;
  int count = 0;
  String type = 'expense';
}

class _DayAccumulator {
  final DateTime date;
  double income = 0;
  double expense = 0;
  _DayAccumulator(DateTime raw)
      : date = DateTime(raw.year, raw.month, raw.day);
}
