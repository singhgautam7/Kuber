import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';

/// Small "SMS" pill shown next to the merchant name on transactions that were
/// imported from a bank SMS (Section 09, recommended treatment B). Tapping it
/// (when [onTap] is provided) opens the original SMS.
class SmsBadge extends StatelessWidget {
  final VoidCallback? onTap;

  const SmsBadge({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        'SMS',
        style: localeFont(
          fontSize: 9.5,
          fontWeight: FontWeight.w700,
          color: cs.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
    if (onTap == null) return pill;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: pill,
    );
  }
}

/// Bottom sheet showing the raw SMS body in a monospace block. Opened from the
/// SMS badge in the transaction row / detail sheet.
void showRawSmsSheet(
  BuildContext context, {
  required String rawSms,
  String? senderId,
}) {
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => KuberBottomSheet(
      title: 'Original SMS',
      subtitle: senderId,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Text(
          rawSms,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12.5,
            height: 1.55,
            color: cs.onSurface,
            letterSpacing: -0.1,
          ),
        ),
      ),
    ),
  );
}
