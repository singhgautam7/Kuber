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

import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'app_button.dart';
import 'app_icon_button.dart';
import '../../core/utils/color_harmonizer.dart';
import 'package:flutter/services.dart';

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
    this.topGap = KuberSpace.xl,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accent = cs.onSurfaceVariant;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: sectionHeaderStyle(context),
                    ),
                    if (sublabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        sublabel!,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall!
                            .copyWith(color: accent),
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
          if (i > 0) const SizedBox(height: KuberSpace.md),
          children[i],
        ],
      ],
    );

    final wrapped = tinted
        ? Container(
            padding: const EdgeInsets.all(KuberSpace.cardPadding),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: KuberShape.cardR,
              border: Border.all(color: cs.outlineVariant),
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
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ]
              : null,
          style: Theme.of(context)
              .textTheme
              .bodySmall!
              .copyWith(color: cs.onSurfaceVariant),
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
///   • HeroAmountTone.income  — context.kuberMoney.income (green)
///   • HeroAmountTone.expense — context.kuberMoney.expense (red)
class KuberHeroAmountInput extends StatelessWidget {
  final String label;
  final String currencySymbol;
  final TextEditingController controller;
  final HeroAmountTone tone;
  final VoidCallback? onCalculatorTap;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;

  /// True (default): the form's hero amount, headlineMedium value (board
  /// 3.19). False: a regular filled field with a titleMedium value (account
  /// balance, board 3.15).
  final bool large;

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
    this.large = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueColor = switch (tone) {
      HeroAmountTone.income => context.kuberMoney.income,
      HeroAmountTone.expense => context.kuberMoney.expense,
      HeroAmountTone.neutral => cs.onSurface,
    };

    final tt = Theme.of(context).textTheme;
    final valueStyle = large ? tt.headlineMedium! : tt.titleMedium!;
    final symbolStyle = large ? tt.titleLarge! : tt.titleMedium!;
    // A filled field (surfaceContainerHigh, r16), label inside at the top,
    // optional calculator on the right.
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: EdgeInsets.fromLTRB(
          16, large ? 14 : 8, onCalculatorTap != null ? 4 : 16, large ? 14 : 8),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.largeR,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(currencySymbol,
                        style: symbolStyle.copyWith(
                            color: large ? cs.onSurfaceVariant : valueColor)),
                    SizedBox(width: large ? 6 : 2),
                    Expanded(
                      child: TextField(
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: onChanged,
                        onTapOutside: (_) =>
                            FocusManager.instance.primaryFocus?.unfocus(),
                        inputFormatters: inputFormatters,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: valueStyle.copyWith(color: valueColor),
                        decoration: InputDecoration(
                          hintText: '0',
                          hintStyle:
                              valueStyle.copyWith(color: cs.onSurfaceVariant),
                          filled: false,
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
                  ],
                ),
              ],
            ),
          ),
          if (onCalculatorTap != null)
            AppIconButton(
              icon: Icons.calculate_outlined,
              kind: AppIconButtonKind.plain,
              semanticLabel: 'Calculator',
              onPressed: onCalculatorTap,
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Navigation row (screens/add-transaction.md "grouped navigation rows"):
    // a 72 row on a surfaceContainer card, 40 leading, value as titleMedium
    // with the label under it.
    return Material(
      color: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          FocusScope.of(context).unfocus();
          onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: KuberSpace.listItem2),
          padding: const EdgeInsets.fromLTRB(16, 8, 12, 8),
          child: Row(
            children: [
              SizedBox(width: 40, height: 40, child: leading),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: valueIsPlaceholder
                            ? cs.onSurfaceVariant
                            : cs.onSurface,
                      ),
                    ),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium!
                          .copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (clearable && onClear != null)
                AppIconButton(
                  icon: Icons.cancel_rounded,
                  kind: AppIconButtonKind.plain,
                  semanticLabel: 'Clear',
                  onPressed: onClear,
                )
              else
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
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
  final bool enabled;

  const KuberSwitchRow({
    super.key,
    required this.icon,
    required this.name,
    required this.sub,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Board 3.15: a card row with title + supporting text and the switch;
    // no leading icon. [icon] is kept for API compatibility.
    final rowBody = Ink(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: tt.titleMedium!.copyWith(color: cs.onSurface)),
                Text(sub,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: KuberSpace.md),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );

    return Opacity(
      opacity: enabled ? 1.0 : 0.38,
      child: IgnorePointer(
        ignoring: !enabled,
        child: InkWell(
          onTap: () => onChanged(!value),
          borderRadius: KuberShape.cardR,
          child: rowBody,
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
          height: 40,
          decoration: const BoxDecoration(borderRadius: KuberShape.fullR),
          foregroundDecoration: BoxDecoration(
            borderRadius: KuberShape.fullR,
            border: Border.all(color: cs.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              for (var i = 0; i < segments.length; i++)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      border: i == 0
                          ? null
                          : Border(left: BorderSide(color: cs.outline)),
                    ),
                    child: _SegmentButton(
                      segment: segments[i],
                      selected: segments[i].value == groupValue,
                      onTap: () => onChanged(segments[i].value),
                    ),
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
    final (Color bg, Color fg) = switch (segment.tone) {
      SegmentTone.income => (
          context.kuberMoney.incomeContainer,
          context.kuberMoney.onIncomeContainer
        ),
      SegmentTone.expense => (
          context.kuberMoney.expenseContainer,
          context.kuberMoney.onExpenseContainer
        ),
      SegmentTone.neutral => (cs.secondaryContainer, cs.onSecondaryContainer),
    };
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          color: selected ? bg : Colors.transparent,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected || segment.icon != null) ...[
                Icon(
                  selected ? Icons.check_rounded : segment.icon,
                  size: 18,
                  color: selected ? fg : cs.onSurface,
                ),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  segment.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                    color: selected ? fg : cs.onSurface,
                  ),
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
            borderRadius: BorderRadius.circular(KuberShape.medium),
            child: Ink(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              decoration: BoxDecoration(
                color: isSelected ? cs.secondaryContainer : cs.surfaceContainer,
                borderRadius: KuberShape.largeR,
                border: Border.all(
                  color: isSelected ? cs.secondaryContainer : cs.outlineVariant,
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
                      color: isSelected
                          ? cs.onSecondaryContainer
                          : cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    opt.label,
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: isSelected
                            ? cs.onSecondaryContainer
                            : cs.onSurfaceVariant),
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
            customBorder: const CircleBorder(),
            child: Ink(
              decoration: BoxDecoration(
                color: isSelected ? cs.primary : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: isSelected ? cs.onPrimary : cs.onSurface,
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
        color: cs.secondaryContainer,
        borderRadius: KuberShape.cardR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(labelIcon, size: 16, color: cs.onSecondaryContainer),
              const SizedBox(width: 6),
              Text(
                labelText.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      letterSpacing: 0.8,
                      color: cs.onSecondaryContainer,
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
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: cs.onSecondaryContainer),
              ),
              const Spacer(),
              Text(
                unitText,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: cs.onSecondaryContainer),
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
                    color: cs.onSecondaryContainer.withValues(alpha: 0.16),
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
                            style: Theme.of(context).textTheme.labelSmall!.copyWith(
                                  letterSpacing: 0.8,
                                  color: cs.onSecondaryContainer,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            meta[i].value,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(color: cs.onSecondaryContainer),
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
    // Pinned save (board 3.15): 1dp divider, stadium 56 primary button.
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: AppButton(
            label: label,
            type: AppButtonType.primary,
            fullWidth: true,
            isLoading: loading,
            onPressed: loading ? null : onPressed,
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
    final tones = empty ? null : categoryTones(context, color);
    return Container(
      decoration: BoxDecoration(
        color: tones?.container ?? cs.surfaceContainerHigh,
        borderRadius: KuberShape.mediumR,
      ),
      child: Center(
        child: Icon(icon,
            size: 20, color: tones?.fg ?? cs.onSurfaceVariant),
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
    final m = context.kuberMoney;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: m.warningContainer,
        borderRadius: KuberShape.largeR,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1, right: 10),
            child: Icon(Icons.error_outline_rounded,
                size: 20, color: m.onWarningContainer),
          ),
          Expanded(
            child: DefaultTextStyle.merge(
              style: TextStyle(color: m.onWarningContainer),
              child: child,
            ),
          ),
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
