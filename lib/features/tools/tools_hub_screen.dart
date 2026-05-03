import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/prefs_keys.dart';
import '../../shared/widgets/kuber_app_bar.dart';
import '../../shared/widgets/kuber_bottom_sheet.dart';
import '../../shared/widgets/kuber_page_header.dart';

// ── View mode ─────────────────────────────────────────────────────────────────

enum ToolsViewMode { grid, list }

class _ToolsViewNotifier extends StateNotifier<ToolsViewMode> {
  _ToolsViewNotifier() : super(ToolsViewMode.grid) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(PrefsKeys.toolsViewMode) ?? 0;
    if (index < ToolsViewMode.values.length) {
      state = ToolsViewMode.values[index];
    }
  }

  Future<void> setMode(ToolsViewMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.toolsViewMode, mode.index);
  }
}

final _toolsViewModeProvider =
    StateNotifierProvider<_ToolsViewNotifier, ToolsViewMode>(
  (_) => _ToolsViewNotifier(),
);

class _ToolEntry {
  final String name;
  final String description;
  final IconData icon;
  final String route;
  final Color accentColor;

  const _ToolEntry({
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
    required this.accentColor,
  });
}

class _ToolGroup {
  final String title;
  final List<_ToolEntry> tools;

  const _ToolGroup({required this.title, required this.tools});
}

const _kBlue = Color(0xFF3B82F6);
const _kGreen = Color(0xFF22C55E);
const _kAmber = Color(0xFFF59E0B);
const _kPurple = Color(0xFFA855F7);
const _kEmerald = Color(0xFF10B981);
const _kPink = Color(0xFFEC4899);
const _kRed = Color(0xFFEF4444);

const _kGroups = [
  _ToolGroup(title: 'Finance Calculators', tools: [
    _ToolEntry(
      name: 'EMI Calculator',
      description: 'Loan repayments',
      icon: Icons.account_balance_rounded,
      route: 'emi-calculator',
      accentColor: _kBlue,
    ),
    _ToolEntry(
      name: 'Investment Returns',
      description: 'SIP & lump-sum growth',
      icon: Icons.trending_up_rounded,
      route: 'sip-calculator',
      accentColor: _kGreen,
    ),
    _ToolEntry(
      name: 'SIP Amount',
      description: 'Find monthly investment',
      icon: Icons.savings_rounded,
      route: 'sip-amount-finder',
      accentColor: _kPurple,
    ),
    _ToolEntry(
      name: 'FD / RD',
      description: 'Fixed & recurring deposits',
      icon: Icons.account_balance_wallet_rounded,
      route: 'fd-rd-calculator',
      accentColor: _kAmber,
    ),
    _ToolEntry(
      name: 'PPF Calculator',
      description: '15-year provident fund',
      icon: Icons.shield_rounded,
      route: 'ppf-calculator',
      accentColor: _kEmerald,
    ),
    _ToolEntry(
      name: 'Inflation',
      description: 'Future purchasing power',
      icon: Icons.trending_down_rounded,
      route: 'inflation-calculator',
      accentColor: _kPink,
    ),
  ]),
  _ToolGroup(title: 'Tax & Salary', tools: [
    _ToolEntry(
      name: 'Salary Breakdown',
      description: 'CTC → in-hand',
      icon: Icons.work_rounded,
      route: 'salary-calculator',
      accentColor: _kBlue,
    ),
    _ToolEntry(
      name: 'GST Calculator',
      description: 'Add or remove GST',
      icon: Icons.percent_rounded,
      route: 'gst-calculator',
      accentColor: _kAmber,
    ),
    _ToolEntry(
      name: 'HRA Exemption',
      description: 'Old regime tax',
      icon: Icons.home_work_rounded,
      route: 'hra-calculator',
      accentColor: _kPurple,
    ),
  ]),
  _ToolGroup(title: 'Quick Calculators', tools: [
    _ToolEntry(
      name: 'Bill Splitter',
      description: 'Split expenses between people',
      icon: Icons.people_rounded,
      route: 'split-calculator',
      accentColor: _kBlue,
    ),
    _ToolEntry(
      name: 'Currency Converter',
      description: 'Convert currencies',
      icon: Icons.currency_exchange_rounded,
      route: 'currency-converter',
      accentColor: _kEmerald,
    ),
    _ToolEntry(
      name: 'Break-even',
      description: 'Months to recover',
      icon: Icons.timeline_rounded,
      route: 'breakeven-calculator',
      accentColor: _kGreen,
    ),
    _ToolEntry(
      name: 'Tip Calculator',
      description: 'Bills & gratuity',
      icon: Icons.receipt_long_rounded,
      route: 'tip-calculator',
      accentColor: _kBlue,
    ),
    _ToolEntry(
      name: 'Discount Calculator',
      description: 'Find the best deal',
      icon: Icons.local_offer_rounded,
      route: 'discount-calculator',
      accentColor: _kRed,
    ),
  ]),
];

class ToolsHubScreen extends ConsumerStatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  ConsumerState<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends ConsumerState<ToolsHubScreen> {
  String _query = '';

  List<_ToolEntry> get _allTools =>
      _kGroups.expand((g) => g.tools).toList();

  void _showViewModeSheet(BuildContext context, ToolsViewMode current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberBottomSheet(
        title: 'View Mode',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ViewModeOption(
              icon: Icons.grid_view_rounded,
              label: 'Grid',
              selected: current == ToolsViewMode.grid,
              onTap: () {
                ref.read(_toolsViewModeProvider.notifier).setMode(ToolsViewMode.grid);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            const SizedBox(height: KuberSpacing.sm),
            _ViewModeOption(
              icon: Icons.list_rounded,
              label: 'List',
              selected: current == ToolsViewMode.list,
              onTap: () {
                ref.read(_toolsViewModeProvider.notifier).setMode(ToolsViewMode.list);
                Navigator.of(context, rootNavigator: true).pop();
              },
            ),
            const SizedBox(height: KuberSpacing.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewMode = ref.watch(_toolsViewModeProvider);
    final isSearching = _query.isNotEmpty;
    final filtered = _allTools
        .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()) ||
            t.description.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(title: '', showBack: true, showHome: true),
          ),
          SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Tools',
              description: 'Calculators and utilities',
              actionIcon: Icons.tune_rounded,
              actionTooltip: 'View mode',
              onAction: () => _showViewModeSheet(context, viewMode),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg,
                0,
                KuberSpacing.lg,
                KuberSpacing.md,
              ),
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search tools...',
                  hintStyle: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: cs.onSurfaceVariant,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainer,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: KuberSpacing.md,
                    horizontal: KuberSpacing.lg,
                  ),
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
            ),
          ),
          if (isSearching)
            ..._buildSearchResults(cs, filtered, viewMode)
          else
            ..._buildGroupedList(cs, viewMode),
        ],
      ),
      ),
    );
  }

  List<Widget> _buildGroupedList(ColorScheme cs, ToolsViewMode viewMode) {
    return [
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) {
            final group = _kGroups[i];
            return Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg,
                KuberSpacing.sm,
                KuberSpacing.lg,
                KuberSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: KuberSpacing.sm),
                    child: Text(
                      group.title.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                  if (viewMode == ToolsViewMode.grid)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: KuberSpacing.sm,
                        crossAxisSpacing: KuberSpacing.sm,
                        childAspectRatio: 1.1,
                      ),
                      itemCount: group.tools.length,
                      itemBuilder: (context, index) =>
                          _ToolCard(tool: group.tools[index]),
                    )
                  else
                    Column(
                      children: group.tools
                          .map((t) => _ToolListItem(tool: t))
                          .toList(),
                    ),
                ],
              ),
            );
          },
          childCount: _kGroups.length,
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: KuberSpacing.xl)),
    ];
  }

  List<Widget> _buildSearchResults(ColorScheme cs, List<_ToolEntry> results, ToolsViewMode viewMode) {
    if (results.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Text(
              'No tools found',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ];
    }
    if (viewMode == ToolsViewMode.list) {
      return [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            KuberSpacing.lg,
            0,
            KuberSpacing.lg,
            KuberSpacing.xl,
          ),
          sliver: SliverList.builder(
            itemCount: results.length,
            itemBuilder: (context, index) => _ToolListItem(tool: results[index]),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpacing.lg,
          0,
          KuberSpacing.lg,
          KuberSpacing.xl,
        ),
        sliver: SliverGrid.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: KuberSpacing.sm,
            crossAxisSpacing: KuberSpacing.sm,
            childAspectRatio: 1.1,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) => _ToolCard(tool: results[index]),
        ),
      ),
    ];
  }
}

// ── View mode option row in the bottom sheet ──────────────────────────────────

class _ViewModeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ViewModeOption({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.md,
        ),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? cs.primary : cs.outline,
            width: selected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: selected ? cs.primary : cs.onSurfaceVariant),
            const SizedBox(width: KuberSpacing.md),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? cs.primary : cs.onSurface,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_rounded, size: 18, color: cs.primary),
          ],
        ),
      ),
    );
  }
}

// ── List-mode tool row ────────────────────────────────────────────────────────

class _ToolListItem extends StatelessWidget {
  final _ToolEntry tool;

  const _ToolListItem({required this.tool});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => context.push('/more/tools/${tool.route}'),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md,
          vertical: KuberSpacing.md,
        ),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tool.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: tool.accentColor.withValues(alpha: 0.18)),
              ),
              alignment: Alignment.center,
              child: Icon(tool.icon, color: tool.accentColor, size: 20),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tool.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tool.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Grid-mode tool card ───────────────────────────────────────────────────────

class _ToolCard extends StatelessWidget {
  final _ToolEntry tool;

  const _ToolCard({required this.tool});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => context.push('/more/tools/${tool.route}'),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md + 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: tool.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(
                    color: tool.accentColor.withValues(alpha: 0.18)),
              ),
              alignment: Alignment.center,
              child: Icon(tool.icon, color: tool.accentColor, size: 20),
            ),
            const Spacer(),
            Text(
              tool.name,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              tool.description,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: cs.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
