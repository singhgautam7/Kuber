import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

/// The row a More search result is opening, for the [SettingsAnchor]s below.
class SettingsHighlight extends InheritedWidget {
  final String? rowId;
  const SettingsHighlight({super.key, required this.rowId, required super.child});

  @override
  bool updateShouldNotify(SettingsHighlight old) => old.rowId != rowId;
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
      body: SettingsHighlight(
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
/// and plays the arrival highlight: primary 16%, in 150 ms, hold 1 s, out
/// 600 ms. Costs nothing unless it is the row being opened.
class SettingsAnchor extends StatefulWidget {
  final String id;
  final Widget child;
  const SettingsAnchor(this.id, {super.key, required this.child});

  @override
  State<SettingsAnchor> createState() => _SettingsAnchorState();
}

const int _in = 150, _hold = 1000, _out = 600;
const _total = Duration(milliseconds: _in + _hold + _out);

class _SettingsAnchorState extends State<SettingsAnchor>
    with SingleTickerProviderStateMixin {
  AnimationController? _glow;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final highlight = context
        .dependOnInheritedWidgetOfExactType<SettingsHighlight>()
        ?.rowId;
    if (highlight != widget.id || _glow != null) return;
    final c = _glow = AnimationController(vsync: this, duration: _total);
    final view = View.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await Scrollable.ensureVisible(
        context,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      if (!mounted) return;
      c.forward();
      // TalkBack hears the row once.
      final text = _rowLabel();
      if (text != null) {
        SemanticsService.sendAnnouncement(view, text, Directionality.of(context));
      }
    });
  }

  /// The row's own title.
  String? _rowLabel() {
    String? found;
    void visit(Element e) {
      if (found != null) return;
      final w = e.widget;
      if (w is Text && w.data != null) {
        found = w.data;
        return;
      }
      e.visitChildren(visit);
    }

    (context as Element).visitChildren(visit);
    return found;
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
                final ms = glow.value * _total.inMilliseconds;
                final a = ms < _in
                    ? ms / _in
                    : ms < _in + _hold
                        ? 1.0
                        : (_total.inMilliseconds - ms) / _out;
                return ColoredBox(color: tint.withValues(alpha: 0.16 * a));
              },
            ),
          ),
        ),
      ],
    );
  }
}
