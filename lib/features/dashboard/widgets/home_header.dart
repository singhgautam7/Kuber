// Home header (board 3.2b): Pro pill, privacy, notifications. Built from the
// shared M3 AppIconButton; tap/state bindings unchanged.

import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../pro/home/premium_home_button.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tutorial/models/tutorial_step_keys.dart';

/// Replaces the brand wordmark + actions row on the dashboard. Other screens
/// keep `KuberAppBar`. Layout: Ask Kuber pill — spacer — privacy
/// icon — notification bell (with badge).
class HomeHeader extends ConsumerWidget {
  final int unreadCount;
  final VoidCallback onTapNotifications;

  const HomeHeader({
    super.key,
    required this.unreadCount,
    required this.onTapNotifications,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPrivate = ref.watch(privacyModeProvider);

    // Header geometry (components/header.md): L20 T14 R16 B12; Pro pill on
    // the left, privacy and notifications on the right (board 3.2b).
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          14,
          KuberSpace.lg,
          KuberSpace.md,
        ),
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              const PremiumHomeButton(),
              const Spacer(),
              AppIconButton(
                key: TutorialStepKeys.privacyModeIcon,
                icon: isPrivate
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                kind: isPrivate
                    ? AppIconButtonKind.tonal
                    : AppIconButtonKind.standard,
                semanticLabel: isPrivate
                    ? context.l10n.privacyModeOn
                    : context.l10n.privacyModeOff,
                onPressed: () =>
                    ref.read(settingsProvider.notifier).togglePrivacyMode(),
              ),
              AppIconButton(
                icon: Icons.notifications_none_rounded,
                semanticLabel: context.l10n.notificationsTooltip,
                badge: unreadCount > 0
                    ? (unreadCount > 9 ? '9+' : '$unreadCount')
                    : null,
                onPressed: onTapNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
