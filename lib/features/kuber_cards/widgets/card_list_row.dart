import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/card_palette.dart';
import '../../../core/utils/locale_font.dart';
import '../data/stored_card.dart';
import 'card_icon.dart';

/// Compact list-view row for a stored card. A 28px colour chip (a mini of the
/// card background) with the bank glyph, the nickname, the masked last 4, and a
/// chevron. Rows sit inside one bordered container, divided like `InfoTable`.
/// See `cards-home.md` list view.
class CardListRow extends StatelessWidget {
  final StoredCard card;
  final bool locked;
  final bool isFirst;
  final bool isLast;
  final VoidCallback onTap;

  const CardListRow({
    super.key,
    required this.card,
    required this.onTap,
    this.locked = false,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onChip =
        CardPalette.onCardColor(colorValue: card.colorValue, isGradient: card.isGradient);

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(
          left: BorderSide(color: cs.outline),
          right: BorderSide(color: cs.outline),
          top: isFirst ? BorderSide(color: cs.outline) : BorderSide.none,
          bottom: BorderSide(
              color: isLast ? cs.outline : cs.outline.withValues(alpha: 0.6)),
        ),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(KuberRadius.md) : Radius.zero,
          bottom: isLast ? const Radius.circular(KuberRadius.md) : Radius.zero,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.vertical(
            top: isFirst ? const Radius.circular(KuberRadius.md) : Radius.zero,
            bottom: isLast ? const Radius.circular(KuberRadius.md) : Radius.zero,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _chip(onChip),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    locked ? 'Locked card' : card.nickname,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: locked ? cs.onSurfaceVariant : cs.onSurface,
                    ),
                  ),
                ),
                if (!locked && (card.last4 ?? '').isNotEmpty) ...[
                  Text(
                    '•••• ${card.last4}',
                    style: localeFont(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: cs.onSurfaceVariant,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Icon(
                  locked ? Icons.lock_rounded : Icons.chevron_right_rounded,
                  size: 20,
                  color: locked ? cs.primary : cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _chip(Color onChip) {
    final decoration = card.isGradient
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                CardPalette.gradientColors(card.colorValue).$1,
                CardPalette.gradientColors(card.colorValue).$2,
              ],
            ),
            borderRadius: BorderRadius.circular(KuberRadius.sm),
          )
        : BoxDecoration(
            color: Color(card.colorValue),
            borderRadius: BorderRadius.circular(KuberRadius.sm),
          );
    return Container(
      width: 28,
      height: 28,
      decoration: decoration,
      alignment: Alignment.center,
      child: CardIcon(iconKey: card.bankIcon, size: 16, color: onChip),
    );
  }
}
