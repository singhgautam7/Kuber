import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/transaction_suggestion.dart';
import '../services/suggestion_service.dart';

export '../data/transaction_suggestion.dart';

final suggestionQueryProvider = StateProvider<String>((ref) => '');

final suggestionProvider = FutureProvider<List<TransactionSuggestion>>((ref) {
  final query = ref.watch(suggestionQueryProvider);
  if (query.isEmpty) return Future.value([]);
  return ref.watch(suggestionServiceProvider).search(query);
});
