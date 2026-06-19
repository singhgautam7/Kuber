import 'dart:async';
import 'dart:isolate';

import '../engine/scan_progress.dart';
import '../engine/sender_ids.dart';
import '../engine/sms_parser.dart';

/// Drives a single inbox scan on a background worker isolate, streaming
/// [ScanProgress] and resolving with the parsed results (or null if cancelled).
///
/// The platform-channel read happens on the caller (root isolate); the heavy
/// regex parse loop runs in [_scanIsolateEntry] so the UI thread is never
/// blocked. Cancellation kills the worker immediately and discards partial
/// work (matching the "progress so far won't be saved" copy).
class SmsScanController {
  final _progress = StreamController<ScanProgress>.broadcast();
  final _completer = Completer<List<SmsParseResult>?>();

  Isolate? _isolate;
  ReceivePort? _port;
  bool _finished = false;

  Stream<ScanProgress> get progress => _progress.stream;

  /// Spawns the worker and returns the parsed results, or null if cancelled.
  Future<List<SmsParseResult>?> run(
    List<RawInboxSms> raw,
    ScanTrigger trigger,
  ) async {
    final port = ReceivePort();
    _port = port;
    _isolate = await Isolate.spawn(
      _scanIsolateEntry,
      _ScanParams(port.sendPort, raw, trigger),
    );
    port.listen((msg) {
      if (_finished) return;
      if (msg is ScanProgress) {
        if (!_progress.isClosed) _progress.add(msg);
      } else if (msg is _ScanDone) {
        if (!_progress.isClosed) _progress.add(msg.progress);
        _finish(msg.results);
      }
    });
    return _completer.future;
  }

  /// Cancels the scan: kills the worker, discards partial results.
  void cancel() => _finish(null);

  void _finish(List<SmsParseResult>? results) {
    if (_finished) return;
    _finished = true;
    _isolate?.kill(priority: Isolate.immediate);
    _isolate = null;
    _port?.close();
    _port = null;
    if (!_completer.isCompleted) _completer.complete(results);
    _progress.close();
  }
}

class _ScanParams {
  final SendPort sendPort;
  final List<RawInboxSms> raw;
  final ScanTrigger trigger;
  const _ScanParams(this.sendPort, this.raw, this.trigger);
}

class _ScanDone {
  final ScanProgress progress;
  final List<SmsParseResult> results;
  const _ScanDone(this.progress, this.results);
}

/// Worker isolate entry: parses [raw] in batches of 50, emitting progress after
/// each batch and a final [_ScanDone] when finished.
void _scanIsolateEntry(_ScanParams p) {
  const parser = SmsParser();
  final total = p.raw.length;
  final results = <SmsParseResult>[];
  var scanned = 0;
  var found = 0;

  for (final r in p.raw) {
    scanned++;
    if (r.body.isNotEmpty && isKnownBankSender(r.address)) {
      final res = parser.parse(
        r.body,
        r.address,
        DateTime.fromMillisecondsSinceEpoch(r.dateMillis),
      );
      if (res != null) {
        results.add(res);
        found++;
      }
    }
    if (scanned % 50 == 0) {
      p.sendPort.send(
        ScanProgress(
          totalMessages: total,
          scannedMessages: scanned,
          bankMessagesFound: found,
          isComplete: false,
          trigger: p.trigger,
        ),
      );
    }
  }

  p.sendPort.send(
    _ScanDone(
      ScanProgress(
        totalMessages: total,
        scannedMessages: scanned,
        bankMessagesFound: found,
        isComplete: true,
        trigger: p.trigger,
      ),
      results,
    ),
  );
}
