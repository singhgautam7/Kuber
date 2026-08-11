import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../paywall/pro_state.dart';
import 'entitlement_override.dart';

/// DEBUG-ONLY sheet to force an entitlement state for local gate testing.
/// Reached from Dev Tools; the whole feature is compiled out of release builds
/// (see [DebugEntitlementOverride]). Never ships to users.
void showEntitlementOverrideSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _EntitlementOverrideSheet(),
  );
}

class _EntitlementOverrideSheet extends ConsumerStatefulWidget {
  const _EntitlementOverrideSheet();

  @override
  ConsumerState<_EntitlementOverrideSheet> createState() =>
      _EntitlementOverrideSheetState();
}

class _EntitlementOverrideSheetState
    extends ConsumerState<_EntitlementOverrideSheet> {
  late DebugForcedTier? _selected;
  late double _trialDays;

  @override
  void initState() {
    super.initState();
    _selected = DebugEntitlementOverride.tier;
    _trialDays = DebugEntitlementOverride.trialDaysLeft.toDouble();
  }

  Future<void> _apply() async {
    await DebugEntitlementOverride.set(
      _selected,
      trialDaysLeft: _trialDays.round(),
    );
    ref.invalidate(kuberProStateProvider);
    if (!mounted) return;
    Navigator.of(context).pop();
    showKuberSnackBar(
      context,
      _selected == null
          ? 'Override cleared, using real Play Billing state'
          : 'Entitlement forced: ${_label(_selected!)}',
    );
  }

  String _label(DebugForcedTier t) => switch (t) {
        DebugForcedTier.free => 'Free',
        DebugForcedTier.trial => 'Trial',
        DebugForcedTier.monthly => 'Monthly',
        DebugForcedTier.yearly => 'Yearly',
        DebugForcedTier.lifetime => 'Lifetime',
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: 'Entitlement override',
      subtitle: 'Debug builds only',
      actions: Row(
        children: [
          Expanded(
            child: AppButton(
              label: 'Cancel',
              type: AppButtonType.outline,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: AppButton(
              label: 'Apply',
              type: AppButtonType.primary,
              onPressed: _apply,
            ),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Force an entitlement to test the Pro gates without a real '
            'purchase. Persists across restarts. Choose "Clear override" to '
            'fall back to real Play Billing state.',
            style: localeFont(
              fontSize: 13,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          _OptionTile(
            label: 'Clear override',
            subtitle: 'Use real Play Billing state',
            selected: _selected == null,
            onTap: () => setState(() => _selected = null),
          ),
          for (final tier in DebugForcedTier.values)
            _OptionTile(
              label: 'Force ${_label(tier)}',
              subtitle: _subtitleFor(tier),
              selected: _selected == tier,
              onTap: () => setState(() => _selected = tier),
            ),
          if (_selected == DebugForcedTier.trial) ...[
            const SizedBox(height: KuberSpacing.md),
            Text(
              'Trial days remaining: ${_trialDays.round()}',
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
              ),
            ),
            Slider(
              value: _trialDays,
              min: 1,
              max: 14,
              divisions: 13,
              label: '${_trialDays.round()}',
              onChanged: (v) => setState(() => _trialDays = v),
            ),
          ],
        ],
      ),
    );
  }

  String _subtitleFor(DebugForcedTier tier) => switch (tier) {
        DebugForcedTier.free => 'All gates engaged',
        DebugForcedTier.trial => 'Full access, trial UI',
        DebugForcedTier.monthly => 'Full Pro, 30-day expiry',
        DebugForcedTier.yearly => 'Full Pro, 14-day trial phase',
        DebugForcedTier.lifetime => 'Full Pro, no expiry',
      };
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.md,
          ),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.10) : cs.surface,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: selected ? cs.primary : cs.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: localeFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, size: 20, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }
}
