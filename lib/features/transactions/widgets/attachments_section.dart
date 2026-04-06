import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/attachment_service.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/widgets/settings_widgets.dart' show SquircleIcon;

/// Shared attachments section used by both normal and transfer forms.
/// Manages its own file picking state internally.
class AttachmentsSection extends StatefulWidget {
  /// Existing attachment paths (from a transaction being edited), minus removed ones, plus pending ones.
  final List<String> displayPaths;

  /// Whether the user can add more attachments.
  final bool canAdd;

  /// Called when a new file is picked (with the file path).
  final void Function(String path) onFileAdded;

  /// Called when a file is removed (with the file path).
  final void Function(String path) onFileRemoved;

  const AttachmentsSection({
    super.key,
    required this.displayPaths,
    required this.canAdd,
    required this.onFileAdded,
    required this.onFileRemoved,
  });

  @override
  State<AttachmentsSection> createState() => _AttachmentsSectionState();
}

class _AttachmentsSectionState extends State<AttachmentsSection> {
  bool _isPickingFile = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: widget.canAdd && !_isPickingFile ? () => _showAttachmentPicker(context) : null,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _isPickingFile
                      ? Padding(
                          padding: const EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: cs.primary,
                          ),
                        )
                      : Icon(
                          Icons.attach_file_rounded,
                          size: 18,
                          color: cs.primary,
                        ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ATTACHMENTS',
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.displayPaths.isEmpty
                          ? 'Add image or PDF'
                          : '${widget.displayPaths.length} file${widget.displayPaths.length == 1 ? '' : 's'} attached',
                      style: textTheme.bodyMedium?.copyWith(
                        color: widget.displayPaths.isEmpty
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (widget.canAdd && !_isPickingFile)
                  Icon(Icons.add, color: cs.onSurfaceVariant),
              ],
            ),

            // Thumbnails — inside the same container boundary
            if (widget.displayPaths.isNotEmpty) ...[
              const SizedBox(height: KuberSpacing.md),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.displayPaths.length,
                  separatorBuilder: (_, __) => const SizedBox(width: KuberSpacing.sm),
                  itemBuilder: (context, index) {
                    final path = widget.displayPaths[index];
                    final isImage = AttachmentService.getFileType(path) == 'image';
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => OpenFilex.open(path),
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(KuberRadius.md),
                              border: Border.all(color: cs.outline),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: isImage
                                ? Image.file(
                                    File(path),
                                    fit: BoxFit.cover,
                                    width: 80,
                                    height: 80,
                                    errorBuilder: (_, __, ___) => Icon(
                                      Icons.broken_image_outlined,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  )
                                : Center(
                                    child: Icon(
                                      Icons.picture_as_pdf,
                                      color: cs.primary,
                                      size: 32,
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: GestureDetector(
                            onTap: () => widget.onFileRemoved(path),
                            child: Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: cs.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAttachmentPicker(BuildContext context) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return KuberBottomSheet(
          title: 'Add Attachments',
          subtitle: 'Max 5MB per file',
          child: Row(
            children: [
              _buildPickerCard(
                context: sheetContext,
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: () {
                  Navigator.of(sheetContext, rootNavigator: true).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(width: KuberSpacing.sm),
              _buildPickerCard(
                context: sheetContext,
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: () {
                  Navigator.of(sheetContext, rootNavigator: true).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(width: KuberSpacing.sm),
              _buildPickerCard(
                context: sheetContext,
                icon: Icons.picture_as_pdf_outlined,
                label: 'PDF',
                onTap: () {
                  Navigator.of(sheetContext, rootNavigator: true).pop();
                  _pickPdf();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPickerCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: KuberSpacing.lg),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SquircleIcon(icon: icon, size: 16, padding: 8),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isPickingFile = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (picked != null && mounted) {
        final file = File(picked.path);
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          if (mounted) {
            showKuberSnackBar(context, 'File exceeds 5MB limit', isError: true);
          }
          return;
        }
        widget.onFileAdded(picked.path);
      }
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(context, 'Failed to pick image: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  Future<void> _pickPdf() async {
    setState(() => _isPickingFile = true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      if (result != null && result.files.isNotEmpty && mounted) {
        final path = result.files.single.path;
        if (path == null) return;
        final file = File(path);
        final size = await file.length();
        if (size > 5 * 1024 * 1024) {
          if (mounted) {
            showKuberSnackBar(context, 'File exceeds 5MB limit', isError: true);
          }
          return;
        }
        widget.onFileAdded(path);
      }
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(context, 'Failed to pick PDF: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }
}
