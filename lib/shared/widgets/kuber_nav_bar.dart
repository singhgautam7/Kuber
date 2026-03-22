import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// Nav item data
// ---------------------------------------------------------------------------

class KuberNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const KuberNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const kuberNavItems = [
  KuberNavItem(
    icon: Icons.home_outlined,
    activeIcon: Icons.home_rounded,
    label: 'Home',
  ),
  KuberNavItem(
    icon: Icons.receipt_long_outlined,
    activeIcon: Icons.receipt_long_rounded,
    label: 'History',
  ),
  KuberNavItem(
    icon: Icons.bar_chart_outlined,
    activeIcon: Icons.bar_chart_rounded,
    label: 'Analytics',
  ),
  KuberNavItem(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    label: 'More',
  ),
];

// Removed KuberBottomNavBar, _NavTab, and _AddButton in favor of standard NavigationBar

// ---------------------------------------------------------------------------
// Side navigation rail (large tablet / desktop ≥ 840dp)
// ---------------------------------------------------------------------------

class KuberNavRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onAddTapped;

  const KuberNavRail({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.onAddTapped,
  });

  @override
  Widget build(BuildContext context) {
    final isMoreTab = currentIndex == 3;

    return Container(
      width: 220,
      decoration: const BoxDecoration(
        color: KuberColors.surfaceCard,
        border: Border(
          right: BorderSide(
            color: KuberColors.border,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Branding
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Text(
                'Kuber',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: KuberColors.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ),

            // Nav items
            ...List.generate(kuberNavItems.length, (i) {
              final item = kuberNavItems[i];
              final isActive = i == currentIndex;
              return _RailItem(
                item: item,
                isActive: isActive,
                onTap: () => onTabTapped(i),
              );
            }),

            const Spacer(),

            // Add button — hidden on More tab
            if (!isMoreTab)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onAddTapped();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: KuberColors.primary,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Add Transaction',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RailItem extends StatelessWidget {
  final KuberNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _RailItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 22,
                color:
                    isActive ? KuberColors.primary : KuberColors.textSecondary,
              ),
              const SizedBox(width: 12),
              Text(
                item.label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? KuberColors.primary
                      : KuberColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
