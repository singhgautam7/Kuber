import 'package:flutter/material.dart';

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
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      maxLines: 2,
      style: textTheme.bodyMedium?.copyWith(
        color: cs.onSurface,
      ),
      decoration: InputDecoration(
        hintText: 'Add a note (optional)',
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
        ),
        prefixIcon: showPrefixIcon
            ? Icon(Icons.note_outlined, color: cs.onSurfaceVariant)
            : null,
      ),
    );
  }
}
