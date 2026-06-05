import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: KuberSpacing.xl)),
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'More',
              description: 'Manage your settings, tools and data',
              actionIcon: Icons.search_rounded,
              actionTooltip: 'Search',
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
                  title: 'Manage',
                  items: [
                    _MenuItem(
                      icon: Icons.account_balance_wallet,
                      label: 'Accounts',
                      subtitle: 'Your wallets and bank accounts',
                      onTap: () => context.push('/more/accounts'),
                    ),
                    _MenuItem(
                      icon: Icons.category,
                      label: 'Categories',
                      subtitle: 'Organize your transactions',
                      onTap: () => context.push('/more/categories'),
                    ),
                    _MenuItem(
                      icon: Icons.label_rounded,
                      label: 'Tags',
                      subtitle: 'Organize the labels for your transactions',
                      onTap: () => context.push('/more/tags'),
                    ),
                    _MenuItem(
                      key: TutorialStepKeys.moreBudgetsItem,
                      icon: Icons.pie_chart_rounded,
                      label: 'Budgets',
                      subtitle: 'Track and control your monthly spending',
                      onTap: () => context.push('/more/budgets'),
                    ),
                    _MenuItem(
                      icon: Icons.sync_rounded,
                      label: 'Recurring Transactions',
                      subtitle: 'Automated scheduled transactions',
                      onTap: () => context.push('/more/recurring'),
                    ),
                    _MenuItem(
                      icon: Icons.handshake,
                      label: 'Lend / Borrow',
                      subtitle: 'Track money you lent or borrowed',
                      onTap: () => context.push('/more/ledger'),
                    ),
                    _MenuItem(
                      icon: Icons.account_balance_outlined,
                      label: 'Loans',
                      subtitle: 'Track EMIs and repayment progress',
                      onTap: () => context.push('/more/loans'),
                    ),
                    _MenuItem(
                      icon: Icons.show_chart,
                      label: 'Investments',
                      subtitle: 'Track portfolio value and growth',
                      onTap: () => context.push('/more/investments'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Tools section
                _MenuSection(
                  title: 'Tools',
                  items: [
                    _MenuItem(
                      key: TutorialStepKeys.moreAskKuberItem,
                      icon: Icons.auto_awesome_rounded,
                      label: 'Ask Kuber (Beta)',
                      subtitle: 'On-device smart assistant',
                      color: const Color(0xFFFFB300),
                      onTap: () => context.push('/more/ask-kuber'),
                    ),
                    _MenuItem(
                      icon: Icons.calculate_rounded,
                      label: 'Calculators & Tools',
                      subtitle: 'EMI, SIP, salary, GST, split & more',
                      onTap: () => context.push('/more/tools'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // App section
                _MenuSection(
                  title: 'App',
                  items: [
                    _MenuItem(
                      icon: Icons.settings,
                      label: 'Settings',
                      subtitle: 'Theme, currency, and profile',
                      onTap: () => context.push('/more/settings'),
                    ),
                    _MenuItem(
                      key: TutorialStepKeys.moreDataItem,
                      icon: Icons.storage_rounded,
                      label: 'Data',
                      subtitle: 'Export, import, automatic backups',
                      onTap: () => context.push('/more/data'),
                    ),
                    _MenuItem(
                      icon: Icons.auto_stories_rounded,
                      label: 'Money Stories Archive',
                      subtitle: 'Every recap, newest first',
                      onTap: () => context.push('/more/stories-archive'),
                    ),
                    _MenuItem(
                      icon: Icons.build,
                      label: 'Troubleshoot',
                      subtitle: 'Fix data and suggestion issues',
                      onTap: () => context.push('/more/troubleshoot'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Tutorial Section
                _MenuSection(
                  title: 'Tutorial',
                  items: [
                    _MenuItem(
                      icon: Icons.school_rounded,
                      label: 'App Tutorial (Beta)',
                      subtitle: 'Replay the feature walkthrough',
                      onTap: () => launchTutorialFromMore(context, ref),
                    ),
                    _MenuItem(
                      icon: Icons.auto_stories_rounded,
                      label: 'Welcome Tour',
                      subtitle: 'Replay the welcome and setup screens',
                      onTap: () => context.push('/onboarding?replay=true'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // Contact Us section
                _MenuSection(
                  title: 'Help Us',
                  items: [
                    _MenuItem(
                      icon: Icons.star_rate_rounded,
                      label: 'Rate Us on Play Store',
                      subtitle: 'Enjoying Kuber? Leave a review',
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
                      label: 'Share This App',
                      subtitle: 'Recommend Kuber to friends and family',
                      onTap: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text:
                                'Manage your expenses like never before. Kuber is a beautifully simple expense manager, made with love in India. Download it here: https://play.google.com/store/apps/details?id=com.grs.kuber',
                          ),
                        );
                      },
                    ),
                    _MenuItem(
                      icon: Icons.feedback,
                      label: 'Submit a Feedback',
                      subtitle: 'Report a bug or suggest a feature',
                      onTap: () => context.push('/more/feedback'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // About section
                _MenuSection(
                  title: 'About',
                  items: [
                    _MenuItem(
                      icon: Icons.info_outline_rounded,
                      label: 'About Kuber',
                      subtitle: 'Vision, origin, and developer',
                      onTap: () => context.pushNamed('about'),
                    ),
                    _MenuItem(
                      icon: Icons.security_outlined,
                      label: 'Permissions',
                      subtitle: 'App limits and security',
                      onTap: () => context.pushNamed('permissions'),
                    ),
                    if (isDevMode)
                      _MenuItem(
                        icon: Icons.bug_report,
                        label: 'Dev Tools',
                        subtitle: 'Developer-only tools',
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
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurfaceVariant,
                        ),
                        children: [
                          const TextSpan(text: "Made with "),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.favorite_rounded,
                              color: Colors.redAccent,
                              size: 14,
                            ),
                          ),
                          const TextSpan(text: " in India"),
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
          style: GoogleFonts.inter(
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
  final Color? color;

  const _MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.color,
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
            SquircleIcon(icon: icon, color: color ?? cs.primary),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
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
