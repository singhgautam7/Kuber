import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/models/info_config.dart';
import '../../l10n/app_localizations.dart';
import '../../core/models/overflow_config.dart';
import '../../core/services/shortcut_pin_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/settings/providers/settings_provider.dart';
import 'app_icon_button.dart';
import 'kuber_info_bottom_sheet.dart';
import 'kuber_menu.dart';
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
  });

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
          onPressed: () => setState(() => _searching = true),
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
    return ColoredBox(
      color: w.background ?? Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Padding(
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
                              AppIconButton(
                                icon: w.closeIcon
                                    ? Icons.close_rounded
                                    : Icons.arrow_back_rounded,
                                semanticLabel: w.closeIcon ? 'Close' : 'Back',
                                onPressed:
                                    w.onBack ?? () => Navigator.pop(context),
                              ),
                            if (showHome)
                              AppIconButton(
                                icon: Icons.home_outlined,
                                semanticLabel: 'Home',
                                onPressed: () => context.go('/'),
                              ),
                            if (hasLeading) const SizedBox(width: 6),
                            Expanded(
                              child: Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: titleWidget ?? const SizedBox.shrink(),
                              ),
                            ),
                            ...trailing,
                          ],
                        ),
                ),
              ),
              if (subtitle != null)
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
            ],
          ),
        ),
      ),
    );
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

/// A page whose [header] scrolls away with its content (review round 3: no
/// sticky headers). Put it in `Scaffold.body` instead of passing the header
/// as `appBar`. The [body]'s scrollable must use the primary scroll
/// controller (no explicit `controller`) so the header and content scroll
/// together.
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
      // The header already consumed the status-bar inset.
      body: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: body,
      ),
    );
  }
}
