import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/transaction_detail_sheet.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/info_provider.dart';
import '../data/recurring_repository.dart';
import '../data/recurring_rule.dart';
import '../providers/recurring_provider.dart';
import '../widgets/recurring_detail_sheet.dart';
import '../widgets/recurring_widgets.dart';

final recurringMonthlyCostProvider =
    FutureProvider<
      ({double total, int activeCount, List<UpcomingCharge> upcoming})
    >((ref) async {
      final rules = await ref.watch(recurringListProvider.future);
      final active = rules
          .where((r) => !r.isPaused && !RecurringRepository.isExpired(r))
          .toList();
      double monthlyEquivalent(RecurringRule rule) {
        return switch (rule.frequency) {
          'daily' => rule.amount * 30,
          'weekly' => rule.amount * 4.33,
          'biweekly' => rule.amount * 2.17,
          'quarterly' => rule.amount / 3,
          'yearly' => rule.amount / 12,
          'custom' =>
            rule.customDays == null || rule.customDays == 0
                ? rule.amount
                : rule.amount * (30 / rule.customDays!),
          _ => rule.amount,
        };
      }

      final upcoming =
          active
              .map(
                (r) => UpcomingCharge(
                  name: r.name,
                  amount: r.amount,
                  on: r.nextDueAt,
                ),
              )
              .toList()
            ..sort((a, b) => a.on.compareTo(b.on));

      return (
        total: active.fold<double>(0, (sum, r) => sum + monthlyEquivalent(r)),
        activeCount: active.length,
        upcoming: upcoming.take(3).toList(),
      );
    });

class RecurringScreen extends ConsumerWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final rulesAsync = ref.watch(recurringListProvider);
    final categoryMapAsync = ref.watch(categoryMapProvider);
    final recentlyProcessedAsync = ref.watch(recentlyProcessedProvider);
    final accountsAsync = ref.watch(accountListProvider);

    ref.listen<AsyncValue<bool>>(
      infoSeenProvider(PrefsKeys.seenInfoRecurring),
      (prev, next) {
        if (next.hasValue && next.value == false) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!context.mounted) return;
            KuberInfoBottomSheet.show(context, InfoConstants.recurring);
            ref
                .read(infoSeenProvider(PrefsKeys.seenInfoRecurring).notifier)
                .markSeen();
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: rulesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (rules) {
          final catMap = categoryMapAsync.valueOrNull ?? {};
          final accounts = accountsAsync.valueOrNull ?? [];

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  showHome: true,
                  title: '',
                  infoConfig: InfoConstants.recurring,
                ),
              ),
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Recurring\nTransactions',
                  description: '',
                  actionTooltip: 'Add Recurring',
                  onAction: () => context.push('/recurring/add'),
                ),
              ),
              if (rules.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.repeat_rounded,
                    title: 'No recurring transactions',
                    description: 'Automate subscriptions and repeated payments',
                    actionLabel: 'Add Recurring',
                    onAction: () => context.push('/recurring/add'),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    0,
                    KuberSpacing.lg,
                    navBarBottomPadding(context) + KuberSpacing.lg,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      ref
                          .watch(recurringMonthlyCostProvider)
                          .when(
                            data: (summary) => RecurringHero(
                              monthlyCost: summary.total,
                              activeCount: summary.activeCount,
                              upcoming: summary.upcoming,
                            ),
                            loading: () => const SizedBox(
                              height: 180,
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, __) => const SizedBox.shrink(),
                          ),
                      const SizedBox(height: KuberSpacing.lg),
                      const _SectionLabel('RULES'),
                      const SizedBox(height: KuberSpacing.sm),
                      ...rules.map((rule) {
                        final catId = int.tryParse(rule.categoryId);
                        final cat = catId != null ? catMap[catId] : null;
                        final accountName = accounts
                            .where((a) => a.id.toString() == rule.accountId)
                            .firstOrNull
                            ?.name;
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: KuberSpacing.sm,
                          ),
                          child: RecurringRuleCard(
                            ruleName: rule.name,
                            frequencyLabel: _frequencyLabel(rule.frequency),
                            accountName: accountName,
                            icon: cat != null
                                ? IconMapper.fromString(cat.icon)
                                : Icons.category_outlined,
                            iconColor: cat != null
                                ? harmonizeCategory(
                                    context,
                                    Color(cat.colorValue),
                                  )
                                : cs.primary,
                            amount: rule.type == 'expense'
                                ? -rule.amount
                                : rule.amount,
                            nextChargeOn: rule.nextDueAt,
                            onTap: () =>
                                showRecurringDetailSheet(context, ref, rule),
                          ),
                        );
                      }),
                      recentlyProcessedAsync.when(
                        data: (transactions) {
                          if (transactions.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: KuberSpacing.lg),
                              const _SectionLabel('RECENTLY PROCESSED'),
                              const SizedBox(height: KuberSpacing.sm),
                              ...transactions.map((t) {
                                final catId = int.tryParse(t.categoryId);
                                final cat = catId != null
                                    ? catMap[catId]
                                    : null;
                                final accountName = accounts
                                    .where(
                                      (a) => a.id.toString() == t.accountId,
                                    )
                                    .firstOrNull
                                    ?.name;
                                return RecurringProcessedRow(
                                  ruleName: t.name,
                                  accountName: accountName,
                                  processedAt: t.createdAt,
                                  icon: cat != null
                                      ? IconMapper.fromString(cat.icon)
                                      : Icons.category_outlined,
                                  iconColor: cat != null
                                      ? harmonizeCategory(
                                          context,
                                          Color(cat.colorValue),
                                        )
                                      : cs.primary,
                                  amount: t.type == 'expense'
                                      ? -t.amount
                                      : t.amount,
                                  onTap: () => showTransactionDetailSheet(
                                    context,
                                    ref,
                                    t,
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),
                    ]),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  static String _frequencyLabel(String frequency) {
    return switch (frequency) {
      'daily' => 'DAILY',
      'weekly' => 'WEEKLY',
      'biweekly' => 'BIWEEKLY',
      'quarterly' => 'QUARTERLY',
      'yearly' => 'YEARLY',
      'custom' => 'CUSTOM',
      _ => 'MONTHLY',
    };
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      label,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        letterSpacing: 1.0,
      ),
    );
  }
}
