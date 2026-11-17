import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_shape_loader.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_ast.dart';
import 'package:kuber/core/theme/app_theme.dart';

/// Bottom button: "Show N transactions". [node] is already debounced by the
/// page. Loader after 150 ms (label "Show transactions", still tappable),
/// 0 matches disables it.
class LiveCountButton extends ConsumerStatefulWidget {
  const LiveCountButton({
    super.key,
    required this.node,
    required this.enabled,
    required this.onApply,
  });
  final QueryNode node;

  /// False while the draft is invalid.
  final bool enabled;
  final VoidCallback onApply;

  @override
  ConsumerState<LiveCountButton> createState() => _LiveCountButtonState();
}

class _LiveCountButtonState extends ConsumerState<LiveCountButton> {
  int? _last;
  bool _slow = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final a = ref.watch(ahCountProvider(widget.node));
    if (a.hasValue && !a.isLoading) {
      _last = a.value;
      _timer?.cancel();
      _timer = null;
      _slow = false;
    } else if (a.isLoading && _timer == null && !_slow) {
      _timer = Timer(KuberMotion.fxFast, () {
        _timer = null;
        if (mounted) setState(() => _slow = true);
      });
    }
    final loading = a.isLoading && _slow;
    final count = _last;
    final none = !a.isLoading && count == 0;
    final label = loading || count == null
        ? l.ahfShowCounting
        : none
            ? l.ahfNoMatch
            : l.ahfShowN(count);
    final reduced = KuberMotion.reduced(context);
    return AnimatedSwitcher(
      duration: reduced ? KuberMotion.fxInstant : KuberMotion.fxFast,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SlideTransition(
                position: Tween(begin: reduced ? Offset.zero : const Offset(0, 0.1), end: Offset.zero)
                    .animate(anim),
                child: child),
      ),
      child: Stack(
        key: ValueKey('ahf-count-$label-$loading'),
        alignment: Alignment.centerLeft,
        children: [
          AppButton(
            label: label,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: none || !widget.enabled ? null : widget.onApply,
          ),
          if (loading)
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: IgnorePointer(
                child: KuberShapeLoader(
                  key: const ValueKey('ahf-count-loader'),
                  size: 24,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
