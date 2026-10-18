import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../data/home_v2_state.dart';
import '../providers/get_started_provider.dart';
import '../providers/home_v2_provider.dart';

/// Get started (suggestion-rules.md §2, board HV2.2). Part of Home's first
/// layout for an eligible v2 install; the body is a skeleton until the
/// step / permission state resolves.
class GetStartedCard extends ConsumerStatefulWidget {
  const GetStartedCard({super.key});

  @override
  ConsumerState<GetStartedCard> createState() => _GetStartedCardState();
}

class _GetStartedCardState extends ConsumerState<GetStartedCard> {
  @override
  void initState() {
    super.initState();
    // First time the card is on screen (for the 14-day timeout).
    final s = ref.read(homeV2Provider);
    if (s.gsFirstShownAt == null) {
      ref
          .read(homeV2Provider.notifier)
          .update((s) => s.copyWith(gsFirstShownAt: DateTime.now()));
    }
    // Graduation is a side effect of fresh data, never of a rebuild.
    ref.listenManual<AsyncValue<GsData?>>(getStartedProvider, (_, next) {
      final d = next.valueOrNull;
      if (d == null) return;
      final reason = gsGraduationFor(
        d,
        firstShownAt: ref.read(homeV2Provider).gsFirstShownAt,
        now: DateTime.now(),
      );
      if (reason != null) _graduate(reason);
    }, fireImmediately: true);
  }

  void _refresh() => ref.read(gsRefreshProvider.notifier).state++;

  bool _graduating = false;

  Future<void> _graduate(GsGraduation reason) async {
    // The listener can fire again before the snapshot write lands.
    if (_graduating) return;
    _graduating = true;
    return ref
        .read(homeV2Provider.notifier)
        .update(
          (s) => s.copyWith(
            gsGraduatedAt: () => DateTime.now(),
            gsGraduationReason: () => reason,
            gsSuccessShown:
                reason == GsGraduation.completed ||
                    reason == GsGraduation.transactions
                ? false
                : true,
          ),
        );
  }

  Future<void> _push(String route, {Object? extra}) async {
    await context.push(route, extra: extra);
    if (mounted) _refresh();
  }

  Future<void> _close() async {
    final l = context.l10n;
    // The card unmounts on graduation: hand the root overlay over directly.
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    final notifier = ref.read(homeV2Provider.notifier);
    showKuberSnackBar(
      context,
      l.homeV2GsClosedSnack,
      overlay: overlay,
      actionLabel: l.homeV2ActUndo,
      onAction: () => notifier.update(
        (s) => s.copyWith(
          gsGraduatedAt: () => null,
          gsGraduationReason: () => null,
        ),
      ),
    );
    await _graduate(GsGraduation.dismissed);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(getStartedProvider);
    final d = async.valueOrNull;
    return KuberCard(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: d == null
            ? const _GsSkeleton(key: ValueKey('gs-loading'))
            : _GsBody(
                key: const ValueKey('gs-body'),
                data: d,
                onClose: _close,
                onAdd: () => _push('/add-transaction'),
                onAccounts: () => _push('/more/accounts'),
              ),
      ),
    );
  }
}

class _GsSkeleton extends StatelessWidget {
  const _GsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => const Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      KuberSkeleton(height: 12, width: 80),
      SizedBox(height: KuberSpace.sm),
      KuberSkeleton(height: 24, width: 200),
      SizedBox(height: KuberSpace.sm),
      KuberSkeleton(height: 40),
      SizedBox(height: KuberSpace.lg),
      KuberSkeleton(height: 96),
      SizedBox(height: KuberSpace.lg),
      KuberSkeleton(height: 48),
    ],
  );
}

class _GsBody extends StatelessWidget {
  final GsData data;
  final VoidCallback onClose;
  final VoidCallback onAdd;
  final VoidCallback onAccounts;

  const _GsBody({
    super.key,
    required this.data,
    required this.onClose,
    required this.onAdd,
    required this.onAccounts,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final d = data;
    final body = switch (d.state) {
      GsState.fresh => l.homeV33GsBodyFresh,
      GsState.oneDone => l.homeV2GsBodyTwoDone,
    };

    // One button per open step, in step order (user review): View
    // accounts (outline), then Add transaction (filled), both full height.
    final buttons = [
      if (!d.step3) _out(l.homeV33GsActAccounts, onAccounts),
      if (!d.step2) _hero(l.homeV2GsActAdd, Icons.add_rounded, onAdd),
    ];

    Widget step(String label, bool done, {String? sub}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Icon(
              done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
              key: ValueKey(done),
              size: 22,
              color: done ? cs.primary : cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: tt.bodyLarge!.copyWith(color: cs.onSurface)),
                if (sub != null)
                  Text(
                    sub,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.homeV33GsProgress(d.done).toUpperCase(),
                    style: tt.labelMedium!.copyWith(
                      letterSpacing: 0.8,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.xs),
                  Text(
                    l.homeV2GsTitle,
                    style: tt.titleLarge!.copyWith(color: cs.onSurface),
                  ),
                ],
              ),
            ),
            AppIconButton(
              icon: Icons.close_rounded,
              kind: AppIconButtonKind.plain,
              size: 40,
              semanticLabel: l.homeV2GsCloseA11y,
              onPressed: onClose,
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.xs),
        Text(body, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: KuberSpace.md),
        step(l.homeV33GsStepAccounts, d.step3),
        step(l.homeV2GsStep2, d.step2),
        const SizedBox(height: KuberSpace.lg),
        for (final (i, b) in buttons.indexed) ...[
          if (i > 0) const SizedBox(height: KuberSpace.sm),
          b,
        ],
      ],
    );
  }

  Widget _hero(String label, IconData icon, VoidCallback onTap) => AppButton(
    label: label,
    icon: icon,
    type: AppButtonType.primary,
    fullWidth: true,
    height: 48,
    onPressed: onTap,
  );

  Widget _out(String label, VoidCallback onTap) => AppButton(
    label: label,
    type: AppButtonType.outline,
    fullWidth: true,
    height: 48,
    onPressed: onTap,
  );
}

/// Complete state (board HV2.2): shown once at the first Home build after a
/// success graduation, held 3 s or until the user scrolls, then collapsed
/// by the top slot via [onDone].
class GetStartedDoneCard extends StatefulWidget {
  final VoidCallback onDone;

  /// The Home tab is the one showing (tabs live in a PageView, so an
  /// inactive tab still has tickers on).
  final bool homeTabShowing;
  const GetStartedDoneCard({
    super.key,
    required this.onDone,
    required this.homeTabShowing,
  });

  @override
  State<GetStartedDoneCard> createState() => _GetStartedDoneCardState();
}

class _GetStartedDoneCardState extends State<GetStartedDoneCard> {
  ValueListenable<bool>? _scrolling;
  Timer? _hold;
  bool _done = false;

  void _finish() {
    if (_done) return;
    _done = true;
    _hold?.cancel();
    _scrolling?.removeListener(_onScrolling);
    widget.onDone();
  }

  // Only a user scroll counts; a layout change that moves the offset
  // (the Get started card leaving) does not.
  void _onScrolling() {
    if (_scrolling?.value ?? false) _finish();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrolling?.removeListener(_onScrolling);
    _scrolling = Scrollable.maybeOf(context)?.position.isScrollingNotifier;
    _scrolling?.addListener(_onScrolling);
    _maybeHold();
  }

  @override
  void didUpdateWidget(GetStartedDoneCard old) {
    super.didUpdateWidget(old);
    _maybeHold();
  }

  // Graduation can happen while another screen (Edit account, SMS import)
  // is on top or another tab is showing: the 3 s hold starts once Home is
  // visible again.
  void _maybeHold() {
    final visible =
        widget.homeTabShowing &&
        (ModalRoute.of(context)?.isCurrent ?? true) &&
        TickerMode.valuesOf(context).enabled;
    if (visible && _hold == null) {
      _hold = Timer(const Duration(milliseconds: 3000), _finish);
    }
  }

  @override
  void dispose() {
    _hold?.cancel();
    _scrolling?.removeListener(_onScrolling);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return KuberCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: cs.onPrimary),
          ),
          const SizedBox(width: KuberSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.homeV2GsDoneTitle,
                  style: tt.titleMedium!.copyWith(color: cs.onSurface),
                ),
                Text(
                  l.homeV2GsDoneBody,
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
