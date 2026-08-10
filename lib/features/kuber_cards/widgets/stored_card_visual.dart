import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/card_palette.dart';
import '../../../core/utils/locale_font.dart';
import 'card_icon.dart';
import 'card_network_glyph.dart';

/// The signature Kuber Cards surface: a realistic-proportioned card carrying the
/// user's chosen background (solid or gradient), a fixed metallic sheen, the bank
/// glyph, nickname, masked last 4, and an abstracted network mark.
///
/// One widget, size-driven by the enclosing width (the caller wraps it in the
/// right layout). Aspect ratio is fixed at 1.586:1 (ISO/IEC 7810 ID-1).
/// See `tokens-and-visual-spec.md`.
class StoredCardVisual extends StatelessWidget {
  final String nickname;
  final String? last4;
  final String? bankIcon;
  final String? network;
  final int colorValue;
  final bool isGradient;

  /// Fully revealed number to render instead of the masked form (detail sheet
  /// "Show details" state). Null keeps the masked `•••• •••• •••• 1234`.
  final String? revealedNumber;

  /// Cardholder + expiry shown along the bottom (detail-sheet hero only).
  final String? cardholder;
  final String? expiry;
  final bool showBottomRow;

  const StoredCardVisual({
    super.key,
    required this.nickname,
    required this.last4,
    required this.bankIcon,
    required this.network,
    required this.colorValue,
    required this.isGradient,
    this.revealedNumber,
    this.cardholder,
    this.expiry,
    this.showBottomRow = false,
  });

  @override
  Widget build(BuildContext context) {
    final onCard =
        CardPalette.onCardColor(colorValue: colorValue, isGradient: isGradient);

    return AspectRatio(
      aspectRatio: 1.586,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          // Scale paddings/typography off the card width so all sizes read well.
          final pad = w * 0.065;
          final nameSize = (w * 0.052).clamp(15.0, 22.0);
          final numSize = (w * 0.046).clamp(14.0, 19.0);

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(KuberRadius.xl),
              gradient: isGradient
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CardPalette.gradientColors(colorValue).$1,
                        CardPalette.gradientColors(colorValue).$2,
                      ],
                    )
                  : null,
              color: isGradient ? null : Color(colorValue),
            ),
            child: Stack(
              children: [
                // Metallic sheen overlay (fixed, identical in both themes).
                Positioned.fill(child: _MetallicSheen()),
                // Inner stroke for depth (no shadow, per Vault).
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(KuberRadius.xl),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.10),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(pad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _bankTile(onCard, w),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  nickname.isEmpty ? 'New card' : nickname,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: localeFont(
                                    fontSize: nameSize,
                                    fontWeight: FontWeight.w700,
                                    color: onCard,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _maskedNumber(),
                                  style: localeFont(
                                    fontSize: numSize,
                                    fontWeight: FontWeight.w600,
                                    color: onCard.withValues(alpha: 0.85),
                                    fontFeatures: const [
                                      ui.FontFeature.tabularFigures()
                                    ],
                                  ),
                                ),
                                if (showBottomRow) ...[
                                  SizedBox(height: pad * 0.5),
                                  _bottomRow(onCard, w),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: pad * 0.5),
                            child: CardNetworkGlyph(
                              network: network,
                              color: onCard,
                              size: w * 0.11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bankTile(Color onCard, double w) {
    final tile = (w * 0.11).clamp(36.0, 52.0);
    return Container(
      width: tile,
      height: tile,
      decoration: BoxDecoration(
        color: onCard.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      alignment: Alignment.center,
      child: CardIcon(iconKey: bankIcon, size: tile * 0.62, color: onCard),
    );
  }

  Widget _bottomRow(Color onCard, double w) {
    final labelStyle = localeFont(
      fontSize: (w * 0.028).clamp(8.0, 11.0),
      fontWeight: FontWeight.w600,
      letterSpacing: 1,
      color: onCard.withValues(alpha: 0.65),
    );
    final valueStyle = localeFont(
      fontSize: (w * 0.033).clamp(10.0, 13.0),
      fontWeight: FontWeight.w600,
      color: onCard,
    );
    return Row(
      children: [
        if ((cardholder ?? '').isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('CARD HOLDER', style: labelStyle),
                Text(cardholder!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: valueStyle),
              ],
            ),
          ),
        if ((expiry ?? '').isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('EXPIRES', style: labelStyle),
              Text(expiry!, style: valueStyle),
            ],
          ),
      ],
    );
  }

  String _maskedNumber() {
    if (revealedNumber != null && revealedNumber!.isNotEmpty) {
      return _group(revealedNumber!);
    }
    if (last4 != null && last4!.isNotEmpty) {
      return '•••• •••• •••• $last4';
    }
    return '•••• •••• •••• ••••';
  }

  String _group(String raw) {
    final digits = raw.replaceAll(RegExp(r'\s'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    return buf.toString();
  }
}

/// The fixed brushed-metal sheen composited over any fill. Identical in both
/// themes; text sits above it. A static gradient (no controller), so no
/// RepaintBoundary is needed.
class _MetallicSheen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(KuberRadius.xl),
        gradient: const LinearGradient(
          // ~115 degrees.
          begin: Alignment(-0.9, -1),
          end: Alignment(0.9, 1),
          colors: [
            Color(0x4DFFFFFF), // white @ 30%
            Color(0x00FFFFFF), // transparent
            Color(0x29FFFFFF), // white @ 16%
            Color(0x33000000), // black @ 20%
          ],
          stops: [0.0, 0.33, 0.75, 1.0],
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(KuberRadius.xl),
          border: const Border(
            top: BorderSide(color: Color(0x4DFFFFFF)), // crisp top-edge highlight
          ),
        ),
      ),
    );
  }
}
