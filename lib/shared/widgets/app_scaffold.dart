import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/breakpoints.dart';
import '../../features/accounts/providers/account_provider.dart';
import 'kuber_nav_bar.dart';

class AppScaffold extends ConsumerStatefulWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  ConsumerState<AppScaffold> createState() => _AppScaffoldState();
}

class _AppScaffoldState extends ConsumerState<AppScaffold> {
  int _currentIndex = 0;
  int _previousIndex = 0;

  static const _routes = ['/', '/history', '/analytics', '/accounts'];

  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });
    context.go(_routes[index]);
  }

  void _onAddTapped() {
    if (_currentIndex == 3) {
      // On Accounts tab → trigger add-account sheet
      ref.read(triggerAddAccountProvider.notifier).state = true;
    } else {
      context.push('/add-transaction');
    }
  }

  double get _slideDirection =>
      _currentIndex > _previousIndex ? 1.0 : -1.0;

  @override
  Widget build(BuildContext context) {
    // Sync tab index from route
    final location = GoRouterState.of(context).uri.path;
    final routeIndex = _routes.indexOf(location);
    if (routeIndex != -1 && routeIndex != _currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _previousIndex = _currentIndex;
            _currentIndex = routeIndex;
          });
        }
      });
    }

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
        key: ValueKey(_currentIndex),
        child: widget.child,
      ),
    );

    if (isWide) {
      // Large tablet / desktop → side rail
      return Scaffold(
        backgroundColor: KuberColors.background,
        body: Row(
          children: [
            KuberNavRail(
              currentIndex: _currentIndex,
              onTabTapped: _onTabTapped,
              onAddTapped: _onAddTapped,
            ),
            Expanded(child: animatedContent),
          ],
        ),
      );
    }

    // Phone / small tablet → glassmorphic bottom bar
    return Scaffold(
      backgroundColor: KuberColors.background,
      extendBody: true,
      body: animatedContent,
      bottomNavigationBar: KuberBottomNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
        onAddTapped: _onAddTapped,
      ),
    );
  }
}
