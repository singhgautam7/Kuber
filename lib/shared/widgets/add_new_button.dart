import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';

class AddNewButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const AddNewButton({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.fromLTRB(
            16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
        child: SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onTap,
            style: OutlinedButton.styleFrom(
              foregroundColor: KuberColors.textPrimary,
              side: const BorderSide(color: KuberColors.border, width: 1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              backgroundColor: Colors.transparent,
            ),
            icon: const Icon(Icons.add_rounded,
                color: KuberColors.textSecondary, size: 18),
            label: Text(label,
                style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: KuberColors.textPrimary)),
          ),
        ),
      );
}
