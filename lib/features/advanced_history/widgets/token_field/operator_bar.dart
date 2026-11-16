import 'package:flutter/material.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../common/ah_motion.dart';
import 'token_filter_controller.dart';

/// `( ) and or not`: inserts at the cursor. 48 dp (docked 44), 2 dp gap,
/// outer full radius, inner r6. Pressed: full pill + primary. Disabled by the
/// controller's rules.
class OperatorBar extends StatelessWidget {
  const OperatorBar({
    super.key,
    required this.controller,
    this.docked = false,
    this.onHideKeyboard,
  });

  final TokenFilterController controller;
  final bool docked;

  /// Docked bars show a keyboard-hide button at the end.
  final VoidCallback? onHideKeyboard;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final h = docked ? 44.0 : 48.0;
    const ops = [
      (QueryOperator.open, '('),
      (QueryOperator.close, ')'),
      (QueryOperator.and, 'and'),
      (QueryOperator.or, 'or'),
      (QueryOperator.not, 'not'),
    ];
    final bar = ListenableBuilder(
      listenable: controller,
      builder: (context, _) => Row(
        children: [
          for (var i = 0; i < ops.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _OpButton(
              key: ValueKey('ahf-op-${ops[i].$1.name}'),
              label: ops[i].$2,
              semantics: switch (ops[i].$1) {
                QueryOperator.open => l.ahfOpOpenSemantics,
                QueryOperator.close => l.ahfOpCloseSemantics,
                _ => ops[i].$2,
              },
              bracket: i < 2,
              height: h,
              first: i == 0,
              last: i == ops.length - 1,
              enabled: controller.enabled(ops[i].$1),
              onTap: () => controller.insertOperator(ops[i].$1),
            ),
          ],
        ],
      ),
    );
    if (!docked) return bar;
    return Container(
      color: cs.surfaceContainerHigh,
      padding: const EdgeInsets.fromLTRB(8, 4, 4, 6),
      child: Row(
        children: [
          Expanded(child: bar),
          const SizedBox(width: 4),
          IconButton(
            key: const ValueKey('ahf-hide-keyboard'),
            tooltip: l.ahfHideKeyboard,
            onPressed: onHideKeyboard,
            icon: const Icon(Icons.keyboard_hide_outlined),
          ),
        ],
      ),
    );
  }
}

class _OpButton extends StatefulWidget {
  const _OpButton({
    super.key,
    required this.label,
    required this.semantics,
    required this.bracket,
    required this.height,
    required this.first,
    required this.last,
    required this.enabled,
    required this.onTap,
  });
  final String label, semantics;
  final bool bracket, first, last, enabled;
  final double height;
  final VoidCallback onTap;

  @override
  State<_OpButton> createState() => _OpButtonState();
}

class _OpButtonState extends State<_OpButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduced = AhMotion.reduced(context);
    final full = widget.height / 2;
    const inner = Radius.circular(6);
    final outerL = widget.first ? Radius.circular(full) : inner;
    final outerR = widget.last ? Radius.circular(full) : inner;
    final radius = _down
        ? BorderRadius.circular(full)
        : BorderRadius.horizontal(left: outerL, right: outerR);
    final Color bg = !widget.enabled
        ? cs.onSurface.withValues(alpha: 0.10)
        : _down
            ? cs.primary
            : cs.secondaryContainer;
    final Color fg = !widget.enabled
        ? cs.onSurface.withValues(alpha: 0.38)
        : _down
            ? cs.onPrimary
            : cs.onSecondaryContainer;
    final text = Text(
      widget.label,
      style: widget.bracket
          ? monoFont(fontSize: 20, fontWeight: FontWeight.w600, color: fg)
          : localeFont(fontSize: 14, fontWeight: FontWeight.w600, color: fg),
    );
    final child = AnimatedContainer(
      duration: _down ? AhMotion.fast : (reduced ? AhMotion.instant : AhMotion.fast),
      curve: _down ? AhMotion.decelerate : Curves.easeOutBack,
      height: widget.height,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: radius),
      child: text,
    );
    final w = Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semantics,
      excludeSemantics: true,
      onTap: widget.enabled ? widget.onTap : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: widget.enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: widget.enabled ? widget.onTap : null,
        child: child,
      ),
    );
    return widget.bracket
        ? SizedBox(width: 52, child: w)
        : Expanded(child: w);
  }
}
