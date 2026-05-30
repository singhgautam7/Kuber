// "Modern" layout for the More tab.
//
// This is the second option that replaces the uniform card-with-rows of the
// current Simple layout. Each section uses a density that matches how often
// users tap into it:
//   - MANAGE   → hero card for Accounts, 2-col tile grid for the rest,
//                wide Investments card at the foot
//   - TOOLS    → two featured cards (Ask Kuber w/ warning gradient, Calculators w/ primary gradient)
//   - APP      → compact list (settings, data, troubleshoot)
//   - TUTORIAL → dense rows, no card chrome
//   - HELP US  → 3-tile action strip
//   - ABOUT    → footnote with inline text links + version stamp
//
// Routing: identical to the Simple layout — every onTap reuses the existing
// `/more/<route>` destinations from `app_router.dart`. Nothing else changes.
//
// Behaviour wired to providers in the existing Simple layout (dev mode,
// tutorial launcher) is preserved here. The MoreScreen wrapper should branch
// on `settings.moreTabLayout`:
//
//   return switch (style) {
//     MoreTabLayout.simple => const MoreScreenSimple(),
//     MoreTabLayout.modern => const MoreScreenModern(),
//   };

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../accounts/providers/account_provider.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../notifications/providers/notification_provider.dart';
import '../../notifications/utils/deep_link_handler.dart';
import '../../notifications/widgets/notifications_sheet.dart';
import '../../settings/providers/settings_provider.dart'
    show appVersionProvider;
import '../../tutorial/models/tutorial_step_keys.dart';
// TODO: re-use the existing `launchTutorialFromMore(context, ref)` helper
// declared in more_screen.dart — export it from there or move it into a
// shared helper file in lib/features/more/.
import '../screens/more_screen.dart' show launchTutorialFromMore;

class MoreScreenModern extends ConsumerWidget {
  const MoreScreenModern({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? const [];
    final accountCount = accounts.length;

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
                // 01 / MANAGE -------------------------------------------------
                const _GroupHead(num: '01', name: 'Manage', hint: '8 spaces'),
                _HeroTile(
                  icon: Icons.account_balance_wallet,
                  label: 'ACCOUNTS',
                  title: 'Your wallets and\nbank accounts',
                  meta:
                      '$accountCount account${accountCount == 1 ? '' : 's'} tracked',
                  onTap: () => context.push('/more/accounts'),
                ),
                const SizedBox(height: KuberSpacing.sm),
                _ManageGrid(
                  items: [
                    _ManageTileData(
                      icon: Icons.category,
                      label: 'Categories',
                      sub: 'Organize transactions',
                      onTap: () => context.push('/more/categories'),
                    ),
                    _ManageTileData(
                      icon: Icons.label_rounded,
                      label: 'Tags',
                      sub: 'Labels for entries',
                      onTap: () => context.push('/more/tags'),
                    ),
                    _ManageTileData(
                      key: TutorialStepKeys.moreBudgetsItem,
                      icon: Icons.pie_chart_rounded,
                      label: 'Budgets',
                      sub: 'Monthly spending limits',
                      onTap: () => context.push('/more/budgets'),
                    ),
                    _ManageTileData(
                      icon: Icons.sync_rounded,
                      label: 'Recurring',
                      sub: 'Scheduled transactions',
                      onTap: () => context.push('/more/recurring'),
                    ),
                    _ManageTileData(
                      icon: Icons.handshake,
                      label: 'Lend / Borrow',
                      sub: 'Money you owe or are owed',
                      onTap: () => context.push('/more/ledger'),
                    ),
                    _ManageTileData(
                      icon: Icons.account_balance_outlined,
                      label: 'Loans',
                      sub: 'EMIs and repayment',
                      onTap: () => context.push('/more/loans'),
                    ),
                    _ManageTileData(
                      icon: Icons.show_chart_rounded,
                      label: 'Investments',
                      sub: 'Portfolio and growth',
                      onTap: () => context.push('/more/investments'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // 02 / TOOLS --------------------------------------------------
                const _GroupHead(num: '02', name: 'Tools'),
                Row(
                  children: [
                    Expanded(
                      child: _ToolCard(
                        key: TutorialStepKeys.moreAskKuberItem,
                        icon: Icons.auto_awesome_rounded,
                        title: 'Ask Kuber',
                        subtitle: 'On-device smart assistant',
                        accent: _ToolAccent.warning,
                        showBetaPill: true,
                        onTap: () => context.push('/more/ask-kuber'),
                      ),
                    ),
                    const SizedBox(width: KuberSpacing.sm),
                    Expanded(
                      child: _ToolCard(
                        icon: Icons.calculate_rounded,
                        title: 'Calculators',
                        subtitle: 'EMI, SIP, salary, GST, split & more',
                        accent: _ToolAccent.primary,
                        onTap: () => context.push('/more/tools'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // 03 / APP ----------------------------------------------------
                const _GroupHead(num: '03', name: 'App'),
                _CompactList(
                  rows: [
                    _CompactRowData(
                      icon: Icons.settings,
                      label: 'Settings',
                      sub: 'Theme, currency, profile',
                      onTap: () => context.push('/more/settings'),
                    ),
                    _CompactRowData(
                      key: TutorialStepKeys.moreDataItem,
                      icon: Icons.storage_rounded,
                      label: 'Data',
                      sub: 'Export, import, automatic backups',
                      onTap: () => context.push('/more/data'),
                    ),
                    _CompactRowData(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      sub: 'Recent alerts and reminders',
                      onTap: () => _openNotificationsSheet(context, ref),
                    ),
                    _CompactRowData(
                      icon: Icons.auto_stories_rounded,
                      label: 'Money Stories Archive',
                      sub: 'Every recap, newest first',
                      onTap: () => context.push('/more/stories-archive'),
                    ),
                    _CompactRowData(
                      icon: Icons.build,
                      label: 'Troubleshoot',
                      sub: 'Fix data and suggestion issues',
                      onTap: () => context.push('/more/troubleshoot'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // 04 / TUTORIAL -----------------------------------------------
                const _GroupHead(num: '04', name: 'Tutorial'),
                _DenseList(
                  rows: [
                    _DenseRowData(
                      icon: Icons.school_rounded,
                      label: 'App Tutorial',
                      labelSuffix: '(Beta)',
                      onTap: () => launchTutorialFromMore(context, ref),
                    ),
                    _DenseRowData(
                      icon: Icons.auto_stories_rounded,
                      label: 'Welcome Tour',
                      onTap: () => context.push('/onboarding?replay=true'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // 05 / CONTACT US ---------------------------------------------
                const _GroupHead(num: '05', name: 'Contact Us'),
                _DenseList(
                  rows: [
                    _DenseRowData(
                      icon: Icons.info_outline_rounded,
                      label: 'About Kuber',
                      onTap: () => context.pushNamed('about'),
                    ),
                    _DenseRowData(
                      icon: Icons.security_outlined,
                      label: 'Permissions',
                      onTap: () => context.pushNamed('permissions'),
                    ),
                    if (isDevMode)
                      _DenseRowData(
                        icon: Icons.bug_report,
                        label: 'Dev Tools',
                        onTap: () => context.push('/more/dev-tools'),
                      ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // 06 / HELP US ------------------------------------------------
                const _GroupHead(
                  num: '06',
                  name: 'Help Us',
                  hint: 'Tap to support',
                ),
                _HelpStrip(
                  actions: [
                    _HelpAction(
                      icon: Icons.star_rate_rounded,
                      label: 'Rate Kuber',
                      accent: _HelpAccent.warning,
                      onTap: () => launchUrl(
                        Uri.parse(
                          'https://play.google.com/store/apps/details?id=com.grs.kuber',
                        ),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                    _HelpAction(
                      icon: Icons.share_rounded,
                      label: 'Share',
                      onTap: () => SharePlus.instance.share(
                        ShareParams(
                          text:
                              'Manage your expenses like never before. Kuber is a '
                              'beautifully simple expense manager, made with love '
                              'in India. Download it here: '
                              'https://play.google.com/store/apps/details?id=com.grs.kuber',
                        ),
                      ),
                    ),
                    _HelpAction(
                      icon: Icons.feedback,
                      label: 'Feedback',
                      onTap: () => context.push('/more/feedback'),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xxl),

                // FOOTER ------------------------------------------------------
                const _MadeInIndiaFooter(),
                const SizedBox(height: KuberSpacing.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Group header
// ---------------------------------------------------------------------------

class _GroupHead extends StatelessWidget {
  final String num;
  final String name;
  final String? hint;
  const _GroupHead({required this.num, required this.name, this.hint});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            num,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Text(
            name.toUpperCase(),
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: cs.primary,
              letterSpacing: 1.2,
            ),
          ),
          if (hint case final h?) ...[
            const Spacer(),
            Text(
              h,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Hero tile (Manage / Investments)
// ---------------------------------------------------------------------------

class _HeroTile extends StatelessWidget {
  final IconData icon;
  final String label; // eyebrow
  final String title;
  final String meta;
  final VoidCallback onTap;

  const _HeroTile({
    required this.icon,
    required this.label,
    required this.title,
    required this.meta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = cs.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: cs.outline),
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [
                Color.alphaBlend(
                  accentColor.withValues(alpha: 0.16),
                  cs.surfaceContainer,
                ),
                cs.surfaceContainer,
              ],
              stops: const [0.0, 0.75],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.all(KuberSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(KuberRadius.lg),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.25),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 26, color: accentColor),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.4,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meta,
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
                color: cs.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Manage tile grid (2 cols)
// ---------------------------------------------------------------------------

class _ManageTileData {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final Key? key;
  _ManageTileData({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.key,
  });
}

class _ManageGrid extends StatelessWidget {
  final List<_ManageTileData> items;
  const _ManageGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    // Manual Column-of-Rows so the last (odd) row only takes one tile's
    // height instead of reserving an empty second cell — keeps the gap
    // before the next section consistent regardless of item count.
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = KuberSpacing.sm;
        final tileWidth = (constraints.maxWidth - gap) / 2;
        final tileHeight = tileWidth / 1.45;
        final rows = <Widget>[];
        for (int i = 0; i < items.length; i += 2) {
          if (i > 0) rows.add(const SizedBox(height: gap));
          final left = items[i];
          final right = i + 1 < items.length ? items[i + 1] : null;
          rows.add(
            SizedBox(
              height: tileHeight,
              child: Row(
                children: [
                  Expanded(child: _ManageTile(data: left)),
                  const SizedBox(width: gap),
                  Expanded(
                    child: right != null
                        ? _ManageTile(data: right)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(children: rows);
      },
    );
  }
}

class _ManageTile extends StatelessWidget {
  final _ManageTileData data;
  const _ManageTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      key: data.key,
      color: Colors.transparent,
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: cs.outline),
          ),
          padding: const EdgeInsets.all(KuberSpacing.md + 2),
          // `spaceBetween` distributes the two halves to the top/bottom of
          // the tile; the redundant SizedBox between them used to push the
          // intrinsic height ~12 px past the cell, overflowing by ~0.7 px
          // on a single-line subtitle and 16 px when subtitle wrapped.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(KuberRadius.md + 2),
                      border: Border.all(
                        color: cs.primary.withValues(alpha: 0.25),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(data.icon, size: 18, color: cs.primary),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    data.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.1,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tool cards (featured pair)
// ---------------------------------------------------------------------------

enum _ToolAccent { primary, warning }

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final _ToolAccent accent;
  final bool showBetaPill;
  final VoidCallback onTap;
  const _ToolCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.accent,
    this.showBetaPill = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Warning color is brand-stable across themes; pull from KuberColors
    // via a fallback because ColorScheme has no `warning` slot.
    final accentColor = switch (accent) {
      _ToolAccent.primary => cs.primary,
      _ToolAccent.warning => const Color(
        0xFFFFB300,
      ), // matches existing Ask Kuber color
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          height: 156,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: accentColor.withValues(alpha: 0.30)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [accentColor.withValues(alpha: 0.13), Colors.transparent],
              stops: const [0.0, 0.7],
            ),
          ),
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.30),
                      ),
                      borderRadius: BorderRadius.circular(KuberRadius.md + 4),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 22, color: accentColor),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11.5,
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (showBetaPill)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.30),
                      ),
                      borderRadius: BorderRadius.circular(KuberRadius.sm),
                    ),
                    child: Text(
                      'BETA',
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: accentColor,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Compact list (App)
// ---------------------------------------------------------------------------

class _CompactRowData {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  final Key? key;
  _CompactRowData({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.key,
  });
}

class _CompactList extends StatelessWidget {
  final List<_CompactRowData> rows;
  const _CompactList({required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: cs.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _CompactRow(data: rows[i]),
            if (i < rows.length - 1) Container(height: 1, color: cs.outline),
          ],
        ],
      ),
    );
  }
}

class _CompactRow extends StatelessWidget {
  final _CompactRowData data;
  const _CompactRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      key: data.key,
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(KuberRadius.md + 1),
              ),
              alignment: Alignment.center,
              child: Icon(data.icon, size: 18, color: cs.primary),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    data.sub,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dense list (Tutorial) — no surrounding card, hairline dividers
// ---------------------------------------------------------------------------

class _DenseRowData {
  final IconData icon;
  final String label;
  final String? labelSuffix;
  final VoidCallback onTap;
  _DenseRowData({
    required this.icon,
    required this.label,
    this.labelSuffix,
    required this.onTap,
  });
}

class _DenseList extends StatelessWidget {
  final List<_DenseRowData> rows;
  const _DenseList({required this.rows});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        for (int i = 0; i < rows.length; i++) ...[
          _DenseRow(data: rows[i]),
          if (i < rows.length - 1) Container(height: 1, color: cs.outline),
        ],
      ],
    );
  }
}

class _DenseRow extends StatelessWidget {
  final _DenseRowData data;
  const _DenseRow({required this.data});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: data.onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 10),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
                borderRadius: BorderRadius.circular(KuberRadius.md - 1),
              ),
              alignment: Alignment.center,
              child: Icon(data.icon, size: 15, color: cs.primary),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Text.rich(
                TextSpan(
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                  children: [
                    TextSpan(text: data.label),
                    if (data.labelSuffix case final suffix?) ...[
                      const TextSpan(text: '  '),
                      TextSpan(
                        text: suffix,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Help Us — 3-action strip
// ---------------------------------------------------------------------------

enum _HelpAccent { primary, warning }

class _HelpAction {
  final IconData icon;
  final String label;
  final _HelpAccent accent;
  final VoidCallback onTap;
  _HelpAction({
    required this.icon,
    required this.label,
    this.accent = _HelpAccent.primary,
    required this.onTap,
  });
}

class _HelpStrip extends StatelessWidget {
  final List<_HelpAction> actions;
  const _HelpStrip({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < actions.length; i++) ...[
          Expanded(child: _HelpTile(action: actions[i])),
          if (i < actions.length - 1) const SizedBox(width: KuberSpacing.sm),
        ],
      ],
    );
  }
}

class _HelpTile extends StatelessWidget {
  final _HelpAction action;
  const _HelpTile({required this.action});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accentColor = switch (action.accent) {
      _HelpAccent.primary => cs.primary,
      _HelpAccent.warning => const Color(0xFFFFB300),
    };

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.12),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.30),
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(action.icon, size: 18, color: accentColor),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                action.label,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                  letterSpacing: -0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Made-in-India footer (icon + line + version stamp)
// ---------------------------------------------------------------------------

class _MadeInIndiaFooter extends ConsumerWidget {
  const _MadeInIndiaFooter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final version = ref.watch(appVersionProvider).valueOrNull;
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.inter(
          fontSize: 11.5,
          fontWeight: FontWeight.w500,
          color: cs.onSurfaceVariant,
        ),
        children: [
          const TextSpan(text: 'Made with '),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Icon(
              Icons.favorite_rounded,
              color: Colors.redAccent,
              size: 13,
            ),
          ),
          TextSpan(
            text: version != null ? ' in India · v$version' : ' in India',
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifications sheet opener — mirrors dashboard's _openNotificationsSheet
// ---------------------------------------------------------------------------

Future<void> _openNotificationsSheet(
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
