import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../settings/widgets/settings_widgets.dart';

class _SearchableItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final String section;
  final String? route;
  final String? namedRoute;
  final Color? color;

  const _SearchableItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.section,
    this.route,
    this.namedRoute,
    this.color,
  });

  bool matches(String q) {
    final lower = q.toLowerCase();
    return label.toLowerCase().contains(lower) ||
        subtitle.toLowerCase().contains(lower);
  }

  void navigate(BuildContext context) {
    if (namedRoute != null) {
      context.pushNamed(namedRoute!);
    } else {
      context.push(route!);
    }
  }
}

List<_SearchableItem> _buildItems(bool isDevMode) => [
      // AI Assistant
      _SearchableItem(
        label: 'Ask Kuber',
        subtitle: 'On-device spending insights',
        icon: Icons.auto_awesome_rounded,
        section: 'AI',
        route: '/more/ask-kuber',
        color: const Color(0xFFFFB300),
      ),
      // Manage
      _SearchableItem(label: 'Accounts', subtitle: 'Your wallets and bank accounts', icon: Icons.account_balance_wallet_outlined, section: 'Manage', route: '/more/accounts'),
      _SearchableItem(label: 'Categories', subtitle: 'Organize your transactions', icon: Icons.category_outlined, section: 'Manage', route: '/more/categories'),
      _SearchableItem(label: 'Tags', subtitle: 'Organize the labels for your transactions', icon: Icons.label_outlined, section: 'Manage', route: '/more/tags'),
      _SearchableItem(label: 'Budgets', subtitle: 'Track and control your monthly spending', icon: Icons.account_balance_rounded, section: 'Manage', route: '/more/budgets'),
      _SearchableItem(label: 'Recurring Transactions', subtitle: 'Automated scheduled transactions', icon: Icons.sync_rounded, section: 'Manage', route: '/more/recurring'),
      _SearchableItem(label: 'Lend / Borrow', subtitle: 'Track money you lent or borrowed', icon: Icons.handshake_outlined, section: 'Manage', route: '/more/ledger'),
      _SearchableItem(label: 'Loans', subtitle: 'Track EMIs and repayment progress', icon: Icons.account_balance_outlined, section: 'Manage', route: '/more/loans'),
      _SearchableItem(label: 'Investments', subtitle: 'Track portfolio value and growth', icon: Icons.show_chart, section: 'Manage', route: '/more/investments'),
      // Tools
      _SearchableItem(label: 'Bill Splitter', subtitle: 'Split bills with friends', icon: Icons.receipt_long_rounded, section: 'Tools', route: '/more/tools/bill-splitter'),
      _SearchableItem(label: 'Currency Converter', subtitle: 'Convert between currencies live', icon: Icons.currency_exchange_rounded, section: 'Tools', route: '/more/tools/currency-converter'),
      _SearchableItem(label: 'EMI Calculator', subtitle: 'Estimate loan EMIs', icon: Icons.account_balance_rounded, section: 'Tools', route: '/more/tools/emi-calculator'),
      _SearchableItem(label: 'Investment Returns', subtitle: 'Estimate SIP & lump-sum growth', icon: Icons.trending_up_rounded, section: 'Tools', route: '/more/tools/sip-calculator'),
      _SearchableItem(label: 'SIP Amount Finder', subtitle: 'Find required monthly investment', icon: Icons.savings_rounded, section: 'Tools', route: '/more/tools/sip-amount-finder'),
      _SearchableItem(label: 'Tip Calculator', subtitle: 'Calculate tips quickly', icon: Icons.percent_rounded, section: 'Tools', route: '/more/tools/tip-calculator'),
      _SearchableItem(label: 'Discount Calculator', subtitle: 'Find the best deal', icon: Icons.local_offer_rounded, section: 'Tools', route: '/more/tools/discount-calculator'),
      _SearchableItem(label: 'GST Calculator', subtitle: 'Add or remove GST instantly', icon: Icons.calculate_rounded, section: 'Tools', route: '/more/tools/gst-calculator'),
      // App
      _SearchableItem(label: 'Settings', subtitle: 'Theme, currency, and profile', icon: Icons.settings_outlined, section: 'App', route: '/more/settings'),
      _SearchableItem(label: 'Data', subtitle: 'Export and clear your data', icon: Icons.storage_rounded, section: 'App', route: '/more/data'),
      _SearchableItem(label: 'Troubleshoot', subtitle: 'Fix data and suggestion issues', icon: Icons.build_outlined, section: 'App', route: '/more/troubleshoot'),
      // About
      _SearchableItem(label: 'About Kuber', subtitle: 'Vision, origin, and developer', icon: Icons.info_outline_rounded, section: 'About', namedRoute: 'about'),
      _SearchableItem(label: 'Permissions', subtitle: 'App limits and security', icon: Icons.security_outlined, section: 'About', namedRoute: 'permissions'),
      // Dev Tools (conditional)
      if (isDevMode)
        _SearchableItem(label: 'Dev Tools', subtitle: 'Developer-only tools', icon: Icons.bug_report_outlined, section: 'Dev', route: '/more/dev-tools'),
    ];

class MoreSearchScreen extends ConsumerStatefulWidget {
  const MoreSearchScreen({super.key});

  @override
  ConsumerState<MoreSearchScreen> createState() => _MoreSearchScreenState();
}

class _MoreSearchScreenState extends ConsumerState<MoreSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(() {
      setState(() => _query = _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;
    final allItems = _buildItems(isDevMode);
    final filtered = _query.isEmpty
        ? allItems
        : allItems.where((item) => item.matches(_query)).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg,
                KuberSpacing.md,
                KuberSpacing.lg,
                KuberSpacing.md,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: cs.onSurface,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search More...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  _focusNode.requestFocus();
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: cs.onSurfaceVariant,
                                  size: 18,
                                ),
                              )
                            : null,
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
                          borderSide: BorderSide(color: cs.outline),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: cs.outline),

            // Results list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No results for "$_query"',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: cs.outline,
                        indent: 52,
                      ),
                      itemBuilder: (context, index) =>
                          _SearchResultItem(item: filtered[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final _SearchableItem item;

  const _SearchResultItem({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => item.navigate(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: item.icon, color: item.color ?? cs.primary),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(KuberRadius.sm),
                        ),
                        child: Text(
                          item.section,
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
