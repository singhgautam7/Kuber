import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/models/export_data.dart';
export '../../../core/models/export_data.dart' show ExportType;
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
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
    final l10n = context.l10n;
    final optionsTitle = _isTransactions
        ? l10n.exportHistory
        : l10n.exportAnalytics;

    // Shared sheet shell (title in the header, close disc, pinned actions).
    return KuberBottomSheet(
      title: switch (_stage) {
        _ExportStage.complete => l10n.exportSuccessful,
        _ExportStage.error => l10n.exportFailed,
        _ => optionsTitle,
      },
      description: switch (_stage) {
        _ExportStage.complete => l10n.reportReady,
        _ExportStage.error => _errorMessage,
        _ => null,
      },
      actions: switch (_stage) {
        _ExportStage.options => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: l10n.generateReport,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _startExport,
            ),
          ],
        ),
        _ExportStage.progress => null,
        _ExportStage.complete => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: l10n.openFile,
              icon: Icons.open_in_new_rounded,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: _openFile,
            ),
            const SizedBox(height: KuberSpace.md),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: _isSaving ? l10n.savingEllipsis : l10n.saveToFolder,
                    icon: Icons.save_alt_rounded,
                    fullWidth: true,
                    onPressed: _isSaving ? null : _saveToFolder,
                  ),
                ),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: AppButton(
                    label: l10n.shareLabel,
                    icon: Icons.share_outlined,
                    fullWidth: true,
                    onPressed: _shareReport,
                  ),
                ),
              ],
            ),
          ],
        ),
        _ExportStage.error => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: l10n.tryAgain,
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: () => setState(() => _stage = _ExportStage.options),
            ),
            const SizedBox(height: KuberSpace.md),
            AppButton(
              label: l10n.cancelLabel,
              fullWidth: true,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      },
      child: switch (_stage) {
        _ExportStage.options => _buildOptions(cs),
        _ExportStage.progress => _buildProgress(cs),
        _ExportStage.complete => _buildComplete(cs),
        _ExportStage.error => const SizedBox.shrink(),
      },
    );
  }

  // ---- Options state -------------------------------------------------------

  Widget _buildOptions(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberSectionHeader(
          title: _isTransactions
              ? context.l10n.selectFormat
              : context.l10n.formatUpper,
        ),
        if (_isTransactions)
          SettingsCardSelector<ExportFormat>(
            options: [
              SelectorOption(
                value: ExportFormat.csv,
                label: 'CSV',
                subtitle: context.l10n.spreadsheetLabel,
                icon: Icons.description_outlined,
              ),
              SelectorOption(
                value: ExportFormat.pdf,
                label: 'PDF',
                subtitle: context.l10n.documentLabel,
                icon: Icons.picture_as_pdf_outlined,
              ),
            ],
            selectedValue: _format,
            onSelected: (val) => setState(() => _format = val),
          )
        else
          // Analytics is PDF only
          SettingsCardSelector<ExportFormat>(
            options: [
              SelectorOption(
                value: ExportFormat.pdf,
                label: context.l10n.pdfDocument,
                subtitle: context.l10n.pdfDocumentDesc,
                icon: Icons.picture_as_pdf_outlined,
              ),
            ],
            selectedValue: ExportFormat.pdf,
            onSelected: (_) {},
          ),
        const SizedBox(height: KuberSpace.xl),
        if (_isTransactions && _hasActiveFilters) ...[
          _buildFiltersCard(cs),
        ] else if (!_isTransactions) ...[
          _buildPeriodCard(cs),
          const SizedBox(height: KuberSpace.md),
          _buildInfoBox(cs),
        ],
      ],
    );
  }

  Widget _buildFiltersCard(ColorScheme cs) {
    return KuberGroup(
      children: [
        KuberListRow(
          leading: const KuberIconTile(icon: Icons.filter_alt_outlined),
          title: context.l10n.applyCurrentFilters,
          subtitle: context.l10n.applyFiltersDesc,
          subtitleLines: 2,
          onTap: () => setState(() => _applyFilters = !_applyFilters),
          trailing: Switch(
            value: _applyFilters,
            onChanged: (val) => setState(() => _applyFilters = val),
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodCard(ColorScheme cs) {
    final filter = ref.read(analyticsFilterProvider);
    final rangeText = filter.type == FilterType.all
        ? context.l10n.periodAllTime
        : '${DateFormat('MMM d, yyyy').format(filter.from)} \u2013 ${DateFormat('MMM d, yyyy').format(filter.to)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberSectionHeader(title: context.l10n.selectedPeriod),
        KuberGroup(
          children: [
            KuberListRow(
              leading: const KuberIconTile(icon: Icons.calendar_today_outlined),
              title: rangeText,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoBox(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.cardR,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 20,
            color: cs.onSecondaryContainer,
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Text(
              context.l10n.analyticsDateFilterInfo,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium!.copyWith(color: cs.onSecondaryContainer),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Progress state ------------------------------------------------------

  Widget _buildProgress(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpace.xxl),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: KuberSpace.xl),
          Text(
            'Generating your report\u2026',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
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

    return KuberGroup(
      children: [
        KuberListRow(
          leading: KuberIconTile(
            icon: isPdf
                ? Icons.picture_as_pdf_outlined
                : Icons.description_outlined,
          ),
          title: fileName,
          subtitle: sizeText,
          trailing: Icon(Icons.check_circle_rounded, color: cs.primary),
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
    final openResult = await OpenFilex.open(
      result.tempFile.path,
      type: mimeType,
    );
    if (openResult.type != ResultType.done && mounted) {
      showKuberSnackBar(context, context.l10n.noAppToOpen);
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
        showKuberSnackBar(context, context.l10n.fileSaved);
      }
    } catch (_) {
      if (mounted) showKuberSnackBar(context, context.l10n.failedToSaveFile);
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
            XFile.fromData(result.bytes, name: fileName, mimeType: mimeType),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(
          context,
          context.l10n.couldNotShareFile(e.toString()),
        );
      }
    }
  }

  // ---- Export logic ---------------------------------------------------------

  Future<void> _startExport() async {
    setState(() => _stage = _ExportStage.progress);

    try {
      dynamic data;
      if (_isTransactions) {
        data = buildTransactionExportData(
          ref,
          applyFilters: _applyFilters && _hasActiveFilters,
        );
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
        _errorMessage = context.l10n.exportGenerateFailed;
        _stage = _ExportStage.error;
      });
    }
  }
}
