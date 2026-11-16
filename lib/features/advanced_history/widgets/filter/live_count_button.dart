import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_ast.dart';
import '../common/ah_motion.dart';

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
      _timer = Timer(AhMotion.fast, () {
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
    final reduced = AhMotion.reduced(context);
    return AnimatedSwitcher(
      duration: reduced ? AhMotion.instant : AhMotion.fast,
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
                child: SizedBox(
                  key: const ValueKey('ahf-count-loader'),
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
