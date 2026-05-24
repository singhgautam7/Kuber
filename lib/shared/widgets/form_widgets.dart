// ignore_for_file: deprecated_member_use

// Shared form primitives for the Add / Edit screens.
//
// Used by:
//   - lib/features/loans/screens/add_loan_screen.dart
//   - lib/features/investments/screens/add_investment_screen.dart
//   - lib/features/recurring/screens/add_recurring_screen.dart
//
// All primitives consume Theme.of(context).colorScheme tokens. No hex
// literals. KuberRadius.* used throughout. No shadows.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Live preview card at the top of each Add/Edit screen.
// Shows the squircle (with selected icon + color) and the user's typed name +
// a meta line. Right side shows the headline amount when relevant.
// ---------------------------------------------------------------------------

class FormPreviewCard extends StatelessWidget {
  final IconData icon;
  final Color accentColor;
  final String? name;
  final String? metaType;
  final String? metaSecondary;
  final String? rightAmount;
  const FormPreviewCard({
    super.key,
    required this.icon,
    required this.accentColor,
    this.name,
    this.metaType,
    this.metaSecondary,
    this.rightAmount,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasName = (name ?? '').trim().isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.lg + 4),
      ),
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(14),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -40,
            child: IgnorePointer(
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.18),
                ),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.30),
                  ),
                  borderRadius: BorderRadius.circular(KuberRadius.lg),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 22, color: accentColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hasName ? name! : 'Name your entry',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 15.5,
                        fontWeight: hasName ? FontWeight.w700 : FontWeight.w600,
                        fontStyle: hasName
                            ? FontStyle.normal
                            : FontStyle.italic,
                        color: hasName ? cs.onSurface : cs.onSurfaceVariant,
                        letterSpacing: -0.2,
                      ),
                    ),
                    if ((metaType ?? '').isNotEmpty ||
                        (metaSecondary ?? '').isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if ((metaType ?? '').isNotEmpty)
                            Text(
                              metaType!.toUpperCase(),
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                                letterSpacing: 0.6,
                              ),
                            ),
                          if ((metaType ?? '').isNotEmpty &&
                              (metaSecondary ?? '').isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              width: 3,
                              height: 3,
                              decoration: BoxDecoration(
                                color: cs.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if ((metaSecondary ?? '').isNotEmpty)
                            Flexible(
                              child: Text(
                                metaSecondary!,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 10.5,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              if ((rightAmount ?? '').isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  rightAmount!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Section header — numbered eyebrow + label + optional description.
// ---------------------------------------------------------------------------

class FormSectionLabel extends StatelessWidget {
  final String num;
  final String label;
  final String? description;
  const FormSectionLabel({
    super.key,
    required this.num,
    required this.label,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                num,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: cs.primary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          if (description != null) ...[
            const SizedBox(height: 4),
            Text(
              description!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Icon picker — 6-col grid of squircles. Selected swatch tints primary.
// ---------------------------------------------------------------------------

class FormIconPicker extends StatelessWidget {
  final List<IconData> icons;
  final IconData? selected;
  final ValueChanged<IconData> onChanged;
  const FormIconPicker({
    super.key,
    required this.icons,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: icons.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, i) {
        final icon = icons[i];
        final isSel = icon == selected;
        return InkWell(
          onTap: () => onChanged(icon),
          borderRadius: BorderRadius.circular(KuberRadius.md + 2),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: isSel
                  ? cs.primary.withValues(alpha: 0.10)
                  : cs.surfaceContainerHigh,
              border: Border.all(color: isSel ? cs.primary : cs.outline),
              borderRadius: BorderRadius.circular(KuberRadius.md + 2),
            ),
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: isSel ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Color picker — row of swatches with a check on the selected one.
// ---------------------------------------------------------------------------

class FormColorPicker extends StatelessWidget {
  final List<Color> colors;
  final Color selected;
  final ValueChanged<Color> onChanged;
  const FormColorPicker({
    super.key,
    required this.colors,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in colors)
          GestureDetector(
            onTap: () => onChanged(c),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: c,
                shape: BoxShape.circle,
                border: c.value == selected.value
                    ? Border.all(color: cs.surface, width: 2)
                    : null,
                boxShadow: c.value == selected.value
                    ? [BoxShadow(color: cs.onSurface, spreadRadius: 1.5)]
                    : null,
              ),
              alignment: Alignment.center,
              child: c.value == selected.value
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inline field row — LABEL  VALUE  (optional trailing chevron / icon).
// Wraps a TextField with the Vault visual.
// ---------------------------------------------------------------------------

class FormInputRow extends StatelessWidget {
  final String label;
  final Widget child; // TextField or custom value (e.g. Text + dropdown chev)
  final bool isFocused;
  final String? currencyPrefix;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const FormInputRow({
    super.key,
    required this.label,
    required this.child,
    this.isFocused = false,
    this.currencyPrefix,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.lg),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          border: Border.all(
            color: isFocused ? cs.primary : cs.outline,
            width: isFocused ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(KuberRadius.lg),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              child: Text(
                label.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isFocused ? cs.primary : cs.onSurfaceVariant,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            const SizedBox(width: 10),
            if (currencyPrefix != null) ...[
              Text(
                currencyPrefix!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Expanded(child: child),
            if (trailingIcon != null) ...[
              const SizedBox(width: 6),
              Icon(
                trailingIcon,
                size: 18,
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Segmented control (Daily / Weekly / Monthly / Quarterly / Yearly etc).
// ---------------------------------------------------------------------------

class FormSegmentedControl<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onChanged;
  const FormSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onChanged,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        border: Border.all(color: cs.outline),
        borderRadius: BorderRadius.circular(KuberRadius.md + 2),
      ),
      child: Row(
        children: [
          for (int i = 0; i < values.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(values[i]),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 32,
                  decoration: BoxDecoration(
                    color: values[i] == selected
                        ? cs.surfaceContainer
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(
                      color: values[i] == selected
                          ? cs.outline
                          : Colors.transparent,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: values[i] == selected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      color: values[i] == selected
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full-width primary save bar.
// ---------------------------------------------------------------------------

class FormSaveBar extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  const FormSaveBar({
    super.key,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: FilledButton(
        onPressed: enabled ? onTap : null,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.1,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
