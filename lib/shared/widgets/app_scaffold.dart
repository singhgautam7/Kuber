import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../features/accounts/providers/account_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../features/history/providers/selection_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import 'kuber_nav_bar.dart';

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

class _AppScaffoldState extends ConsumerState<AppScaffold>
    with SingleTickerProviderStateMixin {
  bool _showSpeedDial = false;
  bool _isAnimatingProgrammatically = false;
  late final PageController _pageController;
  late final AnimationController _dialController;
  late final Animation<double> _dialAnimation;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(initialPage: widget.navigationShell?.currentIndex ?? 0);
    _dialController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _dialAnimation = CurvedAnimation(
      parent: _dialController,
      curve: Curves.easeOut,
    );
    // Pre-warm keepAlive providers so form sheets find data in cache
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountListProvider.future).ignore();
      ref.read(categoryListProvider.future).ignore();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _dialController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.navigationShell == null || oldWidget.navigationShell == null) return;
    if (widget.navigationShell!.currentIndex != oldWidget.navigationShell!.currentIndex) {
      if (_pageController.hasClients &&
          _pageController.page?.round() != widget.navigationShell!.currentIndex) {
        final currentPage = _pageController.page?.round() ?? 0;
        final targetIndex = widget.navigationShell!.currentIndex;
        final distance = (targetIndex - currentPage).abs();
        if (distance > 1) {
          _isAnimatingProgrammatically = true;
          final jumpTo = targetIndex > currentPage ? targetIndex - 1 : targetIndex + 1;
          _pageController.jumpToPage(jumpTo);
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _pageController.animateToPage(
              targetIndex,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).then((_) {
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
    if (_showSpeedDial) _closeSpeedDial();
    
    ref.read(transactionSelectionProvider.notifier).clear();

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
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          ).then((_) {
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
    widget.navigationShell!.goBranch(index);
  }

  void _onAddTapped() {
    if (_showSpeedDial) {
      _closeSpeedDial();
    } else {
      context.push('/add-transaction');
    }
  }

  void _openSpeedDial() {
    setState(() => _showSpeedDial = true);
    _dialController.forward();
  }

  void _closeSpeedDial() {
    _dialController.reverse().then((_) {
      if (mounted) setState(() => _showSpeedDial = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    if (widget.navigationShell == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final currentIndex = widget.navigationShell!.currentIndex;

    final isSelectionMode = ref.watch(isSelectionModeProvider);
    final width = MediaQuery.of(context).size.width;
    final isWide = width >= KuberBreakpoints.smallTablet;

    final swipeMode = settings?.swipeMode ?? SwipeMode.changeTabs;

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
    } else {
      content = Scaffold(
        backgroundColor: cs.surface,
        body: Stack(
        children: [
          animatedContent,
          if (_showSpeedDial) ...[
            // Full-screen barrier
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeSpeedDial,
                child: Container(
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ),
            // Speed dial options
            Positioned(
              right: KuberSpacing.lg,
              bottom: 100,
              child: _SpeedDialMenu(
                animation: _dialAnimation,
                onClose: _closeSpeedDial,
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: currentIndex != 3
          ? AnimatedScale(
              scale: (ref.watch(isSelectionModeProvider) || isKeyboardOpen) ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              child: GestureDetector(
                onLongPress: _openSpeedDial,
                child: FloatingActionButton(
                  onPressed: _onAddTapped,
                  backgroundColor: cs.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: AnimatedRotation(
                    turns: _showSpeedDial ? 0.125 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.add),
                  ),
                ),
              ),
            )
          : null,
      bottomNavigationBar: _KuberAnimatedNavBar(
        currentIndex: currentIndex,
        onTap: _onTabTapped,
      ),
    );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (_showSpeedDial) {
          _closeSpeedDial();
          return;
        }

        if (isSelectionMode) {
          ref.read(transactionSelectionProvider.notifier).clear();
          return;
        }

        if (currentIndex != 0) {
          _onTabTapped(0);
          return;
        }

        // Final fallback: Exit app
        SystemNavigator.pop();
      },
      child: content,
    );
  }
}

// ---------------------------------------------------------------------------
// Animated Bottom Nav Bar
// ---------------------------------------------------------------------------

class _KuberAnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _KuberAnimatedNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  State<_KuberAnimatedNavBar> createState() => _KuberAnimatedNavBarState();
}

class _KuberAnimatedNavBarState extends State<_KuberAnimatedNavBar> {
  static const _animDuration = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outline.withValues(alpha: 0.4))),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
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
  final ColorScheme cs;
  final TextTheme tt;

  const _NavBarItem({
    required this.item,
    required this.isSelected,
    required this.animDuration,
    required this.onTap,
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
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
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
    final selectedColor = widget.cs.primary;
    final unselectedColor = widget.cs.onSurfaceVariant;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              return ScaleTransition(
                scale: _scaleAnim,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outline icon (unselected)
                    Opacity(
                      opacity: (1 - t).clamp(0.0, 1.0),
                      child: Icon(
                        widget.item.icon,
                        size: 24,
                        color: unselectedColor,
                      ),
                    ),
                    // Filled icon (selected)
                    Opacity(
                      opacity: t.clamp(0.0, 1.0),
                      child: Icon(
                        widget.item.activeIcon,
                        size: 24,
                        color: selectedColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: widget.animDuration,
            style: widget.tt.labelSmall!.copyWith(
              fontSize: 11,
              fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
              color: widget.isSelected ? selectedColor : unselectedColor,
            ),
            child: Text(widget.item.label),
          ),
        ],
      ),
    );
  }
}

class _SpeedDialMenu extends AnimatedWidget {
  final VoidCallback onClose;

  const _SpeedDialMenu({
    required Animation<double> animation,
    required this.onClose,
  }) : super(listenable: animation);

  Animation<double> get _progress => listenable as Animation<double>;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildOption(
          context,
          index: 3,
          icon: Icons.sync_rounded,
          label: 'Add a Recurring Transaction',
          onTap: () {
            onClose();
            context.push('/recurring/add');
          },
        ),
        const SizedBox(height: KuberSpacing.md),
        _buildOption(
          context,
          index: 2,
          icon: Icons.account_balance_rounded,
          label: 'Add a Loan',
          onTap: () {
            onClose();
            context.push('/loans/add');
          },
        ),
        const SizedBox(height: KuberSpacing.md),
        _buildOption(
          context,
          index: 1,
          icon: Icons.show_chart_rounded,
          label: 'Add an Investment',
          onTap: () {
            onClose();
            context.push('/investments/add');
          },
        ),
        const SizedBox(height: KuberSpacing.md),
        _buildOption(
          context,
          index: 0,
          icon: Icons.handshake_outlined,
          label: 'Lend / Borrow Money',
          onTap: () {
            onClose();
            context.push('/ledger/add');
          },
        ),
        // const SizedBox(height: KuberSpacing.md),
        // _buildOption(
        //   context,
        //   index: 1,
        //   icon: Icons.swap_horiz_rounded,
        //   label: 'Add Transfer',
        //   onTap: () {
        //     onClose();
        //     context.push('/add-transaction?type=transfer');
        //   },
        // ),
        // const SizedBox(height: KuberSpacing.md),
        // _buildOption(
        //   context,
        //   index: 0,
        //   icon: Icons.arrow_downward_rounded,
        //   label: 'Add Income',
        //   onTap: () {
        //     onClose();
        //     context.push('/add-transaction?type=income');
        //   },
        // ),
      ],
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    final delay = (index * 0.15).clamp(0.0, 0.5);
    final progress =
        ((_progress.value - delay) / (1.0 - delay)).clamp(0.0, 1.0);

    return Opacity(
      opacity: progress,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - progress)),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.lg,
              vertical: KuberSpacing.md,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: cs.primary, size: 20),
                const SizedBox(width: KuberSpacing.sm),
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
