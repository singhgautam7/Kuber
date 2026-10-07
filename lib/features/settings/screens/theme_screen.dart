import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/theme_families.dart' show kSelectableVariants;
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../pro/feature_gates/gate_sheet_themes.dart';
import '../../pro/feature_gates/pro_gate.dart';
import '../../pro/paywall/pro_state.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_options_provider.dart';

/// More → Settings → Theme. Copied from Mull `features/settings/theme_screen.dart`:
/// Light / Dark / System; a true-black row while dark is in effect; a
/// two-column grid of family cards (three swatches each); a "From your
/// wallpaper" row; a live preview card. Kuber Signature is free, every other
/// family and the wallpaper colour are Pro (unchanged gate).
class ThemeScreen extends ConsumerWidget {
  const ThemeScreen({super.key});

  bool _gate(BuildContext context, WidgetRef ref) =>
      proGate(context, ref, showThemesGateSheet);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final mode = ref.watch(themeModeProvider);
    final variant = ref.watch(themeVariantProvider);
    final options = ref.watch(themeOptionsProvider);
    final hasPro = ref.watch(
      kuberProStateProvider.select((s) => s.hasProAccess),
    );
    final settings = ref.read(settingsProvider.notifier);
    final optionsCtl = ref.read(themeOptionsProvider.notifier);
    final platform = MediaQuery.platformBrightnessOf(context);
    final darkInEffect = switch (mode) {
      ThemeMode.light => false,
      ThemeMode.dark => true,
      ThemeMode.system => platform == Brightness.dark,
    };
    final previewBrightness = darkInEffect ? Brightness.dark : Brightness.light;
    final seed = ref.watch(wallpaperSeedProvider).valueOrNull;
    final dynamicOn = options.dynamicColor && hasPro;

    Widget optionRow({
      required Widget leading,
      required String title,
      required String subtitle,
      required bool value,
      required ValueChanged<bool>? onChanged,
      bool highlighted = false,
    }) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.largeR,
        border: Border.all(
          color: highlighted ? cs.primary : cs.outlineVariant,
          width: highlighted ? 2 : 1,
        ),
      ),
      child: Row(
        spacing: KuberSpace.md,
        children: [
          leading,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium!.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );

    return Scaffold(
      body: KuberScrollAwayHeader(
        header: KuberAppBar(showBack: true, title: context.l10n.themeLabel),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            KuberSpace.screenMargin,
            KuberSpace.xs,
            KuberSpace.screenMargin,
            KuberSpace.xxxl,
          ),
          children: [
            _SegmentedToggle<ThemeMode>(
              options: [
                (ThemeMode.light, context.l10n.themeLightChoice),
                (ThemeMode.dark, context.l10n.themeDarkChoice),
                (ThemeMode.system, context.l10n.themeSystemChoice),
              ],
              selected: mode,
              onChanged: (m) {
                HapticFeedback.selectionClick();
                settings.setThemeMode(m);
              },
            ),
            if (darkInEffect &&
                (dynamicOn || themeFamilyHasAmoled(variant))) ...[
              const SizedBox(height: KuberSpace.md),
              optionRow(
                leading: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFF000000),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                ),
                title: 'True black (AMOLED)',
                subtitle: 'Appears only while dark is active',
                value: options.amoled || variant == ThemeVariant.signature,
                // Signature's dark page is already true black.
                onChanged: variant == ThemeVariant.signature && !dynamicOn
                    ? null
                    : (v) => optionsCtl.setAmoled(v),
              ),
            ],
            const SizedBox(height: KuberSpace.lg),
            _TwoColumnGrid(
              children: [
                for (final v in kSelectableVariants)
                  _FamilyCard(
                    name: themeFamilyName(v),
                    blurb:
                        themeFamilyHasAmoled(v) && v != ThemeVariant.signature
                        ? '${themeFamilyBlurb(v)} · true black'
                        : themeFamilyBlurb(v),
                    scheme: AppTheme.schemeOf(
                      v,
                      previewBrightness,
                      amoled: options.amoled,
                    ),
                    selected: !dynamicOn && v == variant,
                    locked: !hasPro && v != ThemeVariant.signature,
                    onTap: () async {
                      if (v != ThemeVariant.signature && !_gate(context, ref)) {
                        return;
                      }
                      HapticFeedback.selectionClick();
                      await optionsCtl.setDynamicColor(false);
                      await settings.setThemeVariant(v);
                    },
                  ),
              ],
            ),
            const SizedBox(height: KuberSpace.lg),
            optionRow(
              highlighted: dynamicOn,
              leading: seed == null
                  ? Icon(Icons.wallpaper_rounded, color: cs.onSurfaceVariant)
                  : Row(
                      spacing: 4,
                      children: [
                        _ThemeDot(
                          AppTheme.schemeOf(
                            variant,
                            previewBrightness,
                            seed: seed,
                          ).primary,
                          size: 26,
                        ),
                        _ThemeDot(
                          AppTheme.schemeOf(
                            variant,
                            previewBrightness,
                            seed: seed,
                          ).primaryContainer,
                          size: 26,
                        ),
                      ],
                    ),
              title: 'From your wallpaper',
              subtitle: 'Dynamic colour, Android 12+',
              value: dynamicOn,
              onChanged: seed == null
                  ? null
                  : (v) {
                      if (v && !_gate(context, ref)) return;
                      optionsCtl.setDynamicColor(v);
                    },
            ),
            const SizedBox(height: KuberSpace.sectionGap),
            const KuberSectionHeader(title: 'Preview'),
            KuberCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'October · Net',
                    style: theme.textTheme.labelMedium!.copyWith(
                      letterSpacing: 0.8,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.xs),
                  Text(
                    '+₹43,457',
                    style: theme.textTheme.headlineMedium!.copyWith(
                      color: context.kuberMoney.income,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.xs),
                  Text(
                    'Every rupee, accounted for.',
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.lg),
                  Wrap(
                    spacing: KuberSpace.sm,
                    runSpacing: KuberSpace.sm,
                    children: [
                      AppButton(
                        label: 'Primary',
                        type: AppButtonType.primary,
                        height: 40,
                        onPressed: () {},
                      ),
                      AppButton(
                        label: 'Outlined',
                        type: AppButtonType.outline,
                        height: 40,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mull `chips.dart` SegmentedToggle: surfaceContainerHigh track, 4dp padding,
/// the selected thumb is the page surface with a 1dp outline.
class _SegmentedToggle<T> extends StatelessWidget {
  const _SegmentedToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<(T, String)> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      padding: const EdgeInsets.all(KuberSpace.xs),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.fullR,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (value, label) in options)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: value == selected,
                  child: InkWell(
                    onTap: () => onChanged(value),
                    borderRadius: KuberShape.fullR,
                    child: AnimatedContainer(
                      duration: KuberMotion.of(context, KuberMotion.fast),
                      curve: KuberMotion.curveOf(
                        context,
                        KuberMotion.decelerate,
                      ),
                      decoration: BoxDecoration(
                        color: value == selected
                            ? cs.surface
                            : Colors.transparent,
                        borderRadius: KuberShape.fullR,
                        border: Border.all(
                          color: value == selected
                              ? cs.outlineVariant
                              : Colors.transparent,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall!.copyWith(
                          color: value == selected
                              ? cs.onSurface
                              : cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Mull `family_card.dart`: three swatches, the name, the blurb; selected = 2dp
/// primary border.
class _FamilyCard extends StatelessWidget {
  const _FamilyCard({
    required this.name,
    required this.blurb,
    required this.scheme,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String name;
  final String blurb;
  final ColorScheme scheme;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: '$name theme',
      child: InkWell(
        onTap: onTap,
        borderRadius: KuberShape.cardR,
        child: Container(
          padding: const EdgeInsets.all(14),
          constraints: const BoxConstraints(minHeight: 116),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: KuberShape.cardR,
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 6,
                children: [
                  _ThemeDot(scheme.primary),
                  _ThemeDot(scheme.primaryContainer),
                  _ThemeDot(
                    scheme.surfaceContainerHigh,
                    border: cs.outlineVariant,
                  ),
                  const Spacer(),
                  if (locked)
                    Icon(
                      Icons.lock_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: KuberSpace.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.titleMedium!.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    blurb,
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeDot extends StatelessWidget {
  const _ThemeDot(this.color, {this.size = 34, this.border});

  final Color color;
  final double size;
  final Color? border;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: border == null ? null : Border.all(color: border!),
    ),
  );
}

/// Mull `two_column_grid.dart`: two columns whose rows are as tall as their
/// taller card.
class _TwoColumnGrid extends StatelessWidget {
  const _TwoColumnGrid({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: KuberSpace.md,
      children: [
        for (int i = 0; i < children.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: KuberSpace.md,
              children: [
                Expanded(child: children[i]),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
