import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart' show kuberPressedLayer;
import '../../../shared/widgets/motion_preview_card.dart';
import '../providers/settings_provider.dart';

/// Localized name of a level.
String motionLevelName(AppLocalizations l, MotionLevel level) => switch (level) {
      MotionLevel.expressive => l.motionExpressive,
      MotionLevel.subtle => l.motionSubtle,
      MotionLevel.off => l.motionOff,
    };

/// The Look and feel row's value: "Auto (Expressive)", "Subtle",
/// "Off (phone setting)", ...
String motionRowValue(AppLocalizations l, MotionPreference pref,
    DeviceClass device, bool systemOff) {
  if (systemOff) return l.motionValuePhone;
  final auto = resolveMotionLevel(MotionPreference.auto, device);
  return switch (pref) {
    MotionPreference.auto => l.motionValueAuto(motionLevelName(l, auto)),
    MotionPreference.expressive => l.motionExpressive,
    MotionPreference.subtle => l.motionSubtle,
    MotionPreference.off => l.motionOff,
  };
}

/// Motion setting sheet (v7.0.0 Screen 11): a preview card that reacts with
/// the chosen level's press response, and four radio rows. A choice applies at
/// once. When the phone's Remove animations is on, Expressive and Subtle are
/// disabled and the note explains why.
class MotionSheet extends ConsumerWidget {
  const MotionSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
      sheetAnimationStyle: kuberSheetStyle(context),
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const MotionSheet(),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final pref = ref.watch(motionPreferenceProvider);
    final device = ref.watch(motionDeviceProvider);
    final sys = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final level = resolveMotionLevel(pref, device, systemOff: sys);
    final autoLevel = resolveMotionLevel(MotionPreference.auto, device);
    final autoDesc = sys
        ? l.motionAutoOff
        : switch (autoLevel) {
            MotionLevel.expressive => l.motionAutoExpressive,
            MotionLevel.subtle => l.motionAutoSubtle,
            MotionLevel.off => l.motionAutoOff,
          };
    // With the phone's setting on, Off is what is really in use.
    final shown = sys ? MotionPreference.off : pref;

    Widget row(MotionPreference p, String title, String desc,
        {bool disabled = false}) {
      return _RadioRow(
        title: title,
        description: desc,
        selected: shown == p,
        disabled: disabled,
        onTap: () {
          KuberHaptics.tick();
          ref.read(motionPreferenceProvider.notifier).set(p);
        },
      );
    }

    return KuberBottomSheet(
      title: l.motionTitle,
      description: l.motionSubtitle,
      bodyPadding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MotionPreviewCard(
            title: 'HDFC Savings',
            amount: ref.watch(formatterProvider).formatCurrency(124500),
            caption: l.motionPreviewHint,
            level: level,
          ),
          const SizedBox(height: 12),
          row(MotionPreference.auto, l.motionAuto, autoDesc),
          row(MotionPreference.expressive, l.motionExpressive,
              l.motionExpressiveDesc,
              disabled: sys),
          row(MotionPreference.subtle, l.motionSubtle, l.motionSubtleDesc,
              disabled: sys),
          row(MotionPreference.off, l.motionOff, l.motionOffDesc),
          if (sys)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.info_outline_rounded,
                        size: 18, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l.motionPhoneNote,
                            style: localeFont(
                                fontSize: 14, color: cs.onSurfaceVariant)),
                        // Transparent padding keeps the text button aligned
                        // with the note above.
                        Transform.translate(
                          offset: const Offset(-12, 0),
                          child: TextButton(
                            // Deviation: opens Kuber's app settings page (the
                            // only helper in the codebase); the user goes on
                            // to Accessibility from there.
                            onPressed: () => openAppSettings(),
                            child: Text(l.motionOpenPhoneSettings),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _RadioRow extends StatelessWidget {
  const _RadioRow({
    required this.title,
    required this.description,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final String title, description;
  final bool selected, disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fg = selected ? cs.onSecondaryContainer : cs.onSurface;
    final fg2 = selected ? cs.onSecondaryContainer : cs.onSurfaceVariant;
    return Opacity(
      opacity: disabled ? 0.38 : 1,
      child: Semantics(
        selected: selected,
        enabled: !disabled,
        inMutuallyExclusiveGroup: true,
        button: true,
        child: Material(
          color: selected ? cs.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberShape.large),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: disabled ? null : onTap,
            overlayColor: kuberPressedLayer(cs),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      height: 40,
                      child: Icon(
                        selected
                            ? Icons.radio_button_checked_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 22,
                        color: selected ? cs.primary : cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: localeFont(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: fg)),
                          Text(description,
                              style: localeFont(fontSize: 14, color: fg2)),
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
