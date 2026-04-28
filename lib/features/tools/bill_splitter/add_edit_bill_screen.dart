import 'widgets/bs_squircle_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart';
import 'data/bill.dart';
import 'people_picker_sheet.dart';
import 'providers/bills_provider.dart';
import 'providers/bill_net_provider.dart';
import 'widgets/bs_avatar.dart';

const _splitTabs = [
  _SplitTab('equal', 'Equal', Icons.drag_handle_rounded),
  _SplitTab('unequal', 'Custom', Icons.edit_rounded),
  _SplitTab('percentage', '%', Icons.percent_rounded),
  _SplitTab('fraction', 'Frac', Icons.call_split_rounded),
];

class _SplitTab {
  final String value;
  final String label;
  final IconData icon;
  const _SplitTab(this.value, this.label, this.icon);
}

class AddEditBillScreen extends ConsumerStatefulWidget {
  final Bill? existingBill;
  const AddEditBillScreen({super.key, this.existingBill});
  @override
  ConsumerState<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends ConsumerState<AddEditBillScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _amountFocus = FocusNode();
  List<String> _participants = ['You'];
  String? _paidBy;
  String _splitType = 'equal';
  bool _isSaving = false;

  final Map<String, TextEditingController> _unequalCtrls = {};
  final Map<String, TextEditingController> _pctCtrls = {};
  final Map<String, TextEditingController> _fracCtrls = {};

  @override
  void initState() {
    super.initState();
    final b = widget.existingBill;
    if (b != null) {
      _nameCtrl.text = b.name;
      _amountCtrl.text = b.totalAmount.toString();
      _participants = b.participants.map((p) => p.personName).toList();
      _paidBy = b.paidByPersonName;
      _splitType = b.splitType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    _amountFocus.dispose();
    for (final c in [..._unequalCtrls.values, ..._pctCtrls.values, ..._fracCtrls.values]) {
      c.dispose();
    }
    super.dispose();
  }

  void _unfocus() {
    FocusScope.of(context).unfocus();
  }

  TextEditingController _ctrl(Map<String, TextEditingController> map, String name) =>
      map.putIfAbsent(name, TextEditingController.new);

  double? get _total => double.tryParse(_amountCtrl.text);

  Map<String, double>? _resolveShares() {
    final total = _total;
    if (total == null || total <= 0 || _participants.isEmpty) return null;
    switch (_splitType) {
      case 'equal':
        final each = total / _participants.length;
        return {for (final p in _participants) p: each};
      case 'unequal':
        final shares = <String, double>{};
        double sum = 0;
        for (final p in _participants) {
          final v = double.tryParse(_ctrl(_unequalCtrls, p).text);
          if (v == null) return null;
          shares[p] = v;
          sum += v;
        }
        return (sum - total).abs() <= 0.01 ? shares : null;
      case 'percentage':
        final shares = <String, double>{};
        double sum = 0;
        for (final p in _participants) {
          final v = double.tryParse(_ctrl(_pctCtrls, p).text);
          if (v == null) return null;
          shares[p] = total * v / 100;
          sum += v;
        }
        return (sum - 100).abs() <= 0.01 ? shares : null;
      case 'fraction':
        final fracs = <String, double>{};
        double sum = 0;
        for (final p in _participants) {
          final v = double.tryParse(_ctrl(_fracCtrls, p).text);
          if (v == null || v <= 0) return null;
          fracs[p] = v;
          sum += v;
        }
        if (sum <= 0) return null;
        return {for (final e in fracs.entries) e.key: total * e.value / sum};
      default:
        return null;
    }
  }

  String? get _validationError {
    final total = _total;
    if (_nameCtrl.text.trim().isEmpty) return 'Bill name is required';
    if (total == null || total <= 0) return 'Enter a valid amount';
    if (_participants.length < 2) return 'Select at least 2 people';
    if (_paidBy == null) return 'Select who paid';
    if (_resolveShares() == null) {
      return switch (_splitType) {
        'unequal' => 'Amounts must add up to total',
        'percentage' => 'Percentages must add up to 100%',
        'fraction' => 'Enter valid parts for all people',
        _ => null,
      };
    }
    return null;
  }

  Future<void> _save() async {
    final err = _validationError;
    if (err != null) {
      showKuberSnackBar(context, err, isError: true);
      return;
    }
    final shares = _resolveShares()!;
    setState(() => _isSaving = true);
    final bill = widget.existingBill ?? Bill();
    bill
      ..name = _nameCtrl.text.trim()
      ..totalAmount = _total!
      ..paidByPersonName = _paidBy!
      ..splitType = _splitType
      ..participants = shares.entries
          .map((e) => BillParticipant()
            ..personName = e.key
            ..share = e.value)
          .toList()
      ..createdAt = widget.existingBill?.createdAt ?? DateTime.now();
    await ref.read(billsListProvider.notifier).save(bill);
    if (mounted) context.pop();
  }

  // ── balance indicator ──────────────────────────────────────────────────
  ({String label, bool balanced}) _balanceState(Map<String, double>? shares) {
    final total = _total;
    if (total == null || shares == null) {
      return (label: '', balanced: false);
    }
    switch (_splitType) {
      case 'equal':
        return (label: '✓ BALANCED', balanced: true);
      case 'unequal':
        final sum = shares.values.fold(0.0, (a, b) => a + b);
        final diff = total - sum;
        if (diff.abs() <= 0.01) return (label: '✓ BALANCED', balanced: true);
        return (label: '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(0)} LEFT', balanced: false);
      case 'percentage':
        final sum = _participants.fold(0.0, (a, p) {
          return a + (double.tryParse(_ctrl(_pctCtrls, p).text) ?? 0);
        });
        if ((sum - 100).abs() <= 0.01) return (label: '✓ BALANCED', balanced: true);
        final diff = 100 - sum;
        return (label: '${diff > 0 ? '+' : ''}${diff.toStringAsFixed(0)}% LEFT', balanced: false);
      case 'fraction':
        final sum = _participants.fold(0.0, (a, p) {
          return a + (double.tryParse(_ctrl(_fracCtrls, p).text) ?? 0);
        });
        return sum > 0
            ? (label: '✓ BALANCED', balanced: true)
            : (label: 'ENTER PARTS', balanced: false);
      default:
        return (label: '', balanced: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);
    final shares = _resolveShares();
    final balance = _balanceState(shares);
    final total = _total ?? 0;
    final isEdit = widget.existingBill != null;

    return Scaffold(
      backgroundColor: cs.surface,
      // ── Top bar ──────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () => context.pop(),
          child: Icon(Icons.close_rounded, color: cs.onSurface),
        ),
        title: Text(
          isEdit ? 'Edit Bill' : 'New Bill',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        centerTitle: true,
      ),

      // ── Sticky save footer ────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(top: BorderSide(color: cs.outline)),
        ),
        child: SafeArea(
          top: false,
          child: AppButton(
            label: isEdit ? 'Update Bill' : 'Save Bill',
            type: AppButtonType.primary,
            fullWidth: true,
            icon: Icons.check_rounded,
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _save,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── BILL NAME ─────────────────────────────────────────────
            _FieldLabel('BILL NAME'),
            const SizedBox(height: 8),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
              decoration: InputDecoration(
                hintText: 'e.g. Goa Airbnb',
                prefixIcon: Icon(Icons.receipt_long_rounded, size: 18, color: cs.onSurfaceVariant),
                filled: true,
                fillColor: cs.surfaceContainer,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  borderSide: BorderSide(color: cs.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── TOTAL AMOUNT ──────────────────────────────────────────
            _FieldLabel('TOTAL AMOUNT'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: [
                  Text(
                    currency.symbol,
                    style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _amountCtrl,
                      focusNode: _amountFocus,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(
                        fontSize: 36, fontWeight: FontWeight.w800,
                        color: cs.onSurface, letterSpacing: -1.2,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: GoogleFonts.inter(fontSize: 36, fontWeight: FontWeight.w800, color: cs.onSurfaceVariant.withValues(alpha: 0.4)),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: ShapeDecoration(
                      color: cs.surfaceContainerHigh,
                      shape: bsSquircle(10, side: BorderSide(color: cs.outline),
                      ),
                    ),
                    child: Icon(Icons.calculate_rounded, size: 16, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ── PARTICIPANTS ──────────────────────────────────────────
            Row(
              children: [
                _FieldLabel('PARTICIPANTS · ${_participants.length}'),
                const Spacer(),
                GestureDetector(
                  onTap: () async {
                    _unfocus();
                    final result = await showPeoplePickerSheet(context, _participants);
                    _unfocus();
                    if (result != null) {
                      setState(() {
                        _participants = result.contains('You') ? result : ['You', ...result];
                        if (_paidBy != null && !_participants.contains(_paidBy)) _paidBy = null;
                      });
                    }
                  },
                  child: Row(
                    children: [
                      Icon(Icons.add_rounded, size: 12, color: cs.primary),
                      const SizedBox(width: 4),
                      Text('ADD / EDIT', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.4, color: cs.primary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Avatar strip
            if (_participants.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _participants.map((name) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Column(
                      children: [
                        BsAvatar(name: name, size: 36),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 44,
                          child: Text(
                            name == kYouName ? 'You' : name.split(' ').first,
                            style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )).toList(),
                ),
              ),
            const SizedBox(height: 14),

            // ── PAID BY ───────────────────────────────────────────────
            _FieldLabel('PAID BY'),
            const SizedBox(height: 8),
            Opacity(
              opacity: _participants.length < 2 ? 0.45 : 1.0,
              child: GestureDetector(
                onTap: _participants.length < 2
                    ? null
                    : () {
                        _unfocus();
                        _showPaidByPicker(context, cs);
                      },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Row(
                    children: [
                      if (_paidBy != null) ...[
                        BsAvatar(name: _paidBy!, size: 28),
                        const SizedBox(width: 10),
                      ] else
                        Icon(
                          _participants.length < 2 ? Icons.lock_outline_rounded : Icons.person_outline_rounded,
                          size: 18,
                          color: cs.onSurfaceVariant,
                        ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _participants.length < 2
                              ? 'Add participants first'
                              : (_paidBy ?? 'Select person'),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: _paidBy != null ? FontWeight.w600 : FontWeight.w500,
                            color: _paidBy != null ? cs.onSurface : cs.onSurfaceVariant,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // ── SPLIT TYPE ────────────────────────────────────────────
            _FieldLabel('SPLIT TYPE'),
            const SizedBox(height: 8),
            Container(
              height: 38,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: _splitTabs.map((tab) {
                  final sel = _splitType == tab.value;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _splitType = tab.value),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: sel ? cs.primary.withValues(alpha: 0.14) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: sel ? Border.all(color: cs.primary.withValues(alpha: 0.35)) : null,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          tab.label,
                          style: GoogleFonts.inter(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: sel ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── DYNAMIC BREAKDOWN CARD ────────────────────────────────
            if (_participants.isNotEmpty && total > 0) ...[
              Container(
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    // Header strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHigh,
                        border: Border(bottom: BorderSide(color: cs.outline)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _breakdownHeader(total),
                              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: cs.onSurfaceVariant),
                            ),
                          ),
                          Text(
                            balance.label,
                            style: GoogleFonts.inter(
                              fontSize: 11, fontWeight: FontWeight.w700,
                              color: balance.balanced ? KuberColors.income : const Color(0xFFF59E0B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Per-person rows
                    ..._participants.asMap().entries.map((entry) {
                      final i = entry.key;
                      final name = entry.value;
                      final isLast = i == _participants.length - 1;
                      final computed = shares?[name] ?? (total / _participants.length);

                      return Container(
                        decoration: BoxDecoration(
                          border: isLast ? null : Border(bottom: BorderSide(color: cs.outline)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            BsAvatar(name: name, size: 36),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface, letterSpacing: -0.1)),
                                  if (_splitType != 'equal')
                                    Text('≈ ${computed.toStringAsFixed(0)}', style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant, fontFeatures: const [FontFeature.tabularFigures()])),
                                ],
                              ),
                            ),

                            // Dynamic input based on split type
                            if (_splitType == 'equal')
                              Text(
                                computed.toStringAsFixed(0),
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface, fontFeatures: const [FontFeature.tabularFigures()]),
                              ),

                            if (_splitType == 'unequal')
                              _SplitInput(controller: _ctrl(_unequalCtrls, name), suffix: '₹', width: 104, onChanged: () => setState(() {})),

                            if (_splitType == 'percentage')
                              _SplitInput(controller: _ctrl(_pctCtrls, name), suffix: '%', width: 86, onChanged: () => setState(() {})),

                            if (_splitType == 'fraction')
                              _SplitInput(
                                controller: _ctrl(_fracCtrls, name),
                                suffix: '/ ${_participants.fold(0.0, (sum, p) => sum + (double.tryParse(_ctrl(_fracCtrls, p).text) ?? 0)).toStringAsFixed(0)}',
                                width: 86,
                                onChanged: () => setState(() {}),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Info card for non-equal modes
              if (_splitType != 'equal') ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 14, color: cs.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _splitType == 'unequal'
                              ? 'Enter exact amounts. Sum must match the total.'
                              : _splitType == 'percentage'
                                  ? 'Percentages must add up to 100%. Computed amounts update live.'
                                  : 'Each person gets a share proportional to their parts.',
                          style: GoogleFonts.inter(fontSize: 11.5, color: cs.onSurface, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  String _breakdownHeader(double total) {
    return switch (_splitType) {
      'equal' => 'SPLIT EQUALLY · ${(total / _participants.length).toStringAsFixed(0)} EACH',
      'unequal' => 'ENTER EXACT AMOUNTS',
      'percentage' => 'ENTER % SHARES',
      'fraction' => 'ENTER PARTS',
      _ => '',
    };
  }

  void _showPaidByPicker(BuildContext context, ColorScheme cs) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(width: 36, height: 4, decoration: BoxDecoration(color: cs.outline, borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Who Paid?', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface)),
              ),
              const SizedBox(height: 12),
              ..._participants.map((name) => ListTile(
                leading: BsAvatar(name: name, size: 36),
                title: Text(name, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface)),
                trailing: _paidBy == name ? Icon(Icons.check_rounded, color: cs.primary) : null,
                onTap: () {
                  setState(() => _paidBy = name);
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w800,
        letterSpacing: 1.1, color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _SplitInput extends StatelessWidget {
  final TextEditingController controller;
  final String suffix;
  final double width;
  final VoidCallback onChanged;

  const _SplitInput({required this.controller, required this.suffix, required this.width, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: width,
      height: 38,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => onChanged(),
        textAlign: TextAlign.right,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: cs.onSurface, fontFeatures: const [FontFeature.tabularFigures()]),
        decoration: InputDecoration(
          filled: true,
          fillColor: cs.surfaceContainerHigh,
          suffixText: suffix,
          suffixStyle: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.outline)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: cs.primary)),
        ),
      ),
    );
  }
}
