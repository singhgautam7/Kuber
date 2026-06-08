// =============================================================================
// home_header.dart  — POLISHED
//
// WHAT CHANGED VISUALLY:
//   • Replaced the AnimatedBuilder shimmer pill with a static `_HeaderIconButton`
//     configured with a custom `Row` (containing KuberMarkWidget and Text)
//     to match Option B from the wireframe design.
//   • Border opacity for primary-accented buttons is updated to 28-32% alpha.
//
// WHAT MUST NOT CHANGE LOGICALLY:
//   • Notification and privacy buttons' onTap/state bindings.
//   • GoRouter navigation to '/more/ask-kuber'.
// =============================================================================

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../../ask_kuber/screen/kuber_mark.dart';

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
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          // Match the surrounding content's horizontal padding so the bell
          // sits at exactly the same right edge as the widget cards below.
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: context.l10n.notificationsTooltip,
                    onTap: onTapNotifications,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: _UnreadBadge(count: unreadCount),
                    ),
                ],
              ),
              const Spacer(),
              _HeaderIconButton(
                tooltip: context.l10n.askKuber,
                onTap: () => context.push('/more/ask-kuber'),
                accentBorder: true,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    KuberMarkWidget(size: 16, bare: true, color: cs.primary),
                    const SizedBox(width: 6),
                    Text(
                      context.l10n.askKuber,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              _HeaderIconButton(
                key: TutorialStepKeys.privacyModeIcon,
                icon: isPrivate
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                accentBorder: isPrivate,
                tooltip: isPrivate
                    ? context.l10n.privacyModeOn
                    : context.l10n.privacyModeOff,
                onTap: () =>
                    ref.read(settingsProvider.notifier).togglePrivacyMode(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final String tooltip;
  final VoidCallback onTap;
  final bool accentBorder;
  const _HeaderIconButton({
    super.key,
    this.icon,
    this.child,
    required this.tooltip,
    required this.onTap,
    this.accentBorder = false,
  }) : assert(icon != null || child != null, 'Either icon or child must be provided');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: accentBorder
                  ? cs.primary.withValues(alpha: 0.3)
                  : cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: child ?? Icon(
            icon,
            size: 16,
            color: accentBorder ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = count > 9 ? '9+' : '$count';
    final wide = label.length > 1;
    return Container(
      constraints: BoxConstraints(
        minWidth: wide ? 20 : 16,
        minHeight: 16,
      ),
      padding: EdgeInsets.symmetric(horizontal: wide ? 5 : 0),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: cs.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: localeFont(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: cs.onError,
          height: 1,
        ),
      ),
    );
  }
}