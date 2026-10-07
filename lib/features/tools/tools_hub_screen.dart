import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/l10n_ext.dart';
import '../../core/constants/tools_l10n.dart';
import '../../core/services/shortcut_pin_service.dart';
import '../../core/utils/color_harmonizer.dart';
import '../../shared/widgets/kuber_app_bar.dart';
import '../../shared/widgets/kuber_chips.dart';
import '../../shared/widgets/kuber_empty_state.dart';
import '../../shared/widgets/kuber_list.dart';
import 'saved/providers/recent_use_provider.dart';
import 'tool_catalog.dart';

class ToolsHubScreen extends ConsumerStatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  ConsumerState<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends ConsumerState<ToolsHubScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matches(ToolMeta t, String lang) {
    final q = _query.toLowerCase();
    return t.name.toLowerCase().contains(q) ||
        t.subtitle.toLowerCase().contains(q) ||
        tL10n(t.name, lang).toLowerCase().contains(q) ||
        tL10n(t.subtitle, lang).toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final isSearching = _query.isNotEmpty;
    final recentKeys = ref.watch(topRecentCalculatorsProvider);
    final recents = [
      for (final k in recentKeys)
        if (ToolCatalog.byKey(k) != null) ToolCatalog.byKey(k)!,
    ];

    return Scaffold(
      backgroundColor: cs.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  title: context.l10n.menuCalculators,
                  showBack: true,
                  pinShortcut: PinShortcutSpec(
                    shortcutId: 'kuber_tools',
                    shortLabel: 'Tools',
                    longLabel: 'Calculators and Tools',
                    iconDrawable: 'ic_shortcut_tools',
                    deepLink: 'kuber://app/tools',
                  ),
                  search: KuberHeaderSearch(
                    controller: _searchController,
                    hint: tL10n('Search tools...', lang),
                    onChanged: (v) => setState(() => _query = v),
                  ),
                ),
              ),

              if (isSearching)
                ..._buildSearchResults(cs, lang)
              else ...[
                SliverToBoxAdapter(child: _savedTile(cs, lang)),
                if (recents.isNotEmpty)
                  SliverToBoxAdapter(child: _RecentPills(tools: recents))
                else
                  const SliverToBoxAdapter(
                    child: SizedBox(height: KuberSpace.sectionGap - 4),
                  ),
                for (final g in ToolCatalog.groups)
                  _buildGroupSliver(cs, lang, tL10n(g.title, lang), g.tools),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: KuberSpace.xl + systemNavBarInset(context),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSliver(
    ColorScheme cs,
    String lang,
    String title,
    List<ToolMeta> tools,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          0,
          KuberSpace.screenMargin,
          KuberSpace.sectionGap - 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            KuberSectionHeader(title: title),
            KuberGroup(children: [for (final t in tools) _ToolRow(tool: t)]),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSearchResults(ColorScheme cs, String lang) {
    final results = [
      for (final t in ToolCatalog.all)
        if (_matches(t, lang)) t,
    ];
    if (results.isEmpty) {
      return [
        SliverFillRemaining(
          hasScrollBody: false,
          child: KuberEmptyState(
            icon: Icons.search_off_rounded,
            title: tL10n('No tools found', lang),
            description: '',
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          0,
          KuberSpace.screenMargin,
          KuberSpace.xl,
        ),
        sliver: SliverToBoxAdapter(
          child: KuberGroup(
            children: [for (final t in results) _ToolRow(tool: t)],
          ),
        ),
      ),
    ];
  }

  Widget _savedTile(ColorScheme cs, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.screenMargin,
        0,
        KuberSpace.screenMargin,
        0,
      ),
      child: KuberGroup(
        children: [
          KuberListRow(
            leading: const KuberIconTile(
              icon: Icons.bookmark_outline_rounded,
              tone: KuberTone.primary,
            ),
            title: tL10n('Saved Calculations', lang),
            subtitle: tL10n('Revisit calculations you saved', lang),
            trailing: const KuberChevron(),
            onTap: () => context.push('/more/tools/saved-calculations'),
          ),
        ],
      ),
    );
  }
}

/// "Recently used": horizontally scrolling chips, icon + tool name.
class _RecentPills extends ConsumerWidget {
  final List<ToolMeta> tools;
  const _RecentPills({required this.tools});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.sectionGap - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpace.screenMargin,
            ),
            child: KuberSectionHeader(title: tL10n('Recently used', lang)),
          ),
          SizedBox(
            height: 32,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpace.screenMargin,
              ),
              children: [
                for (final (i, t) in tools.indexed) ...[
                  if (i > 0) const SizedBox(width: KuberSpace.sm),
                  KuberChip(
                    label: tL10n(t.name, lang),
                    icon: t.icon,
                    onTap: () => openTool(context, ref, t.key),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: KuberSpace.sectionGap - 4),
        ],
      ),
    );
  }
}

/// Records the tool as recently used (so Quick Calculators, whose screens lack
/// the calculator-support mixin, are tracked too) and navigates to it.
void openTool(BuildContext context, WidgetRef ref, String key) {
  ref.read(recentCalculatorsProvider.notifier).touch(key);
  context.push('/more/tools/$key');
}

class _ToolRow extends ConsumerWidget {
  final ToolMeta tool;
  const _ToolRow({required this.tool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = Localizations.localeOf(context).languageCode;
    final tones = categoryTones(context, tool.accent);
    return KuberListRow(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: tones.container,
          borderRadius: KuberShape.mediumR,
        ),
        child: Icon(tool.icon, color: tones.fg, size: 20),
      ),
      title: tL10n(tool.name, lang),
      subtitle: tL10n(tool.subtitle, lang),
      trailing: const KuberChevron(),
      onTap: () => openTool(context, ref, tool.key),
    );
  }
}
