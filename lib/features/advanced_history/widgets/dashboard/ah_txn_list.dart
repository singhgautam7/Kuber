import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/transaction_detail_sheet.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../tags/providers/tag_providers.dart';
import '../../../transactions/data/transaction.dart';
import '../../../transactions/helpers/transaction_filters.dart';
import '../../../transactions/providers/transaction_provider.dart';
import '../../../transactions/widgets/transaction_row.dart';

/// A run of transactions shown together: one day (with a header) when the
/// list is sorted by date, else a plain block of up to [_chunk] rows.
class AhDayEntry {
  AhDayEntry(this.label, this.total, this.txns);
  final String? label;
  final double total;
  final List<Transaction> txns;
}

const _chunk = 20;

/// [ahDayEntries] memoised: regroups only when the list (identity), the
/// sort mode or [salt] (e.g. the locale, which the day headers depend on)
/// changes, not on every rebuild.
class AhDayEntryCache {
  List<Transaction>? _items;
  bool? _byDate;
  Object? _salt;
  List<AhDayEntry> _out = const [];

  List<AhDayEntry> of(List<Transaction> items,
      {required bool byDate, Object? salt}) {
    if (!identical(items, _items) || byDate != _byDate || salt != _salt) {
      _items = items;
      _byDate = byDate;
      _salt = salt;
      _out = ahDayEntries(items, byDate: byDate);
    }
    return _out;
  }
}

List<AhDayEntry> ahDayEntries(List<Transaction> items, {required bool byDate}) {
  final out = <AhDayEntry>[];
  if (!byDate) {
    for (var i = 0; i < items.length; i += _chunk) {
      out.add(AhDayEntry(
          null, 0, items.sublist(i, i + _chunk > items.length ? items.length : i + _chunk)));
    }
    return out;
  }
  int? key;
  var cur = <Transaction>[];
  void flush() {
    if (cur.isEmpty) return;
    var total = 0.0;
    for (final t in cur.validForCalculations) {
      total += t.type == 'income' ? t.amount : -t.amount;
    }
    final k = key!;
    final d = DateTime(k ~/ 10000, (k ~/ 100) % 100, k % 100);
    out.add(AhDayEntry(DateFormatter.groupHeader(d), total, cur));
    cur = [];
  }

  for (final t in items) {
    final c = t.createdAt;
    final k = c.year * 10000 + c.month * 100 + c.day;
    if (k != key) {
      flush();
      key = k;
    }
    cur.add(t);
  }
  flush();
  return out;
}

/// One entry as History draws it: optional day header + the day card. Rows
/// open the transaction detail sheet; edits refresh the providers.
class AhDayBlock extends ConsumerWidget {
  const AhDayBlock({super.key, required this.entry});
  final AhDayEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tagsMap = ref.watch(transactionTagsMapProvider).valueOrNull ?? const {};
    final tagNames = ref.watch(tagNameByIdProvider);
    final tagNamesMap = <int, List<String>>{};
    for (final t in entry.txns) {
      final ids = tagsMap[t.id];
      if (ids == null) continue;
      final names = ids.map((i) => tagNames[i]).whereType<String>().toList();
      if (names.isNotEmpty) tagNamesMap[t.id] = names;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entry.label != null)
          DateGroupHeader(label: entry.label!, dayTotal: entry.total),
        TransactionDayCard(
          transactions: entry.txns,
          onDelete: (t) => deleteTransactionWithUndo(context, ref, t),
          onTap: (t) => showTransactionDetailSheet(context, ref, t),
          onEdit: (t) => context.push('/add-transaction', extra: t),
          formatter: ref.watch(formatterProvider),
          categoryMap: ref.watch(categoryMapProvider).valueOrNull ?? const {},
          accountMap: ref.watch(accountMapProvider).valueOrNull ?? const {},
          transferPairAccountId:
              ref.watch(transferPairAccountIdsProvider).valueOrNull ??
                  const {},
          tagNamesMap: tagNamesMap,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
