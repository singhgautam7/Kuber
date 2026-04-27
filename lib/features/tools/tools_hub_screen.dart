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

  const _ToolEntry({
    required this.name,
    required this.description,
    required this.icon,
    required this.route,
  });
}

const _kTools = [
  _ToolEntry(
    name: 'Bill Splitter',
    description: 'Split bills fairly among friends',
    icon: Icons.receipt_long_rounded,
    route: 'bill-splitter',
  ),
  _ToolEntry(
    name: 'Currency Converter',
    description: 'Convert between currencies live',
    icon: Icons.currency_exchange_rounded,
    route: 'currency-converter',
  ),
  _ToolEntry(
    name: 'EMI Calculator',
    description: 'Plan your loan repayments',
    icon: Icons.account_balance_rounded,
    route: 'emi-calculator',
  ),
  _ToolEntry(
    name: 'Investment Returns',
    description: 'Estimate SIP & lump-sum growth',
    icon: Icons.trending_up_rounded,
    route: 'sip-calculator',
  ),
  _ToolEntry(
    name: 'SIP Amount Finder',
    description: 'Find required monthly investment',
    icon: Icons.savings_rounded,
    route: 'sip-amount-finder',
  ),
  _ToolEntry(
    name: 'Tip Calculator',
    description: 'Calculate tips quickly',
    icon: Icons.percent_rounded,
    route: 'tip-calculator',
  ),
  _ToolEntry(
    name: 'Discount Calculator',
    description: 'Find the best deal',
    icon: Icons.local_offer_rounded,
    route: 'discount-calculator',
  ),
  _ToolEntry(
    name: 'GST Calculator',
    description: 'Add or remove GST instantly',
    icon: Icons.calculate_rounded,
    route: 'gst-calculator',
  ),
];

class ToolsHubScreen extends StatefulWidget {
  const ToolsHubScreen({super.key});

  @override
  State<ToolsHubScreen> createState() => _ToolsHubScreenState();
}

class _ToolsHubScreenState extends State<ToolsHubScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = _kTools
        .where((t) => t.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(title: 'Tools', showBack: true),
      body: Column(
        children: [
          const KuberPageHeader(
            title: 'Tools',
            description: 'Calculators and utilities',
          ),
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
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No tools found',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      KuberSpacing.lg,
                      0,
                      KuberSpacing.lg,
                      KuberSpacing.lg,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: KuberSpacing.sm,
                      crossAxisSpacing: KuberSpacing.sm,
                      childAspectRatio: 0.95,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tool = filtered[index];
                      return _ToolCard(tool: tool);
                    },
                  ),
          ),
        ],
      ),
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
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              alignment: Alignment.center,
              child: Icon(tool.icon, color: cs.primary, size: 22),
            ),
            const Spacer(),
            Text(
              tool.name,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.2,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              tool.description,
              style: GoogleFonts.inter(
                fontSize: 12,
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
