import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import 'category_donut_chart.dart' show CategorySlice;

class DonutCenterTotal extends ConsumerWidget {
  final List<CategorySlice> slices;
  final bool groupMode;

  const DonutCenterTotal({
    super.key,
    required this.slices,
    required this.groupMode,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final total = slices.fold(0.0, (s, x) => s + x.amount);
    final noun = groupMode ? 'groups' : 'categories';

    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              maskAmount(fmt.formatCurrency(total.round()), isPrivate),
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${slices.length} ${slices.length == 1 ? (groupMode ? 'group' : 'category') : noun}',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class DonutCenterSelected extends ConsumerWidget {
  final CategorySlice slice;
  final double total;

  const DonutCenterSelected({
    super.key,
    required this.slice,
    required this.total,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    return SizedBox(
      width: 120,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            slice.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: localeFont(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: slice.color,
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              maskAmount(fmt.formatCurrency(slice.amount.round()), isPrivate),
              style: Theme.of(
                context,
              ).textTheme.titleLarge!.copyWith(color: cs.onSurface),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${fmt.formatPercentage(slice.percentage)} of '
              '${maskAmount(fmt.formatCurrency(total.round()), isPrivate)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class DonutTopRow extends ConsumerWidget {
  final CategorySlice slice;
  final bool dimmed;
  final bool highlighted;
  final VoidCallback onTap;

  const DonutTopRow({
    super.key,
    required this.slice,
    required this.dimmed,
    required this.highlighted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Opacity(
        opacity: dimmed ? KuberChartTheme.unselectedAlpha : 1,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: const EdgeInsets.symmetric(horizontal: KuberSpace.sm),
          color: highlighted
              ? cs.onSurface.withValues(alpha: 0.05)
              : Colors.transparent,
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: slice.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Text(
                  slice.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.bodyMedium!.copyWith(
                    color: cs.onSurface,
                    fontWeight: highlighted ? FontWeight.w600 : null,
                  ),
                ),
              ),
              Text(
                fmt.formatPercentage(slice.percentage),
                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: KuberSpace.md),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 70),
                child: Text(
                  maskAmount(
                    fmt.formatCurrency(slice.amount.round()),
                    isPrivate,
                  ),
                  textAlign: TextAlign.right,
                  style: tt.titleSmall!.copyWith(color: cs.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DonutEmptyState extends StatelessWidget {
  final ColorScheme cs;

  const DonutEmptyState({super.key, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            SizedBox(
              width: 130,
              height: 130,
              child: CustomPaint(
                painter: DonutEmptyRingPainter(color: cs.surfaceContainerHigh),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'No spending yet',
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Add a transaction to see your category breakdown here.',
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 12,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DonutEmptyRingPainter extends CustomPainter {
  final Color color;

  const DonutEmptyRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 19;
    canvas.drawCircle(
      size.center(Offset.zero),
      (size.shortestSide - 19) / 2,
      paint,
    );
  }

  @override
  bool shouldRepaint(DonutEmptyRingPainter oldDelegate) =>
      color != oldDelegate.color;
}
