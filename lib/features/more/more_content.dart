import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/l10n_ext.dart';
import '../ask_kuber/screen/kuber_mark.dart';
import '../notifications/providers/notification_provider.dart';
import '../notifications/utils/deep_link_handler.dart';
import '../notifications/widgets/notifications_sheet.dart';
import '../pro/feature_gates/gate_sheet_advanced_analytics.dart';
import '../pro/feature_gates/gate_sheet_sms_import.dart';
import '../pro/feature_gates/pro_gate.dart';
import '../tutorial/models/tutorial_step_keys.dart';
import 'screens/more_screen.dart' show launchTutorialFromMore;

/// A single More-tab entry. This is **content only** — icon, copy, destination,
/// and a couple of presentation hints. Each layout (`more_screen.dart` classic
/// list, `more_screen_modern.dart` grids/strips) renders it its own way.
class MoreEntry {
  final IconData icon;

  /// Optional custom leading widget (e.g. the animated Kuber mark for Ask
  /// Kuber). When null, [icon] is used.
  final Widget? iconWidget;

  final String label;
  final String subtitle;
  final VoidCallback onTap;

  /// Shows the small "PRO" pill (Advanced Analytics).
  final bool proPill;

  /// Shows the small "beta" pill (Ask Kuber).
  final bool betaPill;

  /// Tutorial-overlay target key, when this row is a coach-mark anchor.
  final Key? tutorialKey;

  const MoreEntry({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconWidget,
    this.proPill = false,
    this.betaPill = false,
    this.tutorialKey,
  });
}

/// Stable identity for a More section, so a layout can pick a bespoke rendering
/// (the modern layout renders Manage as a hero + grid, Signature as a card
/// grid, Help Us as an accent strip, etc.).
enum MoreSectionId { manage, signature, app, tutorial, about, helpUs }

class MoreSection {
  final MoreSectionId id;
  final String title;
  final String? hint;
  final List<MoreEntry> entries;

  const MoreSection({
    required this.id,
    required this.title,
    required this.entries,
    this.hint,
  });
}

/// THE single source of truth for More-tab content. Both More layouts build
/// themselves from this list, so content changes (add/remove/reorder a row,
/// change a label or destination) happen here, once, not in each screen.
///
/// Section order and membership are canonical across both layouts.
List<MoreSection> buildMoreSections(
  BuildContext context,
  WidgetRef ref, {
  required bool isDevMode,
}) {
  final l10n = context.l10n;

  return [
    // ── Manage: core data entities ──────────────────────────────────────────
    MoreSection(
      id: MoreSectionId.manage,
      title: l10n.moreManageTitle,
      entries: [
        MoreEntry(
          icon: Icons.account_balance_wallet,
          label: l10n.menuAccounts,
          subtitle: l10n.menuAccountsDesc,
          onTap: () => context.push('/more/accounts'),
        ),
        MoreEntry(
          icon: Icons.category,
          label: l10n.menuCategories,
          subtitle: l10n.menuCategoriesDesc,
          onTap: () => context.push('/more/categories'),
        ),
        MoreEntry(
          icon: Icons.label_rounded,
          label: l10n.menuTags,
          subtitle: l10n.menuTagsDesc,
          onTap: () => context.push('/more/tags'),
        ),
        MoreEntry(
          icon: Icons.pie_chart_rounded,
          label: l10n.menuBudgets,
          subtitle: l10n.menuBudgetsDesc,
          onTap: () => context.push('/more/budgets'),
          tutorialKey: TutorialStepKeys.moreBudgetsItem,
        ),
        MoreEntry(
          icon: Icons.sync_rounded,
          label: l10n.menuRecurring,
          subtitle: l10n.menuRecurringDesc,
          onTap: () => context.push('/more/recurring'),
        ),
        MoreEntry(
          icon: Icons.handshake,
          label: l10n.menuLedger,
          subtitle: l10n.menuLedgerDesc,
          onTap: () => context.push('/more/ledger'),
        ),
        MoreEntry(
          icon: Icons.account_balance_outlined,
          label: l10n.menuLoans,
          subtitle: l10n.menuLoansDesc,
          onTap: () => context.push('/more/loans'),
        ),
        MoreEntry(
          icon: Icons.show_chart_rounded,
          label: l10n.menuInvestments,
          subtitle: l10n.menuInvestmentsDesc,
          onTap: () => context.push('/more/investments'),
        ),
      ],
    ),

    // ── Signature: Kuber's distinct feature set ─────────────────────────────
    MoreSection(
      id: MoreSectionId.signature,
      title: l10n.moreToolsTitle,
      entries: [
        MoreEntry(
          icon: Icons.auto_awesome_rounded,
          iconWidget: const KuberMarkWidget(size: 20, bare: true),
          label: l10n.menuAskKuber,
          subtitle: l10n.menuAskKuberDesc,
          onTap: () => context.push('/more/ask-kuber'),
          betaPill: true,
          tutorialKey: TutorialStepKeys.moreAskKuberItem,
        ),
        MoreEntry(
          icon: Icons.sms_outlined,
          label: 'Import from SMS',
          subtitle: 'Read bank SMS for transactions',
          onTap: () {
            if (proGate(context, ref, showSmsImportGateSheet)) {
              context.push('/more/sms-import');
            }
          },
        ),
        MoreEntry(
          icon: Icons.insert_chart_outlined_rounded,
          label: 'Advanced Analytics',
          subtitle: 'Deep analytical views of your finances',
          proPill: true,
          onTap: () {
            if (proGate(context, ref, showAdvancedAnalyticsGateSheet)) {
              context.push('/advanced-analytics');
            }
          },
        ),
        MoreEntry(
          icon: Icons.calculate_rounded,
          label: l10n.menuCalculators,
          subtitle: l10n.menuCalculatorsDesc,
          onTap: () => context.push('/more/tools'),
        ),
        MoreEntry(
          icon: Icons.sticky_note_2_outlined,
          label: 'Kuber Notes',
          subtitle: 'Jot expenses and do quick math',
          onTap: () => context.push('/more/notes'),
        ),
        MoreEntry(
          icon: Icons.credit_card_rounded,
          label: 'Kuber Cards',
          subtitle: 'Encrypted vault to save all your cards',
          onTap: () => context.push('/cards'),
        ),
        MoreEntry(
          icon: Icons.flash_on_rounded,
          label: 'Quick Add',
          subtitle: 'Type or speak to log transactions',
          onTap: () => context.push('/quick-add'),
        ),
        MoreEntry(
          icon: Icons.notifications_active_outlined,
          label: 'Reminders',
          subtitle: 'Never miss anything money-related',
          onTap: () => context.push('/more/reminders'),
        ),
      ],
    ),

    // ── App: settings + app-level views ─────────────────────────────────────
    MoreSection(
      id: MoreSectionId.app,
      title: l10n.moreAppTitle,
      entries: [
        MoreEntry(
          icon: Icons.settings,
          label: l10n.menuSettings,
          subtitle: l10n.menuSettingsDesc,
          onTap: () => context.push('/more/settings'),
        ),
        MoreEntry(
          icon: Icons.storage_rounded,
          label: l10n.menuData,
          subtitle: l10n.menuDataDesc,
          onTap: () => context.push('/more/data'),
          tutorialKey: TutorialStepKeys.moreDataItem,
        ),
        MoreEntry(
          icon: Icons.notifications_outlined,
          label: l10n.menuNotifications,
          subtitle: l10n.menuNotificationsDesc,
          onTap: () => openNotificationsSheet(context, ref),
        ),
        MoreEntry(
          icon: Icons.calendar_month_rounded,
          label: 'Upcoming Events',
          subtitle: 'Everything coming up, in one place',
          onTap: () => context.push('/more/upcoming-events'),
        ),
        MoreEntry(
          icon: Icons.auto_stories_rounded,
          label: l10n.menuStoriesArchive,
          subtitle: l10n.menuStoriesArchiveDesc,
          onTap: () => context.push('/more/stories-archive'),
        ),
        MoreEntry(
          icon: Icons.widgets_outlined,
          label: l10n.menuWidgets,
          subtitle: l10n.menuWidgetsDesc,
          onTap: () => context.push('/more/widgets-gallery'),
        ),
      ],
    ),

    // ── Tutorial ────────────────────────────────────────────────────────────
    MoreSection(
      id: MoreSectionId.tutorial,
      title: l10n.moreTutorialTitle,
      entries: [
        MoreEntry(
          icon: Icons.school_rounded,
          label: l10n.menuTutorial,
          subtitle: l10n.menuTutorialDesc,
          onTap: () => launchTutorialFromMore(context, ref),
        ),
        MoreEntry(
          icon: Icons.auto_stories_rounded,
          label: l10n.menuWelcomeTour,
          subtitle: l10n.menuWelcomeTourDesc,
          onTap: () => context.push('/onboarding?replay=true'),
        ),
      ],
    ),

    // ── About ───────────────────────────────────────────────────────────────
    MoreSection(
      id: MoreSectionId.about,
      title: l10n.moreAboutTitle,
      entries: [
        MoreEntry(
          icon: Icons.info_outline_rounded,
          label: l10n.menuAbout,
          subtitle: l10n.menuAboutDesc,
          onTap: () => context.pushNamed('about'),
        ),
        MoreEntry(
          icon: Icons.security_outlined,
          label: l10n.menuPermissions,
          subtitle: l10n.menuPermissionsDesc,
          onTap: () => context.pushNamed('permissions'),
        ),
        if (isDevMode)
          MoreEntry(
            icon: Icons.bug_report,
            label: l10n.menuDevTools,
            subtitle: l10n.menuDevToolsDesc,
            onTap: () => context.push('/more/dev-tools'),
          ),
      ],
    ),

    // ── Help us ─────────────────────────────────────────────────────────────
    MoreSection(
      id: MoreSectionId.helpUs,
      title: l10n.moreHelpUsTitle,
      hint: l10n.menuHelpUsHint,
      entries: [
        MoreEntry(
          icon: Icons.star_rate_rounded,
          label: l10n.menuRateKuber,
          subtitle: l10n.menuRateUsDesc,
          onTap: () => launchUrl(
            Uri.parse(
              'https://play.google.com/store/apps/details?id=com.grs.kuber',
            ),
            mode: LaunchMode.externalApplication,
          ),
        ),
        MoreEntry(
          icon: Icons.share_rounded,
          label: l10n.menuShare,
          subtitle: l10n.menuShareAppDesc,
          onTap: () => SharePlus.instance.share(
            ShareParams(text: l10n.shareMessage),
          ),
        ),
        MoreEntry(
          icon: Icons.feedback,
          label: l10n.menuFeedbackShort,
          subtitle: l10n.menuFeedbackDesc,
          onTap: () => context.push('/more/feedback'),
        ),
      ],
    ),
  ];
}

/// Opens the in-app notifications sheet. Shared by both More layouts (moved out
/// of the modern screen so the notifications row can live in the single content
/// source). Mirrors the dashboard's opener.
Future<void> openNotificationsSheet(
  BuildContext context,
  WidgetRef ref,
) async {
  final repo = ref.read(notificationRepositoryProvider);
  final list = await repo.list();
  if (!context.mounted) return;
  await NotificationsSheet.show(
    context,
    notifications: list,
    onClearAll: () async {
      await repo.clearAll();
    },
    onTapNotification: (n) async {
      await handleNotificationTap(context, ref, n);
    },
  );
  await repo.markAllRead();
}
