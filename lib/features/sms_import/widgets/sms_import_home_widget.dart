import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../main.dart' show onOpenBatchReadyProvider;
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
    // Wait until the app is interactive (cold-start splash gone) before touching
    // the inbox: the platform-thread SMS read + isolate spawn otherwise land in
    // the splash animation. If already interactive (widget re-created later),
    // run now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (ref.read(onOpenBatchReadyProvider)) {
        _maybeBackgroundScan();
        return;
      }
      ref.listenManual<bool>(onOpenBatchReadyProvider, (prev, ready) {
        if (ready) _maybeBackgroundScan();
      });
    });
  }

  /// Deferred, gated background refresh. Reads the LIGHTWEIGHT info first; only
  /// if a scan is actually due does it touch the heavy [smsImportProvider].
  Future<void> _maybeBackgroundScan() async {
    final info = await ref.read(smsHomeInfoProvider.future);
    if (!mounted || !info.hasPermission) return;
    final last = info.lastScannedAt;
    final due =
        last != null &&
        DateTime.now().difference(last) > const Duration(minutes: 30);
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
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberSectionHeader(title: 'SMS IMPORT'),
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
  // SMS Import is free to open for everyone; the weekly import cap is enforced
  // at the import action, not at the entry point.
  context.push('/more/sms-import?tab=${tab.name}');
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
    // Review state: a one-row grouped list (board 3.2a).
    return KuberGroup(
      children: [
        KuberListRow(
          leading: const KuberIconTile(icon: Icons.sms_outlined),
          title: 'Import from SMS',
          subtitle: _label(),
          trailing: const KuberChevron(),
          onTap: () => _openImport(context, ref, SmsImportTabArg.unreviewed),
        ),
      ],
    );
  }
}

class _PermissionNeededCard extends ConsumerWidget {
  const _PermissionNeededCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Permission / CTA state: a card with a tonal action (board 3.2a).
    return KuberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KuberIconTile(icon: Icons.sms_outlined),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-detect transactions',
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      'Enable SMS to read bank messages',
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.md),
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(
              label: 'Set up',
              icon: Icons.arrow_forward_rounded,
              iconAfterLabel: true,
              height: 40,
              onPressed: () =>
                  _openImport(context, ref, SmsImportTabArg.unreviewed),
            ),
          ),
        ],
      ),
    );
  }
}
