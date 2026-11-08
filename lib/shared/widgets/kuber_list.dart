import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_button.dart';

/// Section header (components/cards-lists.md): labelMedium caps, 0.8 tracking,
/// onSurfaceVariant, 8 above the content, optional trailing slot.
///
/// Adapted from Mull `shared/widgets/section_header.dart`.
class KuberSectionHeader extends StatelessWidget {
  final String title;

  /// Trailing slot, e.g. [KuberSectionAction] or a bodySmall note.
  final Widget? trailing;

  /// Inline widgets after the title (help glyph, Beta pill).
  final List<Widget> inline;
  final VoidCallback? onTitleTap;
  final EdgeInsetsGeometry padding;

  const KuberSectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.inline = const [],
    this.onTitleTap,
    this.padding = const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Widget head = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium!.copyWith(
              letterSpacing: 0.8,
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        for (final w in inline) ...[const SizedBox(width: 6), w],
      ],
    );
    if (onTitleTap != null) {
      head = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTitleTap,
        child: head,
      );
    }
    return Padding(
      padding: padding,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 24),
        child: Row(
          children: [
            Expanded(
              child: Align(alignment: Alignment.centerLeft, child: head),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// The trailing labelLarge primary text action of a section header
/// ("View all", "Full screen", "Edit").
class KuberSectionAction extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const KuberSectionAction({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          label,
          style: theme.textTheme.labelLarge!.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Card: surfaceContainer, 1dp outlineVariant, radius 20, padding 16 (hero 20).
class KuberCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool hero;
  final Color? color;
  final Color? borderColor;
  final VoidCallback? onTap;

  const KuberCard({
    super.key,
    required this.child,
    this.padding,
    this.hero = false,
    this.color,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pad =
        padding ??
        EdgeInsets.all(
          hero ? KuberSpace.cardPaddingHero : KuberSpace.cardPadding,
        );
    final shape = RoundedRectangleBorder(
      borderRadius: KuberShape.cardR,
      side: BorderSide(color: borderColor ?? cs.outlineVariant),
    );
    if (onTap == null) {
      return DecoratedBox(
        decoration: ShapeDecoration(
          color: color ?? cs.surfaceContainer,
          shape: shape,
        ),
        child: Padding(padding: pad, child: child),
      );
    }
    return Material(
      color: color ?? cs.surfaceContainer,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: pad, child: child),
      ),
    );
  }
}

/// Grouped list: one card, rows divided by 1dp outlineVariant (grouping over
/// boxing).
class KuberGroup extends StatelessWidget {
  final List<Widget> children;

  /// Left inset of the dividers.
  final double dividerInset;
  final Color? color;

  const KuberGroup({
    super.key,
    required this.children,
    this.dividerInset = 0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: color ?? cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.cardR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: dividerInset,
                color: cs.outlineVariant,
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// List row (2g): min 56 / 72 / 88, padding 16 / 8, leading 24 icon or 40
/// tile, gap 16, titleMedium + bodyMedium, trailing slot.
class KuberListRow extends StatelessWidget {
  final Widget? leading;
  final String title;
  final Widget? titleTrailing;
  final String? subtitle;
  final Widget? below;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool dense;
  final bool destructive;
  final double? minHeight;
  final int titleLines;
  final int subtitleLines;

  /// e.g. line-through for completed items.
  final TextDecoration? titleDecoration;

  const KuberListRow({
    super.key,
    required this.title,
    this.leading,
    this.titleTrailing,
    this.subtitle,
    this.below,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
    this.dense = false,
    this.destructive = false,
    this.minHeight,
    this.titleLines = 1,
    this.subtitleLines = 1,
    this.titleDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final titleColor = selected
        ? cs.onSecondaryContainer
        : (destructive ? cs.error : cs.onSurface);
    final subColor = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    final h =
        minHeight ??
        (subtitle == null
            ? KuberSpace.listItem1
            : (below == null ? KuberSpace.listItem2 : KuberSpace.listItem3));

    final content = Container(
      constraints: BoxConstraints(minHeight: h),
      color: selected ? cs.secondaryContainer : null,
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpace.listRowPadH,
        vertical: KuberSpace.listRowPadV,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: KuberSpace.lg),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        maxLines: titleLines,
                        overflow: TextOverflow.ellipsis,
                        style:
                            (dense
                                    ? theme.textTheme.titleSmall
                                    : theme.textTheme.titleMedium)!
                                .copyWith(
                                  color: titleColor,
                                  decoration: titleDecoration,
                                ),
                      ),
                    ),
                    if (titleTrailing != null) ...[
                      const SizedBox(width: KuberSpace.sm),
                      titleTrailing!,
                    ],
                  ],
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: subtitleLines,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: subColor,
                    ),
                  ),
                ?below,
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: KuberSpace.md),
            trailing!,
          ],
        ],
      ),
    );
    if (onTap == null && onLongPress == null) return content;
    return InkWell(onTap: onTap, onLongPress: onLongPress, child: content);
  }
}

/// Trailing chevron (20, onSurfaceVariant).
class KuberChevron extends StatelessWidget {
  const KuberChevron({super.key});

  @override
  Widget build(BuildContext context) => Icon(
    Icons.chevron_right_rounded,
    size: 20,
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  );
}

/// Pressed layer of rows and cards (handoff v4): onSurface 10%.
WidgetStateProperty<Color?> kuberPressedLayer(ColorScheme cs) =>
    WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.pressed) ? cs.onSurface.withValues(alpha: 0.1) : null,
    );

/// A row that opens a group of settings (Components 2m): 72 min, tonal tile,
/// title, one line of live values, chevron.
class KuberGroupRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const KuberGroupRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      overlayColor: kuberPressedLayer(cs),
      child: Container(
        constraints: const BoxConstraints(minHeight: KuberSpace.listItem2),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.lg,
          vertical: KuberSpace.md,
        ),
        child: Row(
          children: [
            KuberIconTile(icon: icon, glyph: 22),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium!.copyWith(color: cs.onSurface)),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.lg),
            const KuberChevron(),
          ],
        ),
      ),
    );
  }
}

/// A state that needs acting on (Components 2m): errorContainer, message, one
/// action.
class KuberStatusBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  const KuberStatusBanner({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(color: cs.errorContainer, borderRadius: KuberShape.cardR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: cs.onErrorContainer),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleSmall!.copyWith(color: cs.onErrorContainer)),
                    Text(body, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onErrorContainer)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: AppButton(
              label: actionLabel,
              type: AppButtonType.danger,
              filled: true,
              height: 40,
              onPressed: onAction,
            ),
          ),
        ],
      ),
    );
  }
}

/// A quiet note: 16 icon and bodySmall, on the page's own edge.
class KuberInfoLine extends StatelessWidget {
  final IconData icon;
  final String text;
  final EdgeInsetsGeometry padding;

  const KuberInfoLine({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.padding = const EdgeInsets.symmetric(horizontal: KuberSpace.xs),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: KuberSpace.sm),
          Expanded(
            child: Text(text, style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

/// Container role pairs for icon tiles and pills.
enum KuberTone { secondary, primary, neutral, error, warning, income, expense }

(Color, Color) kuberToneColors(BuildContext context, KuberTone tone) {
  final cs = Theme.of(context).colorScheme;
  final m = context.kuberMoney;
  return switch (tone) {
    KuberTone.secondary => (cs.secondaryContainer, cs.onSecondaryContainer),
    KuberTone.primary => (cs.primaryContainer, cs.onPrimaryContainer),
    KuberTone.neutral => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    KuberTone.error => (cs.errorContainer, cs.onErrorContainer),
    KuberTone.warning => (m.warningContainer, m.onWarningContainer),
    KuberTone.income => (m.incomeContainer, m.onIncomeContainer),
    KuberTone.expense => (m.expenseContainer, m.onExpenseContainer),
  };
}

/// 40dp icon tile, radius 12, container role + glyph 20.
class KuberIconTile extends StatelessWidget {
  final IconData icon;
  final KuberTone tone;
  final double size;
  final double? glyph;
  final bool circle;

  /// Corner radius when not [circle]; default 12.
  final double? radius;

  /// Colours outside the tone pairs (the path sheet's current page).
  final Color? color;
  final Color? iconColor;

  const KuberIconTile({
    super.key,
    required this.icon,
    this.tone = KuberTone.secondary,
    this.size = 40,
    this.glyph,
    this.circle = false,
    this.radius,
    this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = kuberToneColors(context, tone);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color ?? bg,
        borderRadius: circle
            ? KuberShape.fullR
            : radius == null
                ? KuberShape.mediumR
                : BorderRadius.circular(radius!),
      ),
      child: Icon(icon, size: glyph ?? size / 2, color: iconColor ?? fg),
    );
  }
}

/// Status pill: labelMedium, radius full, padding 2 / 8.
class KuberPill extends StatelessWidget {
  final String label;
  final KuberTone tone;
  const KuberPill({
    super.key,
    required this.label,
    this.tone = KuberTone.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = kuberToneColors(context, tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: KuberShape.fullR),
      child: Text(
        label,
        maxLines: 1,
        style: Theme.of(context).textTheme.labelMedium!.copyWith(color: fg),
      ),
    );
  }
}

/// Splits a trailing "(Beta)"-style tag off a label ("Ask Kuber (Beta)" ->
/// ("Ask Kuber", "Beta")), so the tag renders as a [KuberPill] instead of
/// brackets. Works for translated tags ("(बीटा)") since it keys on the
/// parentheses, not the word.
(String, String?) splitTrailingTag(String label) {
  final m = RegExp(r'^(.*\S)\s*\(([^()]+)\)\s*$').firstMatch(label);
  if (m == null) return (label, null);
  final tag = m.group(2)!;
  // Sentence-case all-caps tags ("BETA" -> "Beta"); leave other scripts alone.
  final pretty = tag == tag.toUpperCase() && tag != tag.toLowerCase()
      ? tag[0] + tag.substring(1).toLowerCase()
      : tag;
  return (m.group(1)!, pretty);
}
