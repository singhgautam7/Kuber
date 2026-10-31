import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home_v2/providers/home_v2_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/date_separator.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/overflow_config.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_skeleton.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../data/sms_transaction.dart';
import '../engine/scan_progress.dart';
import '../providers/sms_import_provider.dart';
import '../providers/sms_today_summary.dart';
import '../widgets/batch_summary_sheet.dart';
import '../widgets/paste_sms_sheet.dart';
import '../widgets/sms_today_card.dart';
import '../widgets/transaction_review_sheet.dart';
import 'sms_first_load_screen.dart';
import 'sms_import_widgets.dart';
import 'sms_permission_screen.dart';

/// Which tab the import list shows. The home widget can deep-link to a tab.
enum SmsImportTab { unreviewed, imported, dismissed }

class SmsImportScreen extends ConsumerStatefulWidget {
  final SmsImportTab initialTab;
  const SmsImportScreen({super.key, this.initialTab = SmsImportTab.unreviewed});

  @override
  ConsumerState<SmsImportScreen> createState() => _SmsImportScreenState();
}

class _SmsImportScreenState extends ConsumerState<SmsImportScreen>
    with SingleTickerProviderStateMixin {
  /// Tap or swipe between tabs with the M3 horizontal slide; the indicator
  /// follows the drag. Each tab is its own lazily built scroll view.
  late final TabController _tabs = TabController(
    length: SmsImportTab.values.length,
    vsync: this,
    initialIndex: widget.initialTab.index,
  );

  /// Mirrors [_tabs.index] for the app bar only (its overflow depends on the
  /// tab), so a tab change does not rebuild the whole screen.
  late final ValueNotifier<int> _tabIndex = ValueNotifier(_tabs.index);

  SmsPermissionMode? _permMode; // null = permission granted, show list
  bool _resolvingPermission = true;

  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  final _searchController = TextEditingController();
  String _query = '';

  // Pagination: render rows in pages and grow as the user scrolls (the inbox
  // can hold hundreds of messages, so we never build them all at once). One
  // count per tab, so switching back keeps both the rows and the offset
  // (PageStorageKey per tab).
  static const _pageSize = 30;
  final _displayed = List<int>.filled(SmsImportTab.values.length, _pageSize);

  /// True while pull to refresh runs: the top indicator stays hidden then, so
  /// only one loader shows.
  final _pulling = ValueNotifier(false);

  /// Rows a refresh just added; they slide in with a fading tint once.
  Set<int> _freshIds = const {};
  Timer? _freshTimer;

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() => _tabIndex.value = _tabs.index);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // A summary computed before midnight must not show as "today".
      ref.invalidate(smsTodaySummaryProvider);
      _initPermission();
    });
  }

  @override
  void dispose() {
    _freshTimer?.cancel();
    _tabs.dispose();
    _tabIndex.dispose();
    _pulling.dispose();
    _searchController.dispose();
    super.dispose();
  }

  bool _onScroll(SmsImportTab tab, int rowCount, ScrollNotification n) {
    final i = tab.index;
    if (n.depth == 0 &&
        n.metrics.axis == Axis.vertical &&
        n.metrics.extentAfter < 400 &&
        _displayed[i] < rowCount) {
      setState(() => _displayed[i] += _pageSize);
    }
    return false;
  }

  void _setQuery(String v) => setState(() {
    _query = v;
    _displayed.fillRange(0, _displayed.length, _pageSize);
  });

  Future<void> _initPermission() async {
    final supported = ref.read(smsInboxServiceProvider).isSupported;
    if (!supported) {
      // Web / non-Android: no inbox, but paste still works. Show the ask view
      // (its paste fallback is the way in).
      setState(() {
        _permMode = SmsPermissionMode.ask;
        _resolvingPermission = false;
      });
      return;
    }
    final status = await Permission.sms.status;
    if (!mounted) return;
    if (status.isGranted) {
      await _resolveGrantedEntry(refresh: false);
    } else {
      setState(() {
        _permMode = status.isPermanentlyDenied
            ? SmsPermissionMode.permaDenied
            : SmsPermissionMode.ask;
        _resolvingPermission = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    // Home v2: SMS permission has been asked at least once (Get started
    // "denied" state). No-op on v1.
    ref.read(homeV2Provider.notifier).markSmsRequested();
    final status = await Permission.sms.request();
    if (!mounted) return;
    if (status.isGranted) {
      await _resolveGrantedEntry(refresh: true);
    } else if (status.isPermanentlyDenied) {
      setState(() => _permMode = SmsPermissionMode.permaDenied);
    } else {
      setState(() => _permMode = SmsPermissionMode.softDenied);
    }
  }

  /// Decides, once permission is granted, whether to show the full-screen
  /// first-load scan (Scenario A) or the list. [refresh] re-reads the provider
  /// so a freshly granted permission is reflected.
  Future<void> _resolveGrantedEntry({required bool refresh}) async {
    if (refresh) {
      ref.invalidate(smsImportProvider);
      // The home dashboard reads a lightweight FutureProvider mirroring
      // (permission, lastScannedAt). It caches until invalidated — without
      // this line the home widget keeps showing "Set up" even after the
      // user grants permission and returns.
      ref.invalidate(smsHomeInfoProvider);
    }
    await ref.read(smsImportProvider.future);
    if (!mounted) return;
    if (ref.read(smsImportProvider.notifier).shouldFirstLoad()) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const SmsFirstLoadScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
      return;
    }
    setState(() {
      _permMode = null;
      _resolvingPermission = false;
    });
    _autoRefreshAfterTransition();
  }

  /// The once-per-session automatic refresh (board 3.9c). Permission is
  /// granted here. Waits for the route's open transition to finish so the
  /// platform read and isolate spawn never land in it.
  void _autoRefreshAfterTransition() {
    final notifier = ref.read(smsImportProvider.notifier);
    final anim = ModalRoute.of(context)?.animation;
    if (anim == null || anim.isCompleted) {
      notifier.autoRefreshOnce();
      return;
    }
    late final AnimationStatusListener listener;
    listener = (status) {
      if (status != AnimationStatus.completed) return;
      anim.removeStatusListener(listener);
      if (mounted) notifier.autoRefreshOnce();
    };
    anim.addStatusListener(listener);
  }

  Future<void> _pullRefresh() async {
    _pulling.value = true;
    try {
      await ref.read(smsImportProvider.notifier).startBackgroundScan();
    } finally {
      if (mounted) _pulling.value = false;
    }
  }

  /// Marks the rows a completed refresh added, so they animate in once.
  void _onSmsState(
    AsyncValue<SmsImportState>? prev,
    AsyncValue<SmsImportState> next,
  ) {
    final p = prev?.valueOrNull, n = next.valueOrNull;
    if (p == null || n == null || identical(p.unreviewed, n.unreviewed)) return;
    final done = n.scanProgress;
    if (done == null ||
        !done.isComplete ||
        done.trigger != ScanTrigger.backgroundRefresh ||
        done.bankMessagesFound == 0) {
      return;
    }
    final before = {for (final s in p.unreviewed) s.id};
    final fresh = {
      for (final s in n.unreviewed)
        if (!before.contains(s.id)) s.id,
    };
    if (fresh.isEmpty) return;
    setState(() => _freshIds = fresh);
    // Later rebuilds must not replay it (rows already animating keep going).
    _freshTimer?.cancel();
    _freshTimer = Timer(
      const Duration(milliseconds: 1500),
      () => _freshIds = const {},
    );
  }

  void _exitSelection() {
    setState(() {
      _selectionMode = false;
      _selectedIds.clear();
    });
  }

  void _toggleSelect(SmsTransaction sms) {
    setState(() {
      if (_selectedIds.contains(sms.id)) {
        _selectedIds.remove(sms.id);
        if (_selectedIds.isEmpty) _selectionMode = false;
      } else {
        _selectedIds.add(sms.id);
      }
    });
  }

  List<SmsTransaction> _filter(List<SmsTransaction> rows) {
    if (_query.isEmpty) return rows;
    final q = _query.toLowerCase();
    return rows
        .where(
          (sms) =>
              (sms.parsedMerchant?.toLowerCase().contains(q) ?? false) ||
              sms.senderId.toLowerCase().contains(q) ||
              sms.rawSms.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(smsImportProvider, _onSmsState);
    final cs = Theme.of(context).colorScheme;
    final canPop =
        !_selectionMode && _query.isEmpty;

    return PopScope(
      // While selecting or searching, back clears the state instead of leaving.
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_selectionMode) {
          _exitSelection();
          return;
        }
        if (_query.isNotEmpty) {
          _searchController.clear();
          _setQuery('');
          return;
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: _resolvingPermission
            ? Column(
                children: [
                  _topAppBar(cs),
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ],
              )
            : _permMode != null
            ? Column(
                children: [
                  _topAppBar(cs),
                  Expanded(
                    child: SmsPermissionView(
                      mode: _permMode!,
                      onRequest: _requestPermission,
                      onOpenSettings: () => openAppSettings(),
                      onPaste: () => showPasteSmsSheet(context),
                    ),
                  ),
                ],
              )
            : _buildListView(cs),
        // Paste is the screen's create action: a centred extended FAB, like
        // Accounts (user review round 2), hidden while selecting.
        floatingActionButton:
            !_resolvingPermission && _permMode == null && !_selectionMode
            ? KuberExtendedFab(
                icon: Icons.content_paste_rounded,
                label: 'Paste SMS',
                onPressed: () => showPasteSmsSheet(context),
              )
            : null,
        floatingActionButtonLocation: kuberFabLocation,
        bottomNavigationBar: _selectionMode ? _buildSelectionBar(cs) : null,
      ),
    );
  }

  Future<void> _confirmReset() async {
    final cs = Theme.of(context).colorScheme;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset SMS imports?'),
        content: Text(
          'This will clear all the SMS imports we have right now and re-read all the SMS again with the parser. Are you sure you want to proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      await ref
          .read(smsImportProvider.notifier)
          .resetSmsImports(runBackgroundScan: false);
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const SmsFirstLoadScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 200),
          ),
        );
      }
    }
  }

  /// Dismiss all (board 3.9g): every Unreviewed message, search or not, so the
  /// count in the sheet is exactly what moves. One write transaction; Undo
  /// restores exactly these ids in one more.
  Future<void> _confirmDismissAll() async {
    final notifier = ref.read(smsImportProvider.notifier);
    final ids = [
      for (final s
          in ref.read(smsImportProvider).valueOrNull?.unreviewed ??
              const <SmsTransaction>[])
        s.id,
    ];
    if (ids.isEmpty) return;
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final n = ids.length;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => KuberBottomSheet(
        title: l10n.smsDismissAllTitle(n),
        showClose: false,
        actions: SheetButtonSection(
          padding: EdgeInsets.zero,
          actions: [
            SheetAction(
              label: l10n.cancelLabel,
              icon: Icons.close_rounded,
              onPressed: () => Navigator.pop(ctx, false),
            ),
            SheetAction(
              label: l10n.smsDismissAllConfirm(n),
              icon: Icons.do_not_disturb_on_outlined,
              destructive: true,
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        ),
        child: Text(
          n == 1 ? l10n.smsDismissAllBodyOne : l10n.smsDismissAllBody,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;
    await notifier.dismissBatch(ids);
    if (!mounted) return;
    showKuberSnackBar(
      context,
      l10n.smsDismissedSnack(n),
      actionLabel: l10n.msRecUndo,
      duration: const Duration(seconds: 7),
      onAction: () => notifier.undoDismissBatch(ids),
    );
  }

  /// App bar, fixed above the tabs. In selection mode the back arrow clears
  /// the selection. Dismiss all shows only on a non-empty Unreviewed tab.
  Widget _topAppBar(ColorScheme cs) {
    return ValueListenableBuilder<int>(
      valueListenable: _tabIndex,
      builder: (context, tabIndex, _) => Consumer(
        builder: (context, ref, _) {
          final canDismissAll =
              !_resolvingPermission &&
              _permMode == null &&
              tabIndex == SmsImportTab.unreviewed.index &&
              ref.watch(smsUnreviewedCountProvider) > 0;
          return KuberAppBar(
            showBack: true,
            title: 'SMS',
            pinShortcut: const PinShortcutSpec(
              shortcutId: 'sms_import',
              shortLabel: 'SMS Import',
              longLabel: 'Import from SMS',
              iconDrawable: 'ic_shortcut_sms',
              deepLink: 'kuber://app/sms-import',
            ),
            infoConfig: InfoConstants.smsImport,
            onBack: _selectionMode ? _exitSelection : null,
            search: _selectionMode || _permMode != null || _resolvingPermission
                ? null
                : KuberHeaderSearch(
                    controller: _searchController,
                    hint: 'Search merchant, sender, or message',
                    onChanged: _setQuery,
                  ),
            overflowConfig: _selectionMode
                ? null
                : KuberOverflowConfig(
                    items: [
                      if (canDismissAll)
                        KuberOverflowItem(
                          icon: Icons.do_not_disturb_on_outlined,
                          label: context.l10n.smsMenuDismissAll,
                          isDestructive: true,
                          onTap: _confirmDismissAll,
                        ),
                      KuberOverflowItem(
                        icon: Icons.delete_outline_rounded,
                        label: 'Reset SMS Imports',
                        isDestructive: true,
                        onTap: _confirmReset,
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  /// The list view: fixed app bar and tabs (or the selection bar), then one
  /// scroll view per tab in a [TabBarView]. Only the visible tab (and its
  /// neighbour mid-swipe) is built; each tab watches only its own list.
  Widget _buildListView(ColorScheme cs) {
    return SafeArea(
      top: true,
      bottom: false,
      child: Column(
        children: [
          // removeTop avoids double safe-area padding (the outer SafeArea
          // already handles the status bar).
          MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: _topAppBar(cs),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpace.screenMargin,
            ),
            child: _selectionMode
                ? SizedBox(height: 64, child: _selectionHeaderRow(cs))
                : _tabBar(cs),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => FocusScope.of(context).unfocus(),
              behavior: HitTestBehavior.opaque,
              child: Stack(
                children: [
                  TabBarView(
                    controller: _tabs,
                    // Selection only lives on Unreviewed: no tab swipe then.
                    physics: _selectionMode
                        ? const NeverScrollableScrollPhysics()
                        : null,
                    children: [
                      for (final tab in SmsImportTab.values) _page(tab),
                    ],
                  ),
                  Positioned(
                    left: KuberSpace.screenMargin,
                    right: KuberSpace.screenMargin,
                    top: 0,
                    child: _AutoRefreshBar(pulling: _pulling),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// M3 primary tabs (board 3.9a): label-width indicator, count badge on
  /// Unreviewed, a full-width divider under the strip.
  Widget _tabBar(ColorScheme cs) {
    final theme = Theme.of(context);
    final label = theme.textTheme.titleSmall;
    return TabBar(
      controller: _tabs,
      labelColor: cs.primary,
      unselectedLabelColor: cs.onSurfaceVariant,
      labelStyle: label,
      unselectedLabelStyle: label,
      indicatorColor: cs.primary,
      indicatorSize: TabBarIndicatorSize.label,
      dividerColor: cs.outlineVariant,
      // Three equal tabs in a phone width: any side padding leaves
      // "Unreviewed" + a 3-digit badge short (the old tab row had none). The
      // label ellipsizes at large font scales instead of overflowing.
      labelPadding: EdgeInsets.zero,
      tabs: [
        Tab(
          height: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Flexible(
                child: Text(
                  'Unreviewed',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Consumer(
                builder: (context, ref, _) {
                  final count = ref.watch(smsUnreviewedCountProvider);
                  if (count == 0) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(left: 6),
                    constraints: const BoxConstraints(minWidth: 18),
                    height: 18,
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: KuberShape.fullR,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$count',
                      style: theme.textTheme.labelSmall!.copyWith(
                        color: cs.onPrimary,
                        letterSpacing: 0,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        const Tab(height: 48, text: 'Imported'),
        const Tab(height: 48, text: 'Dismissed'),
      ],
    );
  }

  /// One tab: its own scroll view (offset kept by [PageStorageKey]) and pull
  /// to refresh. Rows are read with `select`, so scan-progress emissions and
  /// the other tabs' lists never rebuild it.
  Widget _page(SmsImportTab tab) {
    return Consumer(
      builder: (context, ref, _) {
        final cs = Theme.of(context).colorScheme;
        final rows =
            ref.watch(
              smsImportProvider.select(
                (s) => switch (tab) {
                  SmsImportTab.unreviewed => s.valueOrNull?.unreviewed,
                  SmsImportTab.imported => s.valueOrNull?.imported,
                  SmsImportTab.dismissed => s.valueOrNull?.dismissed,
                },
              ),
            ) ??
            const <SmsTransaction>[];
        final total = ref.watch(
          smsImportProvider.select((s) {
            final v = s.valueOrNull;
            return v == null
                ? 0
                : v.unreviewed.length + v.imported.length + v.dismissed.length;
          }),
        );
        final hasReviewed = ref.watch(
          smsImportProvider.select(
            (s) =>
                (s.valueOrNull?.imported.isNotEmpty ?? false) ||
                (s.valueOrNull?.dismissed.isNotEmpty ?? false),
          ),
        );
        final unreviewed = tab == SmsImportTab.unreviewed;
        // Board 3.9c: an automatic refresh with nothing to show yet gets the
        // card + row skeleton instead of an empty state.
        final skeleton =
            unreviewed &&
            rows.isEmpty &&
            _query.isEmpty &&
            ref.watch(
              smsImportProvider.select((s) {
                final p = s.valueOrNull?.scanProgress;
                return p != null &&
                    !p.isComplete &&
                    p.trigger == ScanTrigger.backgroundRefresh;
              }),
            );
        final visible = _filter(rows);

        return RefreshIndicator(
          onRefresh: _pullRefresh,
          color: cs.primary,
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) => _onScroll(tab, visible.length, n),
            child: CustomScrollView(
              key: PageStorageKey<String>('sms-tab-${tab.name}'),
              physics: const AlwaysScrollableScrollPhysics(),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                // Untracked today (board 3.9d): Unreviewed only, hidden while
                // searching.
                if (unreviewed && _query.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      KuberSpace.screenMargin,
                      KuberSpace.lg,
                      KuberSpace.screenMargin,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: skeleton
                          ? const _SkeletonCard()
                          : const SmsTodayCard(),
                    ),
                  ),
                SliverToBoxAdapter(child: _footer(cs, total)),
                if (skeleton)
                  const SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: KuberSpace.screenMargin,
                    ),
                    sliver: SliverToBoxAdapter(child: _SkeletonList()),
                  )
                else
                  _contentSliver(tab, visible, hasReviewed),
                const SliverToBoxAdapter(
                  child: SizedBox(height: KuberExtendedFab.clearance),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _selectionHeaderRow(ColorScheme cs) {
    return Consumer(
      builder: (context, ref, _) {
        final unreviewed =
            ref.watch(
              smsImportProvider.select((s) => s.valueOrNull?.unreviewed),
            ) ??
            const <SmsTransaction>[];
        final visibleIds = _filter(unreviewed).map((e) => e.id).toSet();
        final selectedVisibleCount = _selectedIds
            .intersection(visibleIds)
            .length;
        final allSelected =
            selectedVisibleCount > 0 &&
            selectedVisibleCount == visibleIds.length;
        return Row(
          children: [
            AppIconButton(
              icon: Icons.close_rounded,
              semanticLabel: 'Cancel selection',
              onPressed: _exitSelection,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${_selectedIds.length} selected',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(color: cs.onSurface),
              ),
            ),
            TextButton(
              onPressed: () => setState(() {
                if (allSelected) {
                  _selectedIds.removeAll(visibleIds);
                  if (_selectedIds.isEmpty) _selectionMode = false;
                } else {
                  _selectedIds.addAll(visibleIds);
                }
              }),
              child: Text(allSelected ? 'Deselect all' : 'Select all'),
            ),
          ],
        );
      },
    );
  }

  Widget _footer(ColorScheme cs, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 16, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$total from the last 90 days',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _contentSliver(
    SmsImportTab tab,
    List<SmsTransaction> visibleItems,
    bool hasReviewedItems,
  ) {
    if (visibleItems.isNotEmpty) {
      return _cardsSliver(
        tab,
        visibleItems,
        selectable: tab == SmsImportTab.unreviewed,
      );
    }
    if (_query.isNotEmpty) {
      return _emptySliver(
        _SearchEmptyState(
          query: _query,
          onClear: () {
            _searchController.clear();
            _setQuery('');
          },
        ),
      );
    }
    return _emptySliver(switch (tab) {
      SmsImportTab.unreviewed =>
        hasReviewedItems
            ? const _EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'All caught up',
                body: 'Every detected transaction has been reviewed.',
              )
            : const _EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No bank SMS found',
                body:
                    'Kuber did not find any bank transaction messages in '
                    'the last 90 days.',
              ),
      SmsImportTab.imported => const _EmptyState(
        icon: Icons.inbox_outlined,
        title: 'Nothing imported yet',
        body: 'Imported transactions will appear here.',
      ),
      SmsImportTab.dismissed => const _EmptyState(
        icon: Icons.do_not_disturb_on_outlined,
        title: 'Nothing dismissed',
        body:
            'Messages you dismiss appear here. You can still add them '
            'later.',
      ),
    });
  }

  Widget _emptySliver(Widget child) =>
      SliverFillRemaining(hasScrollBody: false, child: child);

  /// Paginated card list for a single status. Renders at most the tab's
  /// displayed count; [_onScroll] grows it as the user reaches the bottom.
  Widget _cardsSliver(
    SmsImportTab tab,
    List<SmsTransaction> rows, {
    required bool selectable,
  }) {
    final limit = _displayed[tab.index];
    final count = rows.length < limit ? rows.length : limit;

    // Day groups (board 3.9a): caps section label, then one grouped card.
    final children = <Widget>[];
    var dayRows = <Widget>[];
    DateTime? lastDay;
    void flush() {
      if (dayRows.isEmpty) return;
      children.add(KuberGroup(children: dayRows));
      dayRows = <Widget>[];
    }

    for (var i = 0; i < count; i++) {
      final sms = rows[i];
      final date = sms.smsDate;
      final day = DateTime(date.year, date.month, date.day);
      if (lastDay == null || day != lastDay) {
        flush();
        children.add(
          KuberSectionHeader(
            title: DateSeparator.labelFor(date),
            padding: EdgeInsets.only(
              top: lastDay == null ? KuberSpace.md : KuberSpace.xl,
              bottom: KuberSpace.sectionHeaderGap,
            ),
          ),
        );
        lastDay = day;
      }
      final card = _card(sms, selectable: selectable);
      dayRows.add(
        selectable && _freshIds.contains(sms.id)
            ? _FreshRow(key: ValueKey(('fresh', sms.id)), child: card)
            : card,
      );
    }
    flush();

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      sliver: SliverList(delegate: SliverChildListDelegate(children)),
    );
  }

  Widget _card(SmsTransaction sms, {required bool selectable}) {
    return SmsImportCard(
      key: ValueKey(sms.id),
      onLongPress: selectable
          ? () {
              setState(() {
                _selectionMode = true;
                _selectedIds.add(sms.id);
              });
            }
          : null,
      sms: sms,
      muted: false,
      selectionMode: _selectionMode && selectable,
      selected: _selectedIds.contains(sms.id),
      onTap: () {
        if (_selectionMode && selectable) {
          _toggleSelect(sms);
        } else {
          showSmsReviewSheet(context, sms);
        }
      },
    );
  }

  Widget _buildSelectionBar(ColorScheme cs) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: AppButton(
                label: 'Add Selected (${_selectedIds.length})',
                icon: Icons.playlist_add_check_rounded,
                type: AppButtonType.primary,
                fullWidth: true,
                onPressed: _selectedIds.isEmpty ? null : _openBatch,
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            Expanded(
              flex: 2,
              child: AppButton(
                label: 'Dismiss',
                icon: Icons.remove_circle_outline_rounded,
                fullWidth: true,
                onPressed: _selectedIds.isEmpty ? null : _dismissBatch,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _dismissBatch() async {
    final cs = Theme.of(context).colorScheme;
    final proceed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dismiss messages?'),
        content: Text(
          'Are you sure you want to dismiss ${_selectedIds.length} selected messages? You can find them later under the "Dismissed" tab.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );

    if (proceed == true && mounted) {
      final ids = _selectedIds.toList();
      ref.read(smsImportProvider.notifier).dismissBatch(ids);
      _exitSelection();
      showKuberSnackBar(
        context,
        '${ids.length} transactions dismissed',
        actionLabel: 'Undo',
        duration: const Duration(seconds: 4),
        onAction: () {
          ref.read(smsImportProvider.notifier).undoDismissBatch(ids);
        },
      );
    }
  }

  void _openBatch() {
    final state = ref.read(smsImportProvider).valueOrNull;
    if (state == null) return;
    final selected = state.unreviewed
        .where((s) => _selectedIds.contains(s.id))
        .toList();
    showBatchSummarySheet(
      context,
      selected: selected,
      onImported: _exitSelection,
    );
  }
}

/// Indeterminate M3 linear progress pinned under the tabs while the automatic
/// refresh runs (board 3.9c). It overlays the content, so the list never
/// shifts, and hides during pull to refresh (its spinner is the loader then).
/// Its ticker is muted while hidden, so it costs no frames at rest.
class _AutoRefreshBar extends ConsumerWidget {
  final ValueNotifier<bool> pulling;
  const _AutoRefreshBar({required this.pulling});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanning = ref.watch(
      smsImportProvider.select((s) {
        final p = s.valueOrNull?.scanProgress;
        return p != null &&
            !p.isComplete &&
            p.trigger == ScanTrigger.backgroundRefresh;
      }),
    );
    return ValueListenableBuilder<bool>(
      valueListenable: pulling,
      builder: (context, pull, _) {
        final show = scanning && !pull;
        // Only the indicator's ticker is muted: the fade keeps its own.
        return IgnorePointer(
          child: AnimatedOpacity(
            opacity: show ? 1 : 0,
            duration: KuberMotion.fast,
            curve: KuberMotion.decelerate,
            child: TickerMode(
              enabled: show,
              child: const RepaintBoundary(
                child: LinearProgressIndicator(
                  minHeight: 4,
                  borderRadius: KuberShape.fullR,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A row a refresh just added: grows in (230 ms) and fades in (150 ms), then a
/// primary 8% tint fades out over 1.2 s. Plays once, when the row is created.
class _FreshRow extends StatefulWidget {
  final Widget child;
  const _FreshRow({super.key, required this.child});

  @override
  State<_FreshRow> createState() => _FreshRowState();
}

class _FreshRowState extends State<_FreshRow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1430),
  );

  @override
  void initState() {
    super.initState();
    _c.forward();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (KuberMotion.reduced(context)) return widget.child;
    final tint = Theme.of(context).colorScheme.primary;
    const enter = 230 / 1430;
    return RepaintBoundary(
      child: SizeTransition(
        alignment: Alignment.topCenter,
        sizeFactor: CurvedAnimation(
          parent: _c,
          curve: const Interval(0, enter, curve: KuberMotion.decelerate),
        ),
        child: FadeTransition(
          opacity: CurvedAnimation(
            parent: _c,
            curve: const Interval(0, 150 / 1430, curve: KuberMotion.decelerate),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, child) {
              final t = ((_c.value - enter) / (1 - enter)).clamp(0.0, 1.0);
              return ColoredBox(
                color: tint.withValues(alpha: 0.08 * (1 - t)),
                child: child,
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Untracked today placeholder while an automatic refresh fills an empty tab.
class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget kpi(double label, double value) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KuberSkeleton(width: label, height: 14),
          const SizedBox(height: 10),
          KuberSkeleton(width: value, height: 28),
        ],
      ),
    );
    return KuberCard(
      hero: true,
      color: cs.secondaryContainer,
      borderColor: cs.secondaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberSkeleton(width: 96, height: 10),
          const SizedBox(height: KuberSpace.lg),
          Row(
            children: [
              kpi(64, 100),
              const SizedBox(width: KuberSpace.lg),
              kpi(72, 110),
            ],
          ),
          const SizedBox(height: KuberSpace.lg),
          const KuberSkeleton(width: 140, height: 14),
        ],
      ),
    );
  }
}

/// Four skeleton message rows under a skeleton day label.
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    Widget row(double title, double meta) => Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const KuberSkeleton(
            width: 40,
            height: 40,
            borderRadius: KuberShape.full,
          ),
          const SizedBox(width: KuberSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    KuberSkeleton(width: title, height: 14),
                    const Spacer(),
                    const KuberSkeleton(width: 56, height: 14),
                  ],
                ),
                const SizedBox(height: 10),
                const Row(
                  children: [
                    KuberSkeleton(width: 92, height: 20),
                    SizedBox(width: 6),
                    KuberSkeleton(width: 72, height: 20),
                  ],
                ),
                const SizedBox(height: 10),
                KuberSkeleton(width: meta, height: 10),
              ],
            ),
          ),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: KuberSpace.md),
        const KuberSkeleton(width: 48, height: 10),
        const SizedBox(height: KuberSpace.md),
        KuberGroup(
          children: [
            row(120, 88),
            row(96, 104),
            row(132, 80),
            row(104, 96),
          ],
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) =>
      KuberEmptyState(icon: icon, title: title, description: body);
}

class _SearchEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;

  const _SearchEmptyState({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) => KuberEmptyState(
    icon: Icons.search_off_rounded,
    title: "No matches for '$query'",
    description: 'Try a merchant name, a sender id or part of the message.',
    actionLabel: 'Clear search',
    onAction: onClear,
  );
}
