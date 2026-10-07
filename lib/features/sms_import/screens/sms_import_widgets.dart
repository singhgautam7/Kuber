import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/locale_font.dart' show monoFont;
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/sms_transaction.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/date_formatter.dart';

/// Signed, currency-formatted amount string (e.g. "-₹648.50", "+₹65,000").
String signedAmount(WidgetRef ref, double amount, String type) {
  final formatter = ref.watch(formatterProvider);
  final symbol = ref.watch(currencyProvider).symbol;
  final body = formatter.formatCurrency(amount, symbol: symbol);
  return type == 'income' ? '+$body' : '−$body';
}

/// Filled type circle (board 3.9a): income / expense container with the
/// arrow in its on-container colour. 40 by default.
class SmsTypeGlyph extends StatelessWidget {
  final String type; // 'expense' | 'income'
  final double size;

  const SmsTypeGlyph({super.key, required this.type, this.size = 40});

  @override
  Widget build(BuildContext context) {
    final isIncome = type == 'income';
    final m = context.kuberMoney;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isIncome ? m.incomeContainer : m.expenseContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isIncome ? Icons.south_west_rounded : Icons.north_east_rounded,
        color: isIncome ? m.onIncomeContainer : m.onExpenseContainer,
        size: size * 0.5,
      ),
    );
  }
}

/// Mini chip on an import row (account / category), 24 high, r8,
/// surfaceContainerHigh; `dashed` is the "+ Pick account" placeholder.
class SmsChip extends StatelessWidget {
  final String label;
  final Color? dotColor;
  final IconData? icon;
  final bool dashed;
  final bool accent;

  /// Icon tint (account / category colour, re-toned by the caller).
  final Color? customColor;

  const SmsChip({
    super.key,
    required this.label,
    this.dotColor,
    this.icon,
    this.dashed = false,
    this.accent = false,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = dashed ? cs.onSurfaceVariant : cs.onSurface;
    final iconColor = dashed
        ? cs.onSurfaceVariant
        : (customColor ?? (accent ? cs.primary : cs.onSurfaceVariant));

    final inner = Container(
      height: 24,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: dashed ? Colors.transparent : cs.surfaceContainerHigh,
        borderRadius: KuberShape.smallR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dashed)
            Icon(Icons.add_rounded, size: 14, color: iconColor)
          else if (icon != null)
            Icon(icon, size: 14, color: iconColor)
          else if (dotColor != null)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          if (dashed || icon != null || dotColor != null)
            const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium!.copyWith(color: fg)),
        ],
      ),
    );

    if (dashed) {
      return CustomPaint(
        foregroundPainter: _DashedRectPainter(color: cs.outline),
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
      const Radius.circular(KuberShape.small),
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

/// One import row inside a day group (board 3.9a): type circle (a check
/// circle in selection mode), merchant + signed amount, account / category
/// mini chips, relative time · sender in mono.
class SmsImportCard extends ConsumerWidget {
  final SmsTransaction sms;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final bool selected;
  final bool selectionMode;
  final bool muted; // reviewed rows below the separator

  const SmsImportCard({
    super.key,
    required this.sms,
    required this.onTap,
    this.onLongPress,
    this.selected = false,
    this.selectionMode = false,
    this.muted = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final m = context.kuberMoney;
    final isIncome = sms.parsedType == 'income';

    final accounts = ref.watch(accountMapProvider).valueOrNull;
    final categories = ref.watch(categoryMapProvider).valueOrNull;

    final accId = int.tryParse(sms.suggestedAccountId ?? '');
    final account = accId == null ? null : accounts?[accId];
    final catId = int.tryParse(sms.suggestedCategoryId ?? '');
    final category = catId == null ? null : categories?[catId];

    final Widget leading;
    if (selectionMode) {
      leading = Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? cs.primary : Colors.transparent,
          border: selected ? null : Border.all(color: cs.outline, width: 2),
        ),
        child: selected
            ? Icon(Icons.check_rounded, size: 22, color: cs.onPrimary)
            : null,
      );
    } else {
      leading = SmsTypeGlyph(type: sms.parsedType);
    }

    final titleColor = selected ? cs.onSecondaryContainer : cs.onSurface;
    final subColor = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;

    final row = Material(
      color: selected ? cs.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              leading,
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sms.parsedMerchant ?? sms.senderId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium!.copyWith(
                              color: titleColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          signedAmount(ref, sms.parsedAmount, sms.parsedType),
                          style: theme.textTheme.titleMedium!.copyWith(
                            color: isIncome ? m.income : m.expense,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        SmsChip(
                          label: account?.name ?? 'Pick account',
                          icon: account != null
                              ? resolveAccountIcon(account)
                              : null,
                          dashed: account == null,
                          customColor: account != null
                              ? categoryTones(
                                  context,
                                  resolveAccountColor(account),
                                ).fg
                              : null,
                        ),
                        if (category != null)
                          SmsChip(
                            label: category.name,
                            icon: IconMapper.fromString(category.icon),
                            customColor: categoryTones(
                              context,
                              Color(category.colorValue),
                            ).fg,
                          )
                        else
                          const SmsChip(label: 'Pick category', dashed: true),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                '${DateFormatter.relativeSmsDate(sms.smsDate)}  ·  ',
                          ),
                          TextSpan(
                            text: sms.senderId,
                            style: monoFont(fontSize: 11, color: subColor),
                          ),
                        ],
                      ),
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: subColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return muted ? Opacity(opacity: 0.55, child: row) : row;
  }
}
