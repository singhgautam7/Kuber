import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/data_provider.dart';
import 'settings_widgets.dart';

// ---------------------------------------------------------------------------
// Show helper
// ---------------------------------------------------------------------------

void showDataExportBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const DataExportBottomSheet(),
  );
}

// ---------------------------------------------------------------------------
// Formats
// ---------------------------------------------------------------------------

enum _ExportFmt { csv, json }

enum _Stage { options, progress, complete, error }

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class DataExportBottomSheet extends ConsumerStatefulWidget {
  const DataExportBottomSheet({super.key});

  @override
  ConsumerState<DataExportBottomSheet> createState() => _DataExportBottomSheetState();
}

class _DataExportBottomSheetState extends ConsumerState<DataExportBottomSheet> {
  _Stage _stage = _Stage.options;
  _ExportFmt _format = _ExportFmt.csv;

  Uint8List? _bytes;
  File? _tempFile;
  String _errorMessage = '';
  bool _isSaving = false;

  @override
  void dispose() {
    try {
      if (_tempFile != null && _tempFile!.existsSync()) {
        _tempFile!.deleteSync();
      }
    } catch (_) {}
    super.dispose();
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

          switch (_stage) {
            _Stage.options => _buildOptions(cs),
            _Stage.progress => _buildProgress(cs),
            _Stage.complete => _buildComplete(cs),
            _Stage.error => _buildError(cs),
          },
        ],
      ),
    );
  }

  // ---- Options ---------------------------------------------------------------

  Widget _buildOptions(ColorScheme cs) {
    final isCsv = _format == _ExportFmt.csv;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Export Data',
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

        Text(
          'SELECT FORMAT',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: cs.onSurfaceVariant,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: KuberSpacing.md),
        SettingsCardSelector<_ExportFmt>(
          options: const [
            SelectorOption(
              value: _ExportFmt.csv,
              label: 'CSV',
              subtitle: 'SPREADSHEET',
              icon: Icons.description_outlined,
            ),
            SelectorOption(
              value: _ExportFmt.json,
              label: 'JSON',
              subtitle: 'BACKUP',
              icon: Icons.data_object_rounded,
            ),
          ],
          selectedValue: _format,
          onSelected: (val) => setState(() => _format = val),
        ),
        const SizedBox(height: KuberSpacing.lg),

        // Format info
        Container(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.info_outline_rounded, size: 18, color: cs.primary),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Text(
                  isCsv
                      ? 'Exports transactions, categories, accounts and tags. Does not include recurring automations, budgets, loans, investments, or attachments.'
                      : 'Complete app backup (excluding attachments). Can be used to restore all your data on a new device or after reinstalling.',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: cs.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

        AppButton(
          label: 'Export',
          icon: Icons.upload_rounded,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _startExport,
        ),
      ],
    );
  }

  // ---- Progress --------------------------------------------------------------

  Widget _buildProgress(ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.xxl),
      child: Column(
        children: [
          CircularProgressIndicator(color: cs.primary),
          const SizedBox(height: KuberSpacing.xl),
          Text(
            'Preparing your export…',
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

  // ---- Complete --------------------------------------------------------------

  Widget _buildComplete(ColorScheme cs) {
    final bytes = _bytes;
    final tempFile = _tempFile;
    if (bytes == null || tempFile == null) return const SizedBox.shrink();

    final fileName = tempFile.path.split('/').last;
    final isJson = fileName.toLowerCase().endsWith('.json');

    String sizeText = '-- KB';
    try {
      final len = bytes.length;
      if (len < 1024 * 1024) {
        sizeText = '${(len / 1024).toStringAsFixed(1)} KB';
      } else {
        sizeText = '${(len / (1024 * 1024)).toStringAsFixed(1)} MB';
      }
    } catch (_) {}

    return Column(
      children: [
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
          'Your file is ready.',
          style: GoogleFonts.inter(fontSize: 13, color: cs.onSurfaceVariant),
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
                  isJson ? Icons.data_object_rounded : Icons.description_outlined,
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
                      style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

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
          onPressed: _share,
        ),
      ],
    );
  }

  // ---- Error -----------------------------------------------------------------

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
          style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: KuberSpacing.xl),
        AppButton(
          label: 'Try Again',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: () => setState(() => _stage = _Stage.options),
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

  // ---- Logic -----------------------------------------------------------------

  Future<void> _startExport() async {
    setState(() => _stage = _Stage.progress);
    try {
      final service = ref.read(dataServiceProvider);
      final timestamp = DateFormat('yyyy_MM_dd_HHmm').format(DateTime.now());

      Uint8List bytes;
      String fileName;

      if (_format == _ExportFmt.csv) {
        final exports = await service.exportData();
        final csvString = exports.values.first;
        const bom = [0xEF, 0xBB, 0xBF];
        bytes = Uint8List.fromList([...bom, ...utf8.encode(csvString)]);
        fileName = 'kuber_export_$timestamp.csv';
      } else {
        final jsonString = await service.exportJson();
        bytes = Uint8List.fromList(utf8.encode(jsonString));
        fileName = 'kuber_backup_$timestamp.json';
      }

      final cacheDir = await getTemporaryDirectory();
      final tempFile = File('${cacheDir.path}/$fileName');
      await tempFile.writeAsBytes(bytes, flush: true);

      if (!mounted) return;
      setState(() {
        _bytes = bytes;
        _tempFile = tempFile;
        _stage = _Stage.complete;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Unable to generate file. Please try again.';
        _stage = _Stage.error;
      });
    }
  }

  Future<void> _openFile() async {
    final file = _tempFile;
    if (file == null) return;
    final fileName = file.path.split('/').last;
    final mimeType = fileName.toLowerCase().endsWith('.json')
        ? 'application/json'
        : 'text/csv';
    final result = await OpenFilex.open(file.path, type: mimeType);
    if (result.type != ResultType.done && mounted) {
      showKuberSnackBar(context, 'No app found to open this file type.');
    }
  }

  Future<void> _saveToFolder() async {
    final bytes = _bytes;
    final file = _tempFile;
    if (bytes == null || file == null) return;
    setState(() => _isSaving = true);
    try {
      final fileName = file.path.split('/').last;
      final isJson = fileName.toLowerCase().endsWith('.json');
      final saved = await FilePicker.saveFile(
        dialogTitle: 'Save a copy',
        fileName: fileName,
        bytes: bytes,
        type: isJson ? FileType.any : FileType.custom,
        allowedExtensions: isJson ? null : ['csv'],
      );
      if (!mounted) return;
      if (saved != null) showKuberSnackBar(context, 'File saved successfully.');
    } catch (_) {
      if (mounted) showKuberSnackBar(context, 'Failed to save file.');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _share() async {
    final bytes = _bytes;
    final file = _tempFile;
    if (bytes == null || file == null) return;
    final fileName = file.path.split('/').last;
    final isJson = fileName.toLowerCase().endsWith('.json');
    final mimeType = isJson ? 'application/json' : 'text/csv';
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile.fromData(bytes, name: fileName, mimeType: mimeType)],
        ),
      );
    } catch (e) {
      if (mounted) showKuberSnackBar(context, 'Could not share file: $e');
    }
  }
}
