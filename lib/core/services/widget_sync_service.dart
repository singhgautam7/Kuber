import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/accounts/data/account.dart';
import '../../features/accounts/providers/account_provider.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/categories/data/category.dart';
import '../../features/notes/data/kuber_note.dart';
import '../../features/notes/utils/note_format.dart';
import '../../features/sms_import/data/sms_import_repository.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/upcoming_events/engine/event_aggregator.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../database/isar_service.dart';
import '../utils/formatters.dart';

/// Owns all Flutter -> native home-screen widget data sync. Computes each
/// widget's JSON payload from Isar, renders the chart bitmaps, and pushes
/// everything through the home_widget bridge. Runs post-first-frame and on app
/// resume; must never block startup or throw into the caller.
class WidgetSyncService {
  WidgetSyncService(this.ref);
  final Ref ref;

  Isar get _isar => ref.read(isarProvider);
  AppFormatter get _fmt => ref.read(formatterProvider);

  static const _incomeHex = 0xFF22C55E;
  static const _expenseHex = 0xFFEF4444;
  static const _primaryHex = 0xFF3B82F6;
  static const _mutedHex = 0x3F3F3F46;

  Future<void> syncAll() async {
    // Each sub-sync is isolated so a single failure cannot break the rest.
    for (final task in <Future<void> Function()>[
      _syncMonthlyNet,
      _syncAccountBalances,
      _syncSmsBadge,
      _syncUpcomingEvents,
      _syncRecentTransactions,
      _syncBudgetStatus,
      _syncNotes,
      _syncCharts,
    ]) {
      try {
        await task();
      } catch (_) {
        // Swallow: widget sync must never crash the app.
      }
    }
  }

  // ---- helpers ------------------------------------------------------------

  int get _nowMs => DateTime.now().millisecondsSinceEpoch;

  String _money(num v) => _fmt.formatCurrency(v.abs());
  String _signed(num v) => '${v >= 0 ? '+' : '−'}${_money(v)}';

  bool _isSpendable(Transaction t) => !t.isTransfer && !t.isBalanceAdjustment;

  Future<List<Transaction>> _allTxns() => _isar.transactions.where().findAll();

  Future<void> _save(String key, Map<String, dynamic> data, String androidName) async {
    await HomeWidget.saveWidgetData<String>(key, jsonEncode(data));
    await HomeWidget.updateWidget(name: androidName, androidName: androidName);
  }

  String _hex(int argb) => '#${(argb & 0xFFFFFFFF).toRadixString(16).padLeft(8, '0')}';

  // ---- 1. Monthly Net -----------------------------------------------------

  Future<void> _syncMonthlyNet() async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final txns = await _allTxns();
    var income = 0.0, expense = 0.0;
    for (final t in txns) {
      if (!_isSpendable(t) || t.createdAt.isBefore(monthStart)) continue;
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }
    final net = income - expense;
    final empty = income == 0 && expense == 0;
    await _save('monthly_net', {
      'state': empty ? 'empty' : 'populated',
      'net': _signed(net),
      'netSign': net >= 0 ? 'income' : 'expense',
      'subline': 'Income ${_money(income)} · Expense ${_money(expense)}',
      'updatedMillis': _nowMs,
    }, 'MonthlyNetWidgetProvider');
  }

  // ---- 2. Account Balances ------------------------------------------------

  Future<void> _syncAccountBalances() async {
    final accounts = await ref.read(allAccountsProvider.future);
    final balances = await ref.read(accountBalancesProvider.future);
    for (final Account a in accounts) {
      if (a.isDisabled) continue;
      final bal = (balances[a.id] ?? 0).toDouble();
      await HomeWidget.saveWidgetData<String>('acct_${a.id}', jsonEncode({
        'name': a.name,
        'balance': '${bal < 0 ? '−' : ''}${_money(bal)}',
        'sign': bal < 0 ? 'expense' : 'income',
        'updatedMillis': _nowMs,
      }));
    }
    await HomeWidget.updateWidget(
      name: 'AccountBalanceWidgetProvider',
      androidName: 'AccountBalanceWidgetProvider',
    );
  }

  // ---- 3. SMS Import Badge -------------------------------------------------

  Future<void> _syncSmsBadge() async {
    final count = await SmsImportRepository(_isar).countUnreviewed();
    await _save('sms_badge', {
      'count': count,
      'updatedMillis': _nowMs,
    }, 'SmsImportBadgeWidgetProvider');
  }

  // ---- 4. Upcoming Events --------------------------------------------------

  Future<void> _syncUpcomingEvents() async {
    final events = await UpcomingEventsAggregator(_isar)
        .getUpcomingEvents(window: const Duration(days: 30));
    events.sort((a, b) => a.date.compareTo(b.date));
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final list = events.take(4).map((e) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      final dateLabel = d == today ? 'Today' : '${e.date.day} ${months[e.date.month - 1]}';
      final amt = e.amount ?? 0;
      return {
        'date': dateLabel,
        'title': e.title,
        'amount': e.amount == null ? '' : _signed(amt),
        'amountSign': amt >= 0 ? 'income' : 'expense',
        'sourceType': e.sourceType,
        'path': _eventPath(e),
      };
    }).toList();
    await _save('upcoming_events', {
      'state': list.isEmpty ? 'empty' : 'populated',
      'events': list,
      'updatedMillis': _nowMs,
    }, 'UpcomingEventsWidgetProvider');
  }

  String _eventPath(UpcomingEvent e) => switch (e.sourceType) {
        'reminder' => 'more/reminders?open=${e.sourceId}',
        'emi' => 'more/loans',
        'sip' => 'more/investments',
        'recurring' => 'more/recurring',
        'ledger' => 'more/ledger',
        _ => 'more/upcoming-events',
      };

  // ---- 5. Recent Transactions ---------------------------------------------

  Future<void> _syncRecentTransactions() async {
    final txns = await _allTxns();
    final recent = txns.where((t) => !t.isTransfer).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final accounts = {for (final a in await _isar.accounts.where().findAll()) a.id.toString(): a.name};
    final cats = {for (final c in await _isar.categorys.where().findAll()) c.id.toString(): c};
    final list = recent.take(5).map((t) {
      final cat = cats[t.categoryId];
      return {
        'name': t.name,
        'account': accounts[t.accountId] ?? '',
        'amount': '${t.type == 'income' ? '+' : '−'}${_money(t.amount)}',
        'amountSign': t.type == 'income' ? 'income' : 'expense',
        'color': _hex(cat?.colorValue ?? _primaryHex),
        'path': 'history',
      };
    }).toList();
    await _save('recent_transactions', {
      'state': list.isEmpty ? 'empty' : 'populated',
      'txns': list,
      'updatedMillis': _nowMs,
    }, 'RecentTransactionsWidgetProvider');
  }

  // ---- 6. Budget Status ----------------------------------------------------

  Future<void> _syncBudgetStatus() async {
    final budgets = await _isar.budgets.where().findAll();
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final txns = await _allTxns();
    final cats = {for (final c in await _isar.categorys.where().findAll()) c.id.toString(): c};

    double spentFor(String categoryId) {
      var s = 0.0;
      for (final t in txns) {
        if (t.type == 'expense' && _isSpendable(t) && t.categoryId == categoryId && !t.createdAt.isBefore(monthStart)) {
          s += t.amount;
        }
      }
      return s;
    }

    final rows = budgets.take(3).map((Budget b) {
      final spent = spentFor(b.categoryId);
      final pct = b.amount <= 0 ? 0 : (spent / b.amount * 100).round();
      final status = pct >= 100 ? 'expense' : (pct >= 90 ? 'amber' : 'primary');
      return {
        'name': cats[b.categoryId]?.name ?? 'Budget',
        'value': '${_money(spent)} / ${_money(b.amount)} · $pct%',
        'percent': pct,
        'status': status,
        'path': 'more/budgets',
      };
    }).toList();

    final more = budgets.length - rows.length;
    await _save('budget_status', {
      'state': rows.isEmpty ? 'empty' : 'populated',
      'budgets': rows,
      'moreText': more > 0 ? '+ $more more' : '',
      'updatedMillis': _nowMs,
    }, 'BudgetStatusWidgetProvider');
  }

  // ---- 7. Notes ------------------------------------------------------------

  Future<void> _syncNotes() async {
    final notes = await _isar.kuberNotes.where().findAll();
    notes.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final list = notes.take(3).map((KuberNote n) => {
          'title': n.title.trim().isEmpty ? 'Untitled note' : n.title,
          'preview': _notePreview(n.content),
          'time': noteRelativeTime(n.updatedAt),
          'path': 'notes/editor?id=${n.id}',
        }).toList();
    await _save('notes', {
      'state': list.isEmpty ? 'empty' : 'populated',
      'notes': list,
      'updatedMillis': _nowMs,
    }, 'NotesWidgetProvider');
  }

  String _notePreview(String content) {
    try {
      final ops = jsonDecode(content);
      if (ops is List) {
        final buf = StringBuffer();
        for (final op in ops) {
          if (op is Map && op['insert'] is String) buf.write(op['insert']);
        }
        final text = buf.toString().replaceAll('\n', ' ').trim();
        return text.length > 60 ? '${text.substring(0, 60)}…' : text;
      }
    } catch (_) {}
    return '';
  }

  // ---- 8. Charts (compact / trends / donut) --------------------------------

  Future<void> _syncCharts() async {
    final txns = (await _allTxns()).where(_isSpendable).toList();
    // Isolate each so a failure in one chart can't prevent the others syncing.
    for (final task in <Future<void> Function()>[
      () => _syncChartCompact(txns),
      () => _syncTrends(txns),
      () => _syncDonut(txns),
    ]) {
      try {
        await task();
      } catch (e, s) {
        debugPrint('Kuber: widget chart sync failed: $e\n$s');
      }
    }
  }

  /// Sums (income, expense) into [buckets] time ranges via [bucketOf].
  List<(double, double)> _bucket(List<Transaction> txns, int count, int Function(Transaction) bucketOf) {
    final inc = List<double>.filled(count, 0);
    final exp = List<double>.filled(count, 0);
    for (final t in txns) {
      final b = bucketOf(t);
      if (b < 0 || b >= count) continue;
      if (t.type == 'income') {
        inc[b] += t.amount;
      } else {
        exp[b] += t.amount;
      }
    }
    return [for (var i = 0; i < count; i++) (inc[i], exp[i])];
  }

  Future<void> _syncChartCompact(List<Transaction> txns) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final data = _bucket(txns, 7, (t) => DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day).difference(start).inDays);
    final income = data.fold(0.0, (s, d) => s + d.$1);
    final expense = data.fold(0.0, (s, d) => s + d.$2);
    final path = await _renderBars(data, 480, 150, 'widget_chart_compact.png');
    await _save('chart_compact', {
      'state': (income == 0 && expense == 0 || path == null) ? 'empty' : 'populated',
      'image': path ?? '',
      'net': _signed(income - expense),
      'netSign': income - expense >= 0 ? 'income' : 'expense',
      'income': 'Income ${_money(income)}',
      'expense': 'Expense ${_money(expense)}',
      'updatedMillis': _nowMs,
    }, 'ChartCompactWidgetProvider');
  }

  Future<void> _syncTrends(List<Transaction> txns) async {
    final now = DateTime.now();
    // 7D
    final d7Start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
    final d7 = _bucket(txns, 7, (t) => DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day).difference(d7Start).inDays);
    // 4W
    final w4Start = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 27));
    final w4 = _bucket(txns, 4, (t) {
      final days = DateTime(t.createdAt.year, t.createdAt.month, t.createdAt.day).difference(w4Start).inDays;
      return days ~/ 7;
    });
    // 6M
    final m6 = _bucket(txns, 6, (t) {
      final monthsAgo = (now.year - t.createdAt.year) * 12 + (now.month - t.createdAt.month);
      return 5 - monthsAgo;
    });

    Future<Map<String, dynamic>> range(String key, List<(double, double)> data) async {
      final income = data.fold(0.0, (s, d) => s + d.$1);
      final expense = data.fold(0.0, (s, d) => s + d.$2);
      // Unique filename per range so the three bitmaps don't overwrite each other.
      final path = await _renderBars(data, 480, 170, 'widget_trends_$key.png');
      return {
        'image': path ?? '',
        'net': _signed(income - expense),
        'netSign': income - expense >= 0 ? 'income' : 'expense',
        'income': 'Income ${_money(income)}',
        'expense': 'Expense ${_money(expense)}',
      };
    }

    final anyData = [...d7, ...w4, ...m6].any((d) => d.$1 != 0 || d.$2 != 0);
    await _save('chart_with_range', {
      'state': anyData ? 'populated' : 'empty',
      'ranges': {
        '7D': await range('7D', d7),
        '4W': await range('4W', w4),
        '6M': await range('6M', m6),
      },
      'updatedMillis': _nowMs,
    }, 'ChartWithRangeWidgetProvider');
  }

  Future<void> _syncDonut(List<Transaction> txns) async {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month);
    final cats = {for (final c in await _isar.categorys.where().findAll()) c.id.toString(): c};
    final byCat = <String, double>{};
    for (final t in txns) {
      if (t.type == 'expense' && !t.createdAt.isBefore(monthStart)) {
        byCat[t.categoryId] = (byCat[t.categoryId] ?? 0) + t.amount;
      }
    }
    final total = byCat.values.fold(0.0, (s, v) => s + v);
    final sorted = byCat.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).toList();
    final segments = <(double, int)>[
      for (final e in top) (total == 0 ? 0 : e.value / total, cats[e.key]?.colorValue ?? _primaryHex),
    ];
    final rows = top.map((e) {
      final pct = total == 0 ? 0 : (e.value / total * 100).round();
      return {
        'name': cats[e.key]?.name ?? 'Category',
        'value': '${_money(e.value)} · $pct%',
        'color': _hex(cats[e.key]?.colorValue ?? _primaryHex),
      };
    }).toList();
    final path = await _renderDonut(segments);
    await _save('category_donut', {
      'state': (total == 0 || path == null) ? 'empty' : 'populated',
      'image': path ?? '',
      'cats': rows,
      'updatedMillis': _nowMs,
    }, 'CategoryDonutWidgetProvider');
  }

  // ---- chart rasterisation (offscreen Canvas -> PNG) ----------------------

  Future<String> _file(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$name';
  }

  /// Returns the PNG path, or null on any failure (never throws) so a render
  /// error can't cascade or leave a widget stuck on its loading skeleton.
  Future<String?> _renderBars(List<(double, double)> data, double w, double h, String name) async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, w, h));
      final maxTotal = data.fold(0.0, (m, d) => (d.$1 + d.$2) > m ? d.$1 + d.$2 : m);
      final n = data.length;
      const gap = 12.0;
      final barW = (w - gap * (n - 1)) / n;
      final incPaint = ui.Paint()..color = const ui.Color(_incomeHex);
      final expPaint = ui.Paint()..color = const ui.Color(_expenseHex);
      for (var i = 0; i < n; i++) {
        final x = i * (barW + gap);
        final incH = maxTotal == 0 ? 0.0 : data[i].$1 / maxTotal * h;
        final expH = maxTotal == 0 ? 0.0 : data[i].$2 / maxTotal * h;
        // expense on top, income at the bottom
        final expTop = h - incH - expH;
        canvas.drawRRect(
          ui.RRect.fromLTRBR(x, expTop, x + barW, h - incH, const ui.Radius.circular(4)),
          expPaint,
        );
        canvas.drawRRect(
          ui.RRect.fromLTRBR(x, h - incH, x + barW, h, const ui.Radius.circular(4)),
          incPaint,
        );
      }
      return _encode(recorder.endRecording(), w.toInt(), h.toInt(), name);
    } catch (e, s) {
      debugPrint('Kuber: bar chart render failed: $e\n$s');
      return null;
    }
  }

  Future<String?> _renderDonut(List<(double, int)> segments) async {
    try {
      const size = 184.0;
      final recorder = ui.PictureRecorder();
      final canvas = ui.Canvas(recorder, ui.Rect.fromLTWH(0, 0, size, size));
      final rect = ui.Rect.fromLTWH(0, 0, size, size);
      var start = -1.5708;
      final drawn = segments.fold(0.0, (s, seg) => s + seg.$1);
      final paint = ui.Paint()..style = ui.PaintingStyle.fill;
      for (final (frac, color) in segments) {
        paint.color = ui.Color(color);
        final sweep = frac * 6.28319;
        canvas.drawArc(rect, start, sweep, true, paint);
        start += sweep;
      }
      // remainder
      if (drawn < 1) {
        paint.color = const ui.Color(_mutedHex);
        canvas.drawArc(rect, start, (1 - drawn) * 6.28319, true, paint);
      }
      // transparent hole so the card shows through
      canvas.drawCircle(ui.Offset(size / 2, size / 2), size * 0.28, ui.Paint()..blendMode = ui.BlendMode.clear);
      return _encode(recorder.endRecording(), size.toInt(), size.toInt(), 'widget_donut.png');
    } catch (e, s) {
      debugPrint('Kuber: donut render failed: $e\n$s');
      return null;
    }
  }

  Future<String> _encode(ui.Picture picture, int w, int h, String name) async {
    final img = await picture.toImage(w, h);
    final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
    final path = await _file(name);
    await File(path).writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
    img.dispose();
    picture.dispose();
    return path;
  }
}

/// Access point for the widget sync service.
final widgetSyncServiceProvider = Provider<WidgetSyncService>(WidgetSyncService.new);
