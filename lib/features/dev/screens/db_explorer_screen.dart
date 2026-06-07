import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
import '../../tools/bill_splitter/data/person.dart';
import '../../tools/bill_splitter/data/bill.dart';
import '../../notifications/data/app_notification.dart';
import '../../widget_editor/data/widget_preference.dart';
import '../../stories/data/insight_story.dart';
import '../../backups/data/backup_config.dart';

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
    final isar = ref.read(isarProvider);

    final collections = [
      CollectionMeta('Transaction', (i) => i.collection<Transaction>().count()),
      CollectionMeta('Account', (i) => i.collection<Account>().count()),
      CollectionMeta('Category', (i) => i.collection<Category>().count()),
      CollectionMeta(
        'CategoryGroup',
        (i) => i.collection<CategoryGroup>().count(),
      ),
      CollectionMeta(
        'RecurringRule',
        (i) => i.collection<RecurringRule>().count(),
      ),
      CollectionMeta('Tag', (i) => i.collection<Tag>().count()),
      CollectionMeta(
        'TransactionTag',
        (i) => i.collection<TransactionTag>().count(),
      ),
      CollectionMeta('Budget', (i) => i.collection<Budget>().count()),
      CollectionMeta('Ledger', (i) => i.collection<Ledger>().count()),
      CollectionMeta('Loan', (i) => i.collection<Loan>().count()),
      CollectionMeta('Investment', (i) => i.collection<Investment>().count()),
      CollectionMeta(
        'TransactionSuggestion',
        (i) => i.collection<TransactionSuggestion>().count(),
      ),
      CollectionMeta('Person', (i) => i.collection<Person>().count()),
      CollectionMeta('Bill', (i) => i.collection<Bill>().count()),
      CollectionMeta(
        'AppNotification',
        (i) => i.collection<AppNotification>().count(),
      ),
      CollectionMeta(
        'WidgetPreference',
        (i) => i.collection<WidgetPreference>().count(),
      ),
      CollectionMeta(
        'InsightStory',
        (i) => i.collection<InsightStory>().count(),
      ),
      CollectionMeta(
        'BackupConfig',
        (i) => i.collection<BackupConfig>().count(),
      ),
    ]..sort((a, b) => a.name.compareTo(b.name));

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, title: 'DB Explorer'),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(KuberSpacing.lg),
            sliver: SliverList.separated(
              itemCount: collections.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: KuberSpacing.sm),
              itemBuilder: (context, index) {
                return _CollectionCard(meta: collections[index], isar: isar);
              },
            ),
          ),
        ],
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
              child: Icon(
                Icons.table_rows_outlined,
                color: cs.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.meta.name,
                    style: localeFont(
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
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: cs.onSurfaceVariant,
                      ),
                    )
                  else
                    Text(
                      '${_count ?? '?'} records',
                      style: localeFont(
                        fontSize: 13,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}