import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:isar_community/isar.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
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
import '../../sms_import/data/sms_transaction.dart';
import '../../sms_import/data/sms_account_mapping.dart';
import '../../tools/saved/data/saved_calculation.dart';
import '../../tools/saved/data/calculator_recent_use.dart';
import '../../ask_kuber/data/ask_kuber_message.dart';
import '../../notes/data/kuber_note.dart';
import '../../reminders/data/reminder.dart';
import '../../kuber_cards/data/stored_card.dart';
import '../../kuber_cards/data/card_vault_meta.dart';
import '../../pro/data/user_entitlement.dart';
import '../../search/data/recent_search.dart';

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
      CollectionMeta(
        'SmsTransaction',
        (i) => i.collection<SmsTransaction>().count(),
      ),
      CollectionMeta(
        'SmsAccountMapping',
        (i) => i.collection<SmsAccountMapping>().count(),
      ),
      CollectionMeta(
        'SavedCalculation',
        (i) => i.collection<SavedCalculation>().count(),
      ),
      CollectionMeta(
        'CalculatorRecentUse',
        (i) => i.collection<CalculatorRecentUse>().count(),
      ),
      CollectionMeta(
        'AskKuberMessage',
        (i) => i.collection<AskKuberMessage>().count(),
      ),
      CollectionMeta('KuberNote', (i) => i.collection<KuberNote>().count()),
      CollectionMeta('Reminder', (i) => i.collection<Reminder>().count()),
      CollectionMeta('StoredCard', (i) => i.collection<StoredCard>().count()),
      CollectionMeta(
        'CardVaultMeta',
        (i) => i.collection<CardVaultMeta>().count(),
      ),
      CollectionMeta(
        'UserEntitlement',
        (i) => i.collection<UserEntitlement>().count(),
      ),
      CollectionMeta(
        'RecentSearch',
        (i) => i.collection<RecentSearch>().count(),
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
            padding: const EdgeInsets.fromLTRB(
              KuberSpace.screenMargin,
              0,
              KuberSpace.screenMargin,
              KuberSpace.xl,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: KuberSpace.sm),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lock_outline_rounded,
                          size: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Read-only · ${collections.length} collections',
                          style: Theme.of(context).textTheme.bodySmall!
                              .copyWith(color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  KuberGroup(
                    children: [
                      for (final meta in collections)
                        _CollectionCard(meta: meta, isar: isar),
                    ],
                  ),
                ],
              ),
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
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: () =>
          context.push('/more/dev-tools/db-explorer/${widget.meta.name}'),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
        child: Row(
          children: [
            Icon(
              Icons.table_rows_outlined,
              size: 20,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Text(
                widget.meta.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: monoFont(fontSize: 14, color: cs.onSurface),
              ),
            ),
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
                '${_count ?? '?'}',
                style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
              ),
            const SizedBox(width: KuberSpace.sm),
            const KuberChevron(),
          ],
        ),
      ),
    );
  }
}
