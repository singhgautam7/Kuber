import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../pro/feature_gates/gate_sheet_themes.dart';
import '../../pro/feature_gates/pro_gate.dart';
import '../../pro/paywall/pro_state.dart';
import '../providers/settings_provider.dart';
import 'theme_family_icons.dart';

/// Full display names for the seven theme families. Brand names, deliberately
/// not localized.
String themeFamilyName(ThemeVariant variant) => switch (variant) {
      ThemeVariant.signature => 'Kuber Signature',
      ThemeVariant.flewtube => 'FlewTube Red',
      ThemeVariant.woofsapp => 'Woofsapp Green',
      ThemeVariant.purrhub => 'Purrhub Yellow',
      ThemeVariant.honkpe => 'Honkpe Purple',
      ThemeVariant.squeakdin => 'Squeakdin Navy',
      ThemeVariant.oinkzon => 'Oinkzon Orange',
    };

/// Short family names shown on the preview swatch cards.
String themeFamilyShortName(ThemeVariant variant) => switch (variant) {
      ThemeVariant.signature => 'Signature',
      ThemeVariant.flewtube => 'Flewtube',
      ThemeVariant.woofsapp => 'Woofsapp',
      ThemeVariant.purrhub => 'Purrhub',
      ThemeVariant.honkpe => 'Honkpe',
      ThemeVariant.squeakdin => 'Squeakdin',
      ThemeVariant.oinkzon => 'Oinkzon',
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

/// The Appearance > Theme bottom sheet: appearance-mode control on top, then a
/// 2-column grid of accent-family preview cards. Each card renders a miniature
/// (a transaction row + a Home pill) in that family's own tokens so the user can
/// preview every look. Selecting a mode or family re-tints the app live;
/// dismissing via Cancel / backdrop reverts to the initial selection.
class ThemeSheet extends ConsumerStatefulWidget {
  const ThemeSheet({super.key});

  @override
  ConsumerState<ThemeSheet> createState() => _ThemeSheetState();
}

class _ThemeSheetState extends ConsumerState<ThemeSheet> {
  late ThemeVariant _initialVariant;
  late ThemeMode _initialMode;
  late ThemeVariant _selectedVariant;
  late ThemeMode _selectedMode;
  bool _applied = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _initialVariant = settings?.themeVariant ?? ThemeVariant.signature;
    _initialMode = settings?.themeMode ?? ThemeMode.system;
    _selectedVariant = _initialVariant;
    _selectedMode = _initialMode;
  }

  void _onVariantSelected(ThemeVariant variant) {
    if (variant == _selectedVariant) return;
    // PRO-GATE: Kuber Signature (light + dark) is free; every other accent
    // family is Pro. A free user tapping a Pro family gets the gate sheet and
    // no theme change.
    if (variant != ThemeVariant.signature &&
        !proGate(context, ref, showThemesGateSheet)) {
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _selectedVariant = variant);
    ref.read(settingsProvider.notifier).setThemeVariant(variant);
  }

  void _onModeSelected(ThemeMode mode) {
    if (mode == _selectedMode) return;
    HapticFeedback.mediumImpact();
    setState(() => _selectedMode = mode);
    ref.read(settingsProvider.notifier).setThemeMode(mode);
  }

  void _apply() {
    _applied = true;
    Navigator.of(context).pop();
  }

  void _cancel() => Navigator.of(context).pop();

  void _onPopInvoked(bool didPop) {
    if (didPop && !_applied) {
      if (_selectedVariant != _initialVariant ||
          _selectedMode != _initialMode) {
        ref.read(settingsProvider.notifier).setThemeVariant(_initialVariant);
        ref.read(settingsProvider.notifier).setThemeMode(_initialMode);
      }
    }
  }

  Brightness get _previewBrightness => switch (_selectedMode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system => MediaQuery.platformBrightnessOf(context),
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSameAsInitial = (_selectedVariant == _initialVariant) &&
        (_selectedMode == _initialMode);
    final variants = ThemeVariant.values;
    final brightness = _previewBrightness;
    // PRO-GATE: free users can pick only Kuber Signature; the other families
    // show a lock affordance and route to the gate sheet on tap.
    final hasPro =
        ref.watch(kuberProStateProvider.select((s) => s.hasProAccess));

    return PopScope(
      onPopInvokedWithResult: (didPop, _) => _onPopInvoked(didPop),
      child: KuberBottomSheet(
        title: context.l10n.themeLabel,
        subtitle: 'Pick an appearance mode and accent family.',
        actions: Row(
          children: [
            Expanded(
              child: AppButton(
                label: context.l10n.cancelLabel,
                type: AppButtonType.outline,
                onPressed: _cancel,
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: AppButton(
                label: context.l10n.applyLabel,
                type: AppButtonType.primary,
                onPressed: isSameAsInitial ? null : _apply,
              ),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModeSegmentedRow(
              selected: _selectedMode,
              onChanged: _onModeSelected,
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              'ACCENT FAMILY',
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(height: KuberSpacing.sm),
            for (int i = 0; i < variants.length; i += 2)
              Padding(
                padding: const EdgeInsets.only(bottom: KuberSpacing.md),
                child: Row(
                  // Not `stretch`: this Row lives in the sheet's scroll view,
                  // so its cross-axis (height) is unbounded and stretch would
                  // fail to lay out. The two cards are identical in structure,
                  // so top-alignment keeps them the same height anyway.
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _FamilyPreviewCard(
                        variant: variants[i],
                        brightness: brightness,
                        selected: variants[i] == _selectedVariant,
                        locked: !hasPro && variants[i] != ThemeVariant.signature,
                        onTap: () => _onVariantSelected(variants[i]),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.md),
                    Expanded(
                      child: i + 1 < variants.length
                          ? _FamilyPreviewCard(
                              variant: variants[i + 1],
                              brightness: brightness,
                              selected: variants[i + 1] == _selectedVariant,
                              locked: !hasPro &&
                                  variants[i + 1] != ThemeVariant.signature,
                              onTap: () => _onVariantSelected(variants[i + 1]),
                            )
                          : const SizedBox.shrink(),
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

/// A single accent-family preview: the family icon + name, a miniature
/// transaction row, and a Home pill — all rendered in that family's tokens.
class _FamilyPreviewCard extends StatelessWidget {
  final ThemeVariant variant;
  final Brightness brightness;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  const _FamilyPreviewCard({
    required this.variant,
    required this.brightness,
    required this.selected,
    required this.onTap,
    this.locked = false,
  });

  @override
  Widget build(BuildContext context) {
    final t = KuberTokens.of(variant, brightness);
    final name = themeFamilyShortName(variant);

    return Semantics(
      selected: selected,
      button: true,
      label: locked ? '${themeFamilyName(variant)}, Kuber Pro'
          : themeFamilyName(variant),
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: t.surfaceCard,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: selected ? t.primary : t.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  ThemeFamilyIcon(variant: variant, size: 26),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  if (selected)
                    Icon(Icons.check_circle_rounded, size: 16, color: t.primary)
                  else if (locked)
                    Icon(Icons.lock_rounded, size: 14, color: t.textSecondary),
                ],
              ),
              const SizedBox(height: 10),
              _MiniTransaction(t: t),
              const SizedBox(height: 8),
              _MiniHomePill(t: t),
            ],
          ),
        ),
      ),
    );
  }
}

/// Miniature transaction row: accent chip, two text bars, a red −₹250.
class _MiniTransaction extends StatelessWidget {
  final KuberTokens t;
  const _MiniTransaction({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: t.surfaceMuted,
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: t.primarySubtle,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: t.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 5),
                FractionallySizedBox(
                  widthFactor: 0.5,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: t.borderMuted,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '−₹250',
            style: localeFont(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: t.expense,
            ),
          ),
        ],
      ),
    );
  }
}

/// Miniature Home nav pill in the family accent.
class _MiniHomePill extends StatelessWidget {
  final KuberTokens t;
  const _MiniHomePill({required this.t});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: t.primarySubtle,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: t.primaryRing),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: t.primary),
          ),
          const SizedBox(width: 6),
          Text(
            'Home',
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.primaryText,
            ),
          ),
          const Spacer(),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: t.primaryText.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// System | Light | Dark control: muted track, animated solid-accent pill for
/// the active segment.
class _ModeSegmentedRow extends StatelessWidget {
  final ThemeMode selected;
  final ValueChanged<ThemeMode> onChanged;

  const _ModeSegmentedRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labels = {
      ThemeMode.system: context.l10n.themeSystemChoice,
      ThemeMode.light: context.l10n.themeLightChoice,
      ThemeMode.dark: context.l10n.themeDarkChoice,
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
            ThemeMode.system,
            ThemeMode.light,
            ThemeMode.dark,
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
