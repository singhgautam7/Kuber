import 'package:flutter/material.dart';

/// The quiet "always uses ..." note (board "Hub and score"): an info glyph
/// and bodySmall text, no container.
class FixedWindowNote extends StatelessWidget {
  final String message;

  const FixedWindowNote({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
