import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:kuber/features/history/providers/history_view_provider.dart';
import 'package:kuber/features/tags/providers/tag_providers.dart';
import 'package:kuber/features/tags/data/tag.dart';
import 'package:kuber/features/transactions/providers/transaction_provider.dart';

import '../../helpers/mock_repositories.dart';
import '../../helpers/test_factories.dart';

/// Locks the memoized History derivation (filter → group → totals) that the
/// screen now reads from, so the refactor can't silently change behaviour.
void main() {
  late MockTransactionRepository txnRepo;

  ProviderContainer makeContainer() {
    final c = ProviderContainer(
      overrides: [
        transactionRepositoryProvider.overrideWithValue(txnRepo),
        transactionTagsMapProvider.overrideWith(
          (ref) => Stream.value(<int, Set<int>>{}),
        ),
        tagListProvider.overrideWith((ref) => Stream.value(<Tag>[])),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  setUp(() => txnRepo = MockTransactionRepository());

  test('groups by day and totals income/expense', () async {
    when(() => txnRepo.getAll()).thenAnswer(
      (_) async => [
        makeTransaction(
          type: 'expense',
          amount: 100,
          categoryId: '1',
          createdAt: DateTime(2026, 3, 1, 9),
        ),
        makeTransaction(
          type: 'income',
          amount: 50,
          categoryId: '3',
          createdAt: DateTime(2026, 3, 1, 18),
        ),
        makeTransaction(
          type: 'expense',
          amount: 200,
          categoryId: '2',
          createdAt: DateTime(2026, 3, 2, 12),
        ),
      ],
    );

    final view = await makeContainer().read(historyViewProvider.future);

    expect(view.filteredCount, 3);
    expect(view.totalExpense, 300);
    expect(view.totalIncome, 50);
    expect(view.totalNet, -250);
    expect(view.groups.length, 2, reason: 'two distinct days');
    expect(view.sourceEmpty, isFalse);
  });

  test('reports sourceEmpty when there are no transactions', () async {
    when(() => txnRepo.getAll()).thenAnswer((_) async => []);

    final view = await makeContainer().read(historyViewProvider.future);

    expect(view.filteredCount, 0);
    expect(view.groups, isEmpty);
    expect(view.sourceEmpty, isTrue);
  });
}
