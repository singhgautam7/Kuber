import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/investment.dart';
import '../providers/investment_provider.dart';

class AddInvestmentScreen extends ConsumerStatefulWidget {
  final Investment? existing;

  const AddInvestmentScreen({super.key, this.existing});

  @override
  ConsumerState<AddInvestmentScreen> createState() =>
      _AddInvestmentScreenState();
}

class _AddInvestmentScreenState extends ConsumerState<AddInvestmentScreen> {
  final _nameController = TextEditingController();
  String _investmentType = 'stocks';
  final _investedController = TextEditingController();
  final _currentValueController = TextEditingController();
  bool _autoDebit = false;
  final _sipAmountController = TextEditingController();
  int? _sipDate;
  String? _selectedAccountId;
  final _notesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _isEditing = true;
      _nameController.text = e.name;
      _investmentType = e.investmentType;
      if (e.currentValue != null) {
        _currentValueController.text = e.currentValue!.toStringAsFixed(0);
      }
      _autoDebit = e.autoDebit;
      if (e.sipAmount != null) {
        _sipAmountController.text = e.sipAmount!.toStringAsFixed(0);
      }
      _sipDate = e.sipDate;
      _selectedAccountId = e.accountId;
      _notesController.text = e.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _investedController.dispose();
    _currentValueController.dispose();
    _sipAmountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];
    final selectedAccount = accounts
        .where((a) => a.id.toString() == _selectedAccountId)
        .firstOrNull;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Investment' : 'New Investment',
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              padding:
                  const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: KuberSpacing.lg),

                  // Name
                  _FieldLabel('INVESTMENT NAME'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Apple Stocks',
                  ),

                  const SizedBox(height: 24),

                  // Type
                  _FieldLabel('INVESTMENT TYPE'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _typeChip('SIP', Icons.savings_outlined, 'sip'),
                      _typeChip('Mutual Fund', Icons.pie_chart_outline,
                          'mutual_fund'),
                      _typeChip('Stocks',
                          Icons.candlestick_chart_outlined, 'stocks'),
                      _typeChip(
                          'Crypto', Icons.currency_bitcoin, 'crypto'),
                      _typeChip(
                          'Trading', Icons.trending_up, 'trading'),
                      _typeChip('Other', Icons.show_chart, 'other'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Amounts
                  if (!_isEditing) ...[
                    _FieldLabel('INVESTED AMOUNT'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _investedController,
                      hint: '0',
                      prefix: symbol,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  _FieldLabel('CURRENT VALUE (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _currentValueController,
                    hint: '0',
                    prefix: symbol,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Auto-debit SIP toggle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(KuberRadius.md),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.savings_outlined,
                            size: 20, color: cs.onSurfaceVariant),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Enable Auto-Debit SIP',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface,
                                ),
                              ),
                              Text(
                                'Automate your monthly contributions',
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _autoDebit,
                          onChanged: (v) =>
                              setState(() => _autoDebit = v),
                        ),
                      ],
                    ),
                  ),

                  // SIP fields (animated)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 200),
                    child: _autoDebit
                        ? Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 24),

                              _FieldLabel('MONTHLY SIP AMOUNT'),
                              const SizedBox(height: 8),
                              _buildTextField(
                                controller: _sipAmountController,
                                hint: '0',
                                prefix: symbol,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'^\d+\.?\d{0,2}')),
                                ],
                              ),

                              const SizedBox(height: 24),

                              _FieldLabel('SIP DATE'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(
                                      KuberRadius.md),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<int>(
                                    value: _sipDate,
                                    isExpanded: true,
                                    hint: Text(
                                      'Select day of month',
                                      style: GoogleFonts.inter(
                                        color: cs.onSurfaceVariant,
                                      ),
                                    ),
                                    dropdownColor:
                                        cs.surfaceContainer,
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                    items: List.generate(
                                      28,
                                      (i) => DropdownMenuItem(
                                        value: i + 1,
                                        child: Text(
                                            '${i + 1}${_ordinal(i + 1)} of month'),
                                      ),
                                    ),
                                    onChanged: (v) {
                                      if (v != null) {
                                        setState(
                                            () => _sipDate = v);
                                      }
                                    },
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              _FieldLabel('CHOOSE ACCOUNT'),
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () =>
                                    _pickAccount(context),
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 14),
                                  decoration: BoxDecoration(
                                    color: cs
                                        .surfaceContainerHighest,
                                    borderRadius:
                                        BorderRadius.circular(
                                            KuberRadius.md),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          selectedAccount?.name ??
                                              'Select account',
                                          style:
                                              GoogleFonts.inter(
                                            fontSize: 14,
                                            fontWeight:
                                                FontWeight.w600,
                                            color: selectedAccount !=
                                                    null
                                                ? cs.onSurface
                                                : cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          color:
                                              cs.onSurfaceVariant,
                                          size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // Notes
                  _FieldLabel('STRATEGY NOTES (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _notesController,
                    hint:
                        'Long term goals, strategy, or reference info...',
                    maxLines: 3,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Save button
          Padding(
            padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg, 8, KuberSpacing.lg, KuberSpacing.lg),
            child: AppButton(
              label: _isEditing ? 'SAVE CHANGES' : 'ADD INVESTMENT',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _canSave() ? () => _save(context) : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _typeChip(String label, IconData icon, String value) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _investmentType == value;
    return GestureDetector(
      onTap: () => setState(() => _investmentType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isSelected ? Colors.white : cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    final cs = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefix != null ? '$prefix ' : null,
        hintStyle: GoogleFonts.inter(color: cs.onSurfaceVariant),
        prefixStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: cs.onSurface,
        ),
        filled: true,
        fillColor: cs.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  bool _canSave() {
    if (_nameController.text.trim().isEmpty) return false;
    if (_autoDebit) {
      final sipAmt =
          double.tryParse(_sipAmountController.text.trim()) ?? 0;
      if (sipAmt <= 0 || _sipDate == null || _selectedAccountId == null) {
        return false;
      }
    }
    return true;
  }

  void _pickAccount(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => AccountPickerSheet(
        selectedAccountId: int.tryParse(_selectedAccountId ?? ''),
        onSelected: (id) {
          setState(() => _selectedAccountId = id.toString());
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _save(BuildContext context) async {
    final categories =
        ref.read(categoryListProvider).valueOrNull ?? [];
    final investCat = categories.firstWhere(
      (c) => c.name == 'Investment',
      orElse: () => categories.first,
    );

    final currentValue =
        double.tryParse(_currentValueController.text.trim());
    final sipAmount =
        double.tryParse(_sipAmountController.text.trim());

    if (_isEditing) {
      final inv = widget.existing!
        ..name = _nameController.text.trim()
        ..investmentType = _investmentType
        ..currentValue = currentValue
        ..autoDebit = _autoDebit
        ..sipAmount = _autoDebit ? sipAmount : null
        ..sipDate = _autoDebit ? _sipDate : null
        ..accountId = _autoDebit ? _selectedAccountId : widget.existing!.accountId
        ..categoryId = investCat.id.toString()
        ..notes = _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null;

      await ref.read(investmentListProvider.notifier).updateInvestment(inv);
    } else {
      final initialAmount =
          double.tryParse(_investedController.text.trim()) ?? 0;

      await ref.read(investmentListProvider.notifier).addInvestment(
            name: _nameController.text.trim(),
            investmentType: _investmentType,
            currentValue: currentValue,
            autoDebit: _autoDebit,
            sipAmount: _autoDebit ? sipAmount : null,
            sipDate: _autoDebit ? _sipDate : null,
            accountId: _selectedAccountId,
            categoryId: investCat.id.toString(),
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
            initialAmount: initialAmount,
          );
    }

    if (context.mounted) context.pop();
  }

  String _ordinal(int n) {
    if (n >= 11 && n <= 13) return 'th';
    switch (n % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: cs.onSurfaceVariant,
        letterSpacing: 0.8,
      ),
    );
  }
}
