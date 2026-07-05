import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// "Kuber is thinking" indicator: three bare dots at the left edge, no bubble
/// box (matches the avatarless, box-less Kuber message treatment).
class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(top: 4, bottom: KuberSpacing.md),
        child: SizedBox(
          height: 18,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _Dot(delay: 0),
              SizedBox(width: 5),
              _Dot(delay: 150),
              SizedBox(width: 5),
              _Dot(delay: 300),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatefulWidget {
  final int delay;
  const _Dot({required this.delay});

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _anim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // RepaintBoundary isolates the 60Hz opacity tween to this dot's ~6×6 layer,
    // so the parent Row / Padding / Align / enclosing ListView row don't repaint
    // once per frame while the indicator is visible.
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _anim,
        builder: (_, __) => Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color:
                cs.onSurfaceVariant.withValues(alpha: 0.3 + 0.7 * _anim.value),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
