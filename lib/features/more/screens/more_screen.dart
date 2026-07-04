import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_loader.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/widgets/settings_widgets.dart';
import '../../settings/providers/settings_provider.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../tutorial/providers/tutorial_provider.dart';
import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../../tutorial/services/tutorial_mock_data_service.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../../ask_kuber/screen/kuber_mark.dart';
import 'more_screen_modern.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(moreTabLayoutProvider);
    return switch (layout) {
      MoreTabLayout.simple => const MoreScreenSimple(),
      MoreTabLayout.modern => const MoreScreenModern(),
    };
  }
}

class MoreScreenSimple extends ConsumerWidget {
  const MoreScreenSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;

    final footerHeartParts = context.l10n.madeInIndia('{heart}').split('{heart}');
    final footerBefore = footerHeartParts.first;
    final footerAfter = footerHeartParts.length > 1 ? footerHeartParts.last : '';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: KuberSpacing.xl)),
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: context.l10n.navMore,
              description: context.l10n.moreManageSubtitle,
              actionIcon: Icons.search_rounded,
              actionTooltip: context.l10n.moreSearchTooltip,
              onAction: () => context.push('/more/search'),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.only(
              left: KuberSpacing.lg,
              right: KuberSpacing.lg,
              bottom: navBarBottomPadding(context),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Manage section
                _MenuSection(
                  title: context.l10n.moreManageTitle,
                  items: [
                    _MenuItem(
                      icon: Icons.account_balance_wallet,
                      label: context.l10n.menuAccounts,
                      subtitle: context.l10n.menuAccountsDesc,
                      onTap: () => context.push('/more/accounts'),
                    ),
                    _MenuItem(
                      icon: Icons.category,
                      label: context.l10n.menuCategories,
                      subtitle: context.l10n.menuCategoriesDesc,
                      onTap: () => context.push('/more/categories'),
                    ),
                    _MenuItem(
                      icon: Icons.label_rounded,
                      label: context.l10n.menuTags,
                      subtitle: context.l10n.menuTagsDesc,
                      onTap: () => context.push('/more/tags'),
                    ),
                    _MenuItem(
                      key: TutorialStepKeys.moreBudgetsItem,
                      icon: Icons.pie_chart_rounded,
                      label: context.l10n.menuBudgets,
                      subtitle: context.l10n.menuBudgetsDesc,
                      onTap: () => context.push('/more/budgets'),
                    ),
                    _MenuItem(
                      icon: Icons.sync_rounded,
                      label: context.l10n.menuRecurring,
                      subtitle: context.l10n.menuRecurringDesc,
                      onTap: () => context.push('/more/recurring'),
                    ),
                    _MenuItem(
                      icon: Icons.handshake,
                      label: context.l10n.menuLedger,
                      subtitle: context.l10n.menuLedgerDesc,
                      onTap: () => context.push('/more/ledger'),
                    ),
                    _MenuItem(
                      icon: Icons.account_balance_outlined,
                      label: context.l10n.menuLoans,
                      subtitle: context.l10n.menuLoansDesc,
                      onTap: () => context.push('/more/loans'),
                    ),
                    _MenuItem(
                      icon: Icons.show_chart,
                      label: context.l10n.menuInvestments,
                      subtitle: context.l10n.menuInvestmentsDesc,
                      onTap: () => context.push('/more/investments'),
                    ),
                    // Reminders (English-only feature, like SMS import).
                    _MenuItem(
                      icon: Icons.notifications_active_outlined,
                      label: 'Reminders',
                      subtitle: 'Never miss anything money-related',
                      onTap: () => context.push('/more/reminders'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Tools section
                _MenuSection(
                  title: context.l10n.moreToolsTitle,
                  items: [
                    _MenuItem(
                      key: TutorialStepKeys.moreAskKuberItem,
                      icon: Icons.auto_awesome_rounded,
                      label: context.l10n.menuAskKuber,
                      subtitle: context.l10n.menuAskKuberDesc,
                      iconWidget: const KuberMarkWidget(size: 20, bare: true),
                      onTap: () => context.push('/more/ask-kuber'),
                    ),
                    // SMS import (English-only feature, like Ask Kuber).
                    _MenuItem(
                      icon: Icons.sms_outlined,
                      label: 'Import from SMS',
                      subtitle: 'Read bank SMS for transactions',
                      onTap: () => context.push('/more/sms-import'),
                    ),
                    _MenuItem(
                      icon: Icons.calculate_rounded,
                      label: context.l10n.menuCalculators,
                      subtitle: context.l10n.menuCalculatorsDesc,
                      onTap: () => context.push('/more/tools'),
                    ),
                    // Kuber Notes + Upcoming Events (English-only features).
                    _MenuItem(
                      icon: Icons.sticky_note_2_outlined,
                      label: 'Kuber Notes',
                      subtitle: 'Jot expenses and do quick math',
                      onTap: () => context.push('/more/notes'),
                    ),
                    _MenuItem(
                      icon: Icons.calendar_month_rounded,
                      label: 'Upcoming Events',
                      subtitle: 'Everything coming up, in one place',
                      onTap: () => context.push('/more/upcoming-events'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // App section
                _MenuSection(
                  title: context.l10n.moreAppTitle,
                  items: [
                    _MenuItem(
                      icon: Icons.settings,
                      label: context.l10n.menuSettings,
                      subtitle: context.l10n.menuSettingsDesc,
                      onTap: () => context.push('/more/settings'),
                    ),
                    _MenuItem(
                      key: TutorialStepKeys.moreDataItem,
                      icon: Icons.storage_rounded,
                      label: context.l10n.menuData,
                      subtitle: context.l10n.menuDataDesc,
                      onTap: () => context.push('/more/data'),
                    ),
                    _MenuItem(
                      icon: Icons.auto_stories_rounded,
                      label: context.l10n.menuStoriesArchive,
                      subtitle: context.l10n.menuStoriesArchiveDesc,
                      onTap: () => context.push('/more/stories-archive'),
                    ),
                    _MenuItem(
                      icon: Icons.build,
                      label: context.l10n.menuTroubleshoot,
                      subtitle: context.l10n.menuTroubleshootDesc,
                      onTap: () => context.push('/more/troubleshoot'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Tutorial Section
                _MenuSection(
                  title: context.l10n.moreTutorialTitle,
                  items: [
                    _MenuItem(
                      icon: Icons.school_rounded,
                      label: context.l10n.menuTutorial,
                      subtitle: context.l10n.menuTutorialDesc,
                      onTap: () => launchTutorialFromMore(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.auto_stories_rounded,
                      label: context.l10n.menuWelcomeTour,
                      subtitle: context.l10n.menuWelcomeTourDesc,
                      onTap: () => context.push('/onboarding?replay=true'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Contact Us section
                _MenuSection(
                  title: context.l10n.moreHelpUsTitle,
                  items: [
                    _MenuItem(
                      icon: Icons.star_rate_rounded,
                      label: context.l10n.menuRateUs,
                      subtitle: context.l10n.menuRateUsDesc,
                      onTap: () {
                        launchUrl(
                          Uri.parse(
                            'https://play.google.com/store/apps/details?id=com.grs.kuber',
                          ),
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.share_rounded,
                      label: context.l10n.menuShareApp,
                      subtitle: context.l10n.menuShareAppDesc,
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: context.l10n.shareMessage,
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.feedback,
                      label: context.l10n.menuFeedback,
                      subtitle: context.l10n.menuFeedbackDesc,
                      onTap: () => context.push('/more/feedback'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // About section
                _MenuSection(
                  title: context.l10n.moreAboutTitle,
                  items: [
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: context.l10n.menuAbout,
                      subtitle: context.l10n.menuAboutDesc,
                      onTap: () => context.pushNamed('about'),
                    ),
                    _MenuItem(
                      icon: Icons.security_outlined,
                      label: context.l10n.menuPermissions,
                      subtitle: context.l10n.menuPermissionsDesc,
                      onTap: () => context.pushNamed('permissions'),
                    ),
                    if (isDevMode)
                      _MenuItem(
                        icon: Icons.bug_report,
                        label: context.l10n.menuDevTools,
                        subtitle: context.l10n.menuDevToolsDesc,
                        onTap: () => context.push('/more/dev-tools'),
                      ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xxl),

                // Footer
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        style: localeFont(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(text: footerBefore),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 14,
                            ),
                          ),
                          TextSpan(text: footerAfter),
                        ],
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> launchTutorialFromMore(BuildContext context, WidgetRef ref) async {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const KuberLoader(label: 'Preparing tutorial...'),
  );

  try {
    final currentSandbox = ref.read(tutorialSandboxIsarProvider);
    if (currentSandbox != null) {
      await closeSandboxIsar(currentSandbox);
      ref.read(tutorialSandboxIsarProvider.notifier).state = null;
    }
    final sandbox = await openSandboxIsar();
    ref.read(tutorialSandboxIsarProvider.notifier).state = sandbox;
    await TutorialMockDataService().generateMockData(sandbox);
    ref.read(tutorialNotifierProvider.notifier).setSandboxMode(true);
  } finally {
    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  if (context.mounted) context.push('/tutorial');
}

class _MenuSection extends StatelessWidget {
  final String title;
  final List<_MenuItem> items;

  const _MenuSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: localeFont(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        Material(
          color: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            side: BorderSide(color: cs.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(height: 1, color: cs.outline, indent: 52),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? iconWidget;

  const _MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconWidget,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: icon, glyph: iconWidget),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}