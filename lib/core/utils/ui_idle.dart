import 'dart:async';

import 'package:flutter/scheduler.dart';

/// Completes once no frame has been scheduled for [quiet] (animations and
/// skeletons have stopped), or after [max] at the latest. Startup work that
/// stalls the main thread (the background worker's engine start is ~35 ms on
/// the platform thread) waits for this so the stall never lands on a frame
/// (loan accuracy D2).
Future<void> whenUiIdle({
  Duration quiet = const Duration(milliseconds: 300),
  Duration max = const Duration(seconds: 4),
}) {
  final done = Completer<void>();
  final start = DateTime.now();
  var idleSince = DateTime.now();
  Timer.periodic(const Duration(milliseconds: 50), (t) {
    final s = SchedulerBinding.instance;
    final now = DateTime.now();
    if (s.hasScheduledFrame || s.transientCallbackCount > 0) idleSince = now;
    if (now.difference(idleSince) >= quiet || now.difference(start) >= max) {
      t.cancel();
      done.complete();
    }
  });
  return done.future;
}
