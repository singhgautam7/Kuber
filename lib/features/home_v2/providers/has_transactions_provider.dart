
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../../transactions/data/transaction.dart';

/// Whether the install has any transaction, read with one `count()` in
/// `_bootstrap` (overridden in `main.dart`) so Home's first frame already
/// knows. True by default so tests and un-overridden scopes keep every
/// widget.
final hasTransactionsBootProvider = Provider<bool>((ref) => true);

/// Live "has any transaction" for the transaction gate
/// (specs/home-v3.3/plan.md §3): the boot value, then a `count()` after each
/// change to the transactions collection.
class HasTransactionsNotifier extends Notifier<bool> {
  @override
  bool build() {
    final isar = ref.watch(isarProvider);
    final sub = isar.transactions.watchLazy().listen((_) async {
      final has = await isar.transactions.count() > 0;
      if (has != state) state = has;
    });
    ref.onDispose(sub.cancel);
    return ref.read(hasTransactionsBootProvider);
  }
}

final hasTransactionsProvider = NotifierProvider<HasTransactionsNotifier, bool>(
  HasTransactionsNotifier.new,
);

/// Live transaction count, for the intro cards that start at 2 and 3
/// transactions. Only the v2 top slot listens; a `count()` per change.
final transactionCountProvider = StreamProvider<int>((ref) async* {
  final isar = ref.watch(isarProvider);
  yield await isar.transactions.count();
  await for (final _ in isar.transactions.watchLazy()) {
    yield await isar.transactions.count();
  }
});
