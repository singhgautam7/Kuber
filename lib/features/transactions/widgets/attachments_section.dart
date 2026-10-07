import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/services/attachment_service.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';

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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // A row of the Add Transaction grouped list (board 3.4), thumbnails
    // below it once files are attached.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberListRow(
          onTap: widget.canAdd && !_isPickingFile
              ? () => _showAttachmentPicker(context)
              : null,
          leading: _isPickingFile
              ? SizedBox(
                  width: 40,
                  height: 40,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: cs.primary,
                    ),
                  ),
                )
              : const KuberIconTile(icon: Icons.attach_file_rounded),
          title: widget.displayPaths.isEmpty
              ? context.l10n.addImageOrPdf
              : context.l10n.filesAttached(widget.displayPaths.length),
          subtitle: sentenceCase(context.l10n.attachmentsLabel),
          trailing: widget.canAdd && !_isPickingFile
              ? Icon(Icons.add_rounded, color: cs.onSurfaceVariant)
              : null,
        ),
        // Thumbnails — inside the same container boundary
        if (widget.displayPaths.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              KuberSpace.lg,
              0,
              KuberSpace.lg,
              KuberSpace.lg,
            ),
            child: SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.displayPaths.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: KuberSpace.sm),
                itemBuilder: (context, index) {
                  final path = widget.displayPaths[index];
                  final isImage =
                      AttachmentService.getFileType(path) == 'image';
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => OpenFilex.open(path),
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHigh,
                            borderRadius: KuberShape.mediumR,
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
                            child: Icon(
                              Icons.close,
                              size: 14,
                              color: cs.onError,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
      ],
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
          title: context.l10n.addAttachments,
          subtitle: context.l10n.max5mb,
          child: Row(
            children: [
              _buildPickerCard(
                context: sheetContext,
                icon: Icons.camera_alt_outlined,
                label: context.l10n.cameraLabel,
                onTap: () {
                  Navigator.of(sheetContext, rootNavigator: true).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(width: KuberSpace.sm),
              _buildPickerCard(
                context: sheetContext,
                icon: Icons.photo_library_outlined,
                label: context.l10n.galleryLabel,
                onTap: () {
                  Navigator.of(sheetContext, rootNavigator: true).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(width: KuberSpace.sm),
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
      child: Material(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 96,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KuberIconTile(icon: icon),
                const SizedBox(height: KuberSpace.sm),
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: cs.onSurface),
                ),
              ],
            ),
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
            showKuberSnackBar(
              context,
              context.l10n.fileExceeds5mb,
              isError: true,
            );
          }
          return;
        }
        widget.onFileAdded(picked.path);
      }
    } catch (e) {
      if (mounted) {
        showKuberSnackBar(
          context,
          context.l10n.failedToPickImage('$e'),
          isError: true,
        );
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
            showKuberSnackBar(
              context,
              context.l10n.fileExceeds5mb,
              isError: true,
            );
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
