import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/transaction_preview_card.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../models/chat_message.dart';
import '../models/transaction_preview_payload.dart';
import '../models/viz_payload.dart';
import 'budget_status_viz.dart';
import 'thinking_panel.dart';
import 'top_categories_viz.dart';

/// Dispatches to the user or Kuber message. No avatar on either side. When
/// [stream] is supplied (the actively-typing Kuber message), the text is read
/// from it and a blinking caret is shown; meta/viz/thinking are withheld until
/// streaming completes.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueListenable<String>? stream;

  const MessageBubble({super.key, required this.message, this.stream});

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(message: message)
        : _KuberMessage(message: message, stream: stream);
  }
}

class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.only(bottom: KuberSpacing.md),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 7),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.10),
            border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text,
                  style: localeFont(
                      fontSize: 14, color: cs.onSurface, height: 1.45)),
              const SizedBox(height: 3),
              Text(
                DateFormat('h:mm a').format(message.time),
                style: localeFont(
                    fontSize: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Currency/number highlight spans for Kuber text.
List<InlineSpan> buildRichSpans(String text, TextStyle base, Color highlight) {
  final pattern = RegExp(r'[₹$€£]?[\d,]+(?:\.\d+)?', caseSensitive: false);
  final spans = <InlineSpan>[];
  int last = 0;
  for (final m in pattern.allMatches(text)) {
    final matched = m.group(0)!;
    if (!RegExp(r'\d').hasMatch(matched)) continue;
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    }
    spans.add(TextSpan(
        text: matched,
        style: base.copyWith(fontWeight: FontWeight.w600, color: highlight)));
    last = m.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }
  return spans;
}

/// Kuber message: bare editorial text on the chat surface, no bubble box.
class _KuberMessage extends ConsumerStatefulWidget {
  final ChatMessage message;
  final ValueListenable<String>? stream;
  const _KuberMessage({required this.message, this.stream});

  @override
  ConsumerState<_KuberMessage> createState() => _KuberMessageState();
}

class _KuberMessageState extends ConsumerState<_KuberMessage>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _sizeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  TextStyle get _textStyle =>
      localeFont(fontSize: 15, color: Theme.of(context).colorScheme.onSurface, height: 1.5);

  Future<void> _commitPreview(TransactionPreviewPayload payload) async {
    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final categories = ref.read(categoryListProvider).valueOrNull ?? [];
    final settings = await ref.read(settingsProvider.future);
    final defaultAccId = settings.defaultAccountId;

    int addedCount = 0;
    for (final item in payload.items) {
      if (item.amount == null || item.amount! <= 0) continue;

      String? resolvedAccId;
      if (item.accountHint != null) {
        resolvedAccId = accounts
            .where((a) => a.name.toLowerCase().contains(item.accountHint!.toLowerCase()))
            .firstOrNull
            ?.id
            .toString();
      }
      resolvedAccId ??= defaultAccId;

      Category? cat = item.matchResult.category;
      cat ??= categories.where((c) => c.name.toLowerCase() == 'general' || c.name.toLowerCase() == 'other').firstOrNull;
      cat ??= categories.firstOrNull;

      if (cat == null || resolvedAccId == null) continue;

      final name = item.categoryCandidate?.isNotEmpty == true
          ? item.categoryCandidate!
          : cat.name;

      final txn = Transaction()
        ..name = name
        ..nameLower = name.toLowerCase()
        ..amount = item.amount!
        ..type = item.type
        ..categoryId = cat.id.toString()
        ..accountId = resolvedAccId
        ..quickAddNote = payload.rawPrompt
        ..importSource = 'quick_add'
        ..createdAt = DateTime.now()
        ..updatedAt = DateTime.now();

      await ref.read(transactionListProvider.notifier).add(txn);
      addedCount++;
    }

    if (!mounted) return;
    setState(() {
      payload.isCommitted = true;
    });
    showKuberSnackBar(
      context,
      addedCount == 1 ? 'Transaction added' : '$addedCount transactions added',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final msg = widget.message;
    final maxW = MediaQuery.sizeOf(context).width * 0.86;

    // Streaming: bare growing text + blinking caret, nothing else yet.
    if (widget.stream != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: const EdgeInsets.only(bottom: KuberSpacing.md),
            child: ValueListenableBuilder<String>(
              valueListenable: widget.stream!,
              builder: (context, text, _) => Text.rich(
                TextSpan(children: [
                  ...buildRichSpans(text, _textStyle, cs.primary),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: RepaintBoundary(child: BlinkingCaret(color: cs.primary)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    final thinking = msg.thinking;
    final viz = msg.vizPayload;
    final preview = msg.previewPayload;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.only(bottom: KuberSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(
                  children: buildRichSpans(msg.text, _textStyle, cs.primary))),
              if (preview != null) ...[
                const SizedBox(height: KuberSpacing.sm),
                _buildPreview(cs, preview),
              ],
              if (viz != null) ...[
                const SizedBox(height: KuberSpacing.sm),
                _buildViz(viz),
              ],
              if (thinking != null)
                ThinkingMetaRow(
                  time: DateFormat('h:mm a').format(msg.time),
                  expanded: _expanded,
                  onToggle: _toggle,
                ),
              if (thinking == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('h:mm a').format(msg.time),
                      style:
                          localeFont(fontSize: 11, color: cs.onSurfaceVariant)),
                ),
              if (thinking != null)
                SizeTransition(
                  sizeFactor: _sizeAnim,
                  axisAlignment: -1,
                  child: ThinkingPanel(thinking: thinking),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(ColorScheme cs, TransactionPreviewPayload payload) {
    if (payload.missingDefaultAccount || payload.missingCategories || payload.missingAccounts) {
      String title = 'No default account set';
      String desc = 'Set a default account in settings to add transactions from Ask Kuber.';
      String route = '/more/settings';
      String btnLabel = 'Set default account';

      if (payload.missingCategories) {
        title = 'No categories found';
        desc = 'Set up a category first before adding transactions.';
        route = '/more/categories';
        btnLabel = 'Set up category';
      } else if (payload.missingAccounts) {
        title = 'No accounts found';
        desc = 'Add an account first before adding transactions.';
        route = '/more/accounts';
        btnLabel = 'Add an account';
      }

      return Container(
        margin: const EdgeInsets.only(top: KuberSpacing.xs),
        padding: const EdgeInsets.all(KuberSpacing.md),
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
                Icon(Icons.warning_amber_rounded, size: 20, color: cs.error),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: localeFont(fontSize: 14, fontWeight: FontWeight.w700, color: cs.error),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              desc,
              style: localeFont(fontSize: 13, color: cs.onSurfaceVariant, height: 1.4),
            ),
            const SizedBox(height: KuberSpacing.md),
            AppButton(
              label: btnLabel,
              type: AppButtonType.primary,
              onPressed: () => context.push(route),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < payload.items.length; i++) ...[
          if (i > 0) const SizedBox(height: KuberSpacing.xs),
          TransactionPreviewCard(
            item: payload.items[i],
            dense: true,
          ),
        ],
        const SizedBox(height: KuberSpacing.sm),
        if (!payload.isCommitted)
          AppButton(
            label: payload.items.length > 1
                ? 'Add ${payload.items.length} transactions'
                : 'Add transaction',
            type: AppButtonType.primary,
            onPressed: () => _commitPreview(payload),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: cs.tertiary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.tertiary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_rounded, size: 16, color: cs.tertiary),
                const SizedBox(width: 6),
                Text(
                  payload.items.length == 1
                      ? 'Added transaction'
                      : 'Added ${payload.items.length} transactions',
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.tertiary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildViz(VizPayload viz) => switch (viz) {
        TopCategoriesViz() => TopCategoriesVizView(data: viz),
        BudgetStatusViz() => BudgetStatusVizView(data: viz),
      };
}
