import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../pro/more/more_premium_card.dart';
import '../../pro/support/buy_me_coffee_section.dart' show BuyMeCoffeeButton;
import '../more_content.dart';
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

/// The classic ("simple") More layout: a uniform list of bordered sections.
/// All content comes from [buildMoreSections] (the single source of truth in
/// `more_content.dart`); this screen only maps each entry to a `_MenuItem`.
class MoreScreenSimple extends ConsumerWidget {
  const MoreScreenSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;

    final footerHeartParts = context.l10n
        .madeInIndia('{heart}')
        .split('{heart}');
    final footerBefore = footerHeartParts.first;
    final footerAfter = footerHeartParts.length > 1
        ? footerHeartParts.last
        : '';

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: SizedBox(height: KuberSpacing.xl)),
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: context.l10n.navMore,
              description: context.l10n.moreManageSubtitle,
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
                const MorePremiumCardClassic(),
                const SizedBox(height: KuberSpacing.xl),
                for (final section
                    in buildMoreSections(context, ref, isDevMode: isDevMode)) ...[
                  _MenuSection(
                    title: section.title,
                    items: [
                      for (final e in section.entries)
                        _MenuItem(
                          key: e.tutorialKey,
                          icon: e.icon,
                          iconWidget: e.iconWidget,
                          label: e.label,
                          subtitle: e.subtitle,
                          showProPill: e.proPill,
                          onTap: e.onTap,
                        ),
                    ],
                  ),
                  const SizedBox(height: KuberSpacing.xl),
                ],
                const BuyMeCoffeeButton(),
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
  final bool showProPill;

  const _MenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    this.iconWidget,
    this.showProPill = false,
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
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            if (showProPill) ...[
              const SizedBox(width: KuberSpacing.sm),
              _ProPill(color: cs.primary),
            ],
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

class _ProPill extends StatelessWidget {
  final Color color;

  const _ProPill({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
      ),
      child: Text(
        'PRO',
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: color,
        ),
      ),
    );
  }
}
