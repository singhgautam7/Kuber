import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../widgets/onboarding_entrance.dart';

/// Notifications, after the details steps. The list is what Kuber really
/// sends: reminders, credit card bills, budget alerts, what a background run
/// recorded, and backup problems. Buttons are in the flow's nav bar.
class OnboardingNotificationsPage extends StatelessWidget {
  const OnboardingNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Widget item(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24, color: cs.primary),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Text(text, style: theme.textTheme.bodyLarge!.copyWith(color: cs.onSurface)),
              ),
            ],
          ),
        );
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.xl,
        KuberSpace.xxl,
        KuberSpace.xl,
        KuberSpace.lg,
      ),
      child: OnboardingEntrance(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notifications_active_outlined, size: 56, color: cs.primary),
            const SizedBox(height: KuberSpace.xl),
            Text(l.obNotifTitle,
                style: theme.textTheme.headlineLarge!.copyWith(color: cs.onSurface)),
            const SizedBox(height: KuberSpace.xl),
            item(Icons.alarm_rounded, l.obNotifReminders),
            item(Icons.credit_card_rounded, l.obNotifCards),
            item(Icons.pie_chart_outline_rounded, l.obNotifBudgets),
            item(Icons.event_repeat_rounded, l.obNotifRecorded),
            item(Icons.backup_outlined, l.obNotifBackup),
            const SizedBox(height: KuberSpace.md),
            Text(l.obNotifPromise,
                style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
