import 'package:flutter/material.dart';

import '../../../core/utils/l10n_ext.dart';

/// Shared notes text field used by both normal and transfer forms.
class NotesField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool showPrefixIcon;

  const NotesField({
    super.key,
    required this.controller,
    this.focusNode,
    this.showPrefixIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 2,
      minLines: 1,
      style: textTheme.bodyLarge?.copyWith(color: cs.onSurface),
      // Filled M3 field with the leading notes glyph (board 3.4).
      decoration: InputDecoration(
        hintText: context.l10n.addNoteHint,
        hintStyle: textTheme.bodyLarge?.copyWith(color: cs.onSurfaceVariant),
        prefixIcon: Icon(Icons.notes_rounded, color: cs.onSurfaceVariant),
      ),
    );
  }
}
