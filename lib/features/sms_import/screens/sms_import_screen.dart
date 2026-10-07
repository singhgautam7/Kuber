import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/date_separator.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/overflow_config.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../data/sms_transaction.dart';
import '../providers/sms_import_provider.dart';
import '../widgets/batch_summary_sheet.dart';
import '../widgets/paste_sms_sheet.dart';
import '../widgets/scan_progress_strip.dart';
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
  late SmsImportTab _tab = widget.initialTab;

  /// Fades the list in after a tab change (tap or swipe).
  late final AnimationController _tabFade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );
  SmsPermissionMode? _permMode; // null = permission granted, show list
  bool _resolvingPermission = true;

  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

  final _searchController = TextEditingController();
  String _query = '';

  // Pagination: render rows in pages and grow as the user scrolls (the inbox
  // can hold hundreds of messages, so we never build them all at once).
  static const _pageSize = 30;
  int _displayedCount = _pageSize;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _initPermission());
  }

  @override
  void dispose() {
    _tabFade.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 400) {
      setState(() => _displayedCount += _pageSize);
    }
  }

  void _switchTab(SmsImportTab tab) {
    if (tab == _tab) return;
    setState(() {
      _tab = tab;
      _displayedCount = _pageSize; // reset pagination per tab
    });
    _tabFade.forward(from: 0);
  }

  /// Horizontal swipe moves between Unreviewed / Imported / Dismissed (not
  /// while multi-selecting).
  void _onSwipe(DragEndDetails d) {
    if (_selectionMode) return;
    final v = d.primaryVelocity ?? 0;
    if (v.abs() < 300) return;
    final i = _tab.index + (v < 0 ? 1 : -1);
    if (i < 0 || i >= SmsImportTab.values.length) return;
    _switchTab(SmsImportTab.values[i]);
  }

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

  @override
  Widget build(BuildContext context) {
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
          setState(() {
            _query = '';
            _displayedCount = _pageSize;
          });
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
            : _buildListScrollView(cs),
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

  /// App bar. Not sticky in the list view (it scrolls with the content). In
  /// selection mode the back arrow clears the selection.
  KuberAppBar _topAppBar(ColorScheme cs) {
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
              onChanged: (v) => setState(() {
                _query = v;
                _displayedCount = _pageSize;
              }),
            ),
      overflowConfig: _selectionMode
          ? null
          : KuberOverflowConfig(
              items: [
                KuberOverflowItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Reset SMS Imports',
                  isDestructive: true,
                  onTap: _confirmReset,
                ),
              ],
            ),
    );
  }

  /// The list view. App bar + page header scroll away; only the tab strip is
  /// pinned. Row lists are read via `select` so scan-progress emissions never
  /// rebuild the list.
  Widget _buildListScrollView(ColorScheme cs) {
    final unreviewed =
        ref.watch(smsImportProvider.select((s) => s.valueOrNull?.unreviewed)) ??
        const <SmsTransaction>[];
    final imported =
        ref.watch(smsImportProvider.select((s) => s.valueOrNull?.imported)) ??
        const <SmsTransaction>[];
    final dismissed =
        ref.watch(smsImportProvider.select((s) => s.valueOrNull?.dismissed)) ??
        const <SmsTransaction>[];

    final List<SmsTransaction> visibleItems;
    final List<SmsTransaction> sourceList;
    switch (_tab) {
      case SmsImportTab.unreviewed:
        sourceList = unreviewed;
        break;
      case SmsImportTab.imported:
        sourceList = imported;
        break;
      case SmsImportTab.dismissed:
        sourceList = dismissed;
        break;
    }

    visibleItems = sourceList.where((sms) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return (sms.parsedMerchant?.toLowerCase().contains(q) ?? false) ||
          sms.senderId.toLowerCase().contains(q) ||
          sms.rawSms.toLowerCase().contains(q);
    }).toList();

    final total = unreviewed.length + imported.length + dismissed.length;

    return SafeArea(
      top: true,
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(smsImportProvider.notifier).startBackgroundScan(),
        color: cs.primary,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          onHorizontalDragEnd: _onSwipe,
          behavior: HitTestBehavior.opaque,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: [
              // App bar + header scroll away. removeTop avoids double safe-area
              // padding (the outer SafeArea already handles the status bar).
              SliverToBoxAdapter(
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: _topAppBar(cs),
                ),
              ),
              // Pinned: tabs, or the selection bar during multi-select.
              SliverPersistentHeader(
                pinned: true,
                delegate: _PinnedHeaderDelegate(
                  height: _selectionMode ? 64 : 52,
                  background: cs.surface,
                  child: _selectionMode
                      ? _selectionHeaderRow(cs, visibleItems)
                      : _tabsRow(cs, unreviewed.length),
                ),
              ),
              const SliverToBoxAdapter(child: ScanProgressStrip()),
              SliverToBoxAdapter(child: _footer(cs, total)),
              for (final sliver in _contentSlivers(
                cs,
                visibleItems,
                sourceList.isNotEmpty,
                imported.isNotEmpty || dismissed.isNotEmpty,
              ))
                SliverFadeTransition(opacity: _tabFade, sliver: sliver),
              const SliverToBoxAdapter(
                child: SizedBox(height: KuberExtendedFab.clearance),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// M3 primary tabs (board 3.9a): underline indicator, count badge on
  /// Unreviewed, a full-width divider under the strip.
  Widget _tabsRow(ColorScheme cs, int unreviewedCount) {
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabPill(
              label: 'Unreviewed',
              count: unreviewedCount,
              selected: _tab == SmsImportTab.unreviewed,
              onTap: () => _switchTab(SmsImportTab.unreviewed),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'Imported',
              selected: _tab == SmsImportTab.imported,
              onTap: () => _switchTab(SmsImportTab.imported),
            ),
          ),
          Expanded(
            child: _TabPill(
              label: 'Dismissed',
              selected: _tab == SmsImportTab.dismissed,
              onTap: () => _switchTab(SmsImportTab.dismissed),
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectionHeaderRow(
    ColorScheme cs,
    List<SmsTransaction> visibleItems,
  ) {
    final visibleIds = visibleItems.map((e) => e.id).toSet();
    final selectedVisibleCount = _selectedIds.intersection(visibleIds).length;

    bool? checkboxValue;
    if (selectedVisibleCount == 0) {
      checkboxValue = false;
    } else if (selectedVisibleCount == visibleIds.length) {
      checkboxValue = true;
    } else {
      checkboxValue = null; // Indeterminate
    }

    final allSelected = checkboxValue == true;
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

  List<Widget> _contentSlivers(
    ColorScheme cs,
    List<SmsTransaction> visibleItems,
    bool hasAnyItems,
    bool hasReviewedItems,
  ) {
    switch (_tab) {
      case SmsImportTab.unreviewed:
        if (visibleItems.isEmpty) {
          if (_query.isNotEmpty) {
            return [
              _emptySliver(
                _SearchEmptyState(
                  query: _query,
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _displayedCount = _pageSize;
                    });
                  },
                ),
              ),
            ];
          }
          return [
            _emptySliver(
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
            ),
          ];
        }
        return [_cardsSliver(visibleItems, selectable: true)];
      case SmsImportTab.imported:
        if (visibleItems.isEmpty) {
          if (_query.isNotEmpty) {
            return [
              _emptySliver(
                _SearchEmptyState(
                  query: _query,
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _displayedCount = _pageSize;
                    });
                  },
                ),
              ),
            ];
          }
          return [
            _emptySliver(
              const _EmptyState(
                icon: Icons.inbox_outlined,
                title: 'Nothing imported yet',
                body: 'Imported transactions will appear here.',
              ),
            ),
          ];
        }
        return [_cardsSliver(visibleItems, selectable: false)];
      case SmsImportTab.dismissed:
        if (visibleItems.isEmpty) {
          if (_query.isNotEmpty) {
            return [
              _emptySliver(
                _SearchEmptyState(
                  query: _query,
                  onClear: () {
                    _searchController.clear();
                    setState(() {
                      _query = '';
                      _displayedCount = _pageSize;
                    });
                  },
                ),
              ),
            ];
          }
          return [
            _emptySliver(
              const _EmptyState(
                icon: Icons.do_not_disturb_on_outlined,
                title: 'Nothing dismissed',
                body:
                    'Messages you dismiss appear here. You can still add them '
                    'later.',
              ),
            ),
          ];
        }
        return [_cardsSliver(visibleItems, selectable: false)];
    }
  }

  Widget _emptySliver(Widget child) =>
      SliverFillRemaining(hasScrollBody: false, child: child);

  /// Paginated card list for a single status. Renders at most [_displayedCount]
  /// rows; [_onScroll] grows that as the user reaches the bottom.
  Widget _cardsSliver(List<SmsTransaction> rows, {required bool selectable}) {
    final count = rows.length < _displayedCount ? rows.length : _displayedCount;

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
      dayRows.add(_card(sms, selectable: selectable));
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

class _TabPill extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _TabPill({
    required this.label,
    this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fg = selected ? cs.primary : cs.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleSmall!.copyWith(color: fg),
                ),
                if (count != null && count! > 0) ...[
                  const SizedBox(width: 6),
                  Container(
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
                  ),
                ],
              ],
            ),
            if (selected)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 64,
                  height: 3,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
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

/// Pinned sticky-header delegate with a fixed height, used for the tab strip
/// (or the selection bar) so it stays put while the list scrolls.
class _PinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double height;
  final Color background;
  final Widget child;

  _PinnedHeaderDelegate({
    required this.height,
    required this.background,
    required this.child,
  });

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: background,
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_PinnedHeaderDelegate old) =>
      old.height != height ||
      old.background != background ||
      old.child != child;
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
