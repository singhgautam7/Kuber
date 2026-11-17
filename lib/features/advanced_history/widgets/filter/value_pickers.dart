import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_chips.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../../../accounts/providers/account_provider.dart';
import '../../../categories/providers/category_provider.dart';
import '../../../tags/providers/tag_providers.dart';
import '../../query/query_ast.dart';
import '../../query/query_labels.dart';
import '../../query/query_parser.dart';

/// Icon of a field (field list tile and picker header).
IconData fieldIcon(QueryField f) => switch (f) {
      QueryField.type => Icons.swap_vert_rounded,
      QueryField.amount => Icons.currency_rupee_rounded,
      QueryField.category => Icons.category_outlined,
      QueryField.account => Icons.account_balance_wallet_outlined,
      QueryField.tag => Icons.sell_outlined,
      QueryField.date => Icons.calendar_month_outlined,
      QueryField.has => Icons.attach_file_rounded,
      QueryField.source => Icons.input_rounded,
      QueryField.words => Icons.format_quote_rounded,
      QueryField.subType => Icons.layers_outlined,
    };

/// The items a picked condition inserts: `[not] token`.
List<QueryItem> itemsOf(ConditionNode c, {bool not = false}) => [
      if (not) const NotItem(),
      TokenItem(serializeNode(c), c),
    ];

/// Opens the value picker for [field]. Returns the items to insert at the
/// cursor, or null when closed.
Future<List<QueryItem>?> showFieldPicker(BuildContext context, QueryField field) {
  return showModalBottomSheet<List<QueryItem>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => FieldPickerSheet(field: field),
  );
}

enum _AmountMode { over, under, between, exactly }

class FieldPickerSheet extends ConsumerStatefulWidget {
  const FieldPickerSheet({super.key, required this.field});
  final QueryField field;

  @override
  ConsumerState<FieldPickerSheet> createState() => _FieldPickerSheetState();
}

class _FieldPickerSheetState extends ConsumerState<FieldPickerSheet> {
  final Set<String> _sel = {};
  bool _not = false;
  String _search = '';
  _AmountMode _amountMode = _AmountMode.over;
  final _a = TextEditingController();
  final _b = TextEditingController();
  final _words = TextEditingController();
  int _year = DateTime.now().year;
  DateTimeRange? _range;
  String? _dateValue; // quick / month / year value

  bool get _negatable =>
      widget.field != QueryField.amount &&
      widget.field != QueryField.date &&
      widget.field != QueryField.words;

  @override
  void dispose() {
    _a.dispose();
    _b.dispose();
    _words.dispose();
    super.dispose();
  }

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.replaceAll(',', '').trim());

  String _fmtNum(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toString();

  ConditionNode? _condition() {
    switch (widget.field) {
      case QueryField.amount:
        final a = _num(_a);
        if (a == null || a < 0) return null;
        switch (_amountMode) {
          case _AmountMode.over:
            return ConditionNode(QueryField.amount, QueryOp.gt, [_fmtNum(a)]);
          case _AmountMode.under:
            return ConditionNode(QueryField.amount, QueryOp.lt, [_fmtNum(a)]);
          case _AmountMode.exactly:
            return ConditionNode(QueryField.amount, QueryOp.eq, [_fmtNum(a)]);
          case _AmountMode.between:
            final b = _num(_b);
            if (b == null || b < a) return null;
            return ConditionNode(
                QueryField.amount, QueryOp.range, [_fmtNum(a), _fmtNum(b)]);
        }
      case QueryField.date:
        if (_range != null) {
          final f = DateFormat('yyyy-MM-dd');
          return ConditionNode(QueryField.date, QueryOp.range,
              [f.format(_range!.start), f.format(_range!.end)]);
        }
        return _dateValue == null
            ? null
            : ConditionNode(QueryField.date, QueryOp.eq, [_dateValue!]);
      case QueryField.words:
        final t = _words.text.replaceAll('"', '').trim();
        return t.isEmpty
            ? null
            : ConditionNode(QueryField.words, QueryOp.eq, [t]);
      default:
        if (_sel.isEmpty) return null;
        return ConditionNode(widget.field, QueryOp.eq, _sel.toList());
    }
  }

  void _toggle(String v, {bool exclusive = false}) {
    setState(() {
      if (_sel.contains(v)) {
        _sel.remove(v);
      } else {
        if (exclusive) _sel.clear();
        _sel.add(v);
      }
    });
  }

  void _submit() {
    final c = _condition();
    if (c == null) return;
    Navigator.of(context).pop(itemsOf(c, not: _not));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final c = _condition();
    final multi = switch (widget.field) {
      QueryField.type ||
      QueryField.category ||
      QueryField.account ||
      QueryField.tag ||
      QueryField.has ||
      QueryField.source =>
        true,
      _ => false,
    };
    final cta = multi && _sel.length > 1
        ? l.ahfAddFilterN(_sel.length)
        : l.ahfAddFilterBtn;
    return KuberBottomSheet(
      subtitle: l.ahfFilterBy,
      title: fieldLabel(widget.field, l),
      leadingIcon: KuberIconTile(icon: fieldIcon(widget.field), size: 48, glyph: 24),
      actions: AppButton(
        key: const ValueKey('ahf-picker-cta'),
        label: cta,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: c == null ? null : _submit,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_negatable) ...[
            Row(
              children: [
                KuberChip(
                  key: const ValueKey('ahf-is'),
                  label: l.ahfIs,
                  selected: !_not,
                  onTap: () => setState(() => _not = false),
                ),
                const SizedBox(width: KuberSpace.sm),
                KuberChip(
                  key: const ValueKey('ahf-is-not'),
                  label: l.ahfIsNot,
                  selected: _not,
                  onTap: () => setState(() => _not = true),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.md),
          ],
          _body(l, cs),
          if (multi && widget.field != QueryField.has) ...[
            const SizedBox(height: KuberSpace.sm),
            _note(l.ahfPickMany, cs),
          ],
        ],
      ),
    );
  }

  Widget _note(String t, ColorScheme cs) => Text(t,
      style: localeFont(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4));

  Widget _body(AppLocalizations l, ColorScheme cs) {
    switch (widget.field) {
      case QueryField.type:
        return _chips(l, [
          ('expense', l.ahqTypeExpense),
          ('income', l.ahqTypeIncome),
          ('transfer', l.ahqTypeTransfer),
        ]);
      case QueryField.has:
        return _chips(l, [
          ('attachment', l.ahqHasAttachment),
          ('note', l.ahqHasNote),
        ]);
      case QueryField.source:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _chips(l, [
            ('manual', l.ahqSourceManual),
            ('sms', l.ahqSourceSms),
            ('quickadd', l.ahqSourceQuickAdd),
            ('recurring', l.ahqSourceRecurring),
            ('import', l.ahqSourceImport),
          ]),
          const SizedBox(height: KuberSpace.sm),
          _note(l.ahfSrcNote, cs),
        ]);
      case QueryField.amount:
        return _amountBody(l, cs);
      case QueryField.words:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            key: const ValueKey('ahf-words'),
            controller: _words,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: l.ahfWordsHint,
              prefixIcon: const Icon(Icons.format_quote_rounded),
            ),
          ),
          const SizedBox(height: KuberSpace.sm),
          _note(l.ahfWordsNote, cs),
        ]);
      case QueryField.date:
        return _dateBody(l, cs);
      case QueryField.category:
        return _namesBody(
          l,
          cs,
          l.ahfSearchCategories,
          // A to Z, case ignored.
          [
            for (final c in ref.watch(categoryListProvider).valueOrNull ?? const [])
              c.name as String
          ]..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase())),
        );
      case QueryField.account:
        return _namesBody(
          l,
          cs,
          l.ahfSearchAccounts,
          [
            for (final a in ref.watch(accountListProvider).valueOrNull ?? const [])
              a.name as String
          ],
        );
      case QueryField.tag:
        return _namesBody(
          l,
          cs,
          l.ahfSearchTags,
          [
            for (final t in ref.watch(tagListProvider).valueOrNull ?? const [])
              t.name as String
          ],
          noneRow: true,
        );
      case QueryField.subType:
        return const SizedBox.shrink();
    }
  }

  Widget _chips(AppLocalizations l, List<(String, String)> opts) => Wrap(
        spacing: KuberSpace.sm,
        runSpacing: KuberSpace.sm,
        children: [
          for (final o in opts)
            KuberChip(
              key: ValueKey('ahf-opt-${o.$1}'),
              label: o.$2,
              selected: _sel.contains(o.$1),
              onTap: () => _toggle(o.$1),
            ),
        ],
      );

  Widget _moneyField(TextEditingController c, String label, {Key? key}) =>
      TextField(
        key: key,
        controller: c,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(labelText: label, prefixText: '${ref.watch(formatterProvider).symbol} '),
      );

  Widget _amountBody(AppLocalizations l, ColorScheme cs) {
    final modes = [
      (_AmountMode.over, l.ahfOver),
      (_AmountMode.under, l.ahfUnder),
      (_AmountMode.between, l.ahfBetween),
      (_AmountMode.exactly, l.ahfAmountIs),
    ];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: KuberSpace.sm, runSpacing: KuberSpace.sm, children: [
        for (final m in modes)
          KuberChip(
            key: ValueKey('ahf-amount-${m.$1.name}'),
            label: m.$2,
            selected: _amountMode == m.$1,
            onTap: () => setState(() => _amountMode = m.$1),
          ),
      ]),
      const SizedBox(height: KuberSpace.md),
      Row(children: [
        Expanded(
          child: _moneyField(
              _a, _amountMode == _AmountMode.between ? l.ahfFrom : l.ahqFieldAmount,
              key: const ValueKey('ahf-amount-a')),
        ),
        if (_amountMode == _AmountMode.between) ...[
          const SizedBox(width: KuberSpace.md),
          Expanded(
              child: _moneyField(_b, l.ahfTo, key: const ValueKey('ahf-amount-b'))),
        ],
      ]),
      const SizedBox(height: KuberSpace.sm),
      _note(l.ahfAmountNote, cs),
    ]);
  }

  Widget _namesBody(
    AppLocalizations l,
    ColorScheme cs,
    String hint,
    List<String> all, {
    bool noneRow = false,
  }) {
    final q = _search.trim().toLowerCase();
    final names = [
      for (final n in all)
        if (q.isEmpty || n.toLowerCase().contains(q)) n
    ];
    Widget row(String value, String label, {bool exclusive = false}) {
      final on = _sel.contains(value);
      return InkWell(
        key: ValueKey('ahf-opt-$value'),
        onTap: () => _toggle(value, exclusive: exclusive),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          child: Row(children: [
            Checkbox(
                value: on,
                onChanged: (_) => _toggle(value, exclusive: exclusive)),
            Expanded(
              child: Text(label,
                  style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurface)),
            ),
          ]),
        ),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(
        key: const ValueKey('ahf-search'),
        onChanged: (v) => setState(() => _search = v),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.search_rounded),
        ),
      ),
      const SizedBox(height: KuberSpace.sm),
      if (noneRow && q.isEmpty)
        row('none', l.ahfHasNoTags, exclusive: true),
      for (final n in names)
        row(n, n, exclusive: _sel.contains('none')),
      if (names.isEmpty && !(noneRow && q.isEmpty))
        Padding(
          padding: const EdgeInsets.symmetric(vertical: KuberSpace.lg),
          child: Text(l.ahfNothingFound,
              style: localeFont(fontSize: 14, color: cs.onSurfaceVariant)),
        ),
    ]);
  }

  String _month(int m) => DateFormat.MMM(Localizations.localeOf(context).toString())
      .format(DateTime(2000, m));

  void _pickDate(String value) => setState(() {
        _range = null;
        _dateValue = _dateValue == value ? null : value;
      });

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final r = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _range,
    );
    if (r != null) {
      setState(() {
        _range = r;
        _dateValue = null;
      });
    }
  }

  Widget _dateBody(AppLocalizations l, ColorScheme cs) {
    final now = DateTime.now();
    final quick = [
      ('thismonth', l.ahqDateThisMonth),
      ('lastmonth', l.ahqDateLastMonth),
      ('last30d', l.ahfDateLast30),
      ('thisyear', l.ahqDateThisYear),
    ];
    Widget h(String t) => Padding(
          padding: const EdgeInsets.only(top: KuberSpace.md, bottom: KuberSpace.sm),
          child: Text(t,
              style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant)),
        );
    final years = [for (var y = now.year; y > now.year - 6; y--) y];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      h(l.ahfDateQuick),
      Wrap(spacing: KuberSpace.sm, runSpacing: KuberSpace.sm, children: [
        for (final q in quick)
          KuberChip(
            key: ValueKey('ahf-date-${q.$1}'),
            label: q.$2,
            selected: _range == null && _dateValue == q.$1,
            onTap: () => _pickDate(q.$1),
          ),
      ]),
      h(l.ahfDateMonthYear),
      SizedBox(
        height: 40,
        child: ListView(scrollDirection: Axis.horizontal, children: [
          for (final y in years)
            Padding(
              padding: const EdgeInsets.only(right: KuberSpace.sm),
              child: KuberChip(
                key: ValueKey('ahf-year-$y'),
                label: '$y',
                selected: _year == y,
                onTap: () => setState(() => _year = y),
              ),
            ),
        ]),
      ),
      const SizedBox(height: KuberSpace.sm),
      Wrap(spacing: KuberSpace.sm, runSpacing: KuberSpace.sm, children: [
        KuberChip(
          key: const ValueKey('ahf-all-year'),
          label: l.ahfAllOfYear('$_year'),
          selected: _range == null && _dateValue == '$_year',
          onTap: () => _pickDate('$_year'),
        ),
        for (var m = 1; m <= 12; m++)
          KuberChip(
            key: ValueKey('ahf-month-$m'),
            label: _month(m),
            selected: _range == null &&
                _dateValue == '$_year-${m.toString().padLeft(2, '0')}',
            onTap: () => _pickDate('$_year-${m.toString().padLeft(2, '0')}'),
          ),
      ]),
      h(l.ahfDateCustom),
      KuberChip(
        key: const ValueKey('ahf-date-custom'),
        label: _range == null
            ? l.ahfDateCustomHint
            : '${DateFormat('d MMM y').format(_range!.start)} - ${DateFormat('d MMM y').format(_range!.end)}',
        icon: Icons.date_range_rounded,
        selected: _range != null,
        onTap: _pickRange,
      ),
    ]);
  }
}
