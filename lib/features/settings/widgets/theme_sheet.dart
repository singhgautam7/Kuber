import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../providers/settings_provider.dart';
import 'theme_family_icons.dart';

/// Display names for the seven theme families. Brand names, deliberately not
/// localized.
String themeFamilyName(ThemeVariant variant) => switch (variant) {
      ThemeVariant.signature => 'Kuber Signature',
      ThemeVariant.flewtube => 'FlewTube Red',
      ThemeVariant.woofsapp => 'Woofsapp Green',
      ThemeVariant.purrhub => 'Purrhub Yellow',
      ThemeVariant.honkpe => 'Honkpe Purple',
      ThemeVariant.squeakdin => 'Squeakdin Navy',
      ThemeVariant.oinkzon => 'Oinkzon Orange',
    };

String _familyDescription(BuildContext context, ThemeVariant variant) =>
    switch (variant) {
      ThemeVariant.signature => context.l10n.themeFamilyDescSignature,
      ThemeVariant.flewtube => context.l10n.themeFamilyDescFlewtube,
      ThemeVariant.woofsapp => context.l10n.themeFamilyDescWoofsapp,
      ThemeVariant.purrhub => context.l10n.themeFamilyDescPurrhub,
      ThemeVariant.honkpe => context.l10n.themeFamilyDescHonkpe,
      ThemeVariant.squeakdin => context.l10n.themeFamilyDescSqueakdin,
      ThemeVariant.oinkzon => context.l10n.themeFamilyDescOinkzon,
    };

void showThemeSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ThemeSheet(),
  );
}

/// The Appearance > Theme bottom sheet: theme family picker on top, compact
/// Light / Dark / System mode control at the bottom. Selecting a family
/// re-tints the sheet live (the app theme swaps immediately) and does not
/// close the sheet, so families can be compared back to back.
class ThemeSheet extends ConsumerWidget {
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Narrow watches (performance.md rule 1): the sheet re-tints the entire
    // app on selection, so it must not also rebuild for unrelated settings.
    final selectedVariant = ref.watch(themeVariantProvider);
    final selectedMode = ref.watch(themeModeProvider);
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: context.l10n.themeLabel,
      subtitle: context.l10n.appearanceCategory,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final variant in ThemeVariant.values)
            Padding(
              padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
              child: _ThemeFamilyCard(
                variant: variant,
                selected: variant == selectedVariant,
                onTap: () {
                  if (variant == selectedVariant) return;
                  HapticFeedback.selectionClick();
                  ref
                      .read(settingsProvider.notifier)
                      .setThemeVariant(variant);
                },
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: KuberSpacing.md),
            child: Divider(height: 1),
          ),
          Text(
            context.l10n.themeModeSectionLabel.toUpperCase(),
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          _ModeSegmentedRow(
            selected: selectedMode,
            onChanged: (mode) {
              if (mode == selectedMode) return;
              HapticFeedback.mediumImpact();
              ref.read(settingsProvider.notifier).setThemeMode(mode);
            },
          ),
        ],
      ),
    );
  }
}

class _ThemeFamilyCard extends StatelessWidget {
  final ThemeVariant variant;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeFamilyCard({
    required this.variant,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tokens = KuberTokens.of(variant, Theme.of(context).brightness);
    final name = themeFamilyName(variant);
    final description = _familyDescription(context, variant);

    return Semantics(
      selected: selected,
      button: true,
      label: '$name, $description',
      child: InkWell(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        onTap: onTap,
        highlightColor: cs.surfaceContainerHigh,
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: selected ? tokens.primaryRing : cs.outline,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              ThemeFamilyIcon(variant: variant),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              ExcludeSemantics(
                child: _RadioIndicator(
                  selected: selected,
                  accent: tokens.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  final bool selected;
  final Color accent;

  const _RadioIndicator({required this.selected, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? accent : cs.outline,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent,
              ),
            )
          : null,
    );
  }
}

/// Light | Dark | System control, styled like the Expense | Income | Transfer
/// selector on the Add Transaction screen: muted track, animated solid accent
/// pill for the active segment.
class _ModeSegmentedRow extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  const _ModeSegmentedRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labels = {
      ThemeMode.light: context.l10n.themeLightChoice,
      ThemeMode.dark: context.l10n.themeDarkChoice,
      ThemeMode.system: context.l10n.themeSystemChoice,
    };

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          for (final mode in const [
            ThemeMode.light,
            ThemeMode.dark,
            ThemeMode.system,
          ])
            Expanded(
              child: Semantics(
                inMutuallyExclusiveGroup: true,
                selected: mode == selected,
                button: true,
                child: GestureDetector(
                  onTap: () => onChanged(mode),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      color: mode == selected ? cs.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labels[mode]!,
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: mode == selected
                            ? cs.onPrimary
                            : cs.onSurfaceVariant,
                        fontWeight: mode == selected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
