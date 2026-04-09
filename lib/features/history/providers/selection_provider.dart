import 'package:flutter_riverpod/flutter_riverpod.dart';

class TransactionSelectionNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() {
    return const <int>{};
  }

  void toggle(int id) {
    if (state.contains(id)) {
      state = {...state}..remove(id);
    } else {
      state = {...state}..add(id);
    }
  }

  void selectAll(List<int> ids) {
    state = {...state}..addAll(ids);
  }

  void clear() {
    if (state.isNotEmpty) {
      state = const <int>{};
    }
  }
}

final transactionSelectionProvider =
    NotifierProvider<TransactionSelectionNotifier, Set<int>>(
        TransactionSelectionNotifier.new);

final isSelectionModeProvider = Provider<bool>((ref) {
  return ref.watch(transactionSelectionProvider).isNotEmpty;
});
