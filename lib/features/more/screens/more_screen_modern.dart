// "Modern" layout for the More tab (board 3.7 + review round 3): the slim
// Kuber Pro strip and the Manage grid with live counts, then the previous
// design's sections restored in M3 styling: a 2-column Signature card grid,
// App / Tutorial / About lists, Help us (with Buy me a coffee) and the footer.
// Routing and entries come from more_content.dart, same as the Classic layout.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kuber/core/utils/l10n_ext.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../accounts/providers/account_provider.dart';
import '../../budgets/providers/budget_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../investments/providers/investment_provider.dart';
import '../../ledger/providers/ledger_provider.dart';
import '../../loans/providers/loan_provider.dart';
import '../../pro/more/more_premium_card.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../more_content.dart';
import '../widgets/more_header.dart';
import 'more_screen.dart' show MoreHelpUsStrip, MoreFooter, MoreIconDisc;

class MoreScreenModern extends ConsumerWidget {
  const MoreScreenModern({super.key});

  /// Live captions for the Manage tiles, in [MoreSectionId.manage] order:
  /// accounts, categories, tags, budgets, recurring, ledger, loans,
  /// investments. Each watch is narrowed to a count.
  List<String?> _manageCaptions(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    int? n<T>(ProviderListenable<AsyncValue<List<T>>> p,
            [bool Function(T)? where]) =>
        ref.watch(p.select((a) {
          final list = a.valueOrNull;
          if (list == null) return null;
          return where == null ? list.length : list.where(where).length;
        }));
    String? fmt(int? c, String Function(int) f) => c == null ? null : f(c);
    return [
      fmt(n(accountListProvider), l.moreCountAccounts),
      fmt(n(categoryListProvider), l.moreCountCategories),
      fmt(n(tagListProvider), l.moreCountTags),
      fmt(n(budgetListProvider, (b) => b.isActive), l.moreCountActive),
      fmt(n(recurringListProvider), l.moreCountRules),
      fmt(n(ledgerListProvider, (e) => !e.isSettled), l.moreCountOpen),
      fmt(n(loanListProvider, (e) => !e.isCompleted), l.moreCountActive),
      fmt(n(investmentListProvider), l.moreCountHoldings),
    ];
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;
    final sections = buildMoreSections(context, ref, isDevMode: isDevMode);
    MoreSection byId(MoreSectionId id) =>
        sections.firstWhere((s) => s.id == id);
    final manage = byId(MoreSectionId.manage);
    final captions = _manageCaptions(context, ref);

    Widget list(MoreSection s) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KuberSectionHeader(title: s.title),
            KuberGroup(
              children: [
                for (final e in s.entries)
                  KuberListRow(
                    key: e.tutorialKey,
                    leading: MoreIconDisc(entry: e),
                    title: splitTrailingTag(e.label).$1,
                    titleTrailing: splitTrailingTag(e.label).$2 == null
                        ? null
                        : KuberPill(label: splitTrailingTag(e.label).$2!),
                    subtitle: e.subtitle,
                    trailing: const KuberChevron(),
                    onTap: e.onTap,
                  ),
              ],
            ),
          ],
        );

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
                KuberSectionHeader(title: manage.title),
                _Grid(
                  children: [
                    for (var i = 0; i < manage.entries.length; i++)
                      _ManageTile(
                        entry: manage.entries[i],
                        caption: (i < captions.length ? captions[i] : null) ??
                            manage.entries[i].subtitle,
                      ),
                  ],
                ),
                const SizedBox(height: KuberSpace.sectionGap),
                KuberSectionHeader(title: byId(MoreSectionId.signature).title),
                _Grid(
                  children: [
                    for (final e in byId(MoreSectionId.signature).entries)
                      _ToolCard(entry: e),
                  ],
                ),
                const SizedBox(height: KuberSpace.sectionGap),
                list(byId(MoreSectionId.app)),
                const SizedBox(height: KuberSpace.sectionGap),
                list(byId(MoreSectionId.tutorial)),
                const SizedBox(height: KuberSpace.sectionGap),
                list(byId(MoreSectionId.about)),
                const SizedBox(height: KuberSpace.sectionGap),
                MoreHelpUsStrip(section: byId(MoreSectionId.helpUs)),
                const SizedBox(height: KuberSpace.sectionGap),
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

/// Two columns of equal-height tiles.
class _Grid extends StatelessWidget {
  final List<Widget> children;
  const _Grid({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: KuberSpace.sm,
      children: [
        for (var i = 0; i < children.length; i += 2)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: KuberSpace.sm,
              children: [
                Expanded(child: children[i]),
                Expanded(
                  child: i + 1 < children.length
                      ? children[i + 1]
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Manage tile (image 1 / board 3.7): 56 secondaryContainer tile, r16,
/// titleMedium label, bodyMedium live count.
class _ManageTile extends StatelessWidget {
  final MoreEntry entry;
  final String caption;
  const _ManageTile({required this.entry, required this.caption});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return KuberCard(
      key: entry.tutorialKey,
      padding: const EdgeInsets.all(KuberSpace.lg),
      onTap: entry.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: KuberShape.largeR,
            ),
            child: Icon(entry.icon, size: 24, color: cs.onSecondaryContainer),
          ),
          const SizedBox(height: KuberSpace.lg),
          Text(
            entry.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            caption,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Signature card: the previous design's 2-column tool card in M3 terms
/// (outlined surfaceContainer card, secondaryContainer glyph tile, Beta pill).
class _ToolCard extends StatelessWidget {
  final MoreEntry entry;
  const _ToolCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final (label, tag) = splitTrailingTag(entry.label);
    final pill = tag ?? (entry.betaPill ? 'Beta' : null);
    return KuberCard(
      key: entry.tutorialKey,
      padding: const EdgeInsets.all(KuberSpace.lg),
      onTap: entry.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.secondaryContainer,
                  borderRadius: KuberShape.mediumR,
                ),
                alignment: Alignment.center,
                child: IconTheme(
                  data: IconThemeData(color: cs.onSecondaryContainer, size: 22),
                  child: entry.iconWidget != null
                      ? SizedBox(width: 22, height: 22, child: entry.iconWidget)
                      : Icon(entry.icon),
                ),
              ),
              const Spacer(),
              if (pill != null) KuberPill(label: pill),
            ],
          ),
          const SizedBox(height: KuberSpace.lg),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium,
          ),
          Text(
            entry.subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall!.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
