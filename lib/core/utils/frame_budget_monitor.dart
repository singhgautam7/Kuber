import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Debug/profile-only guardrail that logs frames whose UI-thread build phase
/// blows the display's frame budget.
///
/// Why this exists: several home/analytics cards cost ~10-14ms to first-inflate,
/// and the screens use a deliberate per-frame "progressive reveal" to spread
/// that cost so no single frame drops (see `specs/performance.md`). The risk
/// with that mitigation is that it silently *absorbs* new slow widgets — someone
/// adds an expensive card, the reveal ramp just gets one frame longer, and
/// nobody notices the regression. This monitor un-mutes that signal: when a
/// build phase exceeds budget, it prints a greppable `KUBER_FRAME_BUDGET`
/// warning so the regression shows up during profiling instead of rotting in.
///
/// Important honesty about modes:
///  * **Release** — never attached. Zero overhead. `attach()` returns early.
///  * **Profile** — the real budget (1000 / refreshRate ms). This is the only
///    mode where frame timings are trustworthy; run `flutter run --profile`
///    before shipping and watch the console.
///  * **Debug** — timings are inflated 2-3x by the un-optimised VM, so we raise
///    the threshold to `budget * _kDebugSlack` and only flag genuinely
///    pathological builds. Treat debug numbers as a smoke alarm, not a ruler.
class FrameBudgetMonitor {
  FrameBudgetMonitor._();

  /// Debug builds run un-compiled, so a "normal" frame is already well over the
  /// real budget. Multiply the budget by this so only egregious debug-mode
  /// regressions fire, instead of flooding every frame.
  static const double _kDebugSlack = 4.0;

  /// Don't log more than once per this window — a heavy sequence (cold start,
  /// a fling) would otherwise spam hundreds of near-identical lines.
  static const Duration _kThrottle = Duration(milliseconds: 1000);

  static DateTime _lastLog = DateTime.fromMillisecondsSinceEpoch(0);

  /// Wire the monitor. Call once from `main()`, before `runApp`. No-op in
  /// release. Safe to call unconditionally — the mode check is internal.
  static void attach() {
    if (kReleaseMode) return;

    // Resolve the display refresh rate → per-frame budget in ms. Falls back to
    // 60Hz (16.7ms) if the platform doesn't report a sane value.
    final displays = WidgetsBinding.instance.platformDispatcher.displays;
    final hz = displays.isNotEmpty && displays.first.refreshRate > 30
        ? displays.first.refreshRate
        : 60.0;
    final budgetMs = 1000.0 / hz;
    final thresholdMs = budgetMs * (kDebugMode ? _kDebugSlack : 1.0);

    SchedulerBinding.instance.addTimingsCallback((timings) {
      for (final t in timings) {
        final buildMs = t.buildDuration.inMicroseconds / 1000.0;
        // Build phase is the part app code controls (widget build + layout).
        // Raster (GPU paint) is reported too, for context, but we gate on build.
        if (buildMs <= thresholdMs) continue;

        final now = DateTime.now();
        if (now.difference(_lastLog) < _kThrottle) continue;
        _lastLog = now;

        final rasterMs = t.rasterDuration.inMicroseconds / 1000.0;
        debugPrint(
          'KUBER_FRAME_BUDGET  build=${buildMs.toStringAsFixed(1)}ms '
          'raster=${rasterMs.toStringAsFixed(1)}ms  '
          '(budget ${budgetMs.toStringAsFixed(1)}ms @ ${hz.toStringAsFixed(0)}Hz'
          '${kDebugMode ? ', debug threshold ${thresholdMs.toStringAsFixed(0)}ms' : ''})'
          '  — a widget build overran budget; profile the current screen.',
        );
      }
    });
  }
}
