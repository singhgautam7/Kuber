import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../pro/feature_gates/gate_sheet_sms_import.dart';
import '../../pro/feature_gates/pro_gate.dart';
import '../providers/sms_import_provider.dart';

/// Home dashboard widget for SMS import. Deliberately lightweight: it reads
/// only the last-scan time (shared prefs) + permission flag via
/// [smsHomeInfoProvider] and NEVER loads the staged SMS rows on the home
/// page — those (potentially thousands) are only queried on the SMS Import
/// screen. It shows the last-fetched time in muted text and triggers a gated
/// background scan post-frame, loading the heavy provider only when a scan is
/// actually due.
class SmsImportHomeWidget extends ConsumerStatefulWidget {
  const SmsImportHomeWidget({super.key});

  @override
  ConsumerState<SmsImportHomeWidget> createState() =>
      _SmsImportHomeWidgetState();
}

class _SmsImportHomeWidgetState extends ConsumerState<SmsImportHomeWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeBackgroundScan());
  }

  /// Deferred, gated background refresh. Reads the LIGHTWEIGHT info first; only
  /// if a scan is actually due does it touch the heavy [smsImportProvider].
  Future<void> _maybeBackgroundScan() async {
    final info = await ref.read(smsHomeInfoProvider.future);
    if (!mounted || !info.hasPermission) return;
    final last = info.lastScannedAt;
    final due =
        last != null && DateTime.now().difference(last) > const Duration(minutes: 30);
    if (!due) return;

    final notifier = ref.read(smsImportProvider.notifier);
    await ref.read(smsImportProvider.future);
    if (!mounted) return;
    if (notifier.backgroundRefreshDue()) {
      notifier.startBackgroundScan();
      // Refresh the muted "last checked" line once the scan writes a new time.
      ref.invalidate(smsHomeInfoProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final infoAsync = ref.watch(smsHomeInfoProvider);

    final Widget card = infoAsync.when(
      loading: () => const SizedBox(key: ValueKey('loading'), height: 84),
      error: (_, __) => const SizedBox(key: ValueKey('err'), height: 0),
      data: (info) => info.hasPermission
          ? _LastCheckedCard(
              key: const ValueKey('checked'),
              lastScannedAt: info.lastScannedAt,
            )
          : const _PermissionNeededCard(key: ValueKey('perm')),
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'SMS IMPORT',
              style: localeFont(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: card,
          ),
        ],
      ),
    );
  }
}

void _openImport(BuildContext context, WidgetRef ref, SmsImportTabArg tab) {
  // SMS Import is a Kuber Pro feature. Free users get the gate sheet instead
  // of the screen; Pro and trial users pass straight through.
  if (proGate(context, ref, showSmsImportGateSheet)) {
    context.push('/more/sms-import?tab=${tab.name}');
  }
}

/// Tab the widget deep-links to. Mirrors SmsImportTab without importing the
/// screen here.
enum SmsImportTabArg { unreviewed, imported, dismissed }

/// Muted "last checked" summary — the home surface shows when the inbox was
/// last scanned rather than a live unreviewed counter (which would require
/// loading every staged row).
class _LastCheckedCard extends ConsumerWidget {
  final DateTime? lastScannedAt;
  const _LastCheckedCard({super.key, required this.lastScannedAt});

  String _label() {
    final at = lastScannedAt;
    if (at == null) return 'Not scanned yet';
    final now = DateTime.now();
    final diff = now.difference(at);
    if (diff.inMinutes < 1) return 'Last checked just now';
    if (diff.inMinutes < 60) return 'Last checked ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last checked ${diff.inHours}h ago';
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(at.year, at.month, at.day);
    if (today.difference(day).inDays == 1) {
      return 'Last checked yesterday, ${DateFormat('h:mm a').format(at)}';
    }
    final fmt = at.year == now.year
        ? DateFormat('d MMM, h:mm a')
        : DateFormat('d MMM yyyy');
    return 'Last checked ${fmt.format(at)}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _openImport(context, ref, SmsImportTabArg.unreviewed),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            _IconBadge(
              bg: cs.primary.withValues(alpha: 0.10),
              border: cs.primary.withValues(alpha: 0.25),
              color: cs.primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Import from SMS',
                    style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _label(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}

class _PermissionNeededCard extends ConsumerWidget {
  const _PermissionNeededCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(
                bg: cs.surfaceContainerHigh,
                border: cs.outline,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-detect transactions',
                      style: localeFont(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enable SMS to read bank messages',
                      style: localeFont(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: cs.surfaceContainerHigh,
                foregroundColor: cs.onSurface,
                side: BorderSide(color: cs.outline),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              onPressed: () =>
                  _openImport(context, ref, SmsImportTabArg.unreviewed),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Set up',
                    style: localeFont(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded,
                      size: 13, color: cs.onSurface),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color color;
  const _IconBadge({
    required this.bg,
    required this.border,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Icon(Icons.sms_outlined, size: 22, color: color),
    );
  }
}
