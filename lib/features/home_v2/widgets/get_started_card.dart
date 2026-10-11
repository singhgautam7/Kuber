import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../sms_import/widgets/paste_sms_sheet.dart';
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

class _GetStartedCardState extends ConsumerState<GetStartedCard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Back from phone settings or the permission dialog: read permission and
  // staged counts again.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refresh();
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

  /// Hero "Import from SMS" / "Allow SMS access": ask first if needed, then
  /// open SMS import.
  Future<void> _importSms(GsData d) async {
    if (!d.smsGranted) {
      await ref.read(homeV2Provider.notifier).markSmsRequested();
      final status = await Permission.sms.request();
      _refresh();
      if (!status.isGranted || !mounted) return;
    }
    await _push('/more/sms-import');
  }

  Future<void> _setBalance() async {
    final accounts = await ref.read(allAccountsProvider.future);
    if (!mounted || accounts.isEmpty) return;
    final defaultId = ref.read(
      settingsProvider.select((s) => s.valueOrNull?.defaultAccountId),
    );
    final enabled = accounts.where((a) => !a.isDisabled).toList();
    final pick = enabled.firstWhere(
      (a) => a.id.toString() == defaultId,
      orElse: () => enabled.isNotEmpty ? enabled.first : accounts.first,
    );
    await _push('/accounts/edit', extra: pick);
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
                onImport: () => _importSms(d),
                onAdd: () => _push('/add-transaction'),
                onQuick: () => _push('/quick-add'),
                onBalance: _setBalance,
                onSettings: () async {
                  await openAppSettings();
                },
                onPaste: () => showPasteSmsSheet(context),
                onPro: () => _push('/pro'),
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
  final VoidCallback onImport;
  final VoidCallback onAdd;
  final VoidCallback onQuick;
  final VoidCallback onBalance;
  final VoidCallback onSettings;
  final VoidCallback onPaste;
  final VoidCallback onPro;

  const _GsBody({
    super.key,
    required this.data,
    required this.onClose,
    required this.onImport,
    required this.onAdd,
    required this.onQuick,
    required this.onBalance,
    required this.onSettings,
    required this.onPaste,
    required this.onPro,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final d = data;
    final permissionState =
        d.state == GsState.denied || d.state == GsState.blocked;

    final body = switch (d.state) {
      GsState.fresh => l.homeV2GsBodyFresh,
      GsState.oneDone => l.homeV2GsBodyOneDone,
      GsState.twoDone => l.homeV2GsBodyTwoDone,
      GsState.denied => l.homeV2GsBodyDenied,
      GsState.blocked => l.homeV2GsBodyBlocked,
    };

    // Hero = first incomplete step; secondaries per the action table.
    final (Widget hero, List<Widget> secondary) = switch (d.state) {
      GsState.denied => (
        _hero(l.homeV2GsActAllow, Icons.sms_outlined, onImport),
        [_out(l.homeV2GsActPaste, onPaste), _out(l.homeV2GsActAdd, onAdd)],
      ),
      GsState.blocked => (
        _hero(l.homeV2GsActSettings, Icons.open_in_new_rounded, onSettings),
        [_out(l.homeV2GsActPaste, onPaste), _out(l.homeV2GsActAdd, onAdd)],
      ),
      _ when !d.step1 => (
        _hero(l.homeV2GsActImport, Icons.sms_outlined, onImport),
        [
          if (!d.step2) _out(l.homeV2GsActAdd, onAdd),
          _out(l.homeV2GsActQuick, onQuick),
        ],
      ),
      _ when !d.step2 => (
        _hero(l.homeV2GsActAdd, Icons.add_rounded, onAdd),
        [_out(l.homeV2GsActQuick, onQuick)],
      ),
      _ => (
        _hero(
          l.homeV2GsActBalance,
          Icons.account_balance_wallet_outlined,
          onBalance,
        ),
        <Widget>[],
      ),
    };

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
                    l.homeV2GsProgress(d.done).toUpperCase(),
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
        step(
          l.homeV2GsStep1,
          d.step1,
          sub: permissionState && !d.step1
              ? l.homeV2GsStepNeedsPermission
              : null,
        ),
        step(l.homeV2GsStep2, d.step2),
        step(l.homeV2GsStep3, d.step3),
        if (d.limit) ...[
          const SizedBox(height: KuberSpace.md),
          _LimitTile(data: d, onPro: onPro),
        ],
        const SizedBox(height: KuberSpace.lg),
        hero,
        if (secondary.isNotEmpty) ...[
          const SizedBox(height: KuberSpace.sm),
          Row(
            children: [
              for (final (i, w) in secondary.indexed) ...[
                if (i > 0) const SizedBox(width: KuberSpace.sm),
                Expanded(child: w),
              ],
            ],
          ),
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
    height: 40,
    onPressed: onTap,
  );
}

/// Free weekly SMS allowance used (board HV2.2 "limit"): warning tile with
/// the waiting count, the reset date, and See Kuber Pro.
class _LimitTile extends StatelessWidget {
  final GsData data;
  final VoidCallback onPro;
  const _LimitTile({required this.data, required this.onPro});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final tt = Theme.of(context).textTheme;
    final (bg, fg) = kuberToneColors(context, KuberTone.warning);
    final reset = data.resetDate;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        KuberSpace.lg,
        KuberSpace.md,
        KuberSpace.lg,
        KuberSpace.xs,
      ),
      decoration: BoxDecoration(color: bg, borderRadius: KuberShape.mediumR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.homeV2GsLimitTitle, style: tt.titleSmall!.copyWith(color: fg)),
          const SizedBox(height: 2),
          Text(
            l.homeV2GsLimitBody(data.staged),
            style: tt.bodyMedium!.copyWith(color: fg),
          ),
          if (reset != null)
            Text(
              l.homeV2GsLimitReset(
                DateFormat.MMMd(
                  Localizations.localeOf(context).toString(),
                ).format(reset),
              ),
              style: tt.bodySmall!.copyWith(color: fg),
            ),
          TextButton.icon(
            onPressed: onPro,
            style: TextButton.styleFrom(
              foregroundColor: fg,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(Icons.workspace_premium_outlined, size: 18),
            label: Text(l.homeV2GsActPro),
          ),
        ],
      ),
    );
  }
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
