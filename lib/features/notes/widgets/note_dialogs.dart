import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';

/// Standard destructive confirm used by the editor and the landing screen's
/// multi-select delete.
Future<bool?> showNoteDeleteConfirmDialog(BuildContext context,
    {required int count}) {
  final cs = Theme.of(context).colorScheme;
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        side: BorderSide(color: cs.outline),
      ),
      title: Text(
        count == 1 ? 'Delete note?' : 'Delete $count notes?',
        style: localeFont(fontWeight: FontWeight.w700, fontSize: 18),
      ),
      content: Text(
        count == 1
            ? 'This note will be permanently deleted. This cannot be undone.'
            : 'These notes will be permanently deleted. This cannot be undone.',
        style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text('Cancel',
              style: localeFont(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text('Delete',
              style:
                  localeFont(color: cs.error, fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
}
