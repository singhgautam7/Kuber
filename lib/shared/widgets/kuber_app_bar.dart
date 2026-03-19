import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class KuberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final List<Widget>? actions;

  const KuberAppBar({super.key, this.actions});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: KuberColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Center(
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: KuberColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              color: KuberColors.primary,
              size: 18,
            ),
          ),
        ),
      ),
      title: Text(
        'Kuber',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: KuberColors.primary,
          letterSpacing: -0.3,
        ),
      ),
      actions: actions,
    );
  }
}
