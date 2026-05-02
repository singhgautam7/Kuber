import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/calculator_widgets.dart';

enum _SplitType { equal, unequal, percentage, fraction }

class _Person {
  String name;
  final TextEditingController inputCtrl; // for unequal/percentage/fraction
  final FocusNode nameFocus;

  _Person({this.name = ''})
      : inputCtrl = TextEditingController(),
        nameFocus = FocusNode();

  void dispose() {
    inputCtrl.dispose();
    nameFocus.dispose();
  }
}

class SplitCalculatorScreen extends ConsumerStatefulWidget {
  const SplitCalculatorScreen({super.key});

  @override
  ConsumerState<SplitCalculatorScreen> createState() =>
      _SplitCalculatorScreenState();
}

class _SplitCalculatorScreenState
    extends ConsumerState<SplitCalculatorScreen> {
  final _totalCtrl = TextEditingController();
  _SplitType _splitType = _SplitType.equal;
  final List<_Person> _people = [
    _Person(name: 'Person 1'),
    _Person(name: 'Person 2'),
  ];

  @override
  void dispose() {
    _totalCtrl.dispose();
    for (final p in _people) {
      p.dispose();
    }
    super.dispose();
  }

  double get _total =>
      double.tryParse(_totalCtrl.text.replaceAll(',', '')) ?? 0;

  void _addPerson() {
    if (_people.length >= 20) return;
    setState(() {
      _people.add(_Person(name: 'Person ${_people.length + 1}'));
    });
  }

  void _removePerson(int index) {
    if (_people.length <= 2) return;
    setState(() {
      _people[index].dispose();
      _people.removeAt(index);
    });
  }

  List<double> _computeShares() {
    final total = _total;
    final n = _people.length;
    if (total <= 0 || n == 0) return List.filled(n, 0);

    switch (_splitType) {
      case _SplitType.equal:
        return List.filled(n, total / n);

      case _SplitType.unequal:
        return _people
            .map((p) =>
                double.tryParse(p.inputCtrl.text.replaceAll(',', '')) ?? 0)
            .toList();

      case _SplitType.percentage:
        return _people.map((p) {
          final pct = double.tryParse(p.inputCtrl.text) ?? 0;
          return total * pct / 100;
        }).toList();

      case _SplitType.fraction:
        final numerators = _people
            .map((p) => double.tryParse(p.inputCtrl.text) ?? 0)
            .toList();
        final denominator = numerators.fold(0.0, (a, b) => a + b);
        if (denominator <= 0) return List.filled(n, 0);
        return numerators.map((n) => total * n / denominator).toList();
    }
  }

  bool _isValidSplit(List<double> shares) {
    final total = _total;
    if (total <= 0) return true; // empty state — no error
    switch (_splitType) {
      case _SplitType.equal:
      case _SplitType.fraction:
        return true;
      case _SplitType.unequal:
        final sum = shares.fold(0.0, (a, b) => a + b);
        return (sum - total).abs() < 0.01;
      case _SplitType.percentage:
        final sum = _people.fold(
            0.0,
            (a, p) =>
                a + (double.tryParse(p.inputCtrl.text) ?? 0));
        return (sum - 100).abs() < 0.01;
    }
  }

  String? _errorMessage(List<double> shares) {
    final total = _total;
    if (total <= 0) return null;
    switch (_splitType) {
      case _SplitType.equal:
      case _SplitType.fraction:
        return null;
      case _SplitType.unequal:
        final sum = shares.fold(0.0, (a, b) => a + b);
        final diff = sum - total;
        if (diff.abs() < 0.01) return null;
        final formatter = ref.read(formatterProvider);
        final currency = ref.read(currencyProvider);
        if (diff > 0) {
          return 'Over by ${formatter.formatCurrency(diff, symbol: currency.symbol)}';
        }
        return 'Remaining: ${formatter.formatCurrency(-diff, symbol: currency.symbol)}';
      case _SplitType.percentage:
        final sum = _people.fold(
            0.0,
            (a, p) =>
                a + (double.tryParse(p.inputCtrl.text) ?? 0));
        if ((sum - 100).abs() < 0.01) return null;
        return 'Total: ${sum.toStringAsFixed(1)}% / 100%';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final formatter = ref.watch(formatterProvider);
    final currency = ref.watch(currencyProvider);
    final shares = _computeShares();
    final valid = _isValidSplit(shares);
    final error = _errorMessage(shares);
    final hasData = _total > 0;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(
              title: '',
              showBack: true,
              showHome: true,
              infoConfig: InfoConstants.splitCalculator,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Split Calculator',
              description: 'Split expenses between people',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpacing.lg,
              0,
              KuberSpacing.lg,
              KuberSpacing.xl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                ToolInputCard(
                  children: [
                    ToolTextField(
                      label: 'TOTAL AMOUNT',
                      controller: _totalCtrl,
                      prefix: currency.symbol,
                      onChanged: (_) => setState(() {}),
                      formatAsAmount: true,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('SPLIT TYPE'),
                    const SizedBox(height: KuberSpacing.sm),
                    _SplitTypeChips(
                      selected: _splitType,
                      onChanged: (t) => setState(() => _splitType = t),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    const ToolInputLabel('PEOPLE'),
                    const SizedBox(height: KuberSpacing.sm),
                    ..._people.asMap().entries.map((entry) {
                      final i = entry.key;
                      final person = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                        child: _PersonRow(
                          person: person,
                          share: hasData ? shares[i] : null,
                          splitType: _splitType,
                          canRemove: _people.length > 2,
                          formatter: formatter,
                          currency: currency,
                          onNameChanged: (v) =>
                              setState(() => person.name = v),
                          onInputChanged: (_) => setState(() {}),
                          onRemove: () => _removePerson(i),
                        ),
                      );
                    }),
                    if (_splitType == _SplitType.unequal && hasData) ...[
                      const SizedBox(height: KuberSpacing.xs),
                      _RemainingIndicator(
                        shares: shares,
                        total: _total,
                        formatter: formatter,
                        currency: currency,
                      ),
                    ],
                    if (_splitType == _SplitType.percentage && hasData) ...[
                      const SizedBox(height: KuberSpacing.xs),
                      _PercentageIndicator(people: _people),
                    ],
                    const SizedBox(height: KuberSpacing.sm),
                    TextButton.icon(
                      onPressed: _people.length < 20 ? _addPerson : null,
                      icon: Icon(Icons.add, size: 16, color: cs.primary),
                      label: Text(
                        'Add Person',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.lg),
                // Result card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(KuberSpacing.lg),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                        color: cs.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: !hasData
                      ? const ToolEmptyResult()
                      : !valid && error != null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(KuberSpacing.md),
                                  decoration: BoxDecoration(
                                    color: cs.error.withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(KuberRadius.md),
                                    border: Border.all(
                                        color: cs.error.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.warning_rounded,
                                          size: 16, color: cs.error),
                                      const SizedBox(width: KuberSpacing.sm),
                                      Text(
                                        error,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          color: cs.error,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ..._people.asMap().entries.map((entry) {
                                  final i = entry.key;
                                  final person = entry.value;
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: KuberSpacing.sm),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            person.name.isEmpty
                                                ? 'Person ${i + 1}'
                                                : person.name,
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              color: cs.onSurface,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          formatter.formatCurrency(shares[i],
                                              symbol: currency.symbol),
                                          style: GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: cs.onSurface,
                                          ),
                                        ),
                                        const SizedBox(width: KuberSpacing.sm),
                                        GestureDetector(
                                          onTap: () {
                                            if (person.name.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Enter a name first',
                                                    style: GoogleFonts.inter(),
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            context.push('/ledger/add');
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: KuberSpacing.sm,
                                              vertical: KuberSpacing.xs,
                                            ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      KuberRadius.md),
                                              border: Border.all(
                                                  color: cs.outline),
                                            ),
                                            child: Text(
                                              'Lent/Borrow',
                                              style: GoogleFonts.inter(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: cs.primary,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                                const SizedBox(height: KuberSpacing.md),
                                Divider(
                                    color: cs.outline.withValues(alpha: 0.4),
                                    height: 1),
                                const SizedBox(height: KuberSpacing.md),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Total',
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    Text(
                                      formatter.formatCurrency(_total,
                                          symbol: currency.symbol),
                                      style: GoogleFonts.inter(
                                        fontSize: 13,
                                        color: cs.onSurfaceVariant,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SplitTypeChips extends StatelessWidget {
  final _SplitType selected;
  final ValueChanged<_SplitType> onChanged;

  const _SplitTypeChips({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final types = [
      (_SplitType.equal, 'EQUAL'),
      (_SplitType.unequal, 'UNEQUAL'),
      (_SplitType.percentage, 'PERCENT'),
      (_SplitType.fraction, 'FRACTION'),
    ];
    return Wrap(
      spacing: KuberSpacing.xs,
      runSpacing: KuberSpacing.xs,
      children: types.map((entry) {
        final (type, label) = entry;
        final isSelected = selected == type;
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.md,
              vertical: KuberSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: isSelected ? cs.primary : cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                  color: isSelected ? cs.primary : cs.outline),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : cs.onSurface,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PersonRow extends ConsumerStatefulWidget {
  final _Person person;
  final double? share;
  final _SplitType splitType;
  final bool canRemove;
  final dynamic formatter;
  final dynamic currency;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onInputChanged;
  final VoidCallback onRemove;

  const _PersonRow({
    required this.person,
    required this.share,
    required this.splitType,
    required this.canRemove,
    required this.formatter,
    required this.currency,
    required this.onNameChanged,
    required this.onInputChanged,
    required this.onRemove,
  });

  @override
  ConsumerState<_PersonRow> createState() => _PersonRowState();
}

class _PersonRowState extends ConsumerState<_PersonRow> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.person.name);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showInput = widget.splitType != _SplitType.equal;
    final suffix = switch (widget.splitType) {
      _SplitType.percentage => '%',
      _SplitType.fraction => 'parts',
      _ => null,
    };
    final prefix = widget.splitType == _SplitType.unequal
        ? widget.currency.symbol as String
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _nameCtrl,
            onChanged: widget.onNameChanged,
            focusNode: widget.person.nameFocus,
            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Name',
              hintStyle: GoogleFonts.inter(
                  fontSize: 14, color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: KuberSpacing.md,
                vertical: KuberSpacing.sm,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: KuberSpacing.sm),
        if (showInput)
          Expanded(
            flex: 2,
            child: TextField(
              controller: widget.person.inputCtrl,
              onChanged: widget.onInputChanged,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
              decoration: InputDecoration(
                prefixText: prefix != null ? '$prefix ' : null,
                prefixStyle: GoogleFonts.inter(
                    fontSize: 14, color: cs.onSurfaceVariant),
                suffixText: suffix,
                suffixStyle: GoogleFonts.inter(
                    fontSize: 13, color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainerHigh,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.md,
                  vertical: KuberSpacing.sm,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  borderSide: BorderSide(color: cs.primary),
                ),
              ),
            ),
          )
        else if (widget.share != null)
          Expanded(
            flex: 2,
            child: Text(
              widget.formatter.formatCurrency(widget.share,
                  symbol: widget.currency.symbol as String),
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ),
        const SizedBox(width: KuberSpacing.sm),
        GestureDetector(
          onTap: widget.canRemove ? widget.onRemove : null,
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color: widget.canRemove ? cs.onSurfaceVariant : Colors.transparent,
          ),
        ),
      ],
    );
  }
}

class _RemainingIndicator extends StatelessWidget {
  final List<double> shares;
  final double total;
  final dynamic formatter;
  final dynamic currency;

  const _RemainingIndicator({
    required this.shares,
    required this.total,
    required this.formatter,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sum = shares.fold(0.0, (a, b) => a + b);
    final remaining = total - sum;
    final isOver = remaining < -0.01;
    final color = isOver ? cs.error : cs.onSurfaceVariant;
    final label = isOver
        ? 'Over by ${formatter.formatCurrency(remaining.abs(), symbol: currency.symbol as String)}'
        : 'Remaining: ${formatter.formatCurrency(remaining, symbol: currency.symbol as String)}';

    return Text(
      label,
      style: GoogleFonts.inter(fontSize: 12, color: color),
    );
  }
}

class _PercentageIndicator extends StatelessWidget {
  final List<_Person> people;

  const _PercentageIndicator({required this.people});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final total = people.fold(
        0.0, (a, p) => a + (double.tryParse(p.inputCtrl.text) ?? 0));
    final ok = (total - 100).abs() < 0.01;
    return Text(
      '${total.toStringAsFixed(1)}% / 100%',
      style: GoogleFonts.inter(
        fontSize: 12,
        color: ok ? cs.tertiary : cs.error,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
