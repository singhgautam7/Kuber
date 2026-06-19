import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../engine/scan_progress.dart';
import '../providers/sms_import_provider.dart';

/// Non-blocking strip shown at the top of the import list during a background
/// refresh (Section 04.5 B). Watches only `scanProgress` so the list beneath
/// does not rebuild while a scan runs. Animates its own height in/out.
class ScanProgressStrip extends ConsumerWidget {
  const ScanProgressStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      smsImportProvider.select((s) => s.valueOrNull?.scanProgress),
    );

    // Only background refreshes use this strip; the first-load screen owns the
    // blocking surface.
    final visible =
        progress != null && progress.trigger == ScanTrigger.backgroundRefresh;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: visible
          ? Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _StripContent(progress: progress),
            )
          : const SizedBox(width: double.infinity),
    );
  }
}

class _StripContent extends StatelessWidget {
  final ScanProgress progress;
  const _StripContent({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final complete = progress.isComplete;
    final newCount = progress.bankMessagesFound;

    final Color bg;
    final Color border;
    if (complete && newCount > 0) {
      bg = cs.tertiary.withValues(alpha: 0.10);
      border = cs.tertiary.withValues(alpha: 0.30);
    } else {
      bg = cs.primary.withValues(alpha: 0.10);
      border = cs.primary.withValues(alpha: 0.25);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          _leading(cs, complete, newCount),
          const SizedBox(width: 10),
          Expanded(child: _label(cs, complete, newCount)),
        ],
      ),
    );
  }

  Widget _leading(ColorScheme cs, bool complete, int newCount) {
    if (!complete) {
      return SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(strokeWidth: 1.8, color: cs.primary),
      );
    }
    if (newCount > 0) {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(color: cs.tertiary, shape: BoxShape.circle),
        child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
      );
    }
    return Icon(Icons.check_circle_outline_rounded, size: 16, color: cs.primary);
  }

  Widget _label(ColorScheme cs, bool complete, int newCount) {
    if (!complete) {
      final total = progress.totalMessages;
      final scanned = progress.scannedMessages;
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Checking for new messages… '),
            if (total > 0)
              TextSpan(
                text: '$scanned of $total',
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
          ],
        ),
        style: localeFont(fontSize: 12, color: cs.onSurface),
      );
    }
    if (newCount > 0) {
      return Text.rich(
        TextSpan(
          children: [
            const TextSpan(text: 'Up to date — '),
            TextSpan(
              text:
                  '$newCount new transaction${newCount == 1 ? '' : 's'}',
              style: TextStyle(color: cs.tertiary, fontWeight: FontWeight.w700),
            ),
            const TextSpan(text: ' found'),
          ],
        ),
        style: localeFont(fontSize: 12, color: cs.onSurface),
      );
    }
    return Text(
      'Up to date — nothing new',
      style: localeFont(fontSize: 12, color: cs.onSurface),
    );
  }
}
