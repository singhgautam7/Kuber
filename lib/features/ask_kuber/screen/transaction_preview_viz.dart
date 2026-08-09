import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:collection/collection.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../quick_add/services/quick_add_confirm.dart';
import '../../quick_add/services/quick_add_parser.dart';
import '../../quick_add/services/quick_add_resolver.dart';
import '../../quick_add/widgets/transaction_preview_card.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../models/chat_message.dart';
import '../models/viz_payload.dart';
import '../providers/ask_kuber_providers.dart';

/// Interactive transaction-preview bubble content. Renders the shared preview
/// card(s) plus a confirm/cancel row; on confirm it writes atomically and
/// transforms the bubble in place (never removed), persisting the new state so
/// scroll-back reads cleanly. Source = 'ask_kuber'.
class TransactionPreviewVizView extends ConsumerStatefulWidget {
  final ChatMessage message;
  final TransactionPreviewViz viz;

  const TransactionPreviewVizView({
    super.key,
    required this.message,
    required this.viz,
  });

  @override
  ConsumerState<TransactionPreviewVizView> createState() =>
      _TransactionPreviewVizViewState();
}

class _TransactionPreviewVizViewState
    extends ConsumerState<TransactionPreviewVizView> {
  bool _busy = false;

  /// Per-line category chosen via "Select different category" (line index ->
  /// category). Applied on top of the fresh resolve so the choice survives
  /// rebuilds while the bubble is still in preview state.
  final Map<int, Category> _picked = {};

  TransactionPreviewViz get viz => widget.viz;

  List<QuickAddDraft> _resolveNow() {
    // Watch so a default-account change (returning from settings) re-resolves.
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final accounts = ref.watch(allAccountsProvider).valueOrNull ?? const [];
    final defaultId =
        ref.watch(settingsProvider).valueOrNull?.defaultAccountId;
    final parsed = parseQuickAddMulti(viz.originalMessage);
    final drafts = resolveDrafts(
      parsed,
      categories: categories,
      accounts: accounts,
      defaultAccountId: defaultId,
    );
    // Apply user category picks.
    for (final entry in _picked.entries) {
      if (entry.key >= drafts.length) continue;
      final d = drafts[entry.key];
      final cat = entry.value;
      drafts[entry.key] = d.copyWith(
        status: d.accountId == null
            ? QuickAddDraftStatus.missingAccount
            : QuickAddDraftStatus.ready,
        categoryId: cat.id,
        categoryName: cat.name,
        categoryIcon: cat.icon,
        categoryColor: cat.colorValue,
      );
    }
    return drafts;
  }

  void _pickCategory(int index, QuickAddDraft draft) {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: cs.surfaceContainer,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: draft.categoryId,
        defaultType: draft.type,
        onSelected: (id) {
          Navigator.pop(context);
          final categories =
              ref.read(categoryListProvider).valueOrNull ?? const <Category>[];
          final cat = categories.firstWhereOrNull((c) => c.id == id);
          if (cat != null) setState(() => _picked[index] = cat);
        },
      ),
    );
  }

  Future<void> _confirm(List<QuickAddDraft> drafts) async {
    final ready = drafts.where((d) => d.counts).toList();
    if (ready.isEmpty || _busy) return;
    setState(() => _busy = true);
    // Creates any new categories at confirm time (deduped), then builds the
    // transactions with source 'ask_kuber' and the original message as note.
    final txns = await materializeDrafts(
      ref,
      ready,
      source: 'ask_kuber',
      sourceTextOverride: viz.originalMessage,
    );
    if (txns.isEmpty) {
      if (mounted) setState(() => _busy = false);
      return;
    }
    final ids = await ref.read(transactionListProvider.notifier).addMany(txns);
    if (!mounted) return;
    viz
      ..drafts = ready
          .map((d) => d.copyWith(status: QuickAddDraftStatus.confirmed))
          .toList()
      ..state = 'confirmed'
      ..writtenIds = ids;
    await ref.read(askKuberRepositoryProvider).update(widget.message);
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _cancel(List<QuickAddDraft> drafts) async {
    if (_busy) return;
    viz
      ..drafts = drafts
          .map((d) => d.copyWith(status: QuickAddDraftStatus.cancelled))
          .toList()
      ..state = 'cancelled';
    await ref.read(askKuberRepositoryProvider).update(widget.message);
    if (mounted) setState(() {});
  }

  Future<void> _undo() async {
    if (_busy) return;
    setState(() => _busy = true);
    final notifier = ref.read(transactionListProvider.notifier);
    for (final id in viz.writtenIds) {
      await notifier.delete(id);
    }
    if (!mounted) return;
    viz
      ..state = 'preview'
      ..writtenIds = const [];
    await ref.read(askKuberRepositoryProvider).update(widget.message);
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _openAccountSettings() async {
    await context.push('/more/settings');
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    switch (viz.state) {
      case 'confirmed':
        return _confirmedView();
      case 'cancelled':
        return _cancelledView();
      default:
        return _previewView();
    }
  }

  Widget _previewView() {
    final drafts = _resolveNow();
    final hasMissingAccount =
        drafts.any((d) => d.status == QuickAddDraftStatus.missingAccount);
    final readyCount = drafts.where((d) => d.counts).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cards(drafts, interactive: true),
        const SizedBox(height: KuberSpacing.md),
        if (hasMissingAccount)
          _missingAccountError()
        else
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: readyCount <= 1
                      ? 'Add this transaction'
                      : 'Add $readyCount transactions',
                  type: AppButtonType.primary,
                  height: 44,
                  fullWidth: true,
                  isLoading: _busy,
                  onPressed: readyCount >= 1 ? () => _confirm(drafts) : null,
                ),
              ),
              const SizedBox(width: 9),
              AppButton(
                label: 'Cancel',
                type: AppButtonType.outline,
                width: 96,
                height: 44,
                onPressed: () => _cancel(drafts),
              ),
            ],
          ),
      ],
    );
  }

  Widget _confirmedView() {
    final account = viz.drafts.firstOrNullAccount;
    final n = viz.drafts.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cards(viz.drafts, onUndo: _undo),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          n <= 1
              ? 'Done. Saved${account != null ? ' to $account' : ''}.'
              : 'Added $n transactions${account != null ? ' to $account' : ''}.',
          style: TextStyle(
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _cancelledView() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _cards(viz.drafts),
        const SizedBox(height: KuberSpacing.sm),
        Text('Not added.',
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
      ],
    );
  }

  Widget _cards(
    List<QuickAddDraft> drafts, {
    VoidCallback? onUndo,
    bool interactive = false,
  }) {
    return Column(
      children: [
        for (var i = 0; i < drafts.length; i++) ...[
          if (i > 0) const SizedBox(height: 9),
          TransactionPreviewCard(
            draft: drafts[i],
            compact: true,
            onUndo: onUndo,
            onSetDefaultAccount: _openAccountSettings,
            onPickCategory:
                interactive ? () => _pickCategory(i, drafts[i]) : null,
          ),
        ],
      ],
    );
  }

  Widget _missingAccountError() {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: cs.error.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
              const SizedBox(width: KuberSpacing.sm),
              Expanded(
                child: Text(
                  'No default account selected',
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Set one to add transactions from Ask Kuber.',
            style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: KuberSpacing.sm),
          GestureDetector(
            onTap: _openAccountSettings,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Open Account Settings',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: cs.primary),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 15, color: cs.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension _AccountName on List<QuickAddDraft> {
  String? get firstOrNullAccount {
    for (final d in this) {
      if (d.accountName != null) return d.accountName;
    }
    return null;
  }
}
