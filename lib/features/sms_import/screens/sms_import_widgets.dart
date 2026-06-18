import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/sms_transaction.dart';

/// Signed, currency-formatted amount string (e.g. "-₹648.50", "+₹65,000").
String signedAmount(WidgetRef ref, double amount, String type) {
  final formatter = ref.watch(formatterProvider);
  final symbol = ref.watch(currencyProvider).symbol;
  final body = formatter.formatCurrency(amount, symbol: symbol);
  return type == 'income' ? '+$body' : '−$body';
}

/// 36dp rounded square with a debit/credit arrow tinted by type.
class SmsTypeGlyph extends StatelessWidget {
  final String type; // 'expense' | 'income'
  final double size;

  const SmsTypeGlyph({super.key, required this.type, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = type == 'income';
    final color = isIncome ? cs.tertiary : cs.error;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.30)),
      ),
      child: Icon(
        isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
        color: color,
        size: size * 0.5,
      ),
    );
  }
}

/// A single chip used on import cards (account / category / "pick category").
class SmsChip extends StatelessWidget {
  final String label;
  final Color? dotColor; // shown as a small square (category)
  final IconData? icon; // shown leading (account card icon)
  final bool dashed; // empty "pick category" placeholder
  final bool accent; // primary-tinted (category)

  const SmsChip({
    super.key,
    required this.label,
    this.dotColor,
    this.icon,
    this.dashed = false,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final Color bg;
    final Color border;
    final Color fg;
    if (dashed) {
      bg = Colors.transparent;
      border = cs.onSurfaceVariant.withValues(alpha: 0.5);
      fg = cs.onSurfaceVariant;
    } else if (accent) {
      bg = cs.primary.withValues(alpha: 0.10);
      border = cs.primary.withValues(alpha: 0.25);
      fg = cs.primary;
    } else {
      bg = cs.surfaceContainerHigh;
      border = cs.outline;
      fg = cs.onSurface;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
        ],
        if (dotColor != null) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
        ],
        if (dashed) ...[
          Icon(Icons.add_rounded, size: 10, color: fg),
          const SizedBox(width: 4),
        ],
        Text(
          label,
          style: localeFont(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: fg,
          ),
        ),
      ],
    );

    final inner = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: dashed ? null : Border.all(color: border),
      ),
      child: content,
    );

    // Dashed placeholder ("Pick category") gets a painted dashed border.
    if (dashed) {
      return CustomPaint(
        foregroundPainter: _DashedRectPainter(color: border),
        child: inner,
      );
    }
    return inner;
  }
}

class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1, size.height - 1),
      const Radius.circular(KuberRadius.sm),
    );
    final path = Path()..addRRect(rrect);
    const dash = 3.0, gap = 2.5;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        final n = (d + dash).clamp(0, m.length).toDouble();
        canvas.drawPath(m.extractPath(d, n), paint);
        d = n + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRectPainter old) => old.color != color;
}

/// Option A import card (Section 03). Glyph + merchant + amount on the first
/// row, account / category chips on the second, date + sender at the foot.
class SmsImportCard extends ConsumerWidget {
  final SmsTransaction sms;
  final VoidCallback onTap;
  final bool selected;
  final bool selectionMode;
  final bool muted; // reviewed rows below the separator

  const SmsImportCard({
    super.key,
    required this.sms,
    required this.onTap,
    this.selected = false,
    this.selectionMode = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isIncome = sms.parsedType == 'income';
    final amountColor = isIncome ? cs.tertiary : cs.error;

    final accounts = ref.watch(accountMapProvider).valueOrNull;
    final categories = ref.watch(categoryMapProvider).valueOrNull;

    String? accountName;
    final accId = int.tryParse(sms.suggestedAccountId ?? '');
    if (accId != null) accountName = accounts?[accId]?.name;

    String? categoryName;
    Color? categoryColor;
    final catId = int.tryParse(sms.suggestedCategoryId ?? '');
    if (catId != null) {
      final cat = categories?[catId];
      if (cat != null) {
        categoryName = cat.name;
        categoryColor = harmonizeCategory(context, Color(cat.colorValue));
      }
    }

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: selected
            ? cs.primary.withValues(alpha: 0.12)
            : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: selected
              ? cs.primary.withValues(alpha: 0.4)
              : cs.outline,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectionMode) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 12),
              child: Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                size: 22,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
          ] else ...[
            SmsTypeGlyph(type: sms.parsedType),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        sms.parsedMerchant ?? sms.senderId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: localeFont(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      signedAmount(ref, sms.parsedAmount, sms.parsedType),
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: amountColor,
                      ).copyWith(fontFeatures: const [
                        FontFeature.tabularFigures(),
                      ]),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    SmsChip(
                      label: accountName ?? 'Pick account',
                      icon: Icons.credit_card_rounded,
                      dashed: accountName == null,
                    ),
                    if (categoryName != null)
                      SmsChip(
                        label: categoryName,
                        dotColor: categoryColor,
                        accent: true,
                      )
                    else
                      const SmsChip(label: 'Pick category', dashed: true),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM · h:mm a').format(sms.smsDate),
                      style: localeFont(
                        fontSize: 10.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      sms.senderId,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        color: cs.onSurfaceVariant,
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

    final tappable = InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: card,
    );

    return muted ? Opacity(opacity: 0.55, child: tappable) : tappable;
  }
}
