import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../../settings/providers/settings_provider.dart';
import 'data/bill.dart';
import 'people_picker_sheet.dart';
import 'providers/bills_provider.dart';

class AddEditBillScreen extends ConsumerStatefulWidget {
  final Bill? existingBill;

  const AddEditBillScreen({super.key, this.existingBill});

  @override
  ConsumerState<AddEditBillScreen> createState() => _AddEditBillScreenState();
}

class _AddEditBillScreenState extends ConsumerState<AddEditBillScreen> {
  final _nameCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  List<String> _selectedPeople = [];
  String? _paidBy;
  String _splitType = 'equal';
  bool _isSaving = false;

  // Per-person input controllers for unequal/percentage modes
  final Map<String, TextEditingController> _unequalCtrls = {};
  final Map<String, TextEditingController> _percentageCtrls = {};
  final Map<String, TextEditingController> _fractionCtrls = {};

  static const _splitTypes = ['equal', 'unequal', 'percentage', 'fraction'];

  @override
  void initState() {
    super.initState();
    final b = widget.existingBill;
    if (b != null) {
      _nameCtrl.text = b.name;
      _amountCtrl.text = b.totalAmount.toStringAsFixed(2);
      _selectedPeople = b.participants.map((p) => p.personName).toList();
      _paidBy = b.paidByPersonName;
      _splitType = b.splitType;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    for (final c in _unequalCtrls.values) { c.dispose(); }
    for (final c in _percentageCtrls.values) { c.dispose(); }
    for (final c in _fractionCtrls.values) { c.dispose(); }
    super.dispose();
  }

  TextEditingController _unequalCtrl(String name) =>
      _unequalCtrls.putIfAbsent(name, () => TextEditingController());

  TextEditingController _percentageCtrl(String name) =>
      _percentageCtrls.putIfAbsent(name, () => TextEditingController());

  TextEditingController _fractionCtrl(String name) =>
      _fractionCtrls.putIfAbsent(name, () => TextEditingController());

  // Returns null if invalid
  Map<String, double>? _resolveShares() {
    final total = double.tryParse(_amountCtrl.text);
    if (total == null || total <= 0) return null;
    if (_selectedPeople.isEmpty) return null;

    switch (_splitType) {
      case 'equal':
        final share = total / _selectedPeople.length;
        return {for (final p in _selectedPeople) p: share};

      case 'unequal':
        final shares = <String, double>{};
        double sum = 0;
        for (final p in _selectedPeople) {
          final v = double.tryParse(_unequalCtrl(p).text);
          if (v == null) return null;
          shares[p] = v;
          sum += v;
        }
        if ((sum - total).abs() > 0.01) return null;
        return shares;

      case 'percentage':
        final shares = <String, double>{};
        double sumPct = 0;
        for (final p in _selectedPeople) {
          final v = double.tryParse(_percentageCtrl(p).text);
          if (v == null) return null;
          shares[p] = total * v / 100;
          sumPct += v;
        }
        if ((sumPct - 100).abs() > 0.01) return null;
        return shares;

      case 'fraction':
        final fracs = <String, double>{};
        double sumFrac = 0;
        for (final p in _selectedPeople) {
          final text = _fractionCtrl(p).text.trim();
          final frac = _parseFraction(text);
          if (frac == null) return null;
          fracs[p] = frac;
          sumFrac += frac;
        }
        if (sumFrac <= 0) return null;
        return {
          for (final entry in fracs.entries)
            entry.key: total * entry.value / sumFrac
        };

      default:
        return null;
    }
  }

  double? _parseFraction(String text) {
    if (text.isEmpty) return null;
    if (text.contains('/')) {
      final parts = text.split('/');
      if (parts.length != 2) return null;
      final num = double.tryParse(parts[0].trim());
      final den = double.tryParse(parts[1].trim());
      if (num == null || den == null || den == 0) return null;
      return num / den;
    }
    return double.tryParse(text);
  }

  String? _validationError() {
    final total = double.tryParse(_amountCtrl.text);
    if (_nameCtrl.text.trim().isEmpty) return 'Bill name is required';
    if (total == null || total <= 0) return 'Enter a valid total amount';
    if (_selectedPeople.length < 2) return 'Select at least 2 people';
    if (_paidBy == null) return 'Select who paid';

    switch (_splitType) {
      case 'unequal':
        double sum = 0;
        for (final p in _selectedPeople) {
          final v = double.tryParse(_unequalCtrl(p).text);
          if (v == null) return 'Enter amounts for all people';
          sum += v;
        }
        if ((sum - total).abs() > 0.01) {
          return 'Amounts must add up to ${total.toStringAsFixed(2)}';
        }
      case 'percentage':
        double sum = 0;
        for (final p in _selectedPeople) {
          final v = double.tryParse(_percentageCtrl(p).text);
          if (v == null) return 'Enter percentages for all people';
          sum += v;
        }
        if ((sum - 100).abs() > 0.01) return 'Percentages must add up to 100%';
      case 'fraction':
        for (final p in _selectedPeople) {
          if (_parseFraction(_fractionCtrl(p).text.trim()) == null) {
            return 'Enter valid fractions (e.g. 1/3)';
          }
        }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validationError();
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    final shares = _resolveShares();
    if (shares == null) return;

    setState(() => _isSaving = true);
    final bill = widget.existingBill ?? Bill();
    bill
      ..name = _nameCtrl.text.trim()
      ..totalAmount = double.parse(_amountCtrl.text)
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);
    final formatter = ref.watch(formatterProvider);
    final total = double.tryParse(_amountCtrl.text);
    final shares = _resolveShares();
    final error = _validationError();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: widget.existingBill == null ? 'Add Bill' : 'Edit Bill',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Bill Info ─────────────────────────────────────
            _SectionCard(
              title: 'BILL INFO',
              children: [
                _FormField(
                  label: 'BILL NAME',
                  child: TextField(
                    controller: _nameCtrl,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(cs, 'e.g. Dinner at Olive Garden'),
                  ),
                ),
                const SizedBox(height: KuberSpacing.md),
                _FormField(
                  label: 'TOTAL AMOUNT',
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(cs, '0.00', prefix: '${currency.symbol} '),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.md),

            // ── Section 2: Participants ──────────────────────────────────
            _SectionCard(
              title: 'PARTICIPANTS',
              children: [
                if (_selectedPeople.isEmpty)
                  Text(
                    'No people selected yet',
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
                  )
                else
                  Wrap(
                    spacing: KuberSpacing.sm,
                    runSpacing: KuberSpacing.sm,
                    children: _selectedPeople.map((name) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.sm,
                          vertical: KuberSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(KuberRadius.full),
                          border: Border.all(color: cs.outline),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PersonAvatar(name: name, size: PersonAvatarSize.small),
                            const SizedBox(width: KuberSpacing.xs),
                            Text(
                              name,
                              style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: cs.onSurface),
                            ),
                            const SizedBox(width: KuberSpacing.xs),
                            GestureDetector(
                              onTap: () => setState(() {
                                _selectedPeople.remove(name);
                                if (_paidBy == name) _paidBy = null;
                              }),
                              child: Icon(Icons.close_rounded, size: 14, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: KuberSpacing.md),
                TextButton.icon(
                  onPressed: () async {
                    final result = await showPeoplePickerSheet(context, _selectedPeople);
                    if (result != null) {
                      setState(() {
                        _selectedPeople = result;
                        if (_paidBy != null && !_selectedPeople.contains(_paidBy)) {
                          _paidBy = null;
                        }
                      });
                    }
                  },
                  icon: Icon(Icons.group_add_rounded, size: 18, color: cs.primary),
                  label: Text(
                    '+ Add People',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: cs.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.md),

            // ── Section 3: Paid By ───────────────────────────────────────
            if (_selectedPeople.isNotEmpty) ...[
              _SectionCard(
                title: 'PAID BY',
                children: [
                  Wrap(
                    spacing: KuberSpacing.sm,
                    runSpacing: KuberSpacing.sm,
                    children: _selectedPeople.map((name) {
                      final isSelected = _paidBy == name;
                      return GestureDetector(
                        onTap: () => setState(() => _paidBy = name),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                            horizontal: KuberSpacing.md,
                            vertical: KuberSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? cs.primary.withValues(alpha: 0.12) : cs.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(KuberRadius.full),
                            border: Border.all(
                              color: isSelected ? cs.primary : cs.outline,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              PersonAvatar(name: name, size: PersonAvatarSize.small),
                              const SizedBox(width: KuberSpacing.xs),
                              Text(
                                name,
                                style: GoogleFonts.inter(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? cs.primary : cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.md),

              // ── Section 4: Split Type ──────────────────────────────────
              _SectionCard(
                title: 'SPLIT TYPE',
                children: [
                  Row(
                    children: _splitTypes.map((type) {
                      final selected = _splitType == type;
                      final label = type[0].toUpperCase() + type.substring(1);
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _splitType = type),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(vertical: KuberSpacing.sm),
                            decoration: BoxDecoration(
                              color: selected ? cs.primary : cs.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(KuberRadius.md),
                              border: Border.all(
                                color: selected ? cs.primary : cs.outline,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              label,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: selected ? Colors.white : cs.onSurface,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // Dynamic inputs based on split type
                  if (_splitType != 'equal' && _selectedPeople.isNotEmpty) ...[
                    const SizedBox(height: KuberSpacing.lg),
                    ..._selectedPeople.map((name) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                        child: Row(
                          children: [
                            PersonAvatar(name: name, size: PersonAvatarSize.small),
                            const SizedBox(width: KuberSpacing.sm),
                            Expanded(
                              child: Text(
                                name,
                                style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              child: TextField(
                                controller: _splitType == 'unequal'
                                    ? _unequalCtrl(name)
                                    : _splitType == 'percentage'
                                        ? _percentageCtrl(name)
                                        : _fractionCtrl(name),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (_) => setState(() {}),
                                style: GoogleFonts.inter(fontSize: 13, color: cs.onSurface),
                                decoration: InputDecoration(
                                  hintText: _splitType == 'unequal'
                                      ? '0.00'
                                      : _splitType == 'percentage'
                                          ? '0'
                                          : '1/3',
                                  hintStyle: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                                  suffixText: _splitType == 'percentage' ? '%' : null,
                                  suffixStyle: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
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
                          ],
                        ),
                      );
                    }),
                  ],
                ],
              ),
              const SizedBox(height: KuberSpacing.md),

              // ── Section 5: Result Preview ──────────────────────────────
              _SectionCard(
                title: 'PREVIEW',
                children: shares != null
                    ? _selectedPeople.map((name) {
                        final amount = shares[name] ?? 0;
                        final isPayer = name == _paidBy;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
                          child: Row(
                            children: [
                              PersonAvatar(name: name, size: PersonAvatarSize.small),
                              const SizedBox(width: KuberSpacing.md),
                              Expanded(
                                child: Text(
                                  name,
                                  style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: cs.onSurface),
                                ),
                              ),
                              if (isPayer)
                                Text(
                                  'Paid ✓',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: cs.tertiary,
                                  ),
                                )
                              else
                                Text(
                                  formatter.formatCurrency(amount, symbol: currency.symbol),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: cs.onSurface,
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList()
                    : [
                        if (error != null && _selectedPeople.isNotEmpty && total != null)
                          Text(
                            error,
                            style: GoogleFonts.inter(fontSize: 13, color: cs.error),
                          )
                        else
                          Text(
                            'Fill in the form to see the preview',
                            style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
                          ),
                      ],
              ),
            ],

            const SizedBox(height: KuberSpacing.xl),
            AppButton(
              label: widget.existingBill == null ? 'Save Bill' : 'Update Bill',
              type: AppButtonType.primary,
              fullWidth: true,
              isLoading: _isSaving,
              onPressed: error == null ? _save : null,
            ),
            const SizedBox(height: KuberSpacing.lg),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(ColorScheme cs, String hint, {String? prefix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(fontSize: 15, color: cs.onSurfaceVariant),
      prefixText: prefix,
      prefixStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500, color: cs.onSurfaceVariant),
      filled: true,
      fillColor: cs.surfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.md,
        vertical: KuberSpacing.md,
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
          ...children,
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        child,
      ],
    );
  }
}
