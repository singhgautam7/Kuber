// Running Advanced History jobs off the UI isolate.
//
// [runAh] sends a job to ONE long-lived worker isolate that keeps its own
// Isar instance open and caches the lookups (categories, accounts, tags, tag
// links) until a change arrives, so the small frequent jobs (Filter page
// live count, chart preview, suggestions) skip the isolate spawn, the Isar
// open and the lookup load. The worker is shut down when the last dashboards
// page closes ([AhWorker.shutdown]).

import 'dart:async';
import 'dart:isolate';

import 'package:flutter/foundation.dart'
    show debugPrint, kIsWeb, kReleaseMode, visibleForTesting;
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart' show kIsarSchemas;
import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../tags/data/tag.dart';
import '../../tags/data/transaction_tag.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/data/transaction_repository.dart';
import 'ah_engine.dart';

/// How many times each job function ran through [runAh] (tests assert on it).
@visibleForTesting
final Map<Object, int> ahJobRuns = {};

/// Runs [fn] with [isar] on the AH worker isolate (it reopens the app's
/// database there), or inline when the database isn't the app's default one
/// (tests), on web, or the worker fails. [fn] must be a top-level function
/// and [params] plain data.
Future<R> runAh<P, R>(
    Isar isar, P params, Future<R> Function(Isar, P) fn) async {
  ahJobRuns[fn] = (ahJobRuns[fn] ?? 0) + 1;
  final sw = kReleaseMode ? null : (Stopwatch()..start());
  try {
    final dir = isar.directory;
    if (!kIsWeb &&
        isar.name == Isar.defaultName &&
        dir != null &&
        // ignore: invalid_use_of_visible_for_testing_member
        TransactionRepository.offloadGetAll) {
      try {
        final w = await AhWorker.of(isar, dir);
        return await w.run<R>(fn, params);
      } catch (e) {
        debugPrint('Kuber: Advanced History job on the worker isolate failed, running here: $e');
      }
    }
    return await fn(isar, params);
  } finally {
    if (sw != null) debugPrint('KUBER_AH ${fn.runtimeType} ${sw.elapsedMilliseconds}ms');
  }
}

class _Req {
  _Req(this.id, this.fn, this.params, this.reply);
  final int id;
  final Function fn;
  final Object? params;
  final SendPort reply;
}

class _Init {
  _Init(this.dir, this.reply, this.testCore);
  final String dir;
  final SendPort reply;
  final bool testCore;
}

class AhWorker {
  AhWorker._(this._send, this._recv, this._watchers);

  static Future<AhWorker>? _starting;
  static AhWorker? _current;

  /// Unit tests only: the worker isolate has to load the Isar core itself.
  @visibleForTesting
  static bool testCore = false;

  final SendPort _send;
  final ReceivePort _recv;
  final List<StreamSubscription<void>> _watchers;
  final _pending = <int, Completer<Object?>>{};
  int _next = 0;
  bool _dead = false;

  static Future<AhWorker> of(Isar isar, String dir) =>
      _starting ??= _start(isar, dir).catchError((Object e) {
        _starting = null;
        throw e;
      });

  static Future<AhWorker> _start(Isar isar, String dir) async {
    final recv = ReceivePort();
    final ready = Completer<SendPort>();
    late final AhWorker w;
    recv.listen((m) {
      if (m is SendPort) {
        ready.complete(m);
      } else if (m == null) {
        w._died(); // onExit
      }
    });
    await Isolate.spawn(_main, _Init(dir, recv.sendPort, testCore),
        onExit: recv.sendPort, debugName: 'ah_worker');
    final send = await ready.future.timeout(const Duration(seconds: 20));
    // Anything the lookups read: the worker drops its cache on a change.
    void inval(void _) => send.send('invalidate');
    final watchers = [
      isar.transactions.watchLazy().listen(inval),
      isar.transactionTags.watchLazy().listen(inval),
      isar.categorys.watchLazy().listen(inval),
      isar.categoryGroups.watchLazy().listen(inval),
      isar.accounts.watchLazy().listen(inval),
      isar.tags.watchLazy().listen(inval),
    ];
    w = AhWorker._(send, recv, watchers);
    _current = w;
    return w;
  }

  Future<R> run<R>(Function fn, Object? params) async {
    if (_dead) throw StateError('worker stopped');
    final id = _next++;
    final c = Completer<Object?>();
    _pending[id] = c;
    final reply = ReceivePort(); // one-shot
    reply.listen((m) {
      reply.close();
      final list = m as List;
      final done = _pending.remove(id);
      if (list[0] == true) {
        done?.complete(list[1]);
      } else {
        done?.completeError(StateError('${list[1]}'));
      }
    });
    _send.send(_Req(id, fn, params, reply.sendPort));
    return (await c.future) as R;
  }

  void _died() {
    if (_dead) return;
    _dead = true;
    if (identical(_current, this)) {
      _current = null;
      _starting = null;
    }
    for (final s in _watchers) {
      s.cancel();
    }
    _recv.close();
    for (final c in _pending.values) {
      c.completeError(StateError('worker stopped'));
    }
    _pending.clear();
  }

  /// Stops the worker (last dashboards page closed). A later job starts a
  /// new one.
  static void shutdown() {
    final w = _current;
    _starting = null;
    _current = null;
    if (w == null) return;
    w._send.send('close');
    w._died();
  }

  static Future<void> _main(_Init init) async {
    if (init.testCore) await Isar.initializeIsarCore(download: true);
    final recv = ReceivePort();
    final isar =
        await Isar.open(kIsarSchemas, directory: init.dir, inspector: false);
    AhLookups.cacheEnabled = true;
    init.reply.send(recv.sendPort);
    await for (final m in recv) {
      if (m == 'invalidate') {
        AhLookups.invalidate();
      } else if (m == 'close') {
        recv.close();
        await isar.close();
        Isolate.exit();
      } else if (m is _Req) {
        unawaited(() async {
          try {
            final r = await Function.apply(m.fn, [isar, m.params]);
            m.reply.send([true, r]);
          } catch (e) {
            m.reply.send([false, '$e']);
          }
        }());
      }
    }
  }
}
