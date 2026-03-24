import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(title: 'More'),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
          top: KuberSpacing.sm,
          bottom: navBarBottomPadding(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   'More',
            //   style: GoogleFonts.inter(
            //     fontSize: 22,
            //     fontWeight: FontWeight.w700,
            //     color: cs.onSurface,
            //     letterSpacing: -0.3,
            //   ),
            // ),
            // const SizedBox(height: KuberSpacing.xs),
            // Text(
            //   'Manage your data and app preferences',
            //   style: GoogleFonts.inter(
            //     fontSize: 13,
            //     color: cs.onSurfaceVariant,
            //   ),
            // ),
            const SizedBox(height: KuberSpacing.xl),

            // Manage section
            _MenuSection(
              title: 'Manage',
              items: [
                _MenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  label: 'Accounts',
                  subtitle: 'Your wallets and bank accounts',
                  onTap: () => context.push('/more/accounts'),
                ),
                _MenuItem(
                  icon: Icons.category_outlined,
                  label: 'Categories',
                  subtitle: 'Organize your transactions',
                  onTap: () => context.push('/more/categories'),
                ),
                _MenuItem(
                  icon: Icons.label_outlined,
                  label: 'Tags',
                  subtitle: 'Organize the labels for your transactions',
                  onTap: () => context.push('/more/tags'),
                ),
                _MenuItem(
                  icon: Icons.sync_rounded,
                  label: 'Recurring Transactions',
                  subtitle: 'Automated scheduled transactions',
                  onTap: () => context.push('/more/recurring'),
                ),
              ],
            ),

            const SizedBox(height: KuberSpacing.xl),

            // App section
            _MenuSection(
              title: 'App',
              items: [
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  subtitle: 'Theme, currency, and profile',
                  onTap: () => context.push('/more/settings'),
                ),
                _MenuItem(
                  icon: Icons.storage_rounded,
                  label: 'Data',
                  subtitle: 'Export and clear your data',
                  onTap: () => context.push('/more/data'),
                ),

                _MenuItem(
                  icon: Icons.help_outline_rounded,
                  label: 'How to Use',
                  subtitle: 'Tips and FAQs',
                  onTap: () => context.push('/more/how-to-use'),
                ),
              ],
            ),

            const SizedBox(height: KuberSpacing.xl),

            // About section
            _MenuSection(
              title: 'About',
              items: [
                // _MenuItem(
                //   icon: Icons.waving_hand_outlined,
                //   label: 'Show Welcome Screen',
                //   subtitle: 'View the onboarding experience again',
                //   onTap: () => context.push('/onboarding'),
                // ),
                _MenuItem(
                  icon: Icons.info_outline_rounded,
                  label: 'About Kuber',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.security_outlined,
                  label: 'Permissions',
                  subtitle: 'App limits and security',
                  onTap: () => context.pushNamed('permissions'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
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
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.outline),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    color: cs.outline,
                    indent: 52,
                  ),
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

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, color: cs.onSurfaceVariant, size: 22),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant, size: 20),
          ],
        ),
      ),
    );
  }
}
