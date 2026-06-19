import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../data/sms_transaction.dart';
import '../engine/scan_progress.dart';
import '../providers/sms_import_provider.dart';

/// Home dashboard widget for SMS import (Section 08 + 04.5 State D). States:
/// active (unreviewed > 0), caught up, permission needed, and State D
/// (background scan running). Triggers a gated background refresh on mount.
class SmsImportHomeWidget extends ConsumerStatefulWidget {
  const SmsImportHomeWidget({super.key});

  @override
  ConsumerState<SmsImportHomeWidget> createState() =>
      _SmsImportHomeWidgetState();
}

class _SmsImportHomeWidgetState extends ConsumerState<SmsImportHomeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    // Deferred, gated background refresh — runs only after the first frame
    // (so the rest of the dashboard renders first), never on cold start.
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeBackgroundScan());
  }

  Future<void> _maybeBackgroundScan() async {
    final notifier = ref.read(smsImportProvider.notifier);
    await ref.read(smsImportProvider.future);
    if (!mounted) return;
    final s = ref.read(smsImportProvider).valueOrNull;
    if (s != null && s.hasPermission && notifier.backgroundRefreshDue()) {
      notifier.startBackgroundScan();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Watch a narrow projection rather than the whole state object. A
    // background scan emits a fresh ScanProgress every 50 messages; this
    // widget only cares whether a scan is running (a bool), the permission
    // flag, the unreviewed rows and the imported count — none of which change
    // mid-scan. Selecting them keeps progress-count emissions from rebuilding
    // the card (the indeterminate bar is driven by [_anim], not the counts).
    final vm = ref.watch(
      smsImportProvider.select((async) {
        final s = async.valueOrNull;
        final scanning = s?.scanProgress != null &&
            s!.scanProgress!.trigger == ScanTrigger.backgroundRefresh &&
            !s.scanProgress!.isComplete;
        return (
          loaded: s != null,
          scanning: scanning,
          hasPermission: s?.hasPermission ?? false,
          unreviewed: s?.unreviewed ?? const <SmsTransaction>[],
          importedCount: s?.imported.length ?? 0,
        );
      }),
    );

    // Run the State D animation only while it is showing.
    if (vm.scanning) {
      if (!_anim.isAnimating) _anim.repeat();
    } else {
      if (_anim.isAnimating) _anim.stop();
    }

    final Widget card;
    if (!vm.loaded) {
      card = const SizedBox(key: ValueKey('loading'), height: 84);
    } else if (vm.scanning) {
      card = _ScanningCard(key: const ValueKey('scanning'), anim: _anim);
    } else if (!vm.hasPermission) {
      card = const _PermissionNeededCard(key: ValueKey('perm'));
    } else if (vm.unreviewed.isNotEmpty) {
      card = _ActiveCard(
        key: const ValueKey('active'),
        count: vm.unreviewed.length,
        banks: _bankSummary(vm.unreviewed),
      );
    } else {
      card = _CaughtUpCard(
        key: const ValueKey('caught'),
        importedCount: vm.importedCount,
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.lg),
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

  /// "From HDFC, ICICI & 2 more banks" derived from unreviewed senders.
  static String _bankSummary(List<SmsTransaction> rows) {
    final names = <String>{};
    for (final r in rows) {
      names.add(_bankName(r.senderId));
    }
    final list = names.toList();
    if (list.isEmpty) return 'From your banks';
    if (list.length == 1) return 'From ${list.first}';
    if (list.length == 2) return 'From ${list[0]} & ${list[1]}';
    return 'From ${list[0]}, ${list[1]} & ${list.length - 2} more banks';
  }

  static String _bankName(String senderId) {
    final norm = senderId.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    for (final token in const [
      'HDFC', 'SBI', 'ICICI', 'AXIS', 'KOTAK', 'INDUS', 'YES', 'IDFC',
      'BOB', 'PNB', 'CANARA', 'UNION', 'FED', 'RBL', 'AU', 'PAYTM',
      'PHONEPE', 'GPAY',
    ]) {
      if (norm.contains(token)) return token;
    }
    return senderId;
  }
}

void _openImport(BuildContext context, SmsImportTabArg tab) {
  context.push('/more/sms-import?tab=${tab.name}');
}

/// Tab the widget deep-links to. Mirrors SmsImportTab without importing the
/// screen here.
enum SmsImportTabArg { unreviewed, imported, dismissed }

class _ActiveCard extends StatelessWidget {
  final int count;
  final String banks;
  const _ActiveCard({super.key, required this.count, required this.banks});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final badge = count > 99 ? '99+' : '$count';
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
                bg: cs.primary.withValues(alpha: 0.10),
                border: cs.primary.withValues(alpha: 0.25),
                color: cs.primary,
                badge: badge,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count new transaction${count == 1 ? '' : 's'}',
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      banks,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
          const SizedBox(height: 16),
          SizedBox(
            height: 40,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              onPressed: () =>
                  _openImport(context, SmsImportTabArg.unreviewed),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Review now',
                    style: localeFont(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaughtUpCard extends StatelessWidget {
  final int importedCount;
  const _CaughtUpCard({super.key, required this.importedCount});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _openImport(context, SmsImportTabArg.imported),
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
              bg: cs.tertiary.withValues(alpha: 0.10),
              border: cs.tertiary.withValues(alpha: 0.30),
              color: cs.tertiary,
              icon: Icons.check_rounded,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All caught up',
                    style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '$importedCount imported in the last 90 days',
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionNeededCard extends StatelessWidget {
  const _PermissionNeededCard({super.key});

  @override
  Widget build(BuildContext context) {
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
                  _openImport(context, SmsImportTabArg.unreviewed),
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

/// State D — background scan in progress (Section 04.5 C). Tapping still opens
/// the import screen.
class _ScanningCard extends StatelessWidget {
  final AnimationController anim;
  const _ScanningCard({super.key, required this.anim});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => _openImport(context, SmsImportTabArg.unreviewed),
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            border: Border.all(color: cs.outline),
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    _PulsingBadge(anim: anim),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Checking for new transactions…',
                            style: localeFont(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'This usually takes a few seconds.',
                            style: localeFont(
                              fontSize: 11.5,
                              color: cs.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              _IndeterminateBar(anim: anim),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingBadge extends StatelessWidget {
  final AnimationController anim;
  const _PulsingBadge({required this.anim});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: anim,
      builder: (_, child) {
        final pulse = 0.96 + 0.04 * (0.5 + 0.5 * math.sin(anim.value * 2 * math.pi));
        return Transform.scale(scale: pulse, child: child);
      },
      child: SizedBox(
        width: 44,
        height: 44,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
              ),
              child: Icon(Icons.sms_outlined, size: 22, color: cs.primary),
            ),
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.surfaceContainer, width: 2),
                ),
                child: RotationTransition(
                  turns: anim,
                  child: const Icon(Icons.refresh_rounded,
                      size: 9, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IndeterminateBar extends StatelessWidget {
  final AnimationController anim;
  const _IndeterminateBar({required this.anim});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 2,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          const segFrac = 0.35;
          return Stack(
            children: [
              Container(width: w, height: 2, color: cs.surfaceContainerHigh),
              AnimatedBuilder(
                animation: anim,
                builder: (_, __) {
                  // Segment travels left -> right across the full width.
                  final left = (anim.value * (1 + segFrac) - segFrac) * w;
                  return Positioned(
                    left: left,
                    child: Container(
                      width: w * segFrac,
                      height: 2,
                      color: cs.primary,
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  final Color bg;
  final Color border;
  final Color color;
  final String? badge;
  final IconData icon;
  const _IconBadge({
    required this.bg,
    required this.border,
    required this.color,
    this.badge,
    this.icon = Icons.sms_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 20),
                height: 20,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: cs.surfaceContainer, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  badge!,
                  style: localeFont(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
