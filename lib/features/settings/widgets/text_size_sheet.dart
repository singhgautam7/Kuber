import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../providers/settings_provider.dart';

/// Localized name of a text size level (1 to 5; 3 is the default).
String textSizeLabel(BuildContext context, int level) {
  final l = context.l10n;
  return switch (level.clamp(1, 5)) {
    1 => l.textSizeSmall,
    2 => l.textSizeCompact,
    3 => l.textSizeDefault,
    4 => l.textSizeLarge,
    _ => l.textSizeExtraLarge,
  };
}

class TextSizeSheet extends ConsumerStatefulWidget {
  const TextSizeSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const TextSizeSheet(),
    );
  }

  @override
  ConsumerState<TextSizeSheet> createState() => _TextSizeSheetState();
}

class _TextSizeSheetState extends ConsumerState<TextSizeSheet> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final currentLevel = ref.watch(textSizeLevelProvider);
    final sliderValue =
        (_dragValue ?? currentLevel.toDouble()).clamp(1.0, 5.0);
    final activeLevel = sliderValue.round().clamp(1, 5);
    final activeLabel = textSizeLabel(context, activeLevel);
    final activeScale = kTextSizeScales[activeLevel - 1];
    final percentage = (activeScale * 100).round();

    return KuberBottomSheet(
      title: context.l10n.textSizeTitle,
      subtitle: context.l10n.appearanceCategory,
      actions: AppButton(
        label: context.l10n.doneLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context).pop(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.textSizeTitle,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  '$activeLabel ($percentage%)',
                  style: theme.textTheme.labelLarge!.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpace.sm),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.secondaryContainer,
                thumbColor: cs.primary,
                padding: EdgeInsets.zero,
              ),
              child: Slider(
                // ignore: deprecated_member_use
                year2023: false,
                value: sliderValue,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: '$activeLabel ($percentage%)',
                // Saves only when the level actually changes, not on every
                // drag event.
                onChanged: (v) {
                  setState(() => _dragValue = v);
                  if (v.round() != currentLevel) {
                    ref
                        .read(settingsProvider.notifier)
                        .setTextSizeLevel(v.round());
                  }
                },
                onChangeEnd: (_) => setState(() => _dragValue = null),
              ),
            ),
            const SizedBox(height: KuberSpace.xs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'A',
                    style: theme.textTheme.bodySmall!.copyWith(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    context.l10n.textSizeDefault,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: activeLevel == 3
                          ? cs.primary
                          : cs.onSurfaceVariant,
                      fontWeight: activeLevel == 3
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  Text(
                    'A',
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontSize: 22,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpace.lg),
            KuberCard(
              color: cs.surfaceContainer,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.textSizePreviewUpper,
                    style: theme.textTheme.labelSmall!.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  Text(
                    context.l10n.textSizePreviewBody,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ref.watch(formatterProvider).formatCurrency(2450),
                        style: theme.textTheme.titleMedium!.copyWith(
                          color: cs.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        context.l10n.textSizePreviewMeta,
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: KuberSpace.md),
          ],
        ),
      ),
    );
  }
}
