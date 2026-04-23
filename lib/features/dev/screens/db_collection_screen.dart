import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../core/database/isar_service.dart';

import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../transactions/data/transaction.dart';
import '../../tags/data/tag.dart';
import '../../tags/data/transaction_tag.dart';
import '../../budgets/data/budget.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../investments/data/investment.dart';
import '../../transactions/data/transaction_suggestion.dart';

import '../widgets/record_detail_sheet.dart';

class DbCollectionScreen extends ConsumerStatefulWidget {
  final String collectionName;

  const DbCollectionScreen({super.key, required this.collectionName});

  @override
  ConsumerState<DbCollectionScreen> createState() => _DbCollectionScreenState();
}

class _DbCollectionScreenState extends ConsumerState<DbCollectionScreen> {
  List<Map<String, dynamic>> _allRecords = [];
  bool _isLoading = true;
  int _currentPage = 1;
  int _pageSize = 50;
  int? _sortColumnIndex;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final isar = ref.read(isarProvider);
      List<Map<String, dynamic>> records = [];

      switch (widget.collectionName) {
        case 'Transaction':
          final list = await isar.collection<Transaction>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Account':
          final list = await isar.collection<Account>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Category':
          final list = await isar.collection<Category>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'CategoryGroup':
          final list = await isar.collection<CategoryGroup>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'RecurringRule':
          final list = await isar.collection<RecurringRule>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Tag':
          final list = await isar.collection<Tag>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'TransactionTag':
          final list = await isar.collection<TransactionTag>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Budget':
          final list = await isar.collection<Budget>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Ledger':
          final list = await isar.collection<Ledger>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Loan':
          final list = await isar.collection<Loan>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'Investment':
          final list = await isar.collection<Investment>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
        case 'TransactionSuggestion':
          final list = await isar.collection<TransactionSuggestion>().where().findAll();
          records = list.map((e) => e.toMap()).toList();
          break;
      }

      if (mounted) {
        setState(() {
          _allRecords = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  int get _totalPages => (_allRecords.length / _pageSize).ceil() == 0 ? 1 : (_allRecords.length / _pageSize).ceil();

  List<Map<String, dynamic>> get _currentPageRecords {
    if (_allRecords.isEmpty) return [];
    final start = (_currentPage - 1) * _pageSize;
    final end = (start + _pageSize > _allRecords.length) ? _allRecords.length : start + _pageSize;
    return _allRecords.sublist(start, end);
  }

  Future<void> _setPage(int newPage) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100)); // Artificial delay for smooth loader
    if (mounted) {
      setState(() {
        _currentPage = newPage;
        _isLoading = false;
      });
    }
  }

  Future<void> _setPageSize(int newSize) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100)); // Artificial delay for smooth loader
    if (mounted) {
      setState(() {
        _pageSize = newSize;
        _currentPage = 1;
        _isLoading = false;
      });
    }
  }

  Future<void> _onSort(int columnIndex, bool ascending) async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 100)); // Delay for smooth UI response during sorting

    if (!mounted) return;

    final keys = _allRecords.first.keys.toList();
    final sortKey = keys[columnIndex];

    _allRecords.sort((a, b) {
      final aVal = a[sortKey];
      final bVal = b[sortKey];

      if (aVal == null && bVal == null) return 0;
      if (aVal == null) return ascending ? -1 : 1;
      if (bVal == null) return ascending ? 1 : -1;

      int result;
      if (aVal is num && bVal is num) {
        result = aVal.compareTo(bVal);
      } else if (aVal is bool && bVal is bool) {
        result = aVal == bVal ? 0 : (aVal ? 1 : -1);
      } else {
        result = aVal.toString().compareTo(bVal.toString());
      }
      return ascending ? result : -result;
    });

    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      _isLoading = false;
    });
  }

  void _showRecordDetails(Map<String, dynamic> record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return KuberBottomSheet(
              title: '${widget.collectionName} #${record['id']}',
              child: RecordDetailSheet(recordMap: record),
            );
          },
        );
      },
    ).then((_) {
      // Small delay for focus fix as mentioned in instructions
      Future.delayed(const Duration(milliseconds: 100));
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true, 
        title: widget.collectionName,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Subtitle and Pagination Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg, vertical: KuberSpacing.md),
            decoration: BoxDecoration(
              color: cs.surface,
              border: Border(bottom: BorderSide(color: cs.outline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_allRecords.length} records',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                DropdownButton<int>(
                  value: _pageSize,
                  underline: const SizedBox(),
                  icon: Icon(Icons.arrow_drop_down, color: cs.primary),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                  items: const [
                    DropdownMenuItem(value: 50, child: Text('50 per page')),
                    DropdownMenuItem(value: 100, child: Text('100 per page')),
                    DropdownMenuItem(value: 500, child: Text('500 per page')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      _setPageSize(val);
                    }
                  },
                ),
              ],
            ),
          ),

          // Table Content
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: cs.primary))
                : _allRecords.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_outlined, size: 64, color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
                            const SizedBox(height: KuberSpacing.lg),
                            Text(
                              'Collection is empty',
                              style: GoogleFonts.inter(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: cs.outline,
                            ),
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(cs.surfaceContainerHigh),
                              showCheckboxColumn: false,
                              columnSpacing: 24,
                              sortColumnIndex: _sortColumnIndex,
                              sortAscending: _sortAscending,
                              columns: _buildColumns(cs),
                              rows: _buildRows(cs),
                            ),
                          ),
                        ),
                      ),
          ),

          // Footer Pagination Controls
          Container(
            padding: EdgeInsets.only(
              left: KuberSpacing.lg,
              right: KuberSpacing.lg,
              top: KuberSpacing.md,
              bottom: MediaQuery.of(context).padding.bottom + KuberSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              border: Border(top: BorderSide(color: cs.outline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _currentPage > 1
                      ? () => _setPage(_currentPage - 1)
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                  label: const Text('Prev'),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    disabledForegroundColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                TextButton.icon(
                  onPressed: _currentPage < _totalPages
                      ? () => _setPage(_currentPage + 1)
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                  label: const Text('Next'),
                  style: TextButton.styleFrom(
                    foregroundColor: cs.primary,
                    disabledForegroundColor: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(ColorScheme cs) {
    if (_allRecords.isEmpty) return [];
    
    // We assume all records have the same keys, so we take the first record's keys
    final keys = _allRecords.first.keys.toList();

    return keys.map((key) {
      return DataColumn(
        onSort: (columnIndex, ascending) => _onSort(columnIndex, ascending),
        label: Expanded(
          child: Text(
            key,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: cs.onSurfaceVariant,
            ),
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
  }

  List<DataRow> _buildRows(ColorScheme cs) {
    final records = _currentPageRecords;
    if (records.isEmpty) return [];

    final keys = records.first.keys.toList();

    return records.asMap().entries.map((entry) {
      final index = entry.key;
      final record = entry.value;
      
      final bgColor = index % 2 == 0 
          ? cs.surfaceContainer 
          : cs.surfaceContainerHigh.withValues(alpha: 0.5);

      return DataRow(
        color: WidgetStateProperty.all(bgColor),
        onSelectChanged: (_) => _showRecordDetails(record),
        cells: keys.map((key) {
          final val = record[key];
          String displayVal = val?.toString() ?? 'null';
          
          if (displayVal.length > 20) {
            displayVal = '${displayVal.substring(0, 20)}...';
          }

          return DataCell(
            Text(
              displayVal,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontStyle: val == null ? FontStyle.italic : FontStyle.normal,
                color: val == null ? cs.onSurfaceVariant.withValues(alpha: 0.6) : cs.onSurface,
              ),
            ),
          );
        }).toList(),
      );
    }).toList();
  }
}
