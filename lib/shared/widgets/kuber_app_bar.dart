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

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
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
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icon/app_icon_transparent.png',
                      width: 32,
                      height: 32,
                    ),
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
      ),
    );
  }
}
