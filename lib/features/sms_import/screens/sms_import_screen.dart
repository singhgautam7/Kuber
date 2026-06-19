import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
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

class _SmsImportScreenState extends ConsumerState<SmsImportScreen> {
  late SmsImportTab _tab = widget.initialTab;
  SmsPermissionMode? _permMode; // null = permission granted, show list
  bool _resolvingPermission = true;

  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

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
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.extentAfter < 400) {
      setState(() => _displayedCount += _pageSize);
    }
  }

  void _switchTab(SmsImportTab tab) {
    setState(() {
      _tab = tab;
      _displayedCount = _pageSize; // reset pagination per tab
    });
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
    if (refresh) ref.invalidate(smsImportProvider);
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

    return PopScope(
      // While selecting, back clears the selection instead of leaving.
      canPop: !_selectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectionMode) _exitSelection();
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
        bottomNavigationBar: _selectionMode ? _buildSelectionBar(cs) : null,
      ),
    );
  }

  /// App bar. Not sticky in the list view (it scrolls with the content). In
  /// selection mode the back arrow clears the selection.
  KuberAppBar _topAppBar(ColorScheme cs) {
    return KuberAppBar(
      showBack: true,
      showHome: true,
      title: '',
      infoConfig: InfoConstants.smsImport,
      onBack: _selectionMode ? _exitSelection : null,
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
    final total = unreviewed.length + imported.length + dismissed.length;

    return SafeArea(
      top: true,
      bottom: false,
      child: RefreshIndicator(
        onRefresh: () =>
            ref.read(smsImportProvider.notifier).startBackgroundScan(),
        color: cs.primary,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
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
            SliverToBoxAdapter(
              child: KuberPageHeader(
                title: 'Import from\nSMS',
                description:
                    'Review bank messages from last 90 days and add them as transactions.',
                actionIcon: Icons.content_paste_rounded,
                actionTooltip: 'Paste an SMS',
                onAction: () => showPasteSmsSheet(context),
              ),
            ),
            // Pinned: tabs, or the selection bar during multi-select.
            SliverPersistentHeader(
              pinned: true,
              delegate: _PinnedHeaderDelegate(
                height: 52,
                background: cs.surface,
                child: _selectionMode
                    ? _selectionHeaderRow(cs)
                    : _tabsRow(cs, unreviewed.length),
              ),
            ),
            const SliverToBoxAdapter(child: ScanProgressStrip()),
            SliverToBoxAdapter(child: _footer(cs, total)),
            ..._contentSlivers(cs, unreviewed, imported, dismissed),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  Widget _tabsRow(ColorScheme cs, int unreviewedCount) {
    return Row(
      children: [
        _TabPill(
          label: 'Unreviewed',
          count: unreviewedCount,
          selected: _tab == SmsImportTab.unreviewed,
          onTap: () => _switchTab(SmsImportTab.unreviewed),
        ),
        const SizedBox(width: 6),
        _TabPill(
          label: 'Imported',
          selected: _tab == SmsImportTab.imported,
          onTap: () => _switchTab(SmsImportTab.imported),
        ),
        const SizedBox(width: 6),
        _TabPill(
          label: 'Dismissed',
          selected: _tab == SmsImportTab.dismissed,
          onTap: () => _switchTab(SmsImportTab.dismissed),
        ),
      ],
    );
  }

  Widget _selectionHeaderRow(ColorScheme cs) {
    return Row(
      children: [
        Text(
          '${_selectedIds.length} selected',
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _exitSelection,
          child: Text(
            'Cancel',
            style: localeFont(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: cs.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _footer(ColorScheme cs, int total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 2),
      child: Row(
        children: [
          Icon(Icons.schedule_rounded, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            '$total from the last 90 days',
            style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  List<Widget> _contentSlivers(
    ColorScheme cs,
    List<SmsTransaction> unreviewed,
    List<SmsTransaction> imported,
    List<SmsTransaction> dismissed,
  ) {
    switch (_tab) {
      case SmsImportTab.unreviewed:
        if (unreviewed.isEmpty) {
          return [
            _emptySliver(
              (imported.isNotEmpty || dismissed.isNotEmpty)
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
        return [_cardsSliver(unreviewed, selectable: true)];
      case SmsImportTab.imported:
        if (imported.isEmpty) {
          return [
            _emptySliver(const _EmptyState(
              icon: Icons.inbox_outlined,
              title: 'Nothing imported yet',
              body: 'Imported transactions will appear here.',
            )),
          ];
        }
        return [_cardsSliver(imported, selectable: false)];
      case SmsImportTab.dismissed:
        if (dismissed.isEmpty) {
          return [
            _emptySliver(const _EmptyState(
              icon: Icons.do_not_disturb_on_outlined,
              title: 'Nothing dismissed',
              body: 'Messages you dismiss appear here. You can still add them '
                  'later.',
            )),
          ];
        }
        return [_cardsSliver(dismissed, selectable: false)];
    }
  }

  Widget _emptySliver(Widget child) =>
      SliverFillRemaining(hasScrollBody: false, child: child);

  /// Paginated card list for a single status. Renders at most [_displayedCount]
  /// rows; [_onScroll] grows that as the user reaches the bottom.
  Widget _cardsSliver(List<SmsTransaction> rows, {required bool selectable}) {
    final count =
        rows.length < _displayedCount ? rows.length : _displayedCount;
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, i) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _card(rows[i], selectable: selectable),
          ),
          childCount: count,
        ),
      ),
    );
  }

  Widget _card(SmsTransaction sms, {required bool selectable}) {
    return GestureDetector(
      onLongPress: selectable
          ? () {
              setState(() {
                _selectionMode = true;
                _selectedIds.add(sms.id);
              });
            }
          : null,
      child: SmsImportCard(
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
      ),
    );
  }

  Widget _buildSelectionBar(ColorScheme cs) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: AppButton(
          label: 'Add selected (${_selectedIds.length})',
          type: AppButtonType.primary,
          fullWidth: true,
          onPressed: _selectedIds.isEmpty ? null : _openBatch,
        ),
      ),
    );
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
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.surfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? cs.primary.withValues(alpha: 0.25) : cs.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: localeFont(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 6),
              Container(
                constraints: const BoxConstraints(minWidth: 18),
                height: 18,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(9),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: localeFont(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
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
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // Centered; the surrounding SliverFillRemaining + AlwaysScrollable scroll
    // view keeps pull-to-refresh working even when the tab is empty.
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: cs.outline),
              ),
              child: Icon(icon, size: 30, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: localeFont(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: background,
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }

  @override
  bool shouldRebuild(_PinnedHeaderDelegate old) =>
      old.height != height ||
      old.background != background ||
      old.child != child;
}

