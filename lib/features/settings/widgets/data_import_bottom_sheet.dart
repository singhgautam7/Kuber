import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/data_provider.dart';
import 'settings_widgets.dart';

// ---------------------------------------------------------------------------
// Show helper
// ---------------------------------------------------------------------------

void showDataImportBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const DataImportBottomSheet(),
  );
}

// ---------------------------------------------------------------------------
// Formats
// ---------------------------------------------------------------------------

enum _ImportFmt { csv, json }

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class DataImportBottomSheet extends ConsumerStatefulWidget {
  const DataImportBottomSheet({super.key});

  @override
  ConsumerState<DataImportBottomSheet> createState() => _DataImportBottomSheetState();
}

class _DataImportBottomSheetState extends ConsumerState<DataImportBottomSheet> {
  _ImportFmt _format = _ImportFmt.csv;
  bool _override = false;
  bool _isDownloadingTemplate = false;

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

          _buildOptions(cs),
        ],
      ),
    );
  }

  // ---- Options ---------------------------------------------------------------

  Widget _buildOptions(ColorScheme cs) {
    final isCsv = _format == _ImportFmt.csv;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            'Import Data',
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
        SettingsCardSelector<_ImportFmt>(
          options: const [
            SelectorOption(
              value: _ImportFmt.csv,
              label: 'CSV',
              subtitle: 'SPREADSHEET',
              icon: Icons.description_outlined,
            ),
            SelectorOption(
              value: _ImportFmt.json,
              label: 'JSON',
              subtitle: 'BACKUP',
              icon: Icons.data_object_rounded,
            ),
          ],
          selectedValue: _format,
          onSelected: (val) => setState(() {
            _format = val;
            _override = false;
          }),
        ),
        const SizedBox(height: KuberSpacing.lg),

        if (isCsv) _buildCsvOptions(cs) else _buildJsonDanger(cs),
        const SizedBox(height: KuberSpacing.xl),

        AppButton(
          label: 'Select File & Import',
          icon: Icons.folder_open_outlined,
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _startImport,
        ),
      ],
    );
  }

  Widget _buildCsvOptions(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Override toggle card
        Container(
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
                      'Override existing data',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _override
                          ? 'All existing data will be wiped before import.'
                          : 'New records will be merged with existing data.',
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
                value: _override,
                onChanged: (val) => setState(() => _override = val),
                activeTrackColor: cs.error,
              ),
            ],
          ),
        ),
        if (_override) ...[
          const SizedBox(height: KuberSpacing.md),
          _buildDangerChip(
            cs,
            'All existing data will be permanently deleted before import.',
          ),
        ] else ...[
          const SizedBox(height: KuberSpacing.md),
          _buildInfoChip(cs, 'New records will be merged with your existing data.'),
        ],
        const SizedBox(height: KuberSpacing.lg),
        _buildTemplateCard(cs),
      ],
    );
  }

  Widget _buildJsonDanger(ColorScheme cs) {
    return _buildDangerChip(
      cs,
      'All existing data will be permanently deleted and replaced with the backup.',
    );
  }

  Widget _buildDangerChip(ColorScheme cs, String message) {
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.error,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(ColorScheme cs, String message) {
    return Container(
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
              message,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(ColorScheme cs) {
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.lg,
              vertical: KuberSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.3),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(KuberRadius.md)),
            ),
            child: Row(
              children: [
                Icon(Icons.swap_horiz_rounded, size: 16, color: cs.secondary),
                const SizedBox(width: KuberSpacing.sm),
                Text(
                  'MIGRATING FROM ANOTHER APP?',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cs.secondary,
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download Template',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Get a CSV with the correct column headers to format your data.',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                _isDownloadingTemplate
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: cs.primary,
                        ),
                      )
                    : GestureDetector(
                        onTap: _downloadTemplate,
                        child: Container(
                          padding: const EdgeInsets.all(KuberSpacing.sm),
                          decoration: BoxDecoration(
                            color: cs.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(KuberRadius.md),
                            border: Border.all(
                              color: cs.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Icon(
                            Icons.download_rounded,
                            size: 20,
                            color: cs.primary,
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadTemplate() async {
    setState(() => _isDownloadingTemplate = true);
    try {
      await ref.read(dataControllerProvider.notifier).downloadTemplate();
    } finally {
      if (mounted) setState(() => _isDownloadingTemplate = false);
    }
  }

  // ---- Logic -----------------------------------------------------------------

  Future<void> _startImport() async {
    final ext = _format == _ImportFmt.csv ? 'csv' : 'json';
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: [ext],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final filePath = result.files.first.path;
    if (filePath == null) return;

    final content = await File(filePath).readAsString();

    if (!mounted) return;
    // Close the sheet and let DataManagementScreen show the full-screen loader
    Navigator.of(context).pop();

    ref.read(dataControllerProvider.notifier).runImport(
      content,
      isJson: _format == _ImportFmt.json,
      override: _override,
    );
  }
}
