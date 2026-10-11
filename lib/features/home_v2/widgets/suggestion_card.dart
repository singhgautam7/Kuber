import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../ledger/data/ledger_prefill.dart';
import '../../settings/providers/settings_provider.dart';
import '../engine/suggestion_engine.dart';
import '../providers/home_suggestion_provider.dart';

/// Copy and icon for one suggestion (copy.md › Suggestions).
class _SgCopy {
  final IconData icon;
  final String title;
  final String body;
  final String action;
  final String? done;
  const _SgCopy(this.icon, this.title, this.body, this.action, [this.done]);
}

_SgCopy _copyFor(BuildContext context, WidgetRef ref, SgCandidate c) {
  final l = context.l10n;
  final fmt = ref.read(formatterProvider);
  String money(Object? v) => fmt.formatCurrency((v as num?)?.toDouble() ?? 0);
  String str(String k) => (c.data[k] as String?) ?? '';
  return switch (c.type) {
    SgType.loans => _SgCopy(
      Icons.account_balance_outlined,
      l.homeV2SgLoanTitle,
      l.homeV2SgLoanBody(str('lender')),
      l.homeV2SgLoanAct,
      l.homeV2SgLoanDone,
    ),
    SgType.creditCard => _SgCopy(
      Icons.credit_card_outlined,
      l.homeV2SgCcTitle(str('card')),
      l.homeV2SgCcBody,
      l.homeV2SgCcAct,
      l.homeV2SgCcDone,
    ),
    SgType.recurring => _SgCopy(
      Icons.event_repeat_outlined,
      l.homeV2SgRecTitle(str('merchant')),
      l.homeV2SgRecBody(
        money(c.data['amount']),
        (c.data['months'] as int?) ?? 3,
      ),
      l.homeV2SgRecAct,
      l.homeV2SgRecDone(str('merchant')),
    ),
    SgType.investments => _SgCopy(
      Icons.trending_up_rounded,
      l.homeV2SgInvTitle,
      l.homeV2SgInvBody(money(c.data['amount'])),
      l.homeV2SgInvAct,
      l.homeV2SgInvDone,
    ),
    SgType.budget => _SgCopy(
      Icons.donut_large_outlined,
      l.homeV2SgBudTitle(str('category')),
      l.homeV2SgBudBody(money(c.data['total']), str('category')),
      l.homeV2SgBudAct,
      l.homeV2SgBudDone(str('category')),
    ),
    SgType.ledger =>
      c.data['variant'] == 'note'
          ? _SgCopy(
              Icons.handshake_outlined,
              l.homeV2SgLedNoteTitle,
              l.homeV2SgLedNoteBody(str('note')),
              l.homeV2SgLedAct,
              l.homeV2SgLedDone,
            )
          : _SgCopy(
              Icons.handshake_outlined,
              l.homeV2SgLedTitle(str('name')),
              l.homeV2SgLedBody(str('name'), money(c.data['amount'])),
              l.homeV2SgLedAct,
              l.homeV2SgLedDone,
            ),
    SgType.askKuber => _SgCopy(
      Icons.auto_awesome_outlined,
      l.homeV2SgAskTitle,
      l.homeV2SgAskBody,
      l.homeV2SgAskAct,
    ),
    SgType.voice => _SgCopy(
      Icons.mic_none_rounded,
      l.homeV2SgVoiceTitle,
      l.homeV2SgVoiceBody,
      l.homeV2SgVoiceAct,
    ),
    SgType.homeWidget => _SgCopy(
      Icons.widgets_outlined,
      l.homeV2SgWidgetTitle,
      l.homeV2SgWidgetBody,
      l.homeV2SgWidgetAct,
    ),
    SgType.kuberCards => _SgCopy(
      Icons.wallet_outlined,
      l.homeV2SgCardsTitle,
      l.homeV2SgCardsBody,
      l.homeV2SgCardsAct,
    ),
  };
}

/// Suggestion card (board HV2.3): icon tile, title, body, close (dismiss),
/// Not now and the tonal main action. [success] cross-fades to the done line.
class SuggestionCard extends ConsumerWidget {
  final SgCandidate candidate;
  final bool success;

  const SuggestionCard({
    super.key,
    required this.candidate,
    this.success = false,
  });

  static String _fmt(num v) =>
      v == v.truncateToDouble() ? v.toInt().toString() : v.toStringAsFixed(2);

  /// Opens the main flow with its prefill; resolves to when the user is back.
  Future<void> _main(BuildContext context, WidgetRef ref) async {
    final c = candidate;
    final d = c.data;
    final notifier = ref.read(homeSuggestionProvider.notifier);
    Uri route(String path, Map<String, Object?> q) => Uri(
      path: path,
      queryParameters: {
        for (final e in q.entries)
          if (e.value != null && '${e.value}'.isNotEmpty)
            e.key: e.value is num ? _fmt(e.value as num) : '${e.value}',
      },
    );
    switch (c.type) {
      case SgType.loans:
        await context.push(
          route('/loans/add', {
            'lender': d['lender'],
            'emi': d['amount'],
          }).toString(),
        );
      case SgType.creditCard:
        final accounts = await ref.read(allAccountsProvider.future);
        final acc = accounts.where((a) => a.id == d['accountId']).firstOrNull;
        if (acc == null || !context.mounted) return;
        await context.push('/accounts/edit', extra: acc);
      case SgType.recurring:
        await context.push(
          route('/recurring/add', {
            'name': d['merchant'],
            'amount': d['amount'],
            'categoryId': d['categoryId'],
          }).toString(),
        );
      case SgType.investments:
        await context.push(
          route('/investments/add', {
            'name': d['amc'],
            'sip': d['amount'],
          }).toString(),
        );
      case SgType.budget:
        final cats = await ref.read(categoryListProvider.future);
        final cat = cats.where((x) => '${x.id}' == d['categoryId']).firstOrNull;
        if (!context.mounted) return;
        await context.push(
          route('/budgets/add', {'amount': d['amount']}).toString(),
          extra: cat,
        );
      case SgType.ledger:
        await context.push(
          '/ledger/add',
          extra: LedgerPrefill(
            personName: (d['name'] as String?) ?? '',
            type: 'lent',
            amount: (d['amount'] as num?)?.toDouble() ?? 0,
          ),
        );
      case SgType.askKuber:
        // Ask Kuber is English-only by design, like its sample question.
        final pending = context.push(
          route('/more/ask-kuber', {
            'draft': 'How much did I spend on food last month?',
          }).toString(),
        );
        await notifier.afterMainAction(c);
        await pending;
        return;
      case SgType.voice:
        final pending = context.push('/quick-add?voice=1');
        await notifier.afterMainAction(c);
        await pending;
        return;
      case SgType.homeWidget:
        await HomeWidget.requestPinWidget(
          qualifiedAndroidName:
              'com.grs.kuber.widgets.MonthlyNetWidgetProvider',
        );
        await notifier.afterMainAction(c);
        return;
      case SgType.kuberCards:
        final pending = context.push('/cards');
        await notifier.afterMainAction(c);
        await pending;
        return;
    }
    await notifier.afterMainAction(c);
  }

  void _dismiss(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final notifier = ref.read(homeSuggestionProvider.notifier);
    // The card unmounts on dismiss: hand the root overlay over directly.
    final overlay = Navigator.of(context, rootNavigator: true).overlay;
    showKuberSnackBar(
      context,
      l.homeV2SgDismissedSnack,
      overlay: overlay,
      actionLabel: l.homeV2ActUndo,
      onAction: () => notifier.undoDismiss(candidate),
    );
    notifier.dismiss(candidate);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final copy = _copyFor(context, ref, candidate);
    return KuberCard(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: success && copy.done != null
            ? Row(
                key: const ValueKey('done'),
                children: [
                  Icon(Icons.check_circle_rounded, color: cs.primary),
                  const SizedBox(width: KuberSpace.md),
                  Expanded(
                    child: Text(
                      copy.done!,
                      style: tt.titleSmall!.copyWith(color: cs.onSurface),
                    ),
                  ),
                ],
              )
            : Column(
                key: const ValueKey('card'),
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      KuberIconTile(icon: copy.icon),
                      const SizedBox(width: KuberSpace.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              copy.title,
                              style: tt.titleMedium!.copyWith(
                                color: cs.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              copy.body,
                              style: tt.bodyMedium!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      AppIconButton(
                        icon: Icons.close_rounded,
                        kind: AppIconButtonKind.plain,
                        size: 40,
                        semanticLabel: l.homeV2SgDismissA11y,
                        onPressed: () => _dismiss(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.md),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => ref
                            .read(homeSuggestionProvider.notifier)
                            .notNow(candidate),
                        child: Text(l.homeV2SgNotNow),
                      ),
                      const SizedBox(width: KuberSpace.sm),
                      AppButton(
                        label: copy.action,
                        type: AppButtonType.normal,
                        height: 40,
                        onPressed: () => _main(context, ref),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
