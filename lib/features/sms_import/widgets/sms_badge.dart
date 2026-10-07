import 'package:flutter/material.dart';

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
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.secondaryContainer,
        borderRadius: KuberShape.fullR,
      ),
      child: Text(
        'SMS',
        style: localeFont(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: cs.onSecondaryContainer,
          letterSpacing: 0.5,
          height: 1.0,
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
        padding: const EdgeInsets.all(KuberSpace.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Text(
          rawSms,
          style: monoFont(
            fontSize: 12,
            height: 1.55,
            color: cs.onSurface,
            letterSpacing: -0.1,
          ),
        ),
      ),
    ),
  );
}
