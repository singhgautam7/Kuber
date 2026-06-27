// =============================================================================
// adjustment_confirmation_modal.dart
//
// Confirmation dialog shown when the user taps "Save Changes" on
// EditAccountScreen AND the hero figure (bank/cash balance or credit-card limit
// spent) has actually changed.
//
// Returns a Future<bool?>:
//   • true        → user tapped "Create and save" → caller saves the account and
//                   creates the balance-adjustment transaction.
//   • false/null  → user tapped "Cancel" or dismissed → caller returns to the
//                   edit screen with the typed value still in the field.
//
// Design-system: colorScheme roles only, KuberRadius.md, border (no shadow),
// localeFont() everywhere. Renders in Obsidian + Alabaster. Copy via l10n.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';

/// Shows the "Create adjustment transaction?" dialog.
///
/// [fromText] / [toText] are pre-formatted currency strings (e.g. "₹12,500").
/// [diffText] is the pre-formatted ABSOLUTE difference (e.g. "₹2,500").
/// [increased] drives the signed wording and color: true → increase (tertiary),
/// false → decrease (error).
/// [valueNoun] / [valueNounCap] are the localized lower-case / sentence-case
/// nouns for the thing being changed ("balance" / "limit spent").
Future<bool?> showAdjustmentConfirmation(
  BuildContext context, {
  required String fromText,
  required String toText,
  required String diffText,
  required bool increased,
  required String valueNoun,
  required String valueNounCap,
}) {
  final cs = Theme.of(context).colorScheme;
  final l10n = context.l10n;
  final directionColor = increased ? cs.tertiary : cs.error;
  final directionWord =
      increased ? l10n.adjustmentIncreasedBy : l10n.adjustmentDecreasedBy;

  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        side: BorderSide(color: cs.outline),
      ),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      title: Text(
        l10n.adjustmentModalTitle,
        style: localeFont(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
          color: cs.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body sentence describing the change.
          Text(
            l10n.adjustmentModalBody(valueNoun, fromText, toText, diffText),
            style: localeFont(
              fontSize: 14,
              height: 1.55,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          // Direction + "not income/expense" reassurance chip.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline.withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  increased
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 16,
                  color: directionColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.adjustmentModalChip(
                        valueNounCap, directionWord, diffText),
                    style: localeFont(
                      fontSize: 12.5,
                      height: 1.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Stacked buttons: borderless Cancel on top, primary action below —
          // keeps the long "Create and save" label from truncating.
          AppButton(
            label: l10n.cancelLabel,
            type: AppButtonType.normal,
            height: 46,
            fullWidth: true,
            onPressed: () => Navigator.pop(ctx, false),
          ),
          const SizedBox(height: 10),
          AppButton(
            label: l10n.adjustmentCreateAndSave,
            type: AppButtonType.primary,
            height: 46,
            fullWidth: true,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    ),
  );
}
