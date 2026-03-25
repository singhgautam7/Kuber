import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class KuberAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final bool showBack;

  const KuberAppBar({super.key, this.title, this.actions, this.showBack = false});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 0,
      child: Container(
        height: kToolbarHeight + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: KuberSpacing.lg,
          right: KuberSpacing.lg,
        ),
        child: Row(
          children: [
            if (showBack) ...[
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Icon(Icons.arrow_back_rounded,
                    color: cs.onSurface, size: 22),
              ),
              const SizedBox(width: 12),
            ],
            if (title == null) ...[
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  color: cs.primary,
                  size: 15,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Kuber',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: cs.primary,
                  letterSpacing: -0.3,
                ),
              ),
            ] else
              Text(
                title!,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                ),
              ),
            const Spacer(),
            if (actions != null) ...actions!,
          ],
        ),
      ),
    );
  }
}
