import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_list.dart';

/// Notifications, after the details steps: what Kuber sends and its promise.
/// Buttons are in the flow's nav bar.
class OnboardingNotificationsPage extends StatelessWidget {
  const OnboardingNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 56, KuberSpace.screenMargin, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _NotificationArt(),
                const SizedBox(height: KuberSpace.xl - 4),
                Text(l.obNotifTitle, style: theme.textTheme.headlineMedium!.copyWith(color: cs.onSurface)),
                const SizedBox(height: KuberSpace.md),
                KuberGroup(
                  children: [
                    for (final (icon, title, sub) in [
                      (Icons.event_repeat_rounded, l.obNotifEmi, l.setNotifEmiSub),
                      (Icons.donut_large_rounded, l.obNotifBudget, l.obNotifBudgetSub),
                      (Icons.alarm_rounded, l.appDrawerReminders, l.obNotifRemindersSub),
                    ])
                      KuberListRow(
                        dense: true,
                        minHeight: 64,
                        leading: KuberIconTile(icon: icon, glyph: 22),
                        title: title,
                        titleLines: 3,
                        subtitle: sub,
                        subtitleLines: 3,
                      ),
                  ],
                ),
                const SizedBox(height: KuberSpace.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg, vertical: KuberSpace.md),
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer,
                    borderRadius: BorderRadius.circular(KuberShape.large),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.verified_user_rounded, size: 20, color: cs.onSecondaryContainer),
                      const SizedBox(width: KuberSpace.md),
                      Expanded(
                        child: Text(l.obNotifPromise,
                            style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSecondaryContainer)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A sample notification over a card behind it, and the bell. A picture, so its
/// text keeps its size at every font setting.
class _NotificationArt extends StatelessWidget {
  const _NotificationArt();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return MediaQuery.withNoTextScaling(
      child: Container(
        height: 104,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 44,
              right: 28,
              top: 16,
              height: 56,
              child: Opacity(
                opacity: 0.6,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberShape.large),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 28,
              right: 44,
              top: 30,
              child: Container(
                constraints: const BoxConstraints(minHeight: 60),
                padding: const EdgeInsets.symmetric(horizontal: KuberSpace.md, vertical: 10),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberShape.large),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Row(
                  children: [
                    const KuberIconTile(
                      icon: Icons.currency_rupee_rounded,
                      size: 32,
                      glyph: 18,
                      circle: true,
                      tone: KuberTone.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l.obNotifSampleTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelLarge!.copyWith(color: cs.onSurface)),
                          Text(l.obNotifSampleBody,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 14,
              child: KuberIconTile(
                icon: Icons.notifications_active_rounded,
                glyph: 22,
                circle: true,
                color: cs.primary,
                iconColor: cs.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
