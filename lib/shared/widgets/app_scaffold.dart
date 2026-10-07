import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/accounts/providers/account_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/settings/providers/settings_provider.dart'
    show settingsProvider, navBarStyleProvider, SwipeMode, NavBarStyle;
import '../../features/history/providers/selection_provider.dart';
import '../../features/quick_actions/widgets/add_new_sheet.dart';
import '../../features/quick_actions/widgets/quick_actions_sheet.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import 'kuber_nav_bar.dart';

final currentShellTabIndexProvider = StateProvider<int>((ref) => 0);

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell? navigationShell;
  final List<Widget> children;

  const AppScaffold({
    super.key,
    this.navigationShell,
    this.children = const [],
  });

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  bool _isAnimatingProgrammatically = false;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: widget.navigationShell?.currentIndex ?? 0,
    );
    // Pre-warm keepAlive providers so form sheets find data in cache
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(allAccountsProvider.future).ignore();
      ref.read(categoryListProvider.future).ignore();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell == null || oldWidget.navigationShell == null) {
      return;
    }
    if (widget.navigationShell!.currentIndex !=
        oldWidget.navigationShell!.currentIndex) {
      // Defer the provider mutation until after the current build phase to
      // avoid `Tried to modify a provider while the widget tree was building`
      // when GoRouter swaps the shell branch (e.g. View Transactions from
      // the home accounts sheet routes us to the History tab mid-build).
      final newIndex = widget.navigationShell!.currentIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(currentShellTabIndexProvider.notifier).state = newIndex;
      });
      if (_pageController.hasClients &&
          _pageController.page?.round() !=
              widget.navigationShell!.currentIndex) {
        final currentPage = _pageController.page?.round() ?? 0;
        final targetIndex = widget.navigationShell!.currentIndex;
        final distance = (targetIndex - currentPage).abs();
        if (distance > 1) {
          _isAnimatingProgrammatically = true;
          final jumpTo = targetIndex > currentPage
              ? targetIndex - 1
              : targetIndex + 1;
          _pageController.jumpToPage(jumpTo);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _pageController
                .animateToPage(
                  targetIndex,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                )
                .then((_) {
                  _isAnimatingProgrammatically = false;
                });
          });
        } else {
          _pageController.animateToPage(
            targetIndex,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
    }
  }

  void _onTabTapped(int index) {
    if (widget.navigationShell == null) return;
    if (index == widget.navigationShell!.currentIndex) return;

    ref.read(transactionSelectionProvider.notifier).clear();
    ref.read(currentShellTabIndexProvider.notifier).state = index;

    widget.navigationShell!.goBranch(
      index,
      initialLocation: index == widget.navigationShell!.currentIndex,
    );
    if (_pageController.hasClients) {
      final currentPage = _pageController.page?.round() ?? 0;
      final distance = (index - currentPage).abs();
      if (distance > 1) {
        _isAnimatingProgrammatically = true;
        final jumpTo = index > currentPage ? index - 1 : index + 1;
        _pageController.jumpToPage(jumpTo);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _pageController
              .animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              )
              .then((_) {
                _isAnimatingProgrammatically = false;
              });
        });
      } else {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _onPageChanged(int index) {
    if (_isAnimatingProgrammatically) return;
    if (widget.navigationShell == null) return;
    if (index == widget.navigationShell!.currentIndex) return;
    ref.read(transactionSelectionProvider.notifier).clear();
    ref.read(currentShellTabIndexProvider.notifier).state = index;
    widget.navigationShell!.goBranch(index);
  }

  void _onAddTapped() => context.push('/add-transaction');

  /// FAB / add-button long-press → the Add New sheet (add-entry shortcuts).
  void _openAddMenu() => showAddNewSheet(context);

  /// Nav-tab long-press → the Quick Actions sheet (controls + shortcuts).
  void _openQuickActions() => showQuickActionsSheet(context);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (widget.navigationShell == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final currentIndex = widget.navigationShell!.currentIndex;
    if (ref.read(currentShellTabIndexProvider) != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(currentShellTabIndexProvider.notifier).state = currentIndex;
      });
    }

    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= KuberBreakpoints.smallTablet;

    // Only watch the two fields this scaffold actually renders with —
    // watching the whole settings state would rebuild the app shell on any
    // settings change (theme, currency, etc.).
    final swipeMode = ref.watch(settingsProvider
        .select((s) => s.valueOrNull?.swipeMode ?? SwipeMode.changeTabs));
    final navBarStyle = ref.watch(navBarStyleProvider);

    final animatedContent = swipeMode == SwipeMode.changeTabs
        ? PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: widget.children,
          )
        : widget.navigationShell!;

    Widget content;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    if (isWide) {
      content = Scaffold(
        backgroundColor: cs.surface,
        body: Row(
          children: [
            KuberNavRail(
              currentIndex: currentIndex,
              onTabTapped: _onTabTapped,
              onAddTapped: _onAddTapped,
            ),
            Expanded(child: animatedContent),
          ],
        ),
      );
    } else if (navBarStyle == NavBarStyle.modern) {
      content = Scaffold(
        backgroundColor: cs.surface,
        extendBody: true,
        body: animatedContent,
        bottomNavigationBar: _ModernNavBar(
          currentIndex: currentIndex,
          onTap: _onTabTapped,
          onTabLongPress: _openQuickActions,
          onAddTapped: _onAddTapped,
          onAddLongPress: _openAddMenu,
          isSelectionMode: isSelectionMode,
          isKeyboardOpen: isKeyboardOpen,
        ),
      );
    } else {
      content = Scaffold(
        backgroundColor: cs.surface,
        body: animatedContent,
        floatingActionButton: currentIndex != 3
            ? AnimatedScale(
                scale: (isSelectionMode || isKeyboardOpen) ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: KuberNavFab(
                  onTap: _onAddTapped,
                  onLongPress: _openAddMenu,
                ),
              )
            : null,
        bottomNavigationBar: _KuberAnimatedNavBar(
          currentIndex: currentIndex,
          onTap: _onTabTapped,
          onTabLongPress: _openQuickActions,
        ),
      );
    }

    // PopScope(canPop: false) signals the NavigationNotification system
    // so that _WidgetsAppState calls setFrameworkHandlesBack(true) on
    // Android 13+. This ensures handlePopRoute() fires when the user
    // presses back, which triggers didPopRoute() in app.dart.
    // The onPopInvokedWithResult is a belt-and-suspenders fallback.
    return PopScope(
      canPop: currentIndex == 0 && !isSelectionMode,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (isSelectionMode) {
          ref.read(transactionSelectionProvider.notifier).clear();
          return;
        }
        if (currentIndex != 0) {
          _onTabTapped(0);
          return;
        }
      },
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// Modern Floating Nav Bar
// ---------------------------------------------------------------------------

class _ModernNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onTabLongPress;
  final VoidCallback onAddTapped;
  final VoidCallback onAddLongPress;
  final bool isSelectionMode;
  final bool isKeyboardOpen;

  const _ModernNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onTabLongPress,
    required this.onAddTapped,
    required this.onAddLongPress,
    required this.isSelectionMode,
    required this.isKeyboardOpen,
  });

  @override
  State<_ModernNavBar> createState() => _ModernNavBarState();
}

class _ModernNavBarState extends State<_ModernNavBar> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hide = widget.isSelectionMode || widget.isKeyboardOpen;
    final inset = MediaQuery.of(context).padding.bottom;
    final bottom = inset > 22 ? inset : 22.0;

    // Perch NavShell hide: translate down 72 and fade over 160 ms; the same
    // two Kuber triggers as before (selection mode, keyboard).
    return TweenAnimationBuilder<double>(
      tween: Tween(end: hide ? 1.0 : 0.0),
      duration: KuberMotion.of(context, KuberMotion.navHide),
      curve: KuberMotion.decelerate,
      builder: (context, t, child) => Opacity(
        opacity: 1 - t,
        child: Transform.translate(
          offset: Offset(0, KuberMotion.reduced(context) ? 0 : 72 * t),
          child: IgnorePointer(ignoring: t > 0.5, child: child),
        ),
      ),
      child: SizedBox(
        height: bottom + 56 + 32,
        child: Stack(
          children: [
            // Static scrim so scrolled content fades out under the pill. Pure
            // gradient paint, no blur.
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        cs.surface.withValues(alpha: 0),
                        cs.surface.withValues(alpha: 0.92),
                        cs.surface,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: bottom,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  KuberNavPill(
                    index: widget.currentIndex,
                    onSelect: widget.onTap,
                    onLongPress: widget.onTabLongPress,
                  ),
                  KuberNavFab(
                    onTap: widget.onAddTapped,
                    onLongPress: widget.onAddLongPress,
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

class _KuberAnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final VoidCallback onTabLongPress;

  const _KuberAnimatedNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.onTabLongPress,
  });

  @override
  State<_KuberAnimatedNavBar> createState() => _KuberAnimatedNavBarState();
}

class _KuberAnimatedNavBarState extends State<_KuberAnimatedNavBar> {
  static const _animDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return ColoredBox(
      color: cs.surfaceContainer,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 80,
          child: Row(
            children: List.generate(kuberNavItems.length, (i) {
              final item = kuberNavItems[i];
              final isSelected = i == widget.currentIndex;
              return Expanded(
                child: _NavBarItem(
                  item: item,
                  isSelected: isSelected,
                  animDuration: _animDuration,
                  onTap: () => widget.onTap(i),
                  onLongPress: widget.onTabLongPress,
                  cs: cs,
                  tt: tt,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavBarItem extends StatefulWidget {
  final KuberNavItem item;
  final bool isSelected;
  final Duration animDuration;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final ColorScheme cs;
  final TextTheme tt;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.animDuration,
    required this.onTap,
    this.onLongPress,
    required this.cs,
    required this.tt,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animDuration,
      value: widget.isSelected ? 1.0 : 0.0,
    );
    _scaleAnim = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final cs = widget.cs;
          final iconColor =
              Color.lerp(cs.onSurfaceVariant, cs.onSecondaryContainer, t)!;
          final index = kuberNavItems.indexOf(widget.item);
          final labelStr = localNavLabel(context, widget.item.label);

          // Classic: M3 NavigationBar item (64x32 stadium indicator in
          // secondaryContainer, labelMedium below). Same controller as before.
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 64,
                  height: 32,
                  decoration: BoxDecoration(
                    color: cs.secondaryContainer.withValues(alpha: t),
                    borderRadius: KuberShape.fullR,
                  ),
                  alignment: Alignment.center,
                  child: KuberNavGlyph(
                    index: index,
                    color: iconColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                duration: widget.animDuration,
                style: widget.tt.labelMedium!.copyWith(
                  color: widget.isSelected ? cs.onSurface : cs.onSurfaceVariant,
                ),
                child: Text(labelStr),
              ),
            ],
          );
        },
      ),
    );
  }
}
