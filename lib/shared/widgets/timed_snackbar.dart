import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

// ---------------------------------------------------------------------------
// OverlayEntry-based snackbar.
//
// Using an OverlayEntry (instead of a Flushbar Route) means the snackbar
// never sits on any Navigator's stack, so the Android back button doesn't
// dismiss it. It stays put until the timer expires or the user taps close.
// ---------------------------------------------------------------------------

const Duration _kSnackDuration = Duration(seconds: 7);
const Duration _kAnimDuration = Duration(milliseconds: 220);

OverlayEntry? _currentEntry;
_KuberSnackBarController? _currentController;
Timer? _currentTimer;

void _dismissCurrent() {
  _currentTimer?.cancel();
  _currentTimer = null;

  final controller = _currentController;
  final entry = _currentEntry;
  _currentController = null;
  _currentEntry = null;

  if (controller != null && entry != null) {
    controller.animateOut().then((_) {
      if (entry.mounted) entry.remove();
    });
  } else {
    entry?.remove();
  }
}

void showKuberSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
  String? secondaryActionLabel,
  VoidCallback? onSecondaryAction,
  Duration? duration,
}) {
  // Clear any currently showing snackbar first.
  _dismissCurrent();

  final overlay = Overlay.of(context, rootOverlay: true);
  final controller = _KuberSnackBarController();

  final entry = OverlayEntry(
    builder: (ctx) => _KuberSnackBarWidget(
      controller: controller,
      message: message,
      isError: isError,
      actionLabel: actionLabel,
      onAction: onAction,
      secondaryActionLabel: secondaryActionLabel,
      onSecondaryAction: onSecondaryAction,
      onRequestClose: _dismissCurrent,
      duration: duration,
    ),
  );

  _currentController = controller;
  _currentEntry = entry;
  overlay.insert(entry);

  _currentTimer = Timer(duration ?? _kSnackDuration, _dismissCurrent);
}

// ---------------------------------------------------------------------------
// Controller — bridges the static dismiss logic with the widget's state.
// ---------------------------------------------------------------------------

class _KuberSnackBarController {
  _KuberSnackBarWidgetState? _state;

  void _attach(_KuberSnackBarWidgetState state) => _state = state;

  Future<void> animateOut() async {
    final state = _state;
    if (state == null) return;
    await state._animateOut();
  }
}

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class _KuberSnackBarWidget extends StatefulWidget {
  final _KuberSnackBarController controller;
  final String message;
  final bool isError;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final VoidCallback onRequestClose;
  final Duration? duration;

  const _KuberSnackBarWidget({
    required this.controller,
    required this.message,
    required this.isError,
    required this.onRequestClose,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.duration,
  });

  @override
  State<_KuberSnackBarWidget> createState() => _KuberSnackBarWidgetState();
}

class _KuberSnackBarWidgetState extends State<_KuberSnackBarWidget>
    with TickerProviderStateMixin {
  late final AnimationController _slideCtrl;
  late final Animation<double> _slideAnim;
  late final AnimationController _progressCtrl;
  bool _actionFired = false;

  // Drag-to-dismiss state (in logical pixels). dx > 0 = right, dy < 0 = up.
  // Reset to (0, 0) on a non-dismiss drag end.
  Offset _dragOffset = Offset.zero;

  // Above either threshold a dismiss is committed even if velocity is low.
  static const double _kSwipeDistanceThreshold = 80.0;
  // Above either velocity (px/s) a fling commits even with low distance.
  static const double _kSwipeVelocityThreshold = 600.0;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(vsync: this, duration: _kAnimDuration);
    _slideAnim = CurvedAnimation(
      parent: _slideCtrl,
      curve: Curves.easeOutCubic,
    );
    _progressCtrl = AnimationController(vsync: this, duration: widget.duration ?? _kSnackDuration);
    widget.controller._attach(this);
    _slideCtrl.forward();
    _progressCtrl.forward();
  }

  Future<void> _animateOut() async {
    if (!mounted) return;
    _progressCtrl.stop();
    await _slideCtrl.reverse();
  }

  @override
  void dispose() {
    _slideCtrl.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _handleAction(VoidCallback? cb) {
    if (_actionFired) return;
    _actionFired = true;
    widget.onRequestClose();
    cb?.call();
  }

  void _onDragStart(DragStartDetails _) {
    // Pause the auto-dismiss timer once a drag begins — without this the
    // snackbar can disappear mid-swipe and leave a janky frame.
    _progressCtrl.stop();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    setState(() {
      // Allow horizontal movement freely; vertical only upward (dy ≤ 0)
      // since the snackbar lives at the top of the screen.
      final dx = _dragOffset.dx + details.delta.dx;
      final dy = (_dragOffset.dy + details.delta.dy).clamp(-200.0, 0.0);
      _dragOffset = Offset(dx, dy);
    });
  }

  void _onDragEnd(DragEndDetails details) {
    final v = details.velocity.pixelsPerSecond;
    final distanceMet =
        _dragOffset.dx.abs() >= _kSwipeDistanceThreshold ||
        _dragOffset.dy <= -_kSwipeDistanceThreshold;
    final velocityMet =
        v.dx.abs() >= _kSwipeVelocityThreshold ||
        v.dy <= -_kSwipeVelocityThreshold;

    if (distanceMet || velocityMet) {
      widget.onRequestClose();
      return;
    }

    // Not dismissed — settle the snackbar back to its resting position
    // and resume the auto-dismiss countdown.
    setState(() => _dragOffset = Offset.zero);
    _progressCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final barColor = widget.isError ? cs.error : cs.tertiary;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _slideAnim,
        builder: (context, child) {
          final t = _slideAnim.value;
          // Compose the entry-animation slide with the user's drag offset
          // and fade the snackbar as it travels off screen so the dismiss
          // reads as intentional.
          final entryOffset = Offset(0, (1 - t) * -80);
          final totalOffset = entryOffset + _dragOffset;
          final dragDistance = _dragOffset.distance;
          // Cap the fade at ~50% drag-progress; full fade kicks in only
          // when the user actually flings the snackbar away.
          final dragFade = (dragDistance / 200).clamp(0.0, 0.5);
          return Transform.translate(
            offset: totalOffset,
            child: Opacity(
              opacity: (t * (1 - dragFade)).clamp(0.0, 1.0),
              child: child,
            ),
          );
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onHorizontalDragStart: _onDragStart,
          onHorizontalDragUpdate: _onDragUpdate,
          onHorizontalDragEnd: _onDragEnd,
          onVerticalDragStart: _onDragStart,
          onVerticalDragUpdate: _onDragUpdate,
          onVerticalDragEnd: _onDragEnd,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(
                  color: widget.isError ? cs.error : cs.outline,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Left bar indicator
                  Container(
                    width: 4,
                    height: 48,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: barColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    widget.isError
                        ? Icons.error_outline_rounded
                        : Icons.check_circle_outline_rounded,
                    color: barColor,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.message,
                            style: TextStyle(color: cs.onSurface, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          AnimatedBuilder(
                            animation: _progressCtrl,
                            builder: (context, _) {
                              return LinearProgressIndicator(
                                value: 1.0 - _progressCtrl.value,
                                minHeight: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  cs.primary,
                                ),
                                backgroundColor: cs.outline,
                                borderRadius: BorderRadius.circular(1),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (widget.secondaryActionLabel != null)
                    TextButton(
                      onPressed: () => _handleAction(widget.onSecondaryAction),
                      child: Text(
                        widget.secondaryActionLabel!,
                        style: TextStyle(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if (widget.actionLabel != null)
                    TextButton(
                      onPressed: () => _handleAction(widget.onAction),
                      child: Text(
                        widget.actionLabel!,
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    color: cs.onSurfaceVariant,
                    onPressed: widget.onRequestClose,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
