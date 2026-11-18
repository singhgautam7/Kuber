import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/info_config.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/overflow_config.dart';
import '../../core/motion/motion_level.dart';
import '../../core/motion/spring_curve.dart';
import '../../core/services/shortcut_pin_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'app_icon_button.dart';
import 'kuber_info_bottom_sheet.dart';
import 'kuber_menu.dart';
import 'kuber_list.dart';
import 'kuber_path.dart';
import 'kuber_search_pill.dart';

/// The one header (components/header.md, board 2b).
///
/// Rebuilt on PostPurush `core/widgets/app_header.dart` with Perch's
/// `app_header.dart` geometry: padding L(back|home ? 16 : 20) T14
/// R(actions ? 16 : 20) B12, a 6dp gap after the leading buttons, titleLarge,
/// one-line bodyMedium subtitle. Every Kuber slot is kept: back, home, info,
/// overflow, "Add to home screen" pin, custom actions, onBack, brand.
/// The header search button (round 4): a search glyph beside the overflow
/// that turns the header row into an inline search pill. The screen keeps
/// owning the query: [controller] holds the text and [onChanged] fires on
/// every edit, including the clear when search is closed.
class KuberHeaderSearch {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hint;

  const KuberHeaderSearch({
    required this.controller,
    required this.onChanged,
    this.hint = 'Search',
  });
}

class KuberAppBar extends ConsumerStatefulWidget
    implements PreferredSizeWidget {
  final String? title;

  /// One line under the title (bodyMedium, onSurfaceVariant).
  final String? subtitle;
  final List<Widget>? actions;
  final bool showBack;

  /// Draws the back button as a close glyph (full-screen forms).
  final bool closeIcon;
  final double? horizontalPadding;
  final KuberOverflowConfig? overflowConfig;

  /// When set, adds an "Add to home screen" item to the overflow menu that pins
  /// a launcher shortcut for the current screen. Null (default) hides it, so
  /// existing app bars are unchanged.
  final PinShortcutSpec? pinShortcut;

  /// When set (Android), adds "Add to app drawer" / "Remove from app drawer"
  /// for this screen's own launcher icon.
  final AppDrawerEntry? appDrawerEntry;

  /// Fill behind the header (the multi-select contextual header uses
  /// surfaceContainer). Transparent by default.
  final Color? background;

  const KuberAppBar({
    super.key,
    this.title,
    this.subtitle,
    this.actions,
    this.showBack = false,
    this.closeIcon = false,
    this.showHome = false,
    this.horizontalPadding,
    this.infoConfig,
    this.overflowConfig,
    this.onBack,
    this.showBrand = true,
    this.pinShortcut,
    this.appDrawerEntry,
    this.background,
    this.search,
    this.floating = true,
  });

  /// Inside a [KuberHeaderPage]: false keeps this header fixed at rest (no
  /// pill, no hiding, never scrolls away), for contextual (selection)
  /// headers and edit modes (v7c.F8 "Left out"). No effect elsewhere.
  final bool floating;

  /// Adds the search button; see [KuberHeaderSearch].
  final KuberHeaderSearch? search;

  final bool showHome;

  /// When false and [title] is null, renders no leading brand block (just the
  /// back / home / info buttons).
  final bool showBrand;
  final KuberInfoConfig? infoConfig;

  /// Overrides the default back behavior (pop). Used e.g. to clear a
  /// multi-select instead of leaving the screen.
  final VoidCallback? onBack;

  static const double _height = 14 + 48 + 12;

  @override
  Size get preferredSize =>
      Size.fromHeight(subtitle == null ? _height : _height + 12);

  /// Exact height of the header at rest below the status bar: 14 + 48 + 12,
  /// or with a subtitle 14 + 48 + its one line + 8 (measured, so it holds at
  /// every text size and script).
  double restHeight(BuildContext context) {
    final sub = subtitle;
    if (sub == null) return _height;
    final tp = TextPainter(
      text: TextSpan(text: sub, style: Theme.of(context).textTheme.bodyMedium),
      maxLines: 1,
      textScaler: MediaQuery.textScalerOf(context),
      textDirection: Directionality.of(context),
    )..layout();
    final h = tp.height;
    tp.dispose();
    return 14 + 48 + h + KuberSpace.sm;
  }

  @override
  ConsumerState<KuberAppBar> createState() => _KuberAppBarState();
}

class _KuberAppBarState extends ConsumerState<KuberAppBar> {
  KuberOverflowItem _appDrawerItem(AppDrawerEntry entry) {
    final l = AppLocalizations.of(context)!;
    final added = ref.watch(appDrawerEntriesProvider).valueOrNull?.contains(entry) ?? false;
    return KuberOverflowItem(
      icon: added ? Icons.playlist_remove_rounded : Icons.apps_rounded,
      label: added ? l.appDrawerRemove : l.appDrawerAdd,
      onTap: () => toggleAppDrawerEntry(context, ref, entry, !added),
    );
  }

  /// Key of the pill's transition, so the switcher can keep it on top.
  static const _pillTransition = ValueKey<String>('search-pill');

  // Starts open when the screen comes back with a query still applied.
  late bool _searching = widget.search?.controller.text.isNotEmpty ?? false;

  void _closeSearch() {
    final s = widget.search!;
    FocusScope.of(context).unfocus();
    if (s.controller.text.isNotEmpty) {
      s.controller.clear();
      s.onChanged('');
    }
    setState(() => _searching = false);
    _FloatScope.maybeOf(context, listen: false)?.onSearch(false);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final title = w.title;
    final subtitle = w.subtitle;
    final showBack = w.showBack;
    final showHome = w.showHome;
    final infoConfig = w.infoConfig;
    final pinShortcut = w.pinShortcut;
    final horizontalPadding = w.horizontalPadding;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final route = ModalRoute.of(context);
    if (title != null && route != null) KuberPath.setTitle(route, title);
    // The path sheet: pages with a plain back button (forms close instead,
    // and a custom back means the page wants a say).
    final hasPath = showBack && !w.closeIcon && w.onBack == null && title != null;

    // Board 3.9a: once a screen has an overflow, "How it works" and "Add to
    // home screen" live in it (first), destructive items last.
    final configItems = w.overflowConfig?.items ?? const <KuberOverflowItem>[];
    // "How it works" always lives in the overflow, never as a standalone
    // help button (round 5).
    final infoInOverflow = infoConfig != null;
    final overflowItems = <KuberOverflowItem>[
      if (infoInOverflow)
        KuberOverflowItem(
          icon: Icons.help_outline_rounded,
          label: 'How it works',
          onTap: () => KuberInfoBottomSheet.show(context, infoConfig),
        ),
      if (pinShortcut != null)
        KuberOverflowItem(
          icon: Icons.add_to_home_screen_rounded,
          label: 'Add to home screen',
          onTap: () => requestPinShortcut(context, pinShortcut),
        ),
      if (w.appDrawerEntry != null && AppDrawerEntries.supported)
        _appDrawerItem(w.appDrawerEntry!),
      ...configItems.where((i) => !i.isDestructive),
      ...configItems.where((i) => i.isDestructive),
    ];

    final hasLeading = showBack || showHome;
    final trailing = <Widget>[
      if (w.search != null)
        AppIconButton(
          icon: Icons.search_rounded,
          semanticLabel: w.search!.hint,
          onPressed: () {
            setState(() => _searching = true);
            _FloatScope.maybeOf(context, listen: false)?.onSearch(true);
          },
        ),
      ...?w.actions,
      if (infoConfig != null && !infoInOverflow)
        AppIconButton(
          icon: Icons.info_outline_rounded,
          semanticLabel: 'Help',
          onPressed: () => KuberInfoBottomSheet.show(context, infoConfig),
        ),
      if (overflowItems.isNotEmpty) _OverflowButton(items: overflowItems),
    ];

    Widget? titleWidget;
    if (title != null) {
      titleWidget = Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge!.copyWith(color: cs.onSurface),
      );
      if (hasPath) {
        // The press sits 8 out from the text, so the title stays on its edge.
        titleWidget = Transform.translate(
          offset: const Offset(-KuberSpace.sm, 0),
          child: Semantics(
            button: true,
            hint: AppLocalizations.of(context)!.pathSheetHint,
            child: InkWell(
              onTap: () => KuberPath.open(context),
              borderRadius: KuberShape.mediumR,
              overlayColor: kuberPressedLayer(cs),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpace.sm),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    widthFactor: 1,
                    child: titleWidget,
                  ),
                ),
              ),
            ),
          ),
        );
      }
    } else if (w.showBrand) {
      final currency = ref.watch(currencyProvider);
      titleWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: cs.secondaryContainer,
              borderRadius: KuberShape.mediumR,
            ),
            child: Icon(
              IconMapper.fromCurrencyCode(currency.code),
              color: cs.onSecondaryContainer,
              size: 20,
            ),
          ),
          const SizedBox(width: KuberSpace.sm),
          Text(
            'Kuber',
            style: theme.textTheme.titleLarge!.copyWith(color: cs.primary),
          ),
        ],
      );
    }

    final left =
        horizontalPadding ??
        (hasLeading ? KuberSpace.lg : KuberSpace.screenMargin);
    final right =
        horizontalPadding ??
        (trailing.isNotEmpty ? KuberSpace.lg : KuberSpace.screenMargin);

    final reduced = KuberMotion.reduced(context);
    final searchOpen = _searching && w.search != null;
    final scope = _FloatScope.maybeOf(context);
    final floating = scope != null && scope.floating;
    Widget titleSlot = Align(
      alignment: AlignmentDirectional.centerStart,
      child: titleWidget ?? const SizedBox.shrink(),
    );
    if (floating) {
      titleSlot = _PillTitle(
        progress: scope.progress,
        leadShift: hasLeading ? 0 : _Fh.noButtonShift,
        trailShift: trailing.isEmpty ? _Fh.noButtonShift : 0,
        // Largest font (v7c.F4): text scale >= 1.5 or under 96 dp for the
        // title in the pill drops the title; its semantics stay.
        dropBelow: MediaQuery.textScalerOf(context).scale(1) >= 1.5
            ? double.infinity
            : _Fh.minTitle,
        child: titleSlot,
      );
    }
    final content = Padding(
          padding: EdgeInsets.fromLTRB(
            left,
            14,
            right,
            subtitle == null ? KuberSpace.md : KuberSpace.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 48,
                child: AnimatedSwitcher(
                  duration: reduced
                      ? KuberMotion.reducedFade
                      : const Duration(milliseconds: 250),
                  // Same curve both ways: closing plays the opening backwards.
                  switchInCurve: reduced ? Curves.linear : Curves.easeOutCubic,
                  switchOutCurve: reduced ? Curves.linear : Curves.easeOutCubic,
                  // The pill grows out of the trailing edge (the search icon)
                  // and collapses back into it. It always paints above the
                  // title row, so closing uncovers the row instead of the row
                  // fading in over the pill (which read as no animation).
                  layoutBuilder: (current, previous) {
                    final all = [...previous, ?current];
                    bool pill(Widget w) =>
                        w.key == const ValueKey<Object>(_pillTransition);
                    return Stack(
                      alignment: AlignmentDirectional.centerEnd,
                      children: [
                        ...all.where((w) => !pill(w)),
                        ...all.where(pill),
                      ],
                    );
                  },
                  transitionBuilder: (child, a) {
                    final fade = FadeTransition(opacity: a, child: child);
                    if (reduced || child.key != const ValueKey('search')) {
                      return fade;
                    }
                    // Opaque for most of the move (fades only in the last
                    // 30%), so the title row never shows through it.
                    return SizeTransition(
                      key: _pillTransition,
                      sizeFactor: a,
                      axis: Axis.horizontal,
                      alignment: AlignmentDirectional.centerEnd,
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: a,
                          curve: const Interval(0, 0.3),
                        ),
                        child: child,
                      ),
                    );
                  },
                  child: searchOpen
                      ? KuberSearchPill(
                          key: const ValueKey('search'),
                          controller: w.search!.controller,
                          hint: w.search!.hint,
                          onChanged: w.search!.onChanged,
                          onClose: _closeSearch,
                          autofocus: w.search!.controller.text.isEmpty,
                        )
                      : Row(
                          key: const ValueKey('bar'),
                          children: [
                            if (showBack)
                              // No tooltip on long press (Quick navigation opens
                              // at once); TalkBack still hears what it does.
                              Semantics(
                                onLongPressHint: hasPath
                                    ? AppLocalizations.of(context)!.pathSheetTitle
                                    : null,
                                child: AppIconButton(
                                  icon: w.closeIcon
                                      ? Icons.close_rounded
                                      : Icons.arrow_back_rounded,
                                  semanticLabel: w.closeIcon ? 'Close' : 'Back',
                                  onPressed:
                                      w.onBack ?? () {
                                        // Opened straight from a link or
                                        // shortcut: nothing below, go Home
                                        // instead of a blank screen.
                                        final nav = Navigator.of(context);
                                        if (nav.canPop()) {
                                          nav.pop();
                                        } else {
                                          context.go('/');
                                        }
                                      },
                                  onLongPress: hasPath
                                      ? () => KuberPath.openFromLongPress(context)
                                      : null,
                                ),
                              ),
                            if (showHome)
                              AppIconButton(
                                icon: Icons.home_outlined,
                                semanticLabel: 'Home',
                                onPressed: () => context.go('/'),
                              ),
                            if (hasLeading) const SizedBox(width: 6),
                            Expanded(child: titleSlot),
                            ...trailing,
                          ],
                        ),
                ),
              ),
              if (subtitle != null)
                _maybeFade(
                  floating ? scope.progress : null,
                  _Fh.subtitleFadeEnd,
                  Padding(
                    padding: EdgeInsets.only(left: hasLeading ? 4 : 0),
                    child: Transform.translate(
                      offset: const Offset(0, -4),
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
    if (floating) {
      return _FloatingHeaderSurface(
        scope: scope,
        background: w.background,
        child: content,
      );
    }
    if (scope != null) {
      // Fixed inside a floating page (contextual header, edit mode): it is
      // an overlay there, so it needs its own opaque fill.
      return ColoredBox(
        color: w.background ?? theme.scaffoldBackgroundColor,
        child: Padding(
          padding: EdgeInsets.only(top: scope.statusBar),
          child: SizedBox(height: scope.restHeight, child: content),
        ),
      );
    }
    return ColoredBox(
      color: w.background ?? Colors.transparent,
      child: SafeArea(bottom: false, child: content),
    );
  }

  static Widget _maybeFade(Animation<double>? p, double end, Widget child) {
    if (p == null) return child;
    return _ProgressFade(progress: p, end: end, child: child);
  }
}

/// The overflow (more_vert) button: tonal while its menu is open.
class _OverflowButton extends StatefulWidget {
  final List<KuberOverflowItem> items;
  const _OverflowButton({required this.items});

  @override
  State<_OverflowButton> createState() => _OverflowButtonState();
}

class _OverflowButtonState extends State<_OverflowButton> {
  bool _open = false;

  Future<void> _show(BuildContext anchor) async {
    setState(() => _open = true);
    final picked = await showKuberMenu<KuberOverflowItem>(
      context: anchor,
      entries: [
        for (var i = 0; i < widget.items.length; i++) ...[
          // Divider before the first destructive item, if anything precedes it.
          if (i > 0 &&
              (widget.items[i].dividerBefore ||
                  (widget.items[i].isDestructive &&
                      !widget.items[i - 1].isDestructive)))
            const KuberMenuEntry<KuberOverflowItem>.divider(),
          KuberMenuEntry(
            value: widget.items[i],
            label: widget.items[i].label,
            subtitle: widget.items[i].subtitle,
            icon: widget.items[i].icon,
            destructive: widget.items[i].isDestructive,
            selected: widget.items[i].selected,
          ),
        ],
      ],
    );
    if (mounted) setState(() => _open = false);
    picked?.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (anchor) => AppIconButton(
        icon: Icons.more_vert_rounded,
        semanticLabel: 'More options',
        kind: _open ? AppIconButtonKind.tonal : AppIconButtonKind.standard,
        onPressed: () => _show(anchor),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Floating header (v7.0.0-c, handoff v7c.F1 to F8, motion.md).
// ---------------------------------------------------------------------------

/// Geometry and scroll positions from the handoff (dp).
abstract final class _Fh {
  /// Header becomes the pill at this scroll offset...
  static const double toPill = 32;

  /// ...and the header again at or below this one. Between them it keeps
  /// its state (the gap), so stopping on a line never flickers.
  static const double toHeader = 8;
  static const double margin = 12;
  static const double top = 8;
  static const double pillHeight = 56;
  static const double radius = 28;
  static const double hideDistance = 72;

  /// When scrolling up: hide after this much continuous downward scroll,
  /// show after [showAfter] upward. When scrolling stops: hide after this
  /// much movement, show [stopDelay] after the page stops.
  static const double hideAfter = 16;
  static const double showAfter = 8;
  static const Duration stopDelay = Duration(milliseconds: 300);

  /// After search closes, wait this long before turning back into the pill.
  static const Duration searchFoldDelay = Duration(milliseconds: 160);

  /// titleLarge 22 → 16 dp in the pill.
  static const double titleScale = 16 / 22;
  static const double minTitle = 96;

  /// Title x 20 → 28 (and the right edge 20 → 28) when there is no button.
  static const double noButtonShift = 8;

  /// Subtitle fades over the first 40 % of the morph, a dropped title over
  /// the first 60 %.
  static const double subtitleFadeEnd = 0.4;
  static const double titleDropEnd = 0.6;

  /// Gap between the pill and a docked island.
  static const double islandGap = 8;
}

/// What a [KuberHeaderPage] tells its header and islands. Animations are
/// stable objects; the scope only notifies when a flag changes.
class _FloatScope extends InheritedWidget {
  const _FloatScope({
    required this.progress,
    required this.restAlpha,
    required this.pillAlpha,
    required this.contentAlpha,
    required this.hide,
    required this.away,
    required this.level,
    required this.floating,
    required this.scrollsAway,
    required this.statusBar,
    required this.restHeight,
    required this.inset,
    required this.onSearch,
    required super.child,
  });

  /// p: 0 header, 1 pill (may overshoot at Expressive).
  final Animation<double> progress;

  /// Subtle only: opacity of the header layer and of the pill layer.
  final Animation<double> restAlpha;
  final Animation<double> pillAlpha;

  /// Opacity of the buttons and title (1 except during a Subtle swap).
  final Animation<double> contentAlpha;

  /// 0 shown, 1 hidden (show modes 2 and 3).
  final Animation<double> hide;

  /// Floating header off: how far the page has scrolled (0 .. header).
  final ValueListenable<double> away;
  final MotionLevel level;

  /// The header morphs (setting on and the header wants to float).
  final bool floating;

  /// Floating header off: the header scrolls away with the page.
  final bool scrollsAway;
  final double statusBar;
  final double restHeight;
  final double inset;
  final ValueChanged<bool> onSearch;

  static _FloatScope? maybeOf(BuildContext context, {bool listen = true}) =>
      listen
          ? context.dependOnInheritedWidgetOfExactType<_FloatScope>()
          : context.getInheritedWidgetOfExactType<_FloatScope>();

  @override
  bool updateShouldNotify(_FloatScope old) =>
      level != old.level ||
      floating != old.floating ||
      scrollsAway != old.scrollsAway ||
      statusBar != old.statusBar ||
      restHeight != old.restHeight ||
      inset != old.inset;
}

/// A page with the common header (handoff v7c "Component"). The [header]
/// is pinned over the [body] as an overlay; past 32 dp of scroll it morphs
/// into the floating pill and back within 8 dp of the top, following the
/// Floating header setting and the Motion level. With the setting off it
/// scrolls away with the content. One scroll listener for the page lives
/// here; it updates the header only when a threshold is crossed or the
/// direction changes, and the body never rebuilds because of it.
///
/// The [body]'s scrollable starts with [gap] (box) or [sliverGap] (sliver)
/// so its first item sits fully below the header at rest, exactly as when
/// the header scrolled with the content. An optional [pinned] row (tabs,
/// chips, a search bar) docks under the header and, as an island, under
/// the pill (v7c.F8); give its [pinnedHeight].
class KuberHeaderPage extends ConsumerStatefulWidget {
  const KuberHeaderPage({
    super.key,
    required this.header,
    required this.body,
    this.pinned,
    this.pinnedHeight = 0,
    this.pinnedPillShaped = false,
    this.mode,
  });

  final KuberAppBar header;
  final Widget body;

  /// Docked under the header. Must not bring its own horizontal screen
  /// margin: the island supplies 20 dp at rest.
  final Widget? pinned;
  final double pinnedHeight;

  /// The pinned control is a pill itself (pill tabs, the search pill), so it
  /// is the island; otherwise (a chip row) it sits inside a 48 dp island.
  final bool pinnedPillShaped;

  /// Overrides the setting (the settings previews).
  final FloatingHeaderMode? mode;

  /// Top padding for the body's scrollable: status bar + header at rest +
  /// pinned row. 0 outside a [KuberHeaderPage].
  static double insetOf(BuildContext context) =>
      _FloatScope.maybeOf(context)?.inset ?? 0;

  /// Status bar height above the header (0 outside a page).
  static double statusBarOf(BuildContext context) =>
      _FloatScope.maybeOf(context)?.statusBar ?? 0;

  /// True when the header scrolls with the content (Floating header off,
  /// or outside a page). An in-scroll pinned sliver uses it to collapse its
  /// header spacer with the scroll instead of keeping it.
  static bool scrollsAwayOf(BuildContext context) =>
      _FloatScope.maybeOf(context)?.scrollsAway ?? true;

  /// A box the height of [insetOf]: the first child of a box scrollable.
  static Widget gap() => Builder(
        builder: (c) => SizedBox(height: insetOf(c)),
      );

  /// A sliver the height of [insetOf]: the first sliver of a
  /// CustomScrollView.
  static Widget sliverGap() => Builder(
        builder: (c) => SliverToBoxAdapter(child: SizedBox(height: insetOf(c))),
      );

  @override
  ConsumerState<KuberHeaderPage> createState() => _KuberHeaderPageState();
}

class _KuberHeaderPageState extends ConsumerState<KuberHeaderPage>
    with TickerProviderStateMixin {
  late final AnimationController _p = AnimationController.unbounded(vsync: this);
  late final AnimationController _a0 = AnimationController(vsync: this, value: 1);
  late final AnimationController _a1 = AnimationController(vsync: this);
  late final AnimationController _shift =
      AnimationController.unbounded(vsync: this);
  late final AnimationController _h = AnimationController.unbounded(vsync: this);
  late final AnimationController _scrim = AnimationController(vsync: this);
  final ProxyAnimation _contentAlpha = ProxyAnimation(kAlwaysCompleteAnimation);
  final ValueNotifier<double> _away = ValueNotifier(0);
  final ValueNotifier<bool> _hiddenN = ValueNotifier(false);

  bool _pill = false;
  bool _scrolled = false;
  bool _searching = false;
  double _pixels = 0;
  double _down = 0, _up = 0, _moved = 0;
  Timer? _showTimer, _foldTimer;
  MotionLevel _level = MotionLevel.expressive;
  FloatingHeaderMode _mode = FloatingHeaderMode.always;
  double _headerExtent = 0;

  bool get _floats =>
      _mode != FloatingHeaderMode.off && widget.header.floating;

  @override
  void didUpdateWidget(KuberHeaderPage old) {
    super.didUpdateWidget(old);
    if (old.header.floating != widget.header.floating) {
      // Selection / edit mode started or ended: back to rest, or to the pill
      // if the page is still scrolled.
      _setHidden(false);
      _setPill(_floats && _pixels >= _Fh.toPill);
    }
  }

  @override
  void dispose() {
    _showTimer?.cancel();
    _foldTimer?.cancel();
    for (final c in [_p, _a0, _a1, _shift, _h, _scrim]) {
      c.dispose();
    }
    _away.dispose();
    _hiddenN.dispose();
    super.dispose();
  }

  // ---- State changes (only on thresholds / direction) ----

  void _setPill(bool pill, {bool slow = false}) {
    if (pill == _pill) return;
    _pill = pill;
    final t = pill ? 1.0 : 0.0;
    switch (_level) {
      case MotionLevel.expressive:
        _p.springTo(
          t,
          pill
              ? KuberMotion.springDefault
              : (slow ? KuberMotion.springSlow : KuberMotion.springStandard),
        );
      case MotionLevel.subtle:
        // Two layers at their exact bounds: the outgoing one fades out
        // quickly, the incoming one fades in (and settles 4 dp down into
        // the pill). No bounds morph.
        _p.value = t;
        _a0.animateTo(1 - t,
            duration: pill ? KuberMotion.fxInstant : KuberMotion.fxFast,
            curve: KuberMotion.curveEffects);
        _a1.animateTo(t,
            duration: pill ? KuberMotion.fxFast : KuberMotion.fxInstant,
            curve: KuberMotion.curveEffects);
        _contentAlpha.parent = pill ? _a1 : _a0;
        if (pill) {
          _shift.value = 4;
          _shift.springTo(0, KuberMotion.springSubtle);
        } else {
          _shift.value = 0;
        }
        _scrim.animateTo(t,
            duration: pill ? KuberMotion.fxDefault : KuberMotion.fxFast,
            curve: KuberMotion.curveEffects);
      case MotionLevel.off:
        _p.value = t;
        _scrim.value = t;
    }
  }

  void _setHidden(bool hidden) {
    if (hidden == _hiddenN.value) return;
    _hiddenN.value = hidden;
    final t = hidden ? 1.0 : 0.0;
    switch (_level) {
      case MotionLevel.expressive:
        _h.springTo(
            t, hidden ? KuberMotion.springStandard : KuberMotion.springDefault);
      case MotionLevel.subtle:
        _h.animateTo(t,
            duration: KuberMotion.fxFast, curve: KuberMotion.curveEffects);
      case MotionLevel.off:
        _h.animateTo(t, duration: KuberMotion.fxInstant);
    }
  }

  void _setScrolled(bool scrolled) {
    if (scrolled == _scrolled) return;
    _scrolled = scrolled;
    if (_level == MotionLevel.off) {
      _scrim.value = scrolled ? 1 : 0;
    } else {
      _scrim.animateTo(scrolled ? 1 : 0,
          duration: KuberMotion.fxDefault, curve: KuberMotion.curveEffects);
    }
  }

  /// Snap every value to the current state (level or setting changed).
  void _snap() {
    _showTimer?.cancel();
    _down = _up = _moved = 0;
    final off = _mode == FloatingHeaderMode.off;
    _pill = _floats && !_searching && _pixels >= _Fh.toPill;
    final t = _pill ? 1.0 : 0.0;
    _p.value = t;
    _a0.value = 1 - t;
    _a1.value = t;
    _shift.value = 0;
    _contentAlpha.parent =
        _level == MotionLevel.subtle ? (_pill ? _a1 : _a0) : kAlwaysCompleteAnimation;
    _hiddenN.value = false;
    _h.value = 0;
    _scrolled = _pixels > 0;
    _scrim.value = off ? (_scrolled ? 1 : 0) : t;
    _away.value = off ? _pixels.clamp(0, _headerExtent) : 0;
  }

  void _onSearch(bool open) {
    _foldTimer?.cancel();
    _searching = open;
    if (open) {
      _showTimer?.cancel();
      _setHidden(false);
      _setPill(false, slow: true);
      return;
    }
    _foldTimer = Timer(
      _level == MotionLevel.off ? Duration.zero : _Fh.searchFoldDelay,
      () {
        if (mounted && !_searching && _floats && _pixels >= _Fh.toPill) {
          _setPill(true);
        }
      },
    );
  }

  bool _keyboardOpen() => View.of(context).viewInsets.bottom > 0;

  bool _onScroll(ScrollNotification n) {
    if (n.metrics.axis != Axis.vertical) return false;
    final px = n.metrics.pixels - n.metrics.minScrollExtent;
    _pixels = px;
    if (_mode == FloatingHeaderMode.off && widget.header.floating) {
      final a = px.clamp(0.0, _headerExtent);
      if (a != _away.value) _away.value = a;
      _setScrolled(px > 0);
      return false;
    }
    if (!_floats || _searching) return false;
    if (!_pill && px >= _Fh.toPill) {
      _setPill(true);
    } else if (_pill && px <= _Fh.toHeader) {
      _setPill(false);
      _setHidden(false);
      _showTimer?.cancel();
      _down = _up = _moved = 0;
    }
    if (!_pill) return false;
    final delta = n is ScrollUpdateNotification ? (n.scrollDelta ?? 0) : 0.0;
    switch (_mode) {
      case FloatingHeaderMode.scrollUp:
        if (delta > 0) {
          _down += delta;
          _up = 0;
          if (_down > _Fh.hideAfter && !_keyboardOpen()) _setHidden(true);
        } else if (delta < 0) {
          _up -= delta;
          _down = 0;
          if (_up > _Fh.showAfter) _setHidden(false);
        }
      case FloatingHeaderMode.scrollStop:
        if (delta != 0) {
          _showTimer?.cancel();
          _moved += delta.abs();
          if (_moved > _Fh.hideAfter && !_keyboardOpen()) _setHidden(true);
        } else if (n is ScrollEndNotification) {
          _moved = 0;
          _showTimer?.cancel();
          _showTimer = Timer(_Fh.stopDelay, () {
            if (mounted) _setHidden(false);
          });
        }
      case FloatingHeaderMode.always:
      case FloatingHeaderMode.off:
        break;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final FloatingHeaderMode setting = ref.watch(floatingHeaderProvider);
    final mode = widget.mode ?? setting;
    final level = KuberMotion.levelOf(context);
    final sb = MediaQuery.paddingOf(context).top;
    final restH = widget.header.restHeight(context);
    final first = _headerExtent == 0;
    _headerExtent = sb + restH;
    if (first || mode != _mode || level != _level) {
      _mode = mode;
      _level = level;
      _snap();
    }
    final pinnedH = widget.pinned == null ? 0.0 : widget.pinnedHeight;
    final inset = sb + restH + pinnedH;
    final off = mode == FloatingHeaderMode.off;
    final scrollsAway = off && widget.header.floating;
    final bg = Theme.of(context).scaffoldBackgroundColor;

    final scrim = Positioned(
      key: const ValueKey('fh-scrim'),
      top: 0,
      left: 0,
      right: 0,
      height: sb + 16,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: !off && level == MotionLevel.expressive
              ? _ClampedAnimation(_p)
              : _scrim,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0, sb * 0.5 / (sb + 16), 1],
                colors: [
                  bg.withValues(alpha: 0.94),
                  bg.withValues(alpha: 0.94),
                  bg.withValues(alpha: 0),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    Widget header = SizedBox(height: sb + restH, child: widget.header);
    header = ValueListenableBuilder<bool>(
      valueListenable: _hiddenN,
      child: header,
      // A hidden pill is not focusable and takes no taps.
      builder: (_, hidden, child) => IgnorePointer(
        ignoring: hidden,
        child: ExcludeSemantics(excluding: hidden, child: child),
      ),
    );
    header = _HideTransform(
      hide: _h,
      shift: _shift,
      away: scrollsAway ? _away : null,
      awayMax: sb + restH,
      level: level,
      child: header,
    );

    return _FloatScope(
      progress: _p,
      restAlpha: _a0,
      pillAlpha: _a1,
      contentAlpha: _contentAlpha,
      hide: _h,
      away: _away,
      level: level,
      floating: !off && widget.header.floating,
      scrollsAway: scrollsAway,
      statusBar: sb,
      restHeight: restH,
      inset: inset,
      onSearch: _onSearch,
      child: Stack(
        children: [
          NotificationListener<ScrollNotification>(
            key: const ValueKey('fh-body'),
            onNotification: _onScroll,
            child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: widget.body,
            ),
          ),
          if (!off) scrim,
          if (widget.pinned != null)
            Positioned(
              key: const ValueKey('fh-pinned'),
              top: sb + restH,
              left: 0,
              right: 0,
              height: pinnedH,
              child: RepaintBoundary(
                child: _HideTransform(
                  hide: const AlwaysStoppedAnimation(0),
                  shift: const AlwaysStoppedAnimation(0),
                  // Off: the row stays docked under the status bar, as
                  // pinned rows do today.
                  away: scrollsAway ? _away : null,
                  awayMax: restH,
                  level: MotionLevel.off,
                  child: KuberHeaderIsland(
                    height: pinnedH,
                    pillShaped: widget.pinnedPillShaped,
                    child: widget.pinned!,
                  ),
                ),
              ),
            ),
          Positioned(
            key: const ValueKey('fh-header'),
            top: 0,
            left: 0,
            right: 0,
            child: RepaintBoundary(
              child: Semantics(
                container: true,
                explicitChildNodes: true,
                child: header,
              ),
            ),
          ),
          if (off) scrim,
        ],
      ),
    );
  }
}

/// Hidden (modes 2 and 3) and the Subtle settle, or Floating header off's
/// scroll-away: transform and opacity only.
class _HideTransform extends StatelessWidget {
  const _HideTransform({
    required this.hide,
    required this.shift,
    required this.away,
    required this.awayMax,
    required this.level,
    required this.child,
  });

  final Animation<double> hide;
  final Animation<double> shift;
  final ValueListenable<double>? away;
  final double awayMax;
  final MotionLevel level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = away;
    if (a != null) {
      return ValueListenableBuilder<double>(
        valueListenable: a,
        child: child,
        builder: (_, v, c) => Transform.translate(
          offset: Offset(0, -math.min(v, awayMax)),
          child: c,
        ),
      );
    }
    final dist = switch (level) {
      MotionLevel.expressive => _Fh.hideDistance,
      MotionLevel.subtle => 4.0,
      MotionLevel.off => 0.0,
    };
    final fade = level == MotionLevel.expressive ? 1.25 : 1.0;
    return AnimatedBuilder(
      animation: Listenable.merge([hide, shift]),
      child: child,
      builder: (_, c) {
        final h = hide.value;
        final o = (1 - h * fade).clamp(0.0, 1.0);
        return Transform.translate(
          offset: Offset(0, shift.value - h * dist),
          child: Opacity(opacity: o, alwaysIncludeSemantics: true, child: c),
        );
      },
    );
  }
}

/// A row docked under the header (v7c.F8). At rest it is a full-width strip
/// on the page colour; in the pill state it becomes an island 8 dp under
/// the pill: 12 dp margins, surfaceContainer, 1 dp outlineVariant and
/// shadow.float. A pill-shaped control is the island itself. Shares the
/// header's progress and hide state, so both morph, hide and show together.
/// Outside a [KuberHeaderPage] it is just [child] with 20 dp margins.
///
/// Also used inside an in-scroll pinned sliver (wrap the docked row in it).
class KuberHeaderIsland extends StatelessWidget {
  const KuberHeaderIsland({
    super.key,
    required this.child,
    required this.height,
    this.pillShaped = false,
  });

  final Widget child;
  final double height;
  final bool pillShaped;

  @override
  Widget build(BuildContext context) {
    final scope = _FloatScope.maybeOf(context);
    final pad = const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin);
    if (scope == null) {
      return SizedBox(height: height, child: Padding(padding: pad, child: child));
    }
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final painter = _SurfacePainter(
      progress: scope.progress,
      restAlpha: scope.restAlpha,
      pillAlpha: scope.pillAlpha,
      subtle: scope.floating && scope.level == MotionLevel.subtle,
      restTop: 0,
      restBottom: height,
      // Island 8 dp under the pill: pill bottom (status bar + 8 + 56) + 8,
      // relative to the rest position (status bar + header).
      pillTop: _Fh.top + _Fh.pillHeight + _Fh.islandGap - scope.restHeight,
      pillBottom:
          _Fh.top + _Fh.pillHeight + _Fh.islandGap - scope.restHeight + height,
      pillRadius: height / 2,
      rest: theme.scaffoldBackgroundColor,
      pill: pillShaped ? Colors.transparent : cs.surfaceContainer,
      border: cs.outlineVariant,
      shadows: KuberElevation.float(cs),
      floating: scope.floating,
    );
    Widget body = child;
    if (scope.floating && pillShaped) {
      // The control itself becomes the island: margin 20 → 12.
      body = AnimatedBuilder(
        animation: scope.progress,
        child: child,
        builder: (_, c) {
          final cp = scope.progress.value.clamp(0.0, 1.0);
          return Padding(
            padding: EdgeInsets.symmetric(
              horizontal: KuberSpace.screenMargin -
                  (KuberSpace.screenMargin - _Fh.margin) * cp,
            ),
            child: c,
          );
        },
      );
    } else {
      // Chip rows keep 20 dp: 12 margin + 8 inner padding in the island.
      body = Padding(padding: pad, child: child);
      if (scope.floating) {
        body = ClipPath(clipper: _IslandClip(painter), child: body);
      }
    }
    Widget out = CustomPaint(
      painter: painter,
      child: SizedBox(
        height: height,
        child: scope.floating
            ? _PillDock(painter: painter, child: body)
            : body,
      ),
    );
    if (scope.scrollsAway) return out;
    out = FadeTransition(opacity: scope.contentAlpha, child: out);
    return _HideTransform(
      hide: scope.hide,
      shift: const AlwaysStoppedAnimation(0),
      away: null,
      awayMax: 0,
      level: scope.level,
      child: out,
    );
  }
}

/// Moves the docked row with the island's top edge (transform only).
class _PillDock extends StatelessWidget {
  const _PillDock({required this.painter, required this.child});
  final _SurfacePainter painter;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: painter.progress,
        child: child,
        builder: (_, c) => Transform.translate(
          offset: Offset(0, painter.topAt(painter.geometryP)),
          child: c,
        ),
      );
}

class _IslandClip extends CustomClipper<Path> {
  _IslandClip(this.painter) : super(reclip: painter.progress);
  final _SurfacePainter painter;

  @override
  Path getClip(Size size) {
    final r = painter.rrectAt(size, painter.geometryP);
    // Relative to the row, which already moved with the island's top.
    return Path()..addRRect(r.shift(Offset(0, -painter.topAt(painter.geometryP))));
  }

  @override
  bool shouldReclip(_IslandClip old) => old.painter != painter;
}

/// The header's surface: the full-width rest header (opaque page colour,
/// over the status bar) lerped into the pill (12 dp margins, 8 dp under the
/// status bar, 56 dp, r28, surfaceContainer + 1 dp outlineVariant +
/// shadow.float). Paint only; margins and radius clamp at 0 so an overshoot
/// can never leave a gap at the edges. Hit-tests only inside the surface, so
/// the page around the pill stays tappable.
class _SurfacePainter extends CustomPainter {
  _SurfacePainter({
    required this.progress,
    required this.restAlpha,
    required this.pillAlpha,
    required this.subtle,
    required this.restTop,
    required this.restBottom,
    required this.pillTop,
    required this.pillBottom,
    required this.pillRadius,
    required this.rest,
    required this.pill,
    required this.border,
    required this.shadows,
    required this.floating,
  }) : super(repaint: Listenable.merge([progress, restAlpha, pillAlpha]));

  final Animation<double> progress;
  final Animation<double> restAlpha;
  final Animation<double> pillAlpha;
  final bool subtle;
  final double restTop, restBottom, pillTop, pillBottom, pillRadius;
  final Color rest, pill, border;
  final List<BoxShadow> shadows;
  final bool floating;

  double get geometryP => floating ? progress.value : 0;

  double topAt(double p) => restTop + (pillTop - restTop) * math.max(0, p);

  RRect rrectAt(Size size, double p) {
    final pp = math.max(0.0, p);
    final cq = p.clamp(0.0, 1.0);
    final m = _Fh.margin * pp;
    final top = topAt(p);
    final bottom = restBottom + (pillBottom - restBottom) * p;
    return RRect.fromLTRBR(
        m, top, size.width - m, math.max(top, bottom), Radius.circular(pillRadius * cq));
  }

  void _paintAt(Canvas canvas, Size size, double p, double alpha) {
    if (alpha <= 0) return;
    final cq = p.clamp(0.0, 1.0);
    final r = rrectAt(size, p);
    final a = cq * alpha;
    if (a > 0) {
      for (final s in shadows) {
        canvas.drawRRect(
          r.shift(s.offset).inflate(s.spreadRadius),
          Paint()
            ..color = s.color.withValues(alpha: s.color.a * a)
            ..maskFilter = MaskFilter.blur(BlurStyle.normal, s.blurSigma),
        );
      }
    }
    final fill = Color.lerp(rest, pill, cq)!;
    canvas.drawRRect(r, Paint()..color = fill.withValues(alpha: fill.a * alpha));
    if (a > 0) {
      canvas.drawRRect(
        r.deflate(0.5),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = border.withValues(alpha: border.a * a),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _lastSize = size;
    if (!floating) {
      _paintAt(canvas, size, 0, 1);
    } else if (subtle) {
      _paintAt(canvas, size, 0, restAlpha.value);
      _paintAt(canvas, size, 1, pillAlpha.value);
    } else {
      _paintAt(canvas, size, progress.value, 1);
    }
  }

  @override
  bool? hitTest(Offset position) =>
      rrectAt(_lastSize, geometryP).contains(position);

  Size _lastSize = Size.zero;

  @override
  bool shouldRepaint(_SurfacePainter old) =>
      old.rest != rest ||
      old.pill != pill ||
      old.border != border ||
      old.subtle != subtle ||
      old.floating != floating ||
      old.restBottom != restBottom ||
      old.pillTop != pillTop ||
      old.pillBottom != pillBottom ||
      old.progress != progress;
}

/// The header's surface and content inside a [KuberHeaderPage].
class _FloatingHeaderSurface extends StatelessWidget {
  const _FloatingHeaderSurface({
    required this.scope,
    required this.background,
    required this.child,
  });

  final _FloatScope scope;
  final Color? background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final sb = scope.statusBar;
    final painter = _SurfacePainter(
      progress: scope.progress,
      restAlpha: scope.restAlpha,
      pillAlpha: scope.pillAlpha,
      subtle: scope.level == MotionLevel.subtle,
      restTop: 0,
      restBottom: sb + scope.restHeight,
      pillTop: sb + _Fh.top,
      pillBottom: sb + _Fh.top + _Fh.pillHeight,
      pillRadius: _Fh.radius,
      rest: background ?? theme.scaffoldBackgroundColor,
      pill: cs.surfaceContainer,
      border: cs.outlineVariant,
      shadows: KuberElevation.float(cs),
      floating: true,
    );
    return CustomPaint(
      painter: painter,
      child: Padding(
        padding: EdgeInsets.only(top: sb),
        child: SizedBox(
          height: scope.restHeight,
          child: FadeTransition(
            opacity: scope.contentAlpha,
            child: AnimatedBuilder(
              animation: scope.progress,
              child: child,
              // Buttons keep x and their design; they move 2 dp up (y 14 → 12).
              builder: (_, c) => Transform.translate(
                offset: Offset(0, -2 * scope.progress.value.clamp(0.0, 1.0)),
                child: c,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The title in the pill: titleLarge scaled to 16 dp from its left edge,
/// x 20 → 28 with no leading button, and the clip width growing as it scales
/// so more of a long title fits. Fades out when the pill has no room for it
/// (largest font), keeping its semantics.
class _PillTitle extends StatelessWidget {
  const _PillTitle({
    required this.progress,
    required this.leadShift,
    required this.trailShift,
    required this.dropBelow,
    required this.child,
  });

  final Animation<double> progress;
  final double leadShift;
  final double trailShift;
  final double dropBelow;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, box) => AnimatedBuilder(
          animation: progress,
          child: child,
          builder: (_, c) {
            final cq = progress.value.clamp(0.0, 1.0);
            final s = 1 - (1 - _Fh.titleScale) * cq;
            final lead = leadShift * cq;
            final visual =
                math.max(0.0, box.maxWidth - lead - trailShift * cq);
            final drop = visual < dropBelow;
            Widget t = OverflowBox(
              alignment: AlignmentDirectional.centerStart,
              minWidth: 0,
              maxWidth: visual / s,
              child: c,
            );
            t = Transform(
              alignment: AlignmentDirectional.centerStart,
              transform: Matrix4.translationValues(lead, 0, 0)
                ..scaleByDouble(s, s, 1, 1),
              child: t,
            );
            // Always present (opacity 1 costs nothing), so the title's
            // element never remounts mid-morph.
            return Opacity(
              opacity: drop ? (1 - cq / _Fh.titleDropEnd).clamp(0.0, 1.0) : 1,
              alwaysIncludeSemantics: true,
              child: t,
            );
          },
        ),
      );
}

/// Opacity 1 → 0 over p 0 → [end], semantics kept.
class _ProgressFade extends StatelessWidget {
  const _ProgressFade({
    required this.progress,
    required this.end,
    required this.child,
  });

  final Animation<double> progress;
  final double end;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: progress,
        child: child,
        builder: (_, c) => Opacity(
          opacity: (1 - progress.value.clamp(0.0, 1.0) / end).clamp(0.0, 1.0),
          alwaysIncludeSemantics: true,
          child: c,
        ),
      );
}

/// [parent] clamped to 0..1 (opacity of the status scrim follows p).
class _ClampedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _ClampedAnimation(this.parent);

  @override
  final Animation<double> parent;

  @override
  double get value => parent.value.clamp(0.0, 1.0);
}

/// A page whose [header] scrolls away with its content. Only for the reorder
/// editors the floating header leaves out (v7c.F8: reorder auto-scrolls at
/// the top edge); every other page uses [KuberHeaderPage]. The [body]'s
/// scrollable must use the primary scroll controller.
class KuberScrollAwayHeader extends StatelessWidget {
  final Widget header;
  final Widget body;

  const KuberScrollAwayHeader({
    super.key,
    required this.header,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (_, __) => [SliverToBoxAdapter(child: header)],
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: body,
      ),
    );
  }
}
