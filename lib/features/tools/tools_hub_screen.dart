import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../core/utils/l10n_ext.dart';
import '../../core/constants/tools_l10n.dart';
import '../../shared/widgets/kuber_app_bar.dart';
import '../../shared/widgets/kuber_page_header.dart';
import 'saved/providers/recent_use_provider.dart';
import 'tool_catalog.dart';

class ToolsHubScreen extends ConsumerStatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  ConsumerState<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends ConsumerState<ToolsHubScreen> {
  String _query = '';

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
          behavior:
              ScrollConfiguration.of(context).copyWith(overscroll: false),
          child: CustomScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(title: '', showBack: true, showHome: true),
              ),
            SliverToBoxAdapter(
              child: KuberPageHeader(
                title: context.l10n.moreToolsTitle,
                description: tL10n(
                    'Quick calculations for everyday financial decisions', lang),
              ),
            ),
            SliverToBoxAdapter(child: _searchField(cs, lang)),
            if (isSearching)
              ..._buildSearchResults(cs, lang)
            else ...[
              SliverToBoxAdapter(child: _savedTile(cs, lang)),
              if (recents.isNotEmpty)
                SliverToBoxAdapter(child: _RecentPills(tools: recents)),
              for (final g in ToolCatalog.groups)
                _buildGroupSliver(cs, lang, tL10n(g.title, lang), g.tools),
              SliverToBoxAdapter(
                child: SizedBox(
                    height: KuberSpacing.xl + systemNavBarInset(context)),
              ),
            ],
          ],
          ),
        ),
      ),
    );
  }

  Widget _searchField(ColorScheme cs, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.md),
      child: TextField(
        onChanged: (v) => setState(() => _query = v),
        style: localeFont(fontSize: 14, color: cs.onSurface),
        decoration: InputDecoration(
          hintText: tL10n('Search tools...', lang),
          hintStyle: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
          prefixIcon:
              Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 20),
          filled: true,
          fillColor: cs.surfaceContainer,
          contentPadding: const EdgeInsets.symmetric(
              vertical: KuberSpacing.md, horizontal: KuberSpacing.lg),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            borderSide: BorderSide(color: cs.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            borderSide: BorderSide(color: cs.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(KuberRadius.md),
            borderSide: BorderSide(color: cs.primary),
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSliver(
      ColorScheme cs, String lang, String title, List<ToolMeta> tools) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, KuberSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: KuberSpacing.sm),
              child: Text(
                title.toUpperCase(),
                style: localeFont(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
            for (final t in tools) _ToolRow(tool: t),
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
          child: Center(
            child: Text(tL10n('No tools found', lang),
                style: localeFont(fontSize: 15, color: cs.onSurfaceVariant)),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
            KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.xl),
        sliver: SliverList.builder(
          itemCount: results.length,
          itemBuilder: (_, i) => _ToolRow(tool: results[i]),
        ),
      ),
    ];
  }

  Widget _savedTile(ColorScheme cs, String lang) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, KuberSpacing.xs, KuberSpacing.lg, 0),
      child: InkWell(
        onTap: () => context.push('/more/tools/saved-calculations'),
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Container(
          padding: const EdgeInsets.all(KuberSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                alignment: Alignment.center,
                child: Icon(Icons.bookmark_outline_rounded,
                    color: cs.onSurface, size: 20),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tL10n('Saved Calculations', lang),
                      style: localeFont(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tL10n('Revisit calculations you saved', lang),
                      style:
                          localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 18, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Horizontally-scrollable compact pills for the "Recently used" section:
/// icon + tool name only, tinted with the tool's accent, no description.
class _RecentPills extends StatelessWidget {
  final List<ToolMeta> tools;
  const _RecentPills({required this.tools});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg, KuberSpacing.md, 0, KuberSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: KuberSpacing.sm),
            child: Text(
              tL10n('Recently used', lang).toUpperCase(),
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final t in tools) ...[
                  _RecentPill(tool: t),
                  const SizedBox(width: KuberSpacing.sm),
                ],
                const SizedBox(width: KuberSpacing.sm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentPill extends ConsumerWidget {
  final ToolMeta tool;
  const _RecentPill({required this.tool});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    return InkWell(
      onTap: () => openTool(context, ref, tool.key),
      borderRadius: BorderRadius.circular(KuberRadius.full),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 7, 14, 7),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.full),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: tool.accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(tool.icon, color: tool.accent, size: 15),
            ),
            const SizedBox(width: 8),
            Text(
              tL10n(tool.name, lang),
              style: localeFont(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.onSurface,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
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
    final cs = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    return InkWell(
      onTap: () => openTool(context, ref, tool.key),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tool.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: tool.accent.withValues(alpha: 0.18)),
              ),
              alignment: Alignment.center,
              child: Icon(tool.icon, color: tool.accent, size: 21),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tL10n(tool.name, lang),
                    style: localeFont(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tL10n(tool.subtitle, lang),
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
