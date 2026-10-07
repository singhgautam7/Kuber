import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_loader.dart';
import '../../settings/providers/settings_provider.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../tutorial/providers/tutorial_provider.dart';
import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../../tutorial/services/tutorial_mock_data_service.dart';
import '../../pro/more/more_premium_card.dart';
import '../../pro/support/buy_me_coffee_section.dart' show BuyMeCoffeeButton;
import '../more_content.dart';
import '../widgets/more_header.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'more_screen_modern.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(moreTabLayoutProvider);
    // Classic <-> Modern cross-fades when the view changes (review round 3).
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: switch (layout) {
        MoreTabLayout.simple => const MoreScreenSimple(key: ValueKey('simple')),
        MoreTabLayout.modern => const MoreScreenModern(key: ValueKey('modern')),
      },
    );
  }
}

/// The classic ("simple") More layout (board 3.7): every section a grouped
/// list, numbered heads dropped, Help Us as a 3-tile strip. All content comes
/// from [buildMoreSections] (`more_content.dart`).
class MoreScreenSimple extends ConsumerWidget {
  const MoreScreenSimple({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;
    final sections = buildMoreSections(context, ref, isDevMode: isDevMode);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: MoreHeader()),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              KuberSpace.screenMargin,
              KuberSpace.xs,
              KuberSpace.screenMargin,
              navBarBottomPadding(context),
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const MorePremiumHeroCard(),
                const SizedBox(height: KuberSpace.sectionGap),
                for (final section in sections) ...[
                  if (section.id == MoreSectionId.helpUs)
                    MoreHelpUsStrip(section: section)
                  else ...[
                    KuberSectionHeader(title: section.title),
                    KuberGroup(
                      children: [
                        for (final e in section.entries) MoreEntryRow(entry: e),
                      ],
                    ),
                  ],
                  const SizedBox(height: KuberSpace.sectionGap),
                ],
                const MoreFooter(),
                const SizedBox(height: KuberSpace.xl),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

/// One More entry as a list row: 24 icon, title + subtitle, Beta pill,
/// chevron.
/// Icon on a 40 surfaceContainerHigh disc, the same treatment as the header
/// overflow button (review round 3).
class MoreIconDisc extends StatelessWidget {
  final MoreEntry entry;
  const MoreIconDisc({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: IconTheme(
        data: IconThemeData(color: cs.onSurfaceVariant, size: 20),
        child: entry.iconWidget != null
            ? SizedBox(width: 20, height: 20, child: entry.iconWidget)
            : Icon(entry.icon),
      ),
    );
  }
}

class MoreEntryRow extends StatelessWidget {
  final MoreEntry entry;
  const MoreEntryRow({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return KuberListRow(
      key: entry.tutorialKey,
      leading: MoreIconDisc(entry: entry),
      title: splitTrailingTag(entry.label).$1,
      subtitle: entry.subtitle,
      // No Pro pills on More rows (review round 2); Beta is a pill, never
      // brackets in the label.
      titleTrailing: entry.betaPill || splitTrailingTag(entry.label).$2 != null
          ? KuberPill(label: splitTrailingTag(entry.label).$2 ?? 'Beta')
          : null,
      trailing: const KuberChevron(),
      onTap: entry.onTap,
    );
  }
}

/// Help Us: section header with the hint, three 88 tiles (Rate in the warning
/// container), then Buy me a coffee.
class MoreHelpUsStrip extends StatelessWidget {
  final MoreSection section;
  const MoreHelpUsStrip({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        KuberSectionHeader(
          title: section.title,
          trailing: section.hint == null
              ? null
              : Text(
                  section.hint!,
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        Row(
          spacing: KuberSpace.sm,
          children: [
            for (var i = 0; i < section.entries.length; i++)
              Expanded(
                child: KuberCard(
                  padding: EdgeInsets.zero,
                  onTap: section.entries[i].onTap,
                  child: SizedBox(
                    height: 88,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        KuberIconTile(
                          icon: section.entries[i].icon,
                          tone: i == 0
                              ? KuberTone.warning
                              : KuberTone.secondary,
                        ),
                        const SizedBox(height: KuberSpace.sm),
                        Text(
                          section.entries[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: KuberSpace.md),
        const BuyMeCoffeeButton(),
      ],
    );
  }
}

/// "Made with ♥ in India · vX" footer, bodySmall.
class MoreFooter extends StatelessWidget {
  const MoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final parts = context.l10n.madeInIndia('{heart}').split('{heart}');
    final style = theme.textTheme.bodySmall!.copyWith(
      color: cs.onSurfaceVariant,
    );
    return Center(
      child: Text.rich(
        TextSpan(
          style: style,
          children: [
            TextSpan(text: parts.first),
            TextSpan(
              text: '♥',
              style: style.copyWith(color: context.kuberMoney.expense),
            ),
            if (parts.length > 1) TextSpan(text: parts.last),
          ],
        ),
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
