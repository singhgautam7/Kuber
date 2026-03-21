import 'dart:ui';

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
    icon: Icons.account_balance_wallet_outlined,
    activeIcon: Icons.account_balance_wallet_rounded,
    label: 'Accounts',
  ),
];

// ---------------------------------------------------------------------------
// Glassmorphic bottom nav bar (phone / small tablet)
// ---------------------------------------------------------------------------

class KuberBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabTapped;
  final VoidCallback onAddTapped;

  const KuberBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabTapped,
    required this.onAddTapped,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: safeBottom + 8,
      ),
      child: Row(
        children: [
          // Glassmorphic pill with nav tabs
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: KuberColors.surfaceCard.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.07),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: List.generate(kuberNavItems.length, (i) {
                      return Expanded(
                        child: _NavTab(
                          item: kuberNavItems[i],
                          isActive: i == currentIndex,
                          onTap: () => onTabTapped(i),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),

          // Gap between pill and add button
          const SizedBox(width: 10),

          // Standalone add button
          _AddButton(onTap: onAddTapped),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Individual nav tab — vertical icon + label, always visible
// ---------------------------------------------------------------------------

class _NavTab extends StatelessWidget {
  final KuberNavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTab({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isActive
              ? KuberColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isActive ? item.activeIcon : item.icon,
                size: 22,
                color: isActive
                    ? KuberColors.primary
                    : KuberColors.textSecondary,
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? KuberColors.primary
                      : KuberColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Circular add (+) button with glow
// ---------------------------------------------------------------------------

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: KuberColors.primary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: KuberColors.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

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
    final isAccountsTab = currentIndex == 3;

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 220,
          decoration: BoxDecoration(
            color: KuberColors.surfaceCard.withValues(alpha: 0.78),
            border: Border(
              right: BorderSide(
                color: Colors.white.withValues(alpha: 0.07),
                width: 0.5,
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
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: KuberColors.primary,
                      letterSpacing: -0.5,
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

                // Add button
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
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: KuberColors.primary.withValues(alpha: 0.35),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_rounded,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            isAccountsTab ? 'Add Account' : 'Add Transaction',
                            style: GoogleFonts.plusJakartaSans(
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
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? KuberColors.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
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
              style: GoogleFonts.plusJakartaSans(
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
    );
  }
}
