import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ManualDateRangeBottomSheet extends StatefulWidget {
  final DateTime initialFrom;
  final DateTime initialTo;
  final Function(DateTime from, DateTime to) onApply;

  const ManualDateRangeBottomSheet({
    super.key,
    required this.initialFrom,
    required this.initialTo,
    required this.onApply,
  });

  @override
  State<ManualDateRangeBottomSheet> createState() => _ManualDateRangeBottomSheetState();
}

class _ManualDateRangeBottomSheetState extends State<ManualDateRangeBottomSheet> {
  late TextEditingController _fromController;
  late TextEditingController _toController;
  String? _fromError;
  String? _toError;
  final _df = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController(text: _df.format(widget.initialFrom));
    _toController = TextEditingController(text: _df.format(widget.initialTo));
    
    _fromController.addListener(_liveValidate);
    _toController.addListener(_liveValidate);
  }

  void _liveValidate() {
    setState(() {
       _fromError = null;
       _toError = null;
    });
  }

  bool get _isValid {
    final fromDate = _parseDate(_fromController.text);
    final toDate = _parseDate(_toController.text);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    return fromDate != null && 
           toDate != null && 
           !fromDate.isAfter(toDate) && 
           !toDate.isAfter(today);
  }

  @override
  void dispose() {
    _fromController.removeListener(_liveValidate);
    _toController.removeListener(_liveValidate);
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  DateTime? _parseDate(String val) {
    try {
      final parts = val.split('/');
      if (parts.length != 3) return null;
      final day = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      if (year < 2000 || year > 2100) return null;
      final date = DateTime(year, month, day);
      if (date.day != day || date.month != month || date.year != year) return null;
      return date;
    } catch (_) {
      return null;
    }
  }

  void _validateAndApply() {
    setState(() {
      _fromError = null;
      _toError = null;
    });

    final fromDate = _parseDate(_fromController.text);
    final toDate = _parseDate(_toController.text);
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    if (fromDate == null) {
      setState(() => _fromError = 'Invalid format');
      return;
    }
    if (toDate == null) {
      setState(() => _toError = 'Invalid format');
      return;
    }
    if (fromDate.isAfter(toDate)) {
      setState(() => _toError = 'Start must be before End');
      return;
    }
    if (toDate.isAfter(today)) {
      setState(() => _toError = 'Future dates not allowed');
      return;
    }

    widget.onApply(fromDate, toDate);
    // Pop ONLY bottom sheet
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final isValid = _isValid;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Manual Date Range',
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Specify a custom period for your financial analysis.',
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 32),
          
          _buildDateField(
            label: 'FROM DATE (DD/MM/YYYY)',
            controller: _fromController,
            error: _fromError,
            cs: cs,
            tt: tt,
          ),
          const SizedBox(height: 20),
          _buildDateField(
            label: 'TO DATE (DD/MM/YYYY)',
            controller: _toController,
            error: _toError,
            cs: cs,
            tt: tt,
          ),
          
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: isValid ? _validateAndApply : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.onSurface.withValues(alpha: 0.1),
                disabledForegroundColor: cs.onSurface.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DONE',
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.check_circle_outline_rounded, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'CANCEL',
                style: tt.labelLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    String? error,
    required ColorScheme cs,
    required TextTheme tt,
  }) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: hasError ? cs.error : cs.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.datetime,
          style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: 'DD/MM/YYYY',
            hintStyle: tt.bodyLarge?.copyWith(color: cs.onSurfaceVariant.withValues(alpha: 0.3)),
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: hasError ? cs.error : cs.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: cs.error, width: 2),
            ),
            errorText: error,
            errorStyle: tt.labelSmall?.copyWith(color: cs.error),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          ),
        ),
      ],
    );
  }
}
