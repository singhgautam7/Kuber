import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../engine/scan_progress.dart';
import '../providers/sms_import_provider.dart';
import '../widgets/paste_sms_sheet.dart';
import 'sms_import_screen.dart';

/// Full-screen blocking progress for the very first inbox scan (Scenario A,
/// Section 04.5 A). Streams scan progress, holds 600ms on completion then
/// fades to the list. Zero results stays on this screen.
class SmsFirstLoadScreen extends ConsumerStatefulWidget {
  const SmsFirstLoadScreen({super.key});

  @override
  ConsumerState<SmsFirstLoadScreen> createState() => _SmsFirstLoadScreenState();
}

class _SmsFirstLoadScreenState extends ConsumerState<SmsFirstLoadScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _accent;
  bool _navigated = false;
  ScanProgress? _frozenProgress;

  @override
  void initState() {
    super.initState();
    _accent = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(smsImportProvider.notifier).startFirstLoadScan();
    });
  }

  @override
  void dispose() {
    _accent.dispose();
    super.dispose();
  }

  void _onComplete(ScanProgress progress) {
    if (_navigated) return;
    if (progress.bankMessagesFound <= 0) {
      // Empty result: stay on this screen (handled by build showing the
      // empty state). No navigation.
      return;
    }
    _navigated = true;
    setState(() {
      _frozenProgress = progress;
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      ref.read(smsImportProvider.notifier).clearScanProgress();
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SmsImportScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    });
  }

  Future<bool> _confirmCancel() async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.lg),
          side: BorderSide(color: cs.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancel scanning?',
                style: localeFont(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                  letterSpacing: -0.3,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "You can resume later. Your progress so far won't be saved.",
                style: localeFont(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Cancel scan',
                      type: AppButtonType.danger,
                      onPressed: () => Navigator.pop(ctx, true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: AppButton(
                      label: 'Keep scanning',
                      type: AppButtonType.primary,
                      onPressed: () => Navigator.pop(ctx, false),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final progress = _frozenProgress ?? ref.watch(
      smsImportProvider.select((s) => s.valueOrNull?.scanProgress),
    );

    // Fire completion handling exactly once per completion.
    ref.listen(
      smsImportProvider.select((s) => s.valueOrNull?.scanProgress),
      (prev, next) {
        if (next != null && next.isComplete) {
          _onComplete(next);
        } else if (next == null && prev != null && !prev.isComplete && !_navigated) {
          // The scan failed/cancelled in the background. Exit to avoid hang.
          _navigated = true;
          if (mounted) Navigator.of(context).pop();
        }
      },
    );

    final isComplete = progress?.isComplete ?? false;
    final isEmptyResult = isComplete && (progress?.bankMessagesFound ?? 0) <= 0;
    final scanning = progress != null && !progress.isComplete;

    return PopScope(
      canPop: !scanning,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop || !scanning) return;
        final navigator = Navigator.of(context);
        final confirmed = await _confirmCancel();
        if (!mounted) return;
        if (confirmed) {
          _navigated = true; // prevent listener from double popping
          ref.read(smsImportProvider.notifier).cancelScan();
          navigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: Column(
          children: [
            const KuberAppBar(showBack: true, title: 'Import from SMS'),
            Expanded(
              child: isEmptyResult
                  ? _EmptyResult(progress: progress!)
                  : _ScanningBody(progress: progress, accent: _accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScanningBody extends StatelessWidget {
  final ScanProgress? progress;
  final AnimationController accent;
  const _ScanningBody({required this.progress, required this.accent});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fraction = progress?.fraction;
    final scanned = progress?.scannedMessages ?? 0;
    final total = progress?.totalMessages ?? 0;
    final found = progress?.bankMessagesFound ?? 0;
    final isComplete = progress?.isComplete ?? false;
    final nearDone = (fraction ?? 0) >= 0.85;

    final status = isComplete
        ? 'Done! $found bank transactions found.'
        : nearDone
            ? 'Almost done…'
            : 'Reading your messages…';

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _HeroIcon(accent: accent, complete: isComplete),
                const SizedBox(height: 36),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: _ProgressBar(fraction: fraction, complete: isComplete),
                ),
                const SizedBox(height: 22),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    status,
                    key: ValueKey(status),
                    textAlign: TextAlign.center,
                    style: localeFont(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                if (!isComplete) ...[
                  const SizedBox(height: 14),
                  Text(
                    total > 0
                        ? '$scanned of $total messages scanned'
                        : 'Preparing to scan…',
                    style: localeFont(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ).copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '$found',
                          style: TextStyle(
                            color: cs.tertiary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const TextSpan(text: ' bank transactions found'),
                      ],
                    ),
                    style: localeFont(fontSize: 13, color: cs.onSurfaceVariant),
                  ),
                ] else ...[
                  const SizedBox(height: 14),
                  Text(
                    'Opening your list…',
                    style: localeFont(
                      fontSize: 13,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        _PrivacyLine(),
      ],
    );
  }
}

class _HeroIcon extends StatelessWidget {
  final AnimationController accent;
  final bool complete;
  const _HeroIcon({required this.accent, required this.complete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = complete ? cs.tertiary : cs.primary;
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(KuberRadius.xl),
              border: Border.all(color: color.withValues(alpha: 0.25)),
            ),
            child: Icon(Icons.sms_outlined, size: 40, color: color),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: complete
                      ? const Icon(Icons.check_rounded,
                          size: 14, color: Colors.white)
                      : RotationTransition(
                          turns: accent,
                          child: const Icon(Icons.refresh_rounded,
                              size: 14, color: Colors.white),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double? fraction; // null = indeterminate
  final bool complete;
  const _ProgressBar({required this.fraction, required this.complete});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (fraction == null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: LinearProgressIndicator(
          minHeight: 6,
          backgroundColor: cs.surfaceContainerHigh,
          valueColor: AlwaysStoppedAnimation(cs.primary),
        ),
      );
    }
    final color = complete ? cs.tertiary : cs.primary;
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      clipBehavior: Clip.antiAlias,
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          builder: (_, value, __) => FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyResult extends ConsumerWidget {
  final ScanProgress progress;
  const _EmptyResult({required this.progress});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.xl),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Icon(Icons.speaker_notes_off_outlined,
                      size: 38, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 36),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Container(color: context.kuberColors.borderMuted),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.totalMessages} of ${progress.totalMessages} messages scanned',
                  style: localeFont(
                    fontSize: 11.5,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'No bank transaction messages found.',
                  textAlign: TextAlign.center,
                  style: localeFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Make sure your bank has SMS alerts enabled. You can also '
                  'paste an SMS manually.',
                  textAlign: TextAlign.center,
                  style: localeFont(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
          child: Column(
            children: [
              AppButton(
                label: 'Paste an SMS',
                type: AppButtonType.primary,
                fullWidth: true,
                icon: Icons.content_paste_rounded,
                onPressed: () => showPasteSmsSheet(context),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  'Go back',
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PrivacyLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shield_outlined,
              size: 13, color: cs.onSurfaceVariant.withValues(alpha: 0.7)),
          const SizedBox(width: 8),
          Text(
            'On-device. Nothing leaves your phone.',
            style: localeFont(
              fontSize: 11.5,
              color: cs.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
