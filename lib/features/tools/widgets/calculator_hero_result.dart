import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/animated_amount.dart';

/// A single large hero number with a small-caps label. Animates between values
/// via [AnimatedAmount] when [animate] is true and a [numericValue] is given.
class ToolHero extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final double? numericValue;
  final String Function(double)? format;
  final String? sub;

  const ToolHero({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    this.numericValue,
    this.format,
    this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final valueStyle = localeFont(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: color,
      letterSpacing: -1,
      height: 1.1,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: localeFont(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: (numericValue != null && format != null)
              ? AnimatedAmount(
                  value: numericValue!,
                  format: format!,
                  style: valueStyle,
                )
              : Text(value, style: valueStyle),
        ),
        if (sub != null) ...[
          const SizedBox(height: 3),
          Text(
            sub!,
            style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
          ),
        ],
      ],
    );
  }
}

/// One side of a dual hero.
class HeroSide {
  final String label;
  final String value;
  final Color color;
  final String? sub;
  const HeroSide({
    required this.label,
    required this.value,
    required this.color,
    this.sub,
  });
}

/// Two side-by-side hero results with an optional winner/info banner below.
class ToolDualHero extends StatelessWidget {
  final HeroSide left;
  final HeroSide right;
  final String? bannerText;

  /// Tints the banner green for a "winner" message, else primary.
  final bool bannerIsPositive;

  const ToolDualHero({
    super.key,
    required this.left,
    required this.right,
    this.bannerText,
    this.bannerIsPositive = true,
  });

  Widget _side(BuildContext context, HeroSide s) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            s.label.toUpperCase(),
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              s.value,
              style: localeFont(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: s.color,
                letterSpacing: -0.6,
                height: 1.02,
              ),
            ),
          ),
          if (s.sub != null) ...[
            const SizedBox(height: 2),
            Text(
              s.sub!,
              style: localeFont(fontSize: 11.5, color: cs.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bannerColor = bannerIsPositive ? cs.tertiary : cs.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _side(context, left),
            const SizedBox(width: KuberSpacing.md),
            _side(context, right),
          ],
        ),
        if (bannerText != null) ...[
          const SizedBox(height: KuberSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.md,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: bannerColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: bannerColor.withValues(alpha: 0.32)),
            ),
            child: Text(
              bannerText!,
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: bannerColor,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class StatCol {
  final String label;
  final String value;
  final Color? color;
  const StatCol(this.label, this.value, {this.color});
}

/// A 2–3 column stat grid with 1px vertical dividers, on a muted surface.
class ToolStatCols extends StatelessWidget {
  final List<StatCol> items;
  const ToolStatCols({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      // IntrinsicHeight gives the Row a bounded height so the equal-height
      // columns (CrossAxisAlignment.stretch + vertical dividers) don't try to
      // grow to infinity inside the scroll view.
      child: IntrinsicHeight(
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.md,
                  vertical: 11,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    left: i == 0
                        ? BorderSide.none
                        : BorderSide(color: cs.outline),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      items[i].label.toUpperCase(),
                      style: localeFont(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.6,
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 4),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        items[i].value,
                        style: localeFont(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: items[i].color ?? cs.onSurface,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      ),
    );
  }
}
