
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/export_data.dart';
export '../../../core/models/export_data.dart' show ExportType;
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart'; // showKuberSnackBar
import '../../analytics/providers/analytics_provider.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../settings/widgets/settings_widgets.dart';
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
  ExportResult? _exportResult;
  String _errorMessage = '';
  bool _isSaving = false; // tracks "Save to folder" in-progress

  bool get _isTransactions => widget.exportType == ExportType.transactions;

  @override
  void initState() {
    super.initState();
    _format = _isTransactions ? ExportFormat.csv : ExportFormat.pdf;
  }

  @override
  void dispose() {
    // Clean up the temp file whenever the sheet is closed
    deleteTempExportFile(_exportResult);
    super.dispose();
  }

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
    final title = _isTransactions ? 'Export History' : 'Export Analytics';

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

        // FORMAT Section
        Text(
          _isTransactions ? 'SELECT FORMAT' : 'FORMAT',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        if (_isTransactions)
          SettingsCardSelector<ExportFormat>(
            options: const [
              SelectorOption(
                value: ExportFormat.csv,
                label: 'CSV',
                subtitle: 'SPREADSHEET',
                icon: Icons.description_outlined,
              ),
              SelectorOption(
                value: ExportFormat.pdf,
                label: 'PDF',
                subtitle: 'DOCUMENT',
                icon: Icons.picture_as_pdf_outlined,
              ),
            ],
            selectedValue: _format,
            onSelected: (val) => setState(() => _format = val),
          )
        else
          // Analytics is PDF only
          SettingsCardSelector<ExportFormat>(
            options: const [
              SelectorOption(
                value: ExportFormat.pdf,
                label: 'PDF Document',
                subtitle: 'Universal format for high-fidelity printing.',
                icon: Icons.picture_as_pdf_outlined,
              ),
            ],
            selectedValue: ExportFormat.pdf,
            onSelected: (_) {},
          ),
        const SizedBox(height: KuberSpacing.xl),

        if (_isTransactions && _hasActiveFilters) ...[
          // APPLY FILTERS Card
          _buildFiltersCard(cs),
          const SizedBox(height: KuberSpacing.xl),
        ] else if (!_isTransactions) ...[
          // SELECTED PERIOD Card for Analytics
          _buildPeriodCard(cs),
          const SizedBox(height: KuberSpacing.md),
          // Info Box
          _buildInfoBox(cs),
          const SizedBox(height: KuberSpacing.xl),
        ],

        // CTA
        AppButton(
          label: 'Generate Report',
          icon: _isTransactions ? null : Icons.arrow_forward_rounded,
          iconAfterLabel: !_isTransactions,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _startExport,
        ),
      ],
    );
  }

  Widget _buildFiltersCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Apply current filters',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Generate report using the active filters from the history page.',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Switch.adaptive(
            value: _applyFilters,
            onChanged: (val) => setState(() => _applyFilters = val),
            activeTrackColor: cs.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(ColorScheme cs) {
    final filter = ref.read(analyticsFilterProvider);
    final rangeText = filter.type == FilterType.all
        ? 'All Time'
        : '${DateFormat('MMM d, yyyy').format(filter.from)} \u2013 ${DateFormat('MMM d, yyyy').format(filter.to)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECTED PERIOD',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 18, color: cs.onSurfaceVariant),
              const SizedBox(width: KuberSpacing.md),
              Text(
                rangeText,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBox(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Text(
              'Date filters from your current analytics view are automatically applied to this report.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
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
    final result = _exportResult;
    if (result == null) return const SizedBox.shrink();

    final fileName = result.tempFile.path.split('/').last;
    final fileExt = fileName.split('.').last.toUpperCase();
    final isPdf = fileExt == 'PDF';

    // File size
    String sizeText = '-- KB';
    try {
      final bLength = result.bytes.length;
      if (bLength < 1024 * 1024) {
        sizeText = '${(bLength / 1024).toStringAsFixed(1)} KB';
      } else {
        sizeText = '${(bLength / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (_) {}

    return Column(
      children: [
        // Success icon
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.check_circle_rounded, size: 32, color: cs.primary),
        ),
        const SizedBox(height: KuberSpacing.lg),
        Text(
          'Export Successful',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your report is ready.',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KuberSpacing.xl),

        // File info card
        Container(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isPdf ? Icons.picture_as_pdf_outlined : Icons.description_outlined,
                  size: 20,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sizeText,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

        // Action buttons
        AppButton(
          label: 'Open File',
          icon: Icons.open_in_new_rounded,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _openFile,
        ),
        const SizedBox(height: KuberSpacing.md),
        AppButton(
          label: _isSaving ? 'Saving…' : 'Save to Folder',
          icon: Icons.save_alt_rounded,
          type: AppButtonType.normal,
          fullWidth: true,
          onPressed: _isSaving ? null : _saveToFolder,
        ),
        const SizedBox(height: KuberSpacing.md),
        AppButton(
          label: 'Share',
          icon: Icons.share_outlined,
          type: AppButtonType.normal,
          fullWidth: true,
          onPressed: _shareReport,
        ),
      ],
    );
  }


  Future<void> _openFile() async {
    final result = _exportResult;
    if (result == null) return;
    final fileName = result.tempFile.path.split('/').last;
    // Explicitly pass MIME type — open_file defaults .csv → text/comma-separated-values
    // (Android MimeTypeMap), but Google Sheets only accepts text/csv via ACTION_VIEW.
    final mimeType = fileName.toLowerCase().endsWith('.csv')
        ? 'text/csv'
        : 'application/pdf';
    final openResult = await OpenFile.open(result.tempFile.path, type: mimeType);
    if (openResult.type != ResultType.done && mounted) {
      showKuberSnackBar(context, 'No app found to open this file type.');
    }
  }

  Future<void> _saveToFolder() async {
    final result = _exportResult;
    if (result == null) return;
    setState(() => _isSaving = true);
    try {
      final saved = await saveToFolder(result: result, format: _format);
      if (!mounted) return;
      if (saved) {
        showKuberSnackBar(context, 'File saved successfully.');
      }
    } catch (_) {
      if (mounted) showKuberSnackBar(context, 'Failed to save file.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _shareReport() async {
    final result = _exportResult;
    if (result == null) return;

    final fileName = result.tempFile.path.split('/').last;
    final isPdf = fileName.toLowerCase().endsWith('.pdf');
    final mimeType = isPdf ? 'application/pdf' : 'text/csv';

    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [
            XFile.fromData(
              result.bytes,
              name: fileName,
              mimeType: mimeType,
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(context, 'Could not share file: $e');
      }
    }
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
          child: Icon(Icons.error_outline_rounded, size: 36, color: cs.error),
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
          onPressed: () {
            setState(() => _stage = _ExportStage.options);
          },
        ),
        const SizedBox(height: KuberSpacing.md),
        AppButton(
          label: 'Cancel',
          type: AppButtonType.normal,
          fullWidth: true,
          onPressed: () => Navigator.pop(context),
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

      final result = await performExport(
        type: widget.exportType,
        format: _format,
        data: data,
      );

      if (!mounted) return;

      setState(() {
        _exportResult = result;
        _stage = _ExportStage.complete;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to generate file. Please try again.';
        _stage = _ExportStage.error;
      });
    }
  }
}
