import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/export_data.dart';
export '../../../core/models/export_data.dart' show ExportType;
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../history/providers/history_filter_provider.dart';
import '../providers/export_provider.dart';

// ---------------------------------------------------------------------------
// Show helper
// ---------------------------------------------------------------------------

void showExportBottomSheet({
  required BuildContext context,
  required ExportType exportType,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ExportBottomSheet(exportType: exportType),
  );
}

// ---------------------------------------------------------------------------
// Export Bottom Sheet
// ---------------------------------------------------------------------------

enum _ExportStage { options, progress, complete, error }

class ExportBottomSheet extends ConsumerStatefulWidget {
  final ExportType exportType;

  const ExportBottomSheet({super.key, required this.exportType});

  @override
  ConsumerState<ExportBottomSheet> createState() => _ExportBottomSheetState();
}

class _ExportBottomSheetState extends ConsumerState<ExportBottomSheet> {
  _ExportStage _stage = _ExportStage.options;
  ExportFormat _format = ExportFormat.csv;
  bool _applyFilters = true;
  File? _exportedFile;
  String _errorMessage = '';

  bool get _isTransactions => widget.exportType == ExportType.transactions;

  bool get _hasActiveFilters {
    if (!_isTransactions) return false;
    final filter = ref.read(historyFilterProvider);
    return !filter.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        KuberSpacing.xl,
        KuberSpacing.lg,
        KuberSpacing.xl,
        viewPadding > 0 ? viewPadding + KuberSpacing.lg : KuberSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Close button
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.sm),

          // Content based on stage
          switch (_stage) {
            _ExportStage.options => _buildOptions(cs),
            _ExportStage.progress => _buildProgress(cs),
            _ExportStage.complete => _buildComplete(cs),
            _ExportStage.error => _buildError(cs),
          },
        ],
      ),
    );
  }

  // ---- Options state -------------------------------------------------------

  Widget _buildOptions(ColorScheme cs) {
    final title = _isTransactions ? 'Export Transactions' : 'Export Report';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Title
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

        // Format toggle
        Text('Format',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.5,
            )),
        const SizedBox(height: KuberSpacing.sm),
        Row(
          children: [
            Expanded(child: _formatChip(cs, ExportFormat.csv, 'CSV')),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(child: _formatChip(cs, ExportFormat.pdf, 'PDF')),
          ],
        ),
        const SizedBox(height: KuberSpacing.xl),

        // Apply filters checkbox (only for transactions with active filters)
        if (_isTransactions && _hasActiveFilters) ...[
          GestureDetector(
            onTap: () => setState(() => _applyFilters = !_applyFilters),
            child: Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: Checkbox(
                    value: _applyFilters,
                    onChanged: (v) => setState(() => _applyFilters = v ?? true),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                Text(
                  'Apply current filters',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
          if (_applyFilters) ...[
            const SizedBox(height: KuberSpacing.sm),
            _buildFilterSummary(cs),
          ],
          const SizedBox(height: KuberSpacing.lg),
        ],

        // Info for analytics
        if (!_isTransactions && _format == ExportFormat.pdf) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(KuberSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PDF includes:',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: KuberSpacing.xs),
                ...[
                  'Summary overview',
                  'Spending bar chart',
                  'Category breakdown',
                  'Smart insights',
                  'Daily totals',
                ].map((item) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(Icons.check, size: 14, color: cs.primary),
                          const SizedBox(width: KuberSpacing.xs),
                          Text(item,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: cs.onSurfaceVariant,
                              )),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
        ],

        // Export button
        AppButton(
          label: 'Export',
          icon: Icons.file_download_outlined,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _startExport,
        ),
      ],
    );
  }

  Widget _formatChip(ColorScheme cs, ExportFormat format, String label) {
    final selected = _format == format;
    return GestureDetector(
      onTap: () => setState(() => _format = format),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outline.withValues(alpha: 0.3),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: selected ? cs.onPrimary : cs.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterSummary(ColorScheme cs) {
    final filter = ref.read(historyFilterProvider);
    final chips = <String>[];

    if (filter.from != null && filter.to != null) {
      chips.add(
          '${_shortDate(filter.from!)} \u2013 ${_shortDate(filter.to!)}');
    }
    if (filter.types.isNotEmpty) {
      chips.addAll(filter.types.map((t) => t[0].toUpperCase() + t.substring(1)));
    }
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      chips.add('"${filter.searchQuery}"');
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: KuberSpacing.xs,
      runSpacing: KuberSpacing.xs,
      children: chips
          .map((c) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.sm, vertical: KuberSpacing.xs),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                ),
                child: Text(c,
                    style: GoogleFonts.inter(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500)),
              ))
          .toList(),
    );
  }

  String _shortDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${d.day} ${months[d.month - 1]}';
  }

  // ---- Progress state ------------------------------------------------------

  Widget _buildProgress(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xxl),
      child: Column(
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: KuberSpacing.xl),
          Text(
            'Generating your report\u2026',
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Complete state ------------------------------------------------------

  Widget _buildComplete(ColorScheme cs) {
    final fileName = _exportedFile?.path.split('/').last ?? '';
    final dirPath = _exportedFile?.parent.path ?? '';
    // Show only the last meaningful part of the path
    final shortPath = dirPath.contains('Kuber')
        ? dirPath.substring(dirPath.indexOf('Android'))
        : dirPath;

    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_rounded, size: 36, color: Colors.green.shade600),
        ),
        const SizedBox(height: KuberSpacing.lg),
        Text(
          'Export Complete',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          fileName,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpacing.xs),
        Text(
          'Saved to $shortPath',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KuberSpacing.xl),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Open',
                icon: Icons.open_in_new,
                type: AppButtonType.outline,
                onPressed: () => OpenFilex.open(_exportedFile!.path),
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(
              child: AppButton(
                label: 'Share',
                icon: Icons.share_outlined,
                type: AppButtonType.outline,
                onPressed: () => SharePlus.instance.share(
                  ShareParams(files: [XFile(_exportedFile!.path)]),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.sm),
        AppButton(
          label: 'Done',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  // ---- Error state ---------------------------------------------------------

  Widget _buildError(ColorScheme cs) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.error_outline, size: 36, color: cs.error),
        ),
        const SizedBox(height: KuberSpacing.lg),
        Text(
          'Export Failed',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          _errorMessage,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KuberSpacing.xl),
        AppButton(
          label: 'Try Again',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: () => setState(() => _stage = _ExportStage.options),
        ),
        const SizedBox(height: KuberSpacing.sm),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  // ---- Export logic ---------------------------------------------------------

  Future<void> _startExport() async {
    setState(() => _stage = _ExportStage.progress);

    try {
      dynamic data;
      if (_isTransactions) {
        data = buildTransactionExportData(ref,
            applyFilters: _applyFilters && _hasActiveFilters);
      } else {
        data = buildAnalyticsExportData(ref);
      }

      final file = await performExport(
        type: widget.exportType,
        format: _format,
        data: data,
      );

      if (!mounted) return;
      setState(() {
        _exportedFile = file;
        _stage = _ExportStage.complete;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _stage = _ExportStage.error;
      });
    }
  }
}
