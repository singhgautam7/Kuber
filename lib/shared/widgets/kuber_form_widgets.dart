// =============================================================================
// kuber_form_widgets.dart
//
// Shared visual primitives for the 6 polished entity-creation screens
// (Account, Category, Recurring, Loan, Investment, Ledger). Every screen
// builds its body out of these widgets, in the same order, at the same
// density, so the screens read as siblings.
//
// All colors come from Theme.of(context).colorScheme. Do NOT hardcode hex
// values — the design works in both Obsidian (dark) and Alabaster (light)
// because every surface, text, border, and accent is a ColorScheme role.
//
// Lives at: lib/shared/widgets/kuber_form_widgets.dart
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

/// One labelled section of a form. Renders an uppercase muted heading
/// followed by its children, separated by a configurable inner gap.
/// Pass `tinted: true` to render inside a primary-tinted card — used by
/// Schedule sections in Recurring / Loan / Ledger so the "when" half of
/// the form reads distinct from the "what" half above.
class KuberFormSection extends StatelessWidget {
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final bool tinted;
  final double topGap;
  final List<Widget> children;

  const KuberFormSection({
    super.key,
    required this.label,
    this.sublabel,
    this.trailing,
    this.tinted = false,
    this.topGap = 22,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = tinted ? cs.primary : cs.onSurfaceVariant;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
                        color: accent,
                      ),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sublabel!,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
        // Children are joined by a 10 dp gap, matching the picker rows in
        // the visual reference.
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          children[i],
        ],
      ],
    );

    final wrapped = tinted
        ? Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(
                color: Color.alphaBlend(
                  cs.primary.withValues(alpha: 0.18),
                  cs.outline,
                ),
              ),
            ),
            child: body,
          )
        : body;

    return Padding(
      padding: EdgeInsets.only(top: topGap),
      child: wrapped,
    );
  }
}

/// Small label that sits 6 dp above a field. Pass `optional: true` to
/// append " · optional" in muted weight.
class KuberFieldLabel extends StatelessWidget {
  final String text;
  final bool optional;
  const KuberFieldLabel(this.text, {super.key, this.optional = false});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 6, top: 2),
      child: Text.rich(
        TextSpan(
          text: text,
          children: optional
              ? [
                  TextSpan(
                    text: '  · optional',
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ]
              : null,
          style: GoogleFonts.inter(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Hero-sized currency input. Used everywhere a screen has a single
/// dominant numeric field (Account balance, Recurring amount, Loan
/// principal/EMI, Investment current value, Ledger amount).
///
/// Tone tints the value text:
///   • HeroAmountTone.neutral — onSurface (default)
///   • HeroAmountTone.income  — cs.tertiary (green)
///   • HeroAmountTone.expense — cs.error (red)
class KuberHeroAmountInput extends StatelessWidget {
  final String label;
  final String currencySymbol;
  final TextEditingController controller;
  final HeroAmountTone tone;
  final VoidCallback? onCalculatorTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  const KuberHeroAmountInput({
    super.key,
    required this.label,
    required this.currencySymbol,
    required this.controller,
    this.tone = HeroAmountTone.neutral,
    this.onCalculatorTap,
    this.focusNode,
    this.onChanged,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueColor = switch (tone) {
      HeroAmountTone.income => cs.tertiary,
      HeroAmountTone.expense => cs.error,
      HeroAmountTone.neutral => cs.onSurface,
    };

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                currencySymbol,
                style: GoogleFonts.inter(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
                  inputFormatters: inputFormatters,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                    color: valueColor,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                  decoration: const InputDecoration(
                    hintText: '0',
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (onCalculatorTap != null)
                IconButton(
                  onPressed: onCalculatorTap,
                  icon: Icon(Icons.calculate_outlined,
                      size: 18, color: cs.onSurfaceVariant),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.surfaceContainerHigh,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                    ),
                  ),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

enum HeroAmountTone { neutral, income, expense }

/// Picker row used for icon / color / account / category / group / date /
/// any "tap to open a sheet" surface. 36×36 leading slot, 11/700 label,
/// 14.5/600 value, chevron-right trailing.
///
/// Pass `clearable: true` + `onClear` to render an X-circle instead of the
/// chevron — used by the optional Loan-start and Ledger-expected-return
/// rows when they're filled in.
class KuberPickerRow extends StatelessWidget {
  final Widget leading;
  final String label;
  final String value;
  final bool valueIsPlaceholder;
  final VoidCallback onTap;
  final bool clearable;
  final VoidCallback? onClear;

  const KuberPickerRow({
    super.key,
    required this.leading,
    required this.label,
    required this.value,
    this.valueIsPlaceholder = false,
    required this.onTap,
    this.clearable = false,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          onTap();
        },
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              SizedBox(width: 36, height: 36, child: leading),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 14.5,
                        fontWeight: valueIsPlaceholder
                            ? FontWeight.w500
                            : FontWeight.w600,
                        color: valueIsPlaceholder
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              if (clearable && onClear != null)
                IconButton(
                  onPressed: onClear,
                  icon: Icon(Icons.cancel_rounded,
                      size: 18, color: cs.onSurfaceVariant),
                  visualDensity: VisualDensity.compact,
                  splashRadius: 18,
                )
              else
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

/// Card-style switch row with a leading tinted icon, name + sub, trailing
/// toggle. Used by Loan's "Auto-add transactions" and Investment's
/// "Enable auto-debit SIP".
class KuberSwitchRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String sub;
  final bool value;
  final ValueChanged<bool> onChanged;

  const KuberSwitchRow({
    super.key,
    required this.icon,
    required this.name,
    required this.sub,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Ink(
        padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: value
                    ? cs.primary.withValues(alpha: 0.15)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
              child: Icon(
                icon,
                size: 18,
                color: value ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sub,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

/// Segmented control for 2-3 options. Pass `tones` per index to colour
/// the active segment by intent (expense red, income green, neutral
/// onSurface). Used by Account type (3), Category type (3), Recurring
/// type (2), Ledger type (2), Recurring end type (3).
class KuberSegmented<T> extends StatelessWidget {
  final List<KuberSegment<T>> segments;
  final T groupValue;
  final ValueChanged<T> onChanged;
  final bool enabled;

  const KuberSegmented({
    super.key,
    required this.segments,
    required this.groupValue,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: IgnorePointer(
        ignoring: !enabled,
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Row(
            children: [
              for (final seg in segments)
                Expanded(
                  child: _SegmentButton(
                    segment: seg,
                    selected: seg.value == groupValue,
                    onTap: () => onChanged(seg.value),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class KuberSegment<T> {
  final T value;
  final String label;
  final IconData? icon;
  final SegmentTone tone;
  const KuberSegment({
    required this.value,
    required this.label,
    this.icon,
    this.tone = SegmentTone.neutral,
  });
}

enum SegmentTone { neutral, income, expense }

class _SegmentButton extends StatelessWidget {
  final KuberSegment segment;
  final bool selected;
  final VoidCallback onTap;
  const _SegmentButton({
    required this.segment,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = switch (segment.tone) {
      SegmentTone.income => cs.tertiary,
      SegmentTone.expense => cs.error,
      SegmentTone.neutral => cs.primary,
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? activeColor.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: selected
                ? Border.all(color: activeColor.withValues(alpha: 0.30))
                : Border.all(color: Colors.transparent),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (segment.icon != null) ...[
                Icon(
                  segment.icon,
                  size: 16,
                  color: selected ? activeColor : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                segment.label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? activeColor : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 2-3 column grid of icon+label chips. Used by Loan type, Investment
/// type, Recurring frequency.
class KuberChipGrid<T> extends StatelessWidget {
  final List<KuberChipOption<T>> options;
  final T? selected;
  final ValueChanged<T> onChanged;
  final int columns;

  const KuberChipGrid({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.columns = 3,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 1.4,
      ),
      itemCount: options.length,
      itemBuilder: (_, i) {
        final opt = options[i];
        final isSelected = opt.value == selected;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(opt.value),
            borderRadius: BorderRadius.circular(KuberRadius.md),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withValues(alpha: 0.12)
                    : cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (opt.icon != null) ...[
                    Icon(
                      opt.icon,
                      size: 18,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    opt.label,
                    style: GoogleFonts.inter(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class KuberChipOption<T> {
  final T value;
  final String label;
  final IconData? icon;
  const KuberChipOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

/// 1-31 day grid for "monthly bill date" (Loan) and "SIP date" (Investment).
class KuberDayGrid extends StatelessWidget {
  final int? selected;
  final ValueChanged<int> onChanged;

  const KuberDayGrid({super.key, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemCount: 31,
      itemBuilder: (_, i) {
        final day = i + 1;
        final isSelected = selected == day;
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => onChanged(day),
            borderRadius: BorderRadius.circular(6),
            child: Ink(
              decoration: BoxDecoration(
                color: isSelected
                    ? cs.primary.withValues(alpha: 0.12)
                    : cs.surfaceContainer,
                border: Border.all(
                  color: isSelected ? cs.primary : cs.outline,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? cs.primary : cs.onSurfaceVariant,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The "answer card" — the primary-tinted summary the Loan form shows
/// once the user has typed an EMI. Reads as: "this is what the form is
/// telling you back".
class KuberAnswerCard extends StatelessWidget {
  final String labelText;
  final IconData labelIcon;
  final String amountText;
  final String unitText;
  final List<KuberAnswerMeta> meta;

  const KuberAnswerCard({
    super.key,
    required this.labelText,
    required this.labelIcon,
    required this.amountText,
    required this.unitText,
    this.meta = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: cs.primary.withValues(alpha: 0.40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(labelIcon, size: 13, color: cs.primary),
              const SizedBox(width: 6),
              Text(
                labelText.toUpperCase(),
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  color: cs.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                amountText,
                style: GoogleFonts.inter(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  color: cs.primary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              const Spacer(),
              Text(
                unitText,
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (meta.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.only(top: 10),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: cs.primary.withValues(alpha: 0.20),
                  ),
                ),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < meta.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            meta[i].key.toUpperCase(),
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta[i].value,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class KuberAnswerMeta {
  final String key;
  final String value;
  const KuberAnswerMeta({required this.key, required this.value});
}

/// Sticky bottom save button. Always at the same absolute position
/// across all 6 screens.
class KuberSaveButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const KuberSaveButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(
          top: BorderSide(color: cs.outline, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: loading ? null : onPressed,
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                disabledBackgroundColor: cs.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              child: loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A 36×36 tinted icon "swatch" used as the leading slot in picker rows.
class KuberLeadingSwatch extends StatelessWidget {
  final Color color;
  final IconData icon;
  final bool empty;
  const KuberLeadingSwatch({
    super.key,
    required this.color,
    required this.icon,
    this.empty = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (empty) {
      return Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: cs.outline,
            style: BorderStyle.solid,
          ),
        ),
        child: Center(
          child: Icon(icon, size: 16, color: cs.onSurfaceVariant),
        ),
      );
    }
    final swatchColor = color;
    return Container(
      decoration: BoxDecoration(
        color: swatchColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Center(
        child: Icon(icon, size: 18, color: swatchColor),
      ),
    );
  }
}

/// Warning callout (amber). Used by Ledger's duplicate-person warning.
class KuberCallout extends StatelessWidget {
  final Widget child;
  const KuberCallout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Vault `warning` token isn't a ColorScheme role today. Read from
    // `context.kuberColors.warning` if your codebase has that extension;
    // otherwise the lightweight fallback below is theme-aware.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final warning = isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: warning.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 10),
            child: Icon(Icons.error_outline_rounded, size: 16, color: warning),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

extension FocusDismissibleFuture<T> on Future<T> {
  Future<T> unfocusOnComplete(BuildContext context) {
    return then((value) {
      Future.delayed(const Duration(milliseconds: 120), () {
        if (context.mounted) {
          FocusScope.of(context).unfocus();
        }
      });
      return value;
    });
  }
}

