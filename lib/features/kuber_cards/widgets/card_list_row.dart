import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/card_palette.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../data/stored_card.dart';
import 'card_icon.dart';

/// List-view row for a stored card (board 3.24): a mini card face in the
/// card colour with the bank glyph, nickname, "Credit · VISA · •••• 4321",
/// chevron. Lives inside a [KuberGroup].
class CardListRow extends StatelessWidget {
  final StoredCard card;
  final bool locked;
  final VoidCallback onTap;

  const CardListRow({
    super.key,
    required this.card,
    required this.onTap,
    this.locked = false,
  });

  static String _cap(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final onChip = CardPalette.onCardColor(
      colorValue: card.colorValue,
      isGradient: card.isGradient,
    );
    final subtitle = [
      if ((card.cardType ?? '').isNotEmpty) _cap(card.cardType!),
      if ((card.network ?? '').isNotEmpty) card.network!.toUpperCase(),
      if ((card.last4 ?? '').isNotEmpty) '•••• ${card.last4}',
    ].join(' · ');

    return KuberListRow(
      onTap: onTap,
      leading: _chip(onChip),
      title: locked ? 'Locked card' : card.nickname,
      subtitle: locked || subtitle.isEmpty ? null : subtitle,
      trailing: locked
          ? Icon(Icons.lock_rounded, size: 20, color: cs.primary)
          : const KuberChevron(),
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
            borderRadius: KuberShape.smallR,
          )
        : BoxDecoration(
            color: Color(card.colorValue),
            borderRadius: KuberShape.smallR,
          );
    return Container(
      width: 40,
      height: 28,
      decoration: decoration,
      alignment: Alignment.center,
      child: CardIcon(iconKey: card.bankIcon, size: 16, color: onChip),
    );
  }
}
