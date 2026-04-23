import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar_community/isar.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../core/database/isar_service.dart';

import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../transactions/data/transaction.dart';
import '../../tags/data/tag.dart';
import '../../tags/data/transaction_tag.dart';
import '../../budgets/data/budget.dart';
import '../../ledger/data/ledger.dart';
import '../../loans/data/loan.dart';
import '../../investments/data/investment.dart';
import '../../transactions/data/transaction_suggestion.dart';

class CollectionMeta {
  final String name;
  final Future<int> Function(Isar) getCount;

  CollectionMeta(this.name, this.getCount);
}

class DbExplorerScreen extends ConsumerWidget {
  const DbExplorerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, title: 'DB Explorer'),
      body: Consumer(
        builder: (context, ref, _) {
          // If isarProvider is just a Provider<Isar>, we can read it directly.
          // Let's assume it's synchronous since we throw UnimplementedError in IsarService if not overridden
          // And main.dart usually overrides it with the opened instance.
          final isar = ref.read(isarProvider);
          
          final collections = [
            CollectionMeta('Transaction', (i) => i.collection<Transaction>().count()),
            CollectionMeta('Account', (i) => i.collection<Account>().count()),
            CollectionMeta('Category', (i) => i.collection<Category>().count()),
            CollectionMeta('CategoryGroup', (i) => i.collection<CategoryGroup>().count()),
            CollectionMeta('RecurringRule', (i) => i.collection<RecurringRule>().count()),
            CollectionMeta('Tag', (i) => i.collection<Tag>().count()),
            CollectionMeta('TransactionTag', (i) => i.collection<TransactionTag>().count()),
            CollectionMeta('Budget', (i) => i.collection<Budget>().count()),
            CollectionMeta('Ledger', (i) => i.collection<Ledger>().count()),
            CollectionMeta('Loan', (i) => i.collection<Loan>().count()),
            CollectionMeta('Investment', (i) => i.collection<Investment>().count()),
            CollectionMeta('TransactionSuggestion', (i) => i.collection<TransactionSuggestion>().count()),
          ];

          return ListView.separated(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            itemCount: collections.length,
            separatorBuilder: (context, index) => const SizedBox(height: KuberSpacing.sm),
            itemBuilder: (context, index) {
              final meta = collections[index];
              return _CollectionCard(meta: meta, isar: isar);
            },
          );
        },
      ),
    );
  }
}

class _CollectionCard extends StatefulWidget {
  final CollectionMeta meta;
  final Isar isar;

  const _CollectionCard({required this.meta, required this.isar});

  @override
  State<_CollectionCard> createState() => _CollectionCardState();
}

class _CollectionCardState extends State<_CollectionCard> {
  int? _count;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCount();
  }

  Future<void> _loadCount() async {
    try {
      final count = await widget.meta.getCount(widget.isar);
      if (mounted) {
        setState(() {
          _count = count;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        context.push('/more/dev-tools/db-explorer/${widget.meta.name}');
      },
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.table_rows_outlined, color: cs.primary, size: 20),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meta.name,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  if (_loading)
                    SizedBox(
                      height: 14,
                      width: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: cs.onSurfaceVariant),
                    )
                  else
                    Text(
                      '${_count ?? '?'} records',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
