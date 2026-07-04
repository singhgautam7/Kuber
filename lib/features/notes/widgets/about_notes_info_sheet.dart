import 'package:flutter/material.dart';

import '../../../core/models/info_config.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';

/// About Kuber Notes info sheet (screen 1h). Reuses the app's standard
/// info-sheet shell — section caption + leading icon + body copy.
const kAboutNotesInfoConfig = KuberInfoConfig(
  title: 'About Kuber Notes',
  // Empty so the sheet leads with the "What it is" section (per design 1h).
  description: '',
  items: [
    KuberInfoItem(
      icon: Icons.description_outlined,
      title: 'What it is',
      description:
          'A scratchpad for money. Jot lists, do quick math, and turn any '
          'number into a real transaction.',
    ),
    KuberInfoItem(
      icon: Icons.functions_rounded,
      title: 'How arithmetic works',
      description:
          'Type total, sum or = on a new line and Kuber adds the numbers '
          'above it. Use all sum to add every number in the note.',
      example: KuberInfoExample(
        expression: '60, 45, 90',
        trigger: 'total',
        result: '₹195',
      ),
    ),
    KuberInfoItem(
      icon: Icons.calculate_outlined,
      title: 'Inline math with =',
      description:
          'Write an expression before = on the same line and Kuber solves '
          'it with BODMAS. Works with + - × ÷ and brackets.',
      example: KuberInfoExample(
        expression: 'Eggs 7 * 10',
        trigger: '=',
        result: '70',
      ),
    ),
    KuberInfoItem(
      icon: Icons.touch_app_rounded,
      title: 'Convert a number',
      description:
          'Tap any highlighted number to add it as a transaction, '
          'recurring, investment and more.',
    ),
    KuberInfoItem(
      icon: Icons.lock_outline_rounded,
      title: 'Read-only mode',
      description: 'Lock a note to prevent edits. Numbers stay tappable.',
    ),
    KuberInfoItem(
      icon: Icons.shield_outlined,
      title: 'Privacy',
      description:
          'Notes never leave your device. Fully offline, stored locally, '
          'never synced.',
    ),
  ],
);

void showAboutNotesInfoSheet(BuildContext context) {
  KuberInfoBottomSheet.show(context, kAboutNotesInfoConfig);
}
