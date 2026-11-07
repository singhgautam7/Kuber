import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

/// The row a More search result is opening, for the [SettingsAnchor]s below.
class _SettingsHighlight extends InheritedWidget {
  final String? rowId;
  const _SettingsHighlight({required this.rowId, required super.child});

  @override
  bool updateShouldNotify(_SettingsHighlight old) => old.rowId != rowId;
}

/// One Settings page: the shared header over a plain scrolling column.
/// [highlight]: the row to scroll to and flash (More search).
class SettingsPageFrame extends StatelessWidget {
  final String title;
  final String? highlight;
  final List<Widget> children;

  const SettingsPageFrame({
    super.key,
    required this.title,
    required this.children,
    this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      // Plain slivers, like the long Settings page had: a scroll-away header
      // over a nested scroll view cost three times as much on first open.
      body: _SettingsHighlight(
        rowId: highlight,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: KuberAppBar(showBack: true, title: title)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                KuberSpace.xs,
                KuberSpace.screenMargin,
                KuberSpace.xxxl,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Wraps a settings row with its `settings_index.dart` id: search scrolls to it
/// and tints it briefly. Costs nothing unless it is the row being opened.
class SettingsAnchor extends StatefulWidget {
  final String id;
  final Widget child;
  const SettingsAnchor(this.id, {super.key, required this.child});

  @override
  State<SettingsAnchor> createState() => _SettingsAnchorState();
}

class _SettingsAnchorState extends State<SettingsAnchor>
    with SingleTickerProviderStateMixin {
  AnimationController? _glow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final highlight = context
        .dependOnInheritedWidgetOfExactType<_SettingsHighlight>()
        ?.rowId;
    if (highlight != widget.id || _glow != null) return;
    final c = _glow = AnimationController(
      vsync: this,
      duration: KuberMotion.reduced(context)
          ? const Duration(milliseconds: 600)
          : const Duration(milliseconds: 1500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Scrollable.ensureVisible(
        context,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      if (mounted) c.forward();
    });
  }

  @override
  void dispose() {
    _glow?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = _glow;
    if (glow == null) return widget.child;
    final tint = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: glow,
              builder: (_, _) {
                final t = glow.value;
                // Up fast, then a slow fade.
                final a = t < 0.15 ? t / 0.15 : (1 - t) / 0.85;
                return ColoredBox(color: tint.withValues(alpha: 0.2 * a));
              },
            ),
          ),
        ),
      ],
    );
  }
}
