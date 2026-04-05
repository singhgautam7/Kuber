import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/models/info_config.dart';
import 'kuber_info_bottom_sheet.dart';

class KuberAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBack;
  final double? horizontalPadding;

  const KuberAppBar({
    super.key,
    this.title,
    this.actions,
    this.showBack = false,
    this.horizontalPadding,
    this.infoConfig,
  });

  final KuberInfoConfig? infoConfig;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final currency = ref.watch(currencyProvider);
    final padding = horizontalPadding ?? KuberSpacing.lg;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            children: [
              if (showBack) ...[
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.arrow_back_rounded,
                      color: cs.onSurface, size: 22),
                ),
                const SizedBox(width: 12),
              ],
              if (title == null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      IconMapper.fromCurrencyCode(currency.code),
                      color: cs.primary,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Kuber',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: cs.primary,
                    letterSpacing: -0.3,
                  ),
                ),
              ] else
                Text(
                  title!,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: cs.onSurface,
                    letterSpacing: -0.3,
                  ),
                ),
              const Spacer(),
              if (infoConfig != null) ...[
                IconButton(
                  onPressed: () => KuberInfoBottomSheet.show(context, infoConfig!),
                  icon: const Icon(Icons.help_outline),
                  color: cs.onSurfaceVariant,
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 4),
              ],
              if (actions != null) ...actions!,
            ],
          ),
        ),
      ),
    );
  }
}
