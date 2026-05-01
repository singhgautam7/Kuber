import 'package:flutter/material.dart';
import '../../core/models/info_config.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_info_bottom_sheet.dart';

class KuberHomeWidgetTitle extends StatelessWidget {
  final String title;
  final KuberInfoConfig? infoConfig;
  final Widget? trailing;

  const KuberHomeWidgetTitle({
    super.key,
    required this.title,
    this.infoConfig,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: infoConfig != null ? () => KuberInfoBottomSheet.show(context, infoConfig!) : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: cs.onSurface,
                  ),
                ),
                if (infoConfig != null) ...[
                  const SizedBox(width: KuberSpacing.sm),
                  Icon(
                    Icons.help_outline_rounded,
                    size: 14,
                    color: cs.onSurface.withValues(alpha: 0.5),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const Spacer(),
            trailing!,
          ],
        ],
      ),
    );
  }
}
