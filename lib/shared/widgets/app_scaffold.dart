import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import 'kuber_nav_bar.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppScaffold({super.key, required this.navigationShell});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold>
    with SingleTickerProviderStateMixin {
  int _previousIndex = 0;
  bool _showSpeedDial = false;

  late final AnimationController _dialController;
  late final Animation<double> _dialAnimation;



  @override
  void initState() {
    super.initState();
    _dialController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _dialAnimation = CurvedAnimation(
      parent: _dialController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _dialController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index == widget.navigationShell.currentIndex) return;
    setState(() {
      _previousIndex = widget.navigationShell.currentIndex;
    });
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
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

  double get _slideDirection =>
      widget.navigationShell.currentIndex > _previousIndex ? 1.0 : -1.0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentIndex = widget.navigationShell.currentIndex;

    final width = MediaQuery.of(context).size.width;
    final isWide = width >= KuberBreakpoints.smallTablet;

    final animatedContent = AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final slideIn = Tween<Offset>(
          begin: Offset(_slideDirection, 0),
          end: Offset.zero,
        ).animate(animation);

        return SlideTransition(
          position: slideIn,
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(currentIndex),
        child: widget.navigationShell,
      ),
    );

    if (isWide) {
      return Scaffold(
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
    }

    return Scaffold(
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
          ? GestureDetector(
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
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: _onTabTapped,
        destinations: kuberNavItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
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
          index: 2,
          icon: Icons.sync_rounded,
          label: 'Add Recurring',
          onTap: () {
            onClose();
            context.push('/recurring/add');
          },
        ),
        const SizedBox(height: KuberSpacing.md),
        _buildOption(
          context,
          index: 1,
          icon: Icons.swap_horiz_rounded,
          label: 'Add Transfer',
          onTap: () {
            onClose();
            context.push('/add-transaction');
          },
        ),
        const SizedBox(height: KuberSpacing.md),
        _buildOption(
          context,
          index: 0,
          icon: Icons.arrow_downward_rounded,
          label: 'Add Income',
          onTap: () {
            onClose();
            context.push('/add-transaction');
          },
        ),
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
