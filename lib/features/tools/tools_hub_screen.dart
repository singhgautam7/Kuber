import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/widgets/kuber_app_bar.dart';
import '../../shared/widgets/kuber_page_header.dart';

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
    _ToolEntry(
      name: 'Break-even',
      description: 'Months to recover',
      icon: Icons.timeline_rounded,
      route: 'breakeven-calculator',
      accentColor: _kGreen,
    ),
    _ToolEntry(
      name: 'Split Calculator',
      description: 'Split expenses between people',
      icon: Icons.people_rounded,
      route: 'split-calculator',
      accentColor: _kBlue,
    ),
  ]),
];

class ToolsHubScreen extends StatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  State<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends State<ToolsHubScreen> {
  String _query = '';

  List<_ToolEntry> get _allTools =>
      _kGroups.expand((g) => g.tools).toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSearching = _query.isNotEmpty;
    final filtered = _allTools
        .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()) ||
            t.description.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(title: '', showBack: true, showHome: true),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberPageHeader(
            title: 'Tools',
            description: 'Calculators and utilities',
          ),
          // Search bar
          Padding(
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
          Expanded(
            child: isSearching
                ? _buildSearchResults(cs, filtered)
                : _buildGroupedList(cs),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedList(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
      children: _kGroups.map((group) {
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
                padding: const EdgeInsets.only(
                    left: 4, bottom: KuberSpacing.sm),
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
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: KuberSpacing.sm,
                  crossAxisSpacing: KuberSpacing.sm,
                  childAspectRatio: 1.1,
                ),
                itemCount: group.tools.length,
                itemBuilder: (context, index) =>
                    _ToolCard(tool: group.tools[index]),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchResults(ColorScheme cs, List<_ToolEntry> results) {
    if (results.isEmpty) {
      return Center(
        child: Text(
          'No tools found',
          style: GoogleFonts.inter(
            fontSize: 15,
            color: cs.onSurfaceVariant,
          ),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        0,
        KuberSpacing.lg,
        KuberSpacing.lg,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: KuberSpacing.sm,
        crossAxisSpacing: KuberSpacing.sm,
        childAspectRatio: 1.1,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) => _ToolCard(tool: results[index]),
    );
  }
}

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
