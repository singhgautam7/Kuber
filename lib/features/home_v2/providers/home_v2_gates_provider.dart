import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../../main.dart' show onOpenBatchReadyProvider;
import '../../sms_import/providers/sms_import_provider.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../data/home_v2_state.dart';
import '../data/home_v2_widgets.dart' show kHomeV2Order;
import '../services/home_v2_gates.dart';
import 'home_v2_provider.dart';

/// Turns Data-gated widgets on when their trigger becomes true
/// (widget-inventory.md › State model). Read once by the dashboard.
///
/// Cost model: nothing at all for v1 or once no widget is waiting. For v2
/// with waiting widgets: one evaluation after the on-open batch is ready
/// (never during Home's first frames), then one per burst of Isar changes
/// (debounced), each limited to the waiting ids.
final homeV2GatesProvider = Provider<HomeV2GatesController>((ref) {
  final c = HomeV2GatesController(ref);
  ref.onDispose(c.dispose);
  c.start();
  return c;
});

class HomeV2GatesController {
  final Ref ref;
  HomeV2GatesController(this.ref);

  final _subs = <StreamSubscription<void>>[];
  ProviderSubscription<bool>? _readySub;
  Timer? _debounce;
  bool _running = false;

  Set<String> get _pending => {
    for (final e in ref.read(homeV2Provider).widgets.entries)
      if (e.value.vis == WidgetVis.auto) e.key,
  };

  void start() {
    final s = ref.read(homeV2Provider);
    if (!s.isV2 || _pending.isEmpty) return;
    if (ref.read(onOpenBatchReadyProvider)) {
      _begin();
    } else {
      _readySub = ref.listen<bool>(onOpenBatchReadyProvider, (_, ready) {
        if (!ready) return;
        _readySub?.close();
        _readySub = null;
        _begin();
      });
    }
  }

  void _begin() {
    final isar = ref.read(isarProvider);
    for (final c in HomeV2Gates.watched(isar)) {
      _subs.add(c.watchLazy().listen((_) => _schedule()));
    }
    unawaited(_evaluate());
  }

  void _schedule() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _evaluate);
  }

  /// Re-checks now (SMS scan finished, Dev tools reset).
  void poke() {
    if (_subs.isEmpty) {
      start();
    } else {
      _schedule();
    }
  }

  Future<void> _evaluate() async {
    if (_running) return;
    final pending = _pending;
    if (!ref.read(homeV2Provider).isV2 || pending.isEmpty) {
      _detach();
      return;
    }
    _running = true;
    try {
      final sw = Stopwatch()..start();
      final open = await HomeV2Gates.evaluate(
        ref.read(isarProvider),
        pending,
        seededAccountIds: ref.read(homeV2Provider).seededAccountIds,
        smsPermission: () =>
            ref.read(smsInboxServiceProvider).checkPermission(),
      );
      if (kDebugMode || kProfileMode) {
        debugPrint(
          'Kuber homeV2: gates ${pending.length} in ${sw.elapsedMilliseconds} ms',
        );
      }
      if (open.isNotEmpty) await unlock(open);
      if (_pending.isEmpty) _detach();
    } finally {
      _running = false;
    }
  }

  /// Turns [ids] on (sticky): state `on` + `unlockedAt`, Home row enabled
  /// and inserted after the nearest earlier catalog neighbour that is on
  /// Home (else first). No "New on your Home" label (dropped in review).
  Future<void> unlock(Set<String> ids) async {
    final now = DateTime.now();
    final widgets = Map.of(ref.read(homeV2Provider).widgets);
    for (final id in ids) {
      widgets[id] = (widgets[id] ?? const HomeV2WidgetState(vis: WidgetVis.auto))
          .copyWith(vis: WidgetVis.on, unlockedAt: now);
    }
    await ref.read(homeV2Provider.notifier).update(
      (s) => s.copyWith(widgets: widgets),
    );

    final repo = ref.read(widgetPreferenceRepositoryProvider);
    final configs = await repo.readForScope(WidgetEditorScope.home);
    await repo.save(WidgetEditorScope.home, insertUnlocked(configs, ids));
    ref.invalidate(homeWidgetsProvider);
  }

  void _detach() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    _debounce?.cancel();
  }

  void dispose() {
    _detach();
    _readySub?.close();
  }
}

/// Enables [ids] and moves each right after its nearest earlier catalog
/// neighbour that is on Home, or first if there is none
/// (widget-inventory.md › State model › Insert position).
List<HomeWidgetConfig> insertUnlocked(
  List<HomeWidgetConfig> configs,
  Set<String> ids,
) {
  final list = List.of(configs);
  final catalogIds = kHomeV2Order;
  for (final id in catalogIds.where(ids.contains)) {
    final at = list.indexWhere((c) => c.id == id);
    if (at < 0) continue;
    final item = list.removeAt(at).copyWith(enabled: true);
    final catalogIndex = catalogIds.indexOf(id);
    var insertAt = 0;
    for (var k = catalogIndex - 1; k >= 0; k--) {
      final i = list.indexWhere((c) => c.id == catalogIds[k] && c.enabled);
      if (i >= 0) {
        insertAt = i + 1;
        break;
      }
    }
    list.insert(insertAt, item);
  }
  return list;
}
