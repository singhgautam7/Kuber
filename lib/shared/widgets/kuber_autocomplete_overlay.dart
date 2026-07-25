import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/currency_formatter.dart';
import '../../features/settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;

/// Reusable container overlay for autocomplete dropdowns (e.g. Add Transaction,
/// Add Ledger). Caps height to 200px (max 3 visible suggestions per single scroll)
/// and absorbs scroll notifications so scrolling inside the dropdown does not
/// scroll the background form or unfocus the input.
class KuberAutocompleteOverlay<T> extends ConsumerWidget {
  final Iterable<T> options;
  final void Function(T) onSelected;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final Key? overlayKey;

  const KuberAutocompleteOverlay({
    required this.options,
    required this.onSelected,
    required this.itemBuilder,
    this.overlayKey,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: KuberSpacing.xs),
        child: Material(
          key: overlayKey,
          elevation: 8,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          color: cs.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 200,
              maxWidth: MediaQuery.of(context).size.width - 2 * KuberSpacing.lg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KuberRadius.md),
              child: NotificationListener<ScrollNotification>(
                onNotification: (_) => true,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: KuberSpacing.xs,
                  ),
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final item = options.elementAt(index);
                    return InkWell(
                      onTap: () => onSelected(item),
                      child: itemBuilder(context, item),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard item tile used inside [KuberAutocompleteOverlay].
/// Renders an icon chip (40x40 circle), Title, Subtitle, and optional right-aligned Amount.
class KuberSuggestionTile extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final double? amount;

  const KuberSuggestionTile({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.amount,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.md,
        vertical: KuberSpacing.md,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          if (amount != null)
            Text(
              maskAmount(
                ref.watch(formatterProvider).formatCurrency(amount!),
                ref.watch(privacyModeProvider),
              ),
              style: textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
