import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transaction.dart';
import 'transaction_provider.dart';

final suggestionQueryProvider = StateProvider<String>((ref) => '');

final suggestionProvider = FutureProvider<List<Transaction>>((ref) {
  final query = ref.watch(suggestionQueryProvider);
  if (query.isEmpty) return Future.value([]);
  return ref.watch(transactionRepositoryProvider).getSuggestions(query);
});
