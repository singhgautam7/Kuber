import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_calculator.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider;
import '../../transactions/widgets/account_picker_sheet.dart';
import '../data/loan.dart';
import '../providers/loan_provider.dart';

class AddLoanScreen extends ConsumerStatefulWidget {
  final Loan? existing;

  const AddLoanScreen({super.key, this.existing});

  @override
  ConsumerState<AddLoanScreen> createState() => _AddLoanScreenState();
}

class _AddLoanScreenState extends ConsumerState<AddLoanScreen> {
  double _principalAmount = 0;
  String _loanType = 'personal';
  final _nameController = TextEditingController();
  final _lenderController = TextEditingController();
  final _refController = TextEditingController();
  final _emiController = TextEditingController();
  final _interestController = TextEditingController();
  String? _rateType;
  int _billDate = 1;
  DateTime _startDate = DateTime.now();
  String? _selectedAccountId;
  bool _autoAddTransaction = false;
  final _notesController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _isEditing = true;
      _principalAmount = e.principalAmount;
      _loanType = e.loanType;
      _nameController.text = e.name;
      _lenderController.text = e.lenderName;
      _refController.text = e.referenceNumber ?? '';
      _emiController.text = e.emiAmount.toStringAsFixed(0);
      if (e.interestRate != null) {
        _interestController.text = e.interestRate!.toString();
      }
      _rateType = e.rateType;
      _billDate = e.billDate;
      _startDate = e.startDate;
      _selectedAccountId = e.accountId;
      _autoAddTransaction = e.autoAddTransaction;
      _notesController.text = e.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lenderController.dispose();
    _refController.dispose();
    _emiController.dispose();
    _interestController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
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
          _isEditing ? 'Edit Loan' : 'New Loan',
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

                  // Principal amount
                  _FieldLabel('TOTAL PRINCIPAL AMOUNT'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _openCalculator(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Text(
                        _principalAmount > 0
                            ? '$symbol ${fmt.formatCurrency(_principalAmount)}'
                            : 'Tap to enter amount',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _principalAmount > 0
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Loan type
                  _FieldLabel('LOAN TYPE'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _typeChip('Home', Icons.home_outlined, 'home'),
                      _typeChip('Vehicle', Icons.directions_car_outlined,
                          'vehicle'),
                      _typeChip(
                          'Personal', Icons.work_outline, 'personal'),
                      _typeChip('Education', Icons.school_outlined,
                          'education'),
                      _typeChip(
                          'Other', Icons.description_outlined, 'other'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Loan name
                  _FieldLabel('LOAN IDENTITY'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'e.g. Home Mortgage - 5th Ave',
                  ),

                  const SizedBox(height: 24),

                  // Lender
                  _FieldLabel('LENDER'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _lenderController,
                    hint: 'e.g. HDFC Housing Finance',
                  ),

                  const SizedBox(height: 24),

                  // Reference number
                  _FieldLabel('REFERENCE NUMBER (OPTIONAL)'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _refController,
                    hint: 'e.g. #HL-8829',
                  ),

                  const SizedBox(height: 24),

                  // Monthly EMI
                  _FieldLabel('MONTHLY EMI'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emiController,
                    hint: '0',
                    prefix: symbol,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Interest rate
                  _FieldLabel('INTEREST RATE % P.A. (OPTIONAL)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          controller: _interestController,
                          hint: 'e.g. 8.45',
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _rateTypeChip('FIXED', 'fixed'),
                      const SizedBox(width: 8),
                      _rateTypeChip('FLOATING', 'floating'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Start date
                  _FieldLabel('REPAYMENT START'),
                  const SizedBox(height: 8),
                  _buildDateField(
                    date: _startDate,
                    onTap: () => _pickStartDate(context),
                  ),

                  const SizedBox(height: 24),

                  // Bill date
                  _FieldLabel('MONTHLY BILL DATE'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(KuberRadius.md),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _billDate,
                        isExpanded: true,
                        dropdownColor: cs.surfaceContainer,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                        items: List.generate(
                          28,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('Day ${i + 1} of month'),
                          ),
                        ),
                        onChanged: (v) {
                          if (v != null) setState(() => _billDate = v);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Source account
                  _FieldLabel('SOURCE ACCOUNT'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _pickAccount(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedAccount?.name ?? 'Select account',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: selectedAccount != null
                                    ? cs.onSurface
                                    : cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Icon(Icons.chevron_right,
                              color: cs.onSurfaceVariant, size: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Auto-payment toggle
                  if (_selectedAccountId != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius:
                            BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month,
                              size: 20, color: cs.onSurfaceVariant),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Auto-Payment',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                                Text(
                                  'Create a new transaction automatically on due-date',
                                  style: GoogleFonts.inter(
                                    fontSize: 11,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _autoAddTransaction,
                            onChanged: (v) =>
                                setState(() => _autoAddTransaction = v),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Notes
                  _FieldLabel('LOAN DOCUMENTATION & NOTES'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _notesController,
                    hint:
                        'Add loan reference numbers, interest rate details, or duration notes...',
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
              label: _isEditing ? 'SAVE CHANGES' : 'CONFIRM & ADD LOAN',
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
    final isSelected = _loanType == value;
    return GestureDetector(
      onTap: () => setState(() => _loanType = value),
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

  Widget _rateTypeChip(String label, String value) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _rateType == value;
    return GestureDetector(
      onTap: () =>
          setState(() => _rateType = isSelected ? null : value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? cs.primary
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
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

  Widget _buildDateField({
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today,
                size: 16, color: cs.onSurfaceVariant),
            const SizedBox(width: 10),
            Text(
              DateFormat('MMM d, yyyy').format(date),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canSave() {
    return _principalAmount > 0 &&
        _nameController.text.trim().isNotEmpty &&
        _emiController.text.trim().isNotEmpty &&
        (double.tryParse(_emiController.text.trim()) ?? 0) > 0 &&
        _selectedAccountId != null;
  }

  void _openCalculator(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberCalculator(
        initialValue: _principalAmount,
        onConfirm: (result) =>
            setState(() => _principalAmount = result),
      ),
    );
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

  Future<void> _pickStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2010),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _save(BuildContext context) async {
    // Find "Loan EMI" category
    final categories =
        ref.read(categoryListProvider).valueOrNull ?? [];
    final loanCat = categories.firstWhere(
      (c) => c.name == 'Loan EMI',
      orElse: () => categories.first,
    );

    final emi = double.tryParse(_emiController.text.trim()) ?? 0;
    final interest = double.tryParse(_interestController.text.trim());

    if (_isEditing) {
      final loan = widget.existing!
        ..name = _nameController.text.trim()
        ..loanType = _loanType
        ..lenderName = _lenderController.text.trim()
        ..referenceNumber = _refController.text.trim().isNotEmpty
            ? _refController.text.trim()
            : null
        ..principalAmount = _principalAmount
        ..emiAmount = emi
        ..rateType = _rateType
        ..interestRate = interest
        ..billDate = _billDate
        ..startDate = _startDate
        ..accountId = _selectedAccountId!
        ..categoryId = loanCat.id.toString()
        ..autoAddTransaction = _autoAddTransaction
        ..notes = _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null;

      await ref.read(loanListProvider.notifier).updateLoan(loan);
    } else {
      await ref.read(loanListProvider.notifier).addLoan(
            name: _nameController.text.trim(),
            loanType: _loanType,
            lenderName: _lenderController.text.trim(),
            referenceNumber: _refController.text.trim().isNotEmpty
                ? _refController.text.trim()
                : null,
            principalAmount: _principalAmount,
            emiAmount: emi,
            rateType: _rateType,
            interestRate: interest,
            billDate: _billDate,
            startDate: _startDate,
            accountId: _selectedAccountId!,
            categoryId: loanCat.id.toString(),
            autoAddTransaction: _autoAddTransaction,
            notes: _notesController.text.trim().isNotEmpty
                ? _notesController.text.trim()
                : null,
          );
    }

    if (context.mounted) context.pop();
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
