import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_shape_loader.dart';

// ---------------------------------------------------------------------------
// OverlayEntry-based snackbar.
//
// Using an OverlayEntry (instead of a Flushbar Route) means the snackbar
// never sits on any Navigator's stack, so the Android back button doesn't
// dismiss it. It stays put until the timer expires or the user taps close.
// ---------------------------------------------------------------------------

const Duration _kSnackDuration = Duration(seconds: 7);
// Upper bound on an exit (the real ones are 140 ms or less).
const Duration _kAnimDuration = Duration(milliseconds: 220);

OverlayEntry? _currentEntry;
_KuberSnackBarController? _currentController;
Timer? _currentTimer;

// The background-tasks progress snackbar (one at a time). While a normal
// snackbar is showing it is parked, and it comes back when that one leaves.
_ProgressSnack? _progress;
bool _progressShowing = false;

void _dismissCurrent({bool restoreProgress = true, bool replacing = false}) {
  _currentTimer?.cancel();
  _currentTimer = null;

  final controller = _currentController;
  final entry = _currentEntry;
  _currentController = null;
  _currentEntry = null;
  final wasProgress = _progressShowing;
  _progressShowing = false;

  if (controller != null && entry != null) {
    // Bounded: with the app in the background no frames run, so the slide
    // out may never finish and the entry would be left on screen for good.
    controller
        .animateOut(replacing: replacing)
        .timeout(_kAnimDuration * 2, onTimeout: () {})
        .then((_) {
      if (entry.mounted) entry.remove();
      if (restoreProgress && !wasProgress) _restoreProgress();
    });
  } else {
    entry?.remove();
    if (restoreProgress && !wasProgress) _restoreProgress();
  }
}

void _restoreProgress() {
  final p = _progress;
  if (p == null || _currentEntry != null) return;
  // The app was rebuilt meanwhile (restore, clear data): its overlay is gone.
  if (!p.overlay.mounted) {
    _progress = null;
    return;
  }
  _insert(
    p.overlay,
    (controller) => _KuberSnackBarWidget(
      controller: controller,
      message: '',
      isError: false,
      progress: p.state,
      onRequestClose: () {
        // Only reachable once swiping is allowed (backup, after 5 s).
        final cb = p.onSwiped;
        _progress = null;
        _dismissCurrent(restoreProgress: false);
        cb?.call();
      },
    ),
    progress: true,
  );
}

void _insert(
  OverlayState overlay,
  Widget Function(_KuberSnackBarController) build, {
  Duration? timer,
  bool progress = false,
}) {
  final controller = _KuberSnackBarController();
  final entry = OverlayEntry(builder: (_) => build(controller));
  _currentController = controller;
  _currentEntry = entry;
  _progressShowing = progress;
  overlay.insert(entry);
  if (timer != null) _currentTimer = Timer(timer, _dismissCurrent);
}

/// State of the progress snackbar: text, an optional second line, and
/// whether a swipe may dismiss it.
@immutable
class KuberProgressState {
  final String message;
  final String? detail;
  final bool dismissible;

  /// 0 to 1 when the share done is known (the ring fills), else spinning.
  final double? value;
  const KuberProgressState(
    this.message, {
    this.detail,
    this.dismissible = false,
    this.value,
  });
}

class _ProgressSnack {
  final OverlayState overlay;
  final ValueNotifier<KuberProgressState> state;
  final VoidCallback? onSwiped;
  _ProgressSnack(this.overlay, this.state, this.onSwiped);
}

/// The progress state of the standard snackbar, used for the background task
/// queue: a circular indicator instead of the timer bar, no timer, no swipe
/// until [KuberProgressState.dismissible]. One at a time; a user snackbar
/// shown meanwhile takes over and this one comes back after it.
class KuberProgressSnackBar {
  static bool get isActive => _progress != null;

  static void show(
    OverlayState overlay,
    KuberProgressState state, {
    VoidCallback? onSwiped,
  }) {
    if (_progress != null) {
      update(state);
      return;
    }
    _progress = _ProgressSnack(overlay, ValueNotifier(state), onSwiped);
    if (_currentEntry == null) _restoreProgress();
  }

  static void update(KuberProgressState state) =>
      _progress?.state.value = state;

  /// Turns the progress snackbar into the normal one (check, timer bar,
  /// swipe), or removes it when [message] is null.
  static void finish(
    BuildContext context,
    String? message, {
    bool isError = false,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final p = _progress;
    _progress = null;
    if (_progressShowing) _dismissCurrent(restoreProgress: false);
    if (message == null || message.isEmpty) return;
    if (p == null && !context.mounted) return;
    showKuberSnackBar(
      context,
      message,
      isError: isError,
      actionLabel: actionLabel,
      onAction: onAction,
      overlay: p?.overlay,
    );
  }

  static void hide() {
    _progress = null;
    if (_progressShowing) _dismissCurrent(restoreProgress: false);
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
  OverlayState? overlay,
}) {
  // Clear any currently showing snackbar first (a progress snackbar is
  // parked and comes back when this one leaves).
  _dismissCurrent(restoreProgress: false, replacing: true);

  // Callers that only hold a root-navigator context (e.g. a global service)
  // can pass [overlay] directly, because `Overlay.of` cannot resolve an
  // overlay from the Navigator's own context — the overlay is its descendant,
  // not its ancestor.
  final resolvedOverlay = overlay ??
      (context is StatefulElement && context.state is NavigatorState
          ? (context.state as NavigatorState).overlay
          : null) ??
      Overlay.of(context, rootOverlay: true);
  _insert(
    resolvedOverlay,
    (controller) => _KuberSnackBarWidget(
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
    timer: duration ?? _kSnackDuration,
  );
}

// ---------------------------------------------------------------------------
// Controller — bridges the static dismiss logic with the widget's state.
// ---------------------------------------------------------------------------

class _KuberSnackBarController {
  _KuberSnackBarWidgetState? _state;

  void _attach(_KuberSnackBarWidgetState state) => _state = state;

  Future<void> animateOut({bool replacing = false}) async {
    final state = _state;
    if (state == null) return;
    await state._animateOut(replacing: replacing);
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

  /// Non-null: the progress state (see [KuberProgressSnackBar]).
  final ValueListenable<KuberProgressState>? progress;

  const _KuberSnackBarWidget({
    this.progress,
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
  // Enter / exit position: 0 hidden, 1 shown (unbounded: the spring may pass 1).
  late final AnimationController _pos =
      AnimationController.unbounded(vsync: this);
  late final AnimationController _fade = AnimationController(vsync: this);
  // The finger's offset (dx > 0 = right, dy < 0 = up), springs back on release.
  late final AnimationController _dx =
      AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _dy =
      AnimationController.unbounded(vsync: this, value: 0);
  late final AnimationController _progressCtrl;
  bool _actionFired = false;
  bool _started = false;
  bool _crossed = false;
  MotionLevel _level = MotionLevel.expressive;

  // Past this share of the snackbar's own size a release dismisses.
  static const double _kSwipeShare = 0.4;
  // Above this fling speed (dp/s) a release dismisses whatever the distance.
  static const double _kSwipeVelocityThreshold = 800.0;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: widget.duration ?? _kSnackDuration,
    );
    widget.controller._attach(this);
    if (widget.progress == null) _progressCtrl.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _level = KuberMotion.levelOf(context);
    if (_started) return;
    _started = true;
    // Enter: y -100 % -> 0 on springDefault + fade fx.fast. Subtle:
    // springSubtle over 4 dp. Off: a 90 ms fade.
    _fade.animateTo(1,
        duration: _level == MotionLevel.off
            ? KuberMotion.fxInstant
            : KuberMotion.fxFast);
    if (_level == MotionLevel.off) {
      _pos.value = 1;
    } else {
      _pos.springTo(1, KuberMotion.spatial(_level, KuberMotion.springDefault));
    }
  }

  bool get _locked =>
      widget.progress != null && !widget.progress!.value.dismissible;

  /// Leaves: up + fade over snackExit (140 ms); a swipe leaves the way it
  /// was thrown; a message being replaced only fades (the new one fades in).
  Future<void> _animateOut({bool replacing = false}) async {
    if (!mounted) return;
    _progressCtrl.stop();
    final off = _level == MotionLevel.off;
    final d = off ? KuberMotion.fxInstant : KuberMotion.snackExit;
    final fade = _fade.animateTo(0, duration: d, curve: Curves.easeIn);
    if (off || replacing) return fade;
    final w = context.size?.width ?? 320;
    final v = _lastFling;
    if (_leaveHorizontal && v.dx != 0) {
      final target = (v.dx > 0 ? 1 : -1) * (w + 40.0);
      final ms = ((target - _dx.value).abs() / v.dx.abs() * 1000)
          .clamp(80, 140)
          .round();
      await Future.wait([
        _dx.animateTo(target, duration: Duration(milliseconds: ms), curve: Curves.easeIn),
        fade,
      ]);
    } else {
      await Future.wait([
        _pos.animateTo(0, duration: d, curve: Curves.easeIn),
        fade,
      ]);
    }
  }

  Offset _lastFling = Offset.zero;
  bool _leaveHorizontal = false;

  @override
  void dispose() {
    _pos.dispose();
    _fade.dispose();
    _dx.dispose();
    _dy.dispose();
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
    if (_locked) return;
    // Pause the auto-dismiss timer once a drag begins — without this the
    // snackbar can disappear mid-swipe and leave a janky frame.
    _progressCtrl.stop();
    _dx.stop();
    _dy.stop();
  }

  double _share() {
    final size = context.size;
    if (size == null) return 0;
    return math.max(_dx.value.abs() / size.width, -_dy.value / size.height);
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_locked) return;
    // Horizontal moves freely; vertical only upward (dy <= 0) since the
    // snackbar lives at the top of the screen.
    _dx.value += details.delta.dx;
    _dy.value = (_dy.value + details.delta.dy).clamp(-200.0, 0.0);
    final past = _share() >= _kSwipeShare;
    if (past && !_crossed) KuberHaptics.threshold();
    _crossed = past;
  }

  void _onDragEnd(DragEndDetails details) {
    if (_locked) return;
    final v = details.velocity.pixelsPerSecond;
    if (_share() >= _kSwipeShare ||
        v.dx.abs() >= _kSwipeVelocityThreshold ||
        v.dy <= -_kSwipeVelocityThreshold) {
      _lastFling = v;
      _leaveHorizontal = _dx.value.abs() >= -_dy.value;
      widget.onRequestClose();
      return;
    }

    // Not dismissed: back on springFast, and the countdown resumes.
    _crossed = false;
    final spring = KuberMotion.spatial(_level, KuberMotion.springFast);
    if (_level == MotionLevel.off) {
      _dx.value = 0;
      _dy.value = 0;
    } else {
      _dx.springTo(0, spring);
      _dy.springTo(0, spring);
    }
    if (widget.progress == null) _progressCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Follows the app theme (round 3): success sits on surfaceContainerHigh
    // with a primary accent, error on errorContainer. A 1dp outlineVariant
    // edge lifts it off the page (no shadows).
    final bg = widget.isError ? cs.errorContainer : cs.surfaceContainerHigh;
    final fg = widget.isError ? cs.onErrorContainer : cs.onSurface;
    final accent = widget.isError ? cs.error : cs.primary;
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: Listenable.merge([_pos, _fade, _dx, _dy]),
        builder: (context, child) {
          // Compose the entry slide with the finger's offset, and fade as it
          // travels so a dismiss reads as intentional.
          final p = _pos.value;
          final drag = Offset(_dx.value, _dy.value);
          // Cap the drag fade at ~50 %; the full fade comes from the exit.
          final dragFade = (drag.distance / 200).clamp(0.0, 0.5);
          Widget w = child!;
          w = _level == MotionLevel.subtle
              ? Transform.translate(offset: Offset(0, -4 * (1 - p)), child: w)
              : FractionalTranslation(
                  translation: Offset(0, _level == MotionLevel.off ? 0 : p - 1),
                  child: w);
          return Opacity(
            opacity: (_fade.value * (1 - dragFade)).clamp(0.0, 1.0),
            child: Transform.translate(offset: drag, child: w),
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
          child: widget.progress == null
              ? _body(context, widget.message, null, bg, fg, accent)
              : ValueListenableBuilder<KuberProgressState>(
                  valueListenable: widget.progress!,
                  builder: (context, p, _) =>
                      _body(context, p.message, p, bg, fg, accent),
                ),
        ),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    String message,
    KuberProgressState? p,
    Color bg,
    Color fg,
    Color accent,
  ) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.largeR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
              child: Row(
                children: [
                  if (p != null)
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: p.value == null
                          ? KuberShapeLoader(size: 20, color: accent)
                          : CircularProgressIndicator(
                              value: p.value,
                              strokeWidth: 2.5,
                              color: accent,
                              backgroundColor: fg.withValues(alpha: 0.16),
                            ),
                    )
                  else
                    Icon(
                      widget.isError
                          ? Icons.error_rounded
                          : Icons.check_circle_rounded,
                      color: accent,
                      size: 20,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            message,
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: fg,
                            ),
                          ),
                          if (p?.detail != null)
                            Text(
                              p!.detail!,
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (widget.secondaryActionLabel != null)
                    TextButton(
                      onPressed: () => _handleAction(widget.onSecondaryAction),
                      style: TextButton.styleFrom(
                        foregroundColor: fg.withValues(alpha: 0.8),
                        minimumSize: const Size(48, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(widget.secondaryActionLabel!),
                    ),
                  if (widget.actionLabel != null)
                    TextButton(
                      onPressed: () => _handleAction(widget.onAction),
                      style: TextButton.styleFrom(
                        foregroundColor: accent,
                        minimumSize: const Size(48, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      child: Text(widget.actionLabel!),
                    ),
                  if (p == null || p.dismissible)
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        color: fg,
                        onPressed: widget.onRequestClose,
                      ),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          ),
          if (p == null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: AnimatedBuilder(
                animation: _progressCtrl,
                builder: (context, _) {
                  return SizedBox(
                    height: 4,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _TimerPainter(
                        value: 1.0 - _progressCtrl.value,
                        indicator: accent,
                        track: fg.withValues(alpha: 0.16),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// The snackbar timer: flat 4dp indicator and track with a 4dp gap and round
/// ends (M3 2024 linear, without the stop dot).
class _TimerPainter extends CustomPainter {
  final double value;
  final Color indicator;
  final Color track;

  _TimerPainter({
    required this.value,
    required this.indicator,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final r = Radius.circular(h / 2);
    final v = value.clamp(0.0, 1.0);
    final indW = v * size.width - (v < 1 ? 2 : 0);
    if (indW > 0) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, indW, h), r),
        Paint()..color = indicator,
      );
    }
    final trackX = indW > 0 ? indW + 4 : 0.0;
    if (trackX < size.width) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(trackX, 0, size.width - trackX, h),
          r,
        ),
        Paint()..color = track,
      );
    }
  }

  @override
  bool shouldRepaint(_TimerPainter o) =>
      o.value != value || o.indicator != indicator || o.track != track;
}
