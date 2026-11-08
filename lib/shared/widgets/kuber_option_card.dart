import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_button.dart';
import 'kuber_list.dart';
import 'kuber_progress.dart';

enum KuberOptionState { idle, busy, failed, disabled }

/// A choice card (Components 2m): 48 tonal tile, title, helper line, chevron.
/// Grows to show progress or an error.
class KuberOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final KuberOptionState state;
  final VoidCallback? onTap;

  /// Busy: the bar, the step line, and a percentage or a cancel action.
  final double progress;
  final String? step;
  final String? cancelLabel;
  final VoidCallback? onCancel;

  /// Failed: the two ways on.
  final String? retryLabel;
  final VoidCallback? onRetry;
  final String? otherLabel;
  final VoidCallback? onOther;

  const KuberOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.state = KuberOptionState.idle,
    this.onTap,
    this.progress = 0,
    this.step,
    this.cancelLabel,
    this.onCancel,
    this.retryLabel,
    this.onRetry,
    this.otherLabel,
    this.onOther,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final busy = state == KuberOptionState.busy;
    final failed = state == KuberOptionState.failed;
    final idle = state == KuberOptionState.idle;
    final bg = failed
        ? cs.errorContainer
        : busy
            ? cs.secondaryContainer
            : cs.surfaceContainer;
    final titleColor = failed
        ? cs.onErrorContainer
        : busy
            ? cs.onSecondaryContainer
            : cs.onSurface;
    final subColor = failed
        ? cs.onErrorContainer
        : busy
            ? cs.onSecondaryContainer
            : cs.onSurfaceVariant;
    final (tileBg, tileFg) = failed
        ? (cs.error, cs.onError)
        : busy
            ? (cs.primary, cs.onPrimary)
            : (cs.secondaryContainer, cs.onSecondaryContainer);
    final motion = KuberMotion.reduced(context);
    final grow = motion ? KuberMotion.reducedFade : const Duration(milliseconds: 250);
    final tint = motion ? KuberMotion.reducedFade : const Duration(milliseconds: 200);

    return AnimatedOpacity(
      opacity: state == KuberOptionState.disabled ? 0.38 : 1,
      duration: KuberMotion.fast,
      child: IgnorePointer(
        ignoring: state == KuberOptionState.disabled,
        child: AnimatedContainer(
          duration: tint,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: KuberShape.cardR,
            border: Border.all(color: busy || failed ? bg : cs.outlineVariant),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: idle ? onTap : null,
              borderRadius: KuberShape.cardR,
              overlayColor: kuberPressedLayer(cs),
              child: AnimatedSize(
                duration: grow,
                curve: Curves.easeInOutCubicEmphasized,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      constraints: const BoxConstraints(minHeight: 80),
                      padding: const EdgeInsets.all(KuberSpace.lg),
                      child: Row(
                        children: [
                          AnimatedSwitcher(
                            duration: tint,
                            child: KuberIconTile(
                              key: ValueKey(state),
                              icon: failed ? Icons.error_rounded : icon,
                              size: 48,
                              glyph: 24,
                              radius: 14,
                              color: tileBg,
                              iconColor: tileFg,
                            ),
                          ),
                          const SizedBox(width: KuberSpace.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(title, style: theme.textTheme.titleMedium!.copyWith(color: titleColor)),
                                Text(
                                  subtitle,
                                  // Busy shows a file name: one line.
                                  maxLines: busy ? 1 : null,
                                  overflow: busy ? TextOverflow.ellipsis : null,
                                  style: theme.textTheme.bodyMedium!.copyWith(color: subColor),
                                ),
                              ],
                            ),
                          ),
                          if (!busy && !failed) ...[
                            const SizedBox(width: KuberSpace.lg),
                            const KuberChevron(),
                          ],
                        ],
                      ),
                    ),
                    if (busy)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            KuberLinearProgress(value: progress),
                            const SizedBox(height: KuberSpace.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(step ?? '',
                                      style: theme.textTheme.bodySmall!.copyWith(color: cs.onSecondaryContainer)),
                                ),
                                const SizedBox(width: KuberSpace.md),
                                if (cancelLabel != null)
                                  TextButton(
                                    onPressed: onCancel,
                                    style: TextButton.styleFrom(
                                      minimumSize: Size.zero,
                                      padding: EdgeInsets.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(cancelLabel!),
                                  )
                                else
                                  Text('${(progress * 100).round()}%',
                                      style: theme.textTheme.labelMedium!.copyWith(color: cs.onSecondaryContainer)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (failed)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Wrap(
                          spacing: KuberSpace.sm,
                          runSpacing: KuberSpace.sm,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppButton(
                              label: retryLabel ?? '',
                              type: AppButtonType.danger,
                              filled: true,
                              height: 40,
                              icon: Icons.refresh_rounded,
                              onPressed: onRetry,
                            ),
                            TextButton(
                              onPressed: onOther,
                              style: TextButton.styleFrom(foregroundColor: cs.onErrorContainer),
                              child: Text(otherLabel ?? ''),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined 40 pill: translate icon, current language, chevron.
class KuberLanguageButton extends StatelessWidget {
  final String label;
  final Locale locale;
  final bool enabled;
  final VoidCallback onTap;

  const KuberLanguageButton({
    super.key,
    required this.label,
    required this.locale,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return AnimatedOpacity(
      opacity: enabled ? 1 : 0.38,
      duration: KuberMotion.fast,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: enabled ? onTap : null,
          customBorder: const StadiumBorder(),
          overlayColor: kuberPressedLayer(cs),
          child: Container(
            constraints: const BoxConstraints(minHeight: 40),
            padding: const EdgeInsets.fromLTRB(12, 0, 10, 0),
            decoration: ShapeDecoration(
              shape: StadiumBorder(side: BorderSide(color: cs.outlineVariant)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.translate_rounded, size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(label, style: theme.textTheme.labelLarge!.copyWith(color: cs.onSurface)),
                const SizedBox(width: 6),
                Icon(Icons.expand_more_rounded, size: 18, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A large checkbox row: the whole row toggles the box.
class KuberConsentRow extends StatelessWidget {
  final String text;
  final bool value;
  final ValueChanged<bool> onChanged;

  const KuberConsentRow({
    super.key,
    required this.text,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Semantics(
      checked: value,
      label: text,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: KuberMotion.of(context, const Duration(milliseconds: 200)),
        decoration: BoxDecoration(
          color: value ? cs.secondaryContainer : cs.surfaceContainer,
          borderRadius: KuberShape.cardR,
          border: Border.all(color: value ? cs.secondaryContainer : cs.outlineVariant),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onChanged(!value),
            borderRadius: KuberShape.cardR,
            overlayColor: kuberPressedLayer(cs),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Checkbox(value: value, onChanged: (v) => onChanged(v ?? false)),
                  ),
                  const SizedBox(width: KuberSpace.xs),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: KuberSpace.sm),
                      child: Text(
                        text,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: value ? cs.onSecondaryContainer : cs.onSurface,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
