import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../more/screens/more_screen.dart';
import '../../settings/widgets/settings_widgets.dart';

/// Opens the post-onboarding "Just so you know" bottom sheet. Called directly
/// after the user taps "Start my journey" so the sheet appears on top of the
/// home screen without relying on a global widget listener.
void showTutorialNudgeSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => const _TutorialNudgeSheet(),
  );
}

class _TutorialNudgeSheet extends ConsumerWidget {
  const _TutorialNudgeSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: context.l10n.justSoYouKnow,
      leadingIcon: SquircleIcon(icon: Icons.school_rounded, color: cs.primary),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 48,
            child: OutlinedButton(
              onPressed: () async {
                Navigator.of(context, rootNavigator: true).pop();
                if (context.mounted) {
                  await launchTutorialFromMore(context, ref);
                }
              },
              child: Text(context.l10n.goToTutorials),
            ),
          ),
          const SizedBox(height: KuberSpace.sm),
          SizedBox(
            height: 48,
            child: FilledButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: Text(
                context.l10n.gotIt,
                style: localeFont(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          _NudgeRow(
            icon: Icons.touch_app_rounded,
            title: context.l10n.exploreAtOwnPace,
            body: context.l10n.exploreAtOwnPaceBody,
          ),
          const SizedBox(height: KuberSpace.md),
          _NudgeRow(
            icon: Icons.map_rounded,
            title: context.l10n.walkthroughNearby,
            body: context.l10n.walkthroughNearbyBody,
          ),
        ],
      ),
    );
  }
}

class _NudgeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _NudgeRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SquircleIcon(icon: icon, color: cs.primary),
        const SizedBox(width: KuberSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpace.xs),
              Text(
                body,
                style: localeFont(
                  fontSize: 14,
                  height: 1.45,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
