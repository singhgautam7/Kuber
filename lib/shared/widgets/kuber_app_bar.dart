import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    this.showHome = false,
    this.horizontalPadding,
    this.infoConfig,
  });

  final bool showHome;
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
                _AppBarButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onTap: () => Navigator.pop(context),
                  cs: cs,
                ),
                const SizedBox(width: KuberSpacing.sm),
              ],
              if (showHome) ...[
                _AppBarButton(
                  icon: Icons.home_outlined,
                  tooltip: 'Home',
                  onTap: () => context.go('/'),
                  cs: cs,
                ),
                const SizedBox(width: KuberSpacing.sm),
              ],
              if (title == null) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(KuberRadius.md),
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
                _AppBarButton(
                  icon: Icons.help_outline_rounded,
                  tooltip: 'Help',
                  onTap: () => KuberInfoBottomSheet.show(context, infoConfig!),
                  cs: cs,
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

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final ColorScheme cs;

  const _AppBarButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: cs.onSurfaceVariant, size: 18),
        ),
      ),
    );
  }
}
