import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:io';
import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../../core/utils/color_harmonizer.dart';
import 'app_button.dart';
import 'kuber_chips.dart';
import 'kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';

import '../../core/motion/motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/attachment_service.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/icon_mapper.dart';
import '../../features/accounts/providers/account_provider.dart';
import '../../features/categories/providers/category_provider.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/providers/transaction_provider.dart';
import '../../features/recurring/providers/recurring_provider.dart';
import '../../features/recurring/widgets/rule_sheet.dart';
import '../../features/loans/providers/loan_provider.dart';
import '../../features/loans/widgets/loan_sheet.dart';
import '../../features/investments/providers/investment_provider.dart';
import '../../features/investments/widgets/holding_sheet.dart';
import 'money_widgets.dart';
import 'money_info_sheets.dart';
import 'kuber_form_widgets.dart' show KuberInfoGlyph;
import '../../features/settings/providers/settings_provider.dart';
import '../../features/notes/providers/notes_provider.dart';
import 'category_icon.dart';
import 'timed_snackbar.dart'; // showKuberSnackBar
import '../../features/tags/providers/tag_providers.dart';
import 'info_table.dart';
import 'kuber_bottom_sheet.dart';
import 'sheet_button_section.dart';

/// Shows the transaction detail bottom sheet with edit/delete actions.
void showTransactionDetailSheet(
  BuildContext context,
  WidgetRef ref,
  Transaction t,
) {
  showModalBottomSheet(
      sheetAnimationStyle: kuberSheetStyle(context),
    context: context,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => TransactionDetailSheet(
      transaction: t,
      onEdit: () {
        Navigator.of(context, rootNavigator: true).pop();
        context.push('/add-transaction', extra: t);
      },
      onDelete: () {
        Navigator.of(context, rootNavigator: true).pop();
        deleteTransactionWithUndo(context, ref, t);
      },
    ),
  );
}

/// Opens the transaction detail from a tapped row with the container
/// transform (motion.md "Container transform"). Same sheet, same actions.
///
/// Expressive (with [sourceRect], the row's global rect read at tap time):
/// the sheet grows out of the row, bounds + corners 16 to the sheet's top
/// radius on springSlow; the container colour shows over the first 30 %, then
/// the content fades in over fx.fast. Closing (back, scrim, X) reverses into
/// the row on springStandard; after Edit / Delete / drag-to-close, or when the
/// row is off screen, the sheet leaves the normal way (slides down). Subtle:
/// fade-through with a 4 dp shift. Off: 90 ms cross-fade. Without a
/// [sourceRect] Expressive slides up like a plain sheet.
void openTransactionDetail(
  BuildContext context,
  WidgetRef ref,
  Transaction t, {
  Rect? sourceRect,
}) {
  final nav = Navigator.of(context, rootNavigator: true);
  final cs = Theme.of(context).colorScheme;
  late final _DetailRoute route;
  void leave() {
    route.intoRow = false;
    nav.pop();
  }

  route = _DetailRoute(
    level: KuberMotion.levelOf(context),
    sourceRect: sourceRect,
    scrim: cs.scrim.withValues(alpha: 0.32),
    label: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    builder: (_) => TransactionDetailSheet(
      transaction: t,
      onEdit: () {
        leave();
        context.push('/add-transaction', extra: t);
      },
      onDelete: () {
        leave();
        deleteTransactionWithUndo(context, ref, t);
      },
    ),
  );
  nav.push(route);
}

class _DetailRoute extends PopupRoute<void> {
  _DetailRoute({
    required this.level,
    required this.sourceRect,
    required this.scrim,
    required this.label,
    required this.builder,
  });

  final MotionLevel level;
  final Rect? sourceRect;
  final Color scrim;
  final String label;
  final WidgetBuilder builder;

  /// Reverse into the row (true) or slide away (false).
  bool intoRow = true;

  @override
  Color get barrierColor => scrim;
  @override
  bool get barrierDismissible => true;
  @override
  String get barrierLabel => label;

  @override
  Duration get transitionDuration => switch (level) {
        MotionLevel.expressive => KuberMotion.slowCurve.settle,
        MotionLevel.subtle => KuberMotion.subtleCurve.settle,
        MotionLevel.off => KuberMotion.fxInstant,
      };
  @override
  Duration get reverseTransitionDuration => switch (level) {
        MotionLevel.expressive => KuberMotion.standardCurve.settle,
        MotionLevel.subtle => KuberMotion.subtleCurve.settle,
        MotionLevel.off => KuberMotion.fxInstant,
      };

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return _DetailPage(route: this, animation: animation, child: builder(context));
  }
}

class _DetailPage extends StatefulWidget {
  const _DetailPage(
      {required this.route, required this.animation, required this.child});
  final _DetailRoute route;
  final Animation<double> animation;
  final Widget child;

  @override
  State<_DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<_DetailPage>
    with SingleTickerProviderStateMixin {
  /// Drag-to-close offset (dp), independent of the route animation.
  final ValueNotifier<double> _drag = ValueNotifier(0);
  AnimationController? _back;
  final _sheetKey = GlobalKey();

  @override
  void dispose() {
    _back?.dispose();
    _drag.dispose();
    super.dispose();
  }

  void _dragUpdate(DragUpdateDetails d) {
    _back?.stop();
    _drag.value = (_drag.value + d.delta.dy).clamp(0.0, double.infinity);
  }

  void _dragEnd(DragEndDetails d) {
    final v = d.velocity.pixelsPerSecond.dy;
    if (v > 700 || _drag.value > (_sheetKey.currentContext?.size?.height ?? 400) * 0.5) {
      widget.route.intoRow = false;
      Navigator.of(context).maybePop();
      return;
    }
    if (_drag.value == 0) return;
    _back ??= AnimationController.unbounded(vsync: this)
      ..addListener(() => _drag.value = _back!.value.clamp(0.0, double.infinity));
    _back!.value = _drag.value;
    _back!.springTo(0, KuberMotion.springFast);
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;
    final level = route.level;
    final cs = Theme.of(context).colorScheme;
    final media = MediaQuery.of(context);
    final screen = media.size;
    final animation = widget.animation;

    final sheet = Material(
      key: _sheetKey,
      type: MaterialType.transparency,
      child: widget.child,
    );

    final fwdCurve = level == MotionLevel.subtle
        ? KuberMotion.subtleCurve
        : KuberMotion.slowCurve;
    final revCurve = (level == MotionLevel.subtle
            ? KuberMotion.subtleCurve
            : KuberMotion.standardCurve)
        .flipped;
    final fade = Interval(
        0.3,
        math.min(
            1.0,
            0.3 +
                KuberMotion.fxFast.inMilliseconds /
                    fwdCurve.settle.inMilliseconds),
        curve: KuberMotion.curveEffects);
    final source = route.sourceRect;

    Widget animated = AnimatedBuilder(
      animation: animation,
      child: sheet,
      builder: (context, child) {
        final reversing = animation.status == AnimationStatus.reverse;
        final v = animation.value;
        final t = (reversing ? revCurve : fwdCurve).transform(v);
        if (level == MotionLevel.off) {
          return Opacity(opacity: v.clamp(0.0, 1.0), child: child);
        }
        final toRow = source != null &&
            level == MotionLevel.expressive &&
            (!reversing || (route.intoRow && screen.contains(source.center)));
        if (toRow) {
          return ClipPath(
            clipper: _SheetClipper(source, t, screen.height),
            child: Stack(children: [
              Positioned.fill(child: ColoredBox(color: cs.surfaceContainer)),
              Opacity(
                opacity:
                    (reversing ? v : fade.transform(v)).clamp(0.0, 1.0),
                child: child,
              ),
            ]),
          );
        }
        if (level == MotionLevel.subtle) {
          final o = reversing ? v : fade.transform(v);
          return Opacity(
            opacity: o.clamp(0.0, 1.0),
            child: Transform.translate(
                offset: Offset(0, 4 * (1 - t.clamp(0.0, 1.0))), child: child),
          );
        }
        // Expressive without a source (or leaving): the plain slide.
        return FractionalTranslation(
            translation: Offset(0, 1 - t.clamp(0.0, 1.0)), child: child);
      },
    );

    animated = ValueListenableBuilder<double>(
      valueListenable: _drag,
      child: animated,
      builder: (context, d, child) =>
          Transform.translate(offset: Offset(0, d), child: child),
    );

    return GestureDetector(
      behavior: HitTestBehavior.deferToChild,
      onVerticalDragUpdate: _dragUpdate,
      onVerticalDragEnd: _dragEnd,
      child: Padding(
        padding: EdgeInsets.only(top: media.padding.top),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: animated,
        ),
      ),
    );
  }
}

/// Clips the sheet to a rect that grows from the tapped row (global [source])
/// to the sheet's own bounds. The sheet sits flush at the bottom, so its
/// global top is `screenH - size.height`; corners go 16 to the sheet's top
/// radius (bottom 16 to 0).
class _SheetClipper extends CustomClipper<Path> {
  _SheetClipper(this.source, this.t, this.screenH);
  final Rect source;
  final double t;
  final double screenH;

  @override
  Path getClip(Size size) {
    final from = source.shift(Offset(0, -(screenH - size.height)));
    final rect = Rect.lerp(from, Offset.zero & size, t)!;
    final top = math.max(0.0,
        KuberShape.large + (KuberShape.extraLarge - KuberShape.large) * t);
    final bottom = math.max(0.0, KuberShape.large * (1 - t));
    return Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: Radius.circular(top),
        topRight: Radius.circular(top),
        bottomLeft: Radius.circular(bottom),
        bottomRight: Radius.circular(bottom),
      ));
  }

  @override
  bool shouldReclip(_SheetClipper o) =>
      o.t != t || o.source != source || o.screenH != screenH;
}

/// Deletes the transaction and shows an undo snackbar.
void deleteTransactionWithUndo(BuildContext context, WidgetRef ref, Transaction t) {
  // If transfer, find pair BEFORE deleting
  Transaction? pair;
  if (t.isTransfer && t.transferId != null) {
    final allTxns = ref.read(transactionListProvider).valueOrNull ?? [];
    pair = allTxns.firstWhereOrNull(
        (tx) => tx.transferId == t.transferId && tx.id != t.id);
  }

  ref.read(transactionListProvider.notifier).delete(t.id);
  showKuberSnackBar(
    context,
    t.isTransfer ? context.l10n.transferDeleted : context.l10n.transactionDeleted,
    actionLabel: context.l10n.undoLabel,
    onAction: () {
      ref.read(transactionListProvider.notifier).restore(t);
      if (pair != null) {
        ref.read(transactionListProvider.notifier).restore(pair);
      }
    },
  );
}

class TransactionDetailSheet extends ConsumerStatefulWidget {
  final Transaction transaction;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TransactionDetailSheet({
    super.key,
    required this.transaction,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  ConsumerState<TransactionDetailSheet> createState() =>
      _TransactionDetailSheetState();
}

class _TransactionDetailSheetState
    extends ConsumerState<TransactionDetailSheet> {
  Transaction get transaction => widget.transaction;

  String _formatDetailDatetime(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    final timeStr = DateFormatter.time(dt);
    if (d == today) return 'Today • $timeStr';
    if (d == today.subtract(const Duration(days: 1))) return 'Yesterday • $timeStr';
    if (dt.year != now.year) return '${DateFormat('d MMM yyyy').format(dt)} • $timeStr';
    return '${DateFormat('EEE, d MMM').format(dt)} • $timeStr';
  }

  /// Derives the human Source label + icon from the transaction's provenance.
  ///
  /// The source is one of six values, decided from stored fields:
  ///  * `importSource == 'sms'` → SMS
  ///  * `linkedRuleType == 'recurring'` → Recurring
  ///  * `linkedRuleType == 'loan'` → Loan
  ///  * `linkedRuleType == 'investment'` → Investment / SIP
  ///  * `linkedRuleType == 'lent' | 'borrowed'` → Lent or Borrowed
  ///  * everything else → Entered by you
  ///
  /// Older auto-created rows may carry a `linkedRuleId` but a null
  /// `linkedRuleType` (the type field was added later). For those we resolve
  /// the id against the recurring rules so they still read as "Recurring".
  ({String label, IconData icon}) _source(BuildContext context) {
    final t = transaction;
    if (t.sourceNoteId != null) {
      return (
        label: 'Added from Kuber Notes',
        icon: Icons.sticky_note_2_outlined,
      );
    }
    if (t.importSource == 'sms') {
      return (label: context.l10n.sourceSms, icon: Icons.sms_outlined);
    }
    // Quick Add / Ask Kuber provenance. English literals, matching the
    // Kuber Notes label above (these are English-only features). The original
    // typed / spoken text is stored in `quickAddNote` and renders in the
    // "ADDED USING PROMPT" block below, mirroring how the SMS body is shown.
    if (t.importSource == 'quick_add') {
      return (label: 'Quick Add', icon: Icons.flash_on_rounded);
    }
    if (t.importSource == 'ask_kuber') {
      return (label: 'Ask Kuber', icon: Icons.auto_awesome_rounded);
    }

    var type = t.linkedRuleType;
    if (type == null && t.linkedRuleId != null) {
      final rules = ref.read(recurringListProvider).valueOrNull ?? const [];
      if (rules.any((r) => r.id.toString() == t.linkedRuleId)) {
        type = 'recurring';
      }
    }

    // vNext: posted by a schedule (rule, EMI, SIP).
    if (t.occurrenceDate != null) {
      return (
        label: t.sourceType == 'investment'
            ? context.l10n.msTxnSourceSip
            : context.l10n.msTxnSourceAuto,
        icon: Icons.event_repeat_rounded,
      );
    }
    switch (type) {
      case 'recurring':
        return (label: context.l10n.sourceRecurring, icon: Icons.repeat_rounded);
      case 'loan':
        return (label: context.l10n.sourceLoan, icon: Icons.account_balance_rounded);
      case 'investment':
        return (label: context.l10n.sourceInvestment, icon: Icons.trending_up_rounded);
      case 'lent':
      case 'borrowed':
        return (label: context.l10n.sourceLentBorrowed, icon: Icons.swap_horiz_rounded);
    }
    return (label: context.l10n.sourceManual, icon: Icons.edit_outlined);
  }

  /// "From Home loan ›" under the amount (components/source-chip.md). A
  /// deleted source hides the chip; the Source row then says so.
  List<Widget> _sourceChip(BuildContext context) {
    final t = transaction;
    final l = context.l10n;
    final type = t.sourceType ?? t.linkedRuleType;
    final id = t.sourceId ?? t.linkedRuleId;
    if (id == null) return const [];
    Widget chip(String label, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: SourceChip(label: label, onTap: onTap),
        );
    Widget gone(String kind) => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(kind,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        );
    switch (type) {
      case 'recurring':
        final rule = (ref.watch(recurringListProvider).valueOrNull ?? const [])
            .where((r) => '${r.id}' == id)
            .firstOrNull;
        if (rule == null) return [gone(l.msTxnDeletedRule)];
        return [chip(l.msSourceRule(rule.name), () => showRuleSheet(context, ref, rule))];
      case 'loan':
        final loan = (ref.watch(loanListProvider).valueOrNull ?? const [])
            .where((x) => x.uid == id)
            .firstOrNull;
        if (loan == null) return [gone(l.msTxnDeletedLoan)];
        return [chip(l.msSource(loan.name), () => showLoanSheet(context, ref, loan))];
      case 'investment':
        final inv = (ref.watch(investmentListProvider).valueOrNull ?? const [])
            .where((x) => x.uid == id)
            .firstOrNull;
        if (inv == null) return [gone(l.msTxnDeletedInvestment)];
        return [chip(l.msSource(inv.name), () => showHoldingSheet(context, ref, inv))];
    }
    return const [];
  }

  /// Opens the source note in the editor, or falls back to a snackbar when
  /// the note has been deleted.
  Future<void> _openSourceNote() async {
    final id = int.tryParse(transaction.sourceNoteId ?? '');
    final note = id == null
        ? null
        : await ref.read(notesRepositoryProvider).getById(id);
    if (!mounted) return;
    if (note == null) {
      showKuberSnackBar(context, 'This note was deleted.');
      return;
    }
    Navigator.of(context, rootNavigator: true).pop();
    context.push('/notes/editor?id=${note.id}');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isTransfer = transaction.isTransfer;

    final category = ref.watch(categoryListProvider.select(
      (async) => async.whenOrNull(
        data: (cats) => cats.firstWhereOrNull(
          (c) => c.id.toString() == transaction.categoryId,
        ),
      ),
    ));

    final account = ref.watch(allAccountsProvider.select(
      (async) => async.whenOrNull(
        data: (accs) => accs.firstWhereOrNull(
          (a) => a.id.toString() == transaction.accountId,
        ),
      ),
    ));

    // Transfer-specific lookups
    String? fromAccountName;
    String? toAccountName;
    if (isTransfer) {
      fromAccountName = account?.name;
      final pairAccountId = ref.watch(transactionListProvider.select(
        (async) => async.whenOrNull(
          data: (txns) => txns
              .firstWhereOrNull(
                  (t) => t.transferId == transaction.transferId && t.id != transaction.id)
              ?.accountId,
        ),
      ));
      toAccountName = pairAccountId != null
          ? ref.watch(allAccountsProvider.select(
              (async) => async.whenOrNull(
                data: (accs) => accs.firstWhereOrNull(
                  (a) => a.id.toString() == pairAccountId,
                )?.name,
              ),
            ))
          : null;
    }

    final isIncome = transaction.type == 'income';
    final amountColor = isTransfer
        ? cs.onSurface
        : (isIncome ? context.kuberMoney.income : context.kuberMoney.expense);

    final formattedAmount = ref.watch(formatterProvider).formatCurrency(transaction.amount);
    final amountText = isTransfer
        ? formattedAmount
        : (isIncome ? '+$formattedAmount' : '−$formattedAmount');
    final iconData = isTransfer
        ? Icons.swap_horiz_rounded
        : (category != null
            ? IconMapper.fromString(category.icon)
            : Icons.category);
    final iconColor = isTransfer
        ? cs.onSurfaceVariant
        : (category != null ? Color(category.colorValue) : cs.primary);
    final displayName = isTransfer
        ? '${fromAccountName ?? context.l10n.unknownLabel} → ${toAccountName ?? context.l10n.unknownLabel}'
        : transaction.name;

    // Account display
    String accountDisplay = account?.name ?? context.l10n.unknownLabel;
    if (account?.last4Digits != null && account!.last4Digits!.isNotEmpty) {
      accountDisplay += ' •••• ${account.last4Digits}';
    }
    final accountIcon = account?.icon != null
        ? IconMapper.fromString(account!.icon!)
        : Icons.account_balance_wallet_rounded;
    final accountColor = account?.colorValue != null
        ? Color(account!.colorValue!)
        : cs.primary;

    final dateLabel = _formatDetailDatetime(transaction.createdAt);
    final source = _source(context);
    final hasSms = transaction.importSource == 'sms' &&
        transaction.importedFromSms != null &&
        transaction.importedFromSms!.isNotEmpty;

    final tags = ref.watch(transactionTagsProvider(transaction.id)).valueOrNull ?? [];

    // ── InfoTable rows ──────────────────────────────────────────────────────
    final rows = <InfoTableRow>[
      InfoTableDataRow(label: context.l10n.dateTimeTitle, value: dateLabel),
      InfoTableDataRow(
        label: context.l10n.accountLabel,
        value: accountDisplay,
        valueLeadingIcon: accountIcon,
        valueIconColor: harmonizeCategory(context, accountColor),
      ),
      InfoTableDataRow(
        label: context.l10n.categoryLabel,
        value: isTransfer
            ? context.l10n.transferLabel
            : (category?.name ??
                (isIncome ? context.l10n.incomeLabel : context.l10n.noneLabel)),
        valueLeadingIcon: iconData,
        valueIconColor: isTransfer
            ? cs.onSurfaceVariant
            : harmonizeCategory(context, iconColor),
      ),
      if (transaction.sourceNoteId != null)
        InfoTableDataRow(
          label: context.l10n.sourceLabel,
          value: source.label,
          valueLeadingIcon: source.icon,
          valueIconColor: cs.primary,
          valueColor: cs.primary,
          tappable: true,
          onTap: _openSourceNote,
        )
      else
        InfoTableDataRow(
          label: context.l10n.sourceLabel,
          value: source.label,
          valueLeadingIcon: source.icon,
          valueIconColor: cs.onSurfaceVariant,
        ),
    ];

    return KuberBottomSheet(
      title: displayName,
      subtitle: (isTransfer
              ? context.l10n.transferLabel
              : (transaction.type == 'income'
                    ? context.l10n.incomeLabel
                    : context.l10n.expenseLabel))
          .toUpperCase(),
      leadingIcon: isTransfer
          ? Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, size: 24, color: cs.onSurfaceVariant),
            )
          : CategoryIcon.square(
              icon: iconData,
              rawColor: iconColor,
              size: 48,
            ),
      actions: SheetButtonSection(
        padding: EdgeInsets.zero,
        actions: [
          SheetAction(
            label: context.l10n.editLabel,
            icon: Icons.edit_outlined,
            onPressed: widget.onEdit,
          ),
          SheetAction(
            label: context.l10n.deleteLabel,
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: widget.onDelete,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SheetAmountHero(
            caption: context.l10n.transactionAmount,
            amount: amountText,
            amountColor: amountColor,
          ),
          ..._sourceChip(context),
          const SizedBox(height: KuberSpace.xl - 4),
          InfoTable(rows: rows),
          if (transaction.principalPart != null && transaction.interestPart != null) ...[
            const SizedBox(height: KuberSpace.xl - 4),
            Row(children: [
              Flexible(
                child: Text(context.l10n.msTxnSplit.toUpperCase(),
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        color: cs.onSurfaceVariant, letterSpacing: 0.8)),
              ),
              // Changed by the user to match the bank (A2).
              if (transaction.splitEdited) ...[
                const SizedBox(width: 8),
                KuberPill(label: context.l10n.msTxnEdited, tone: KuberTone.neutral),
                KuberInfoGlyph(
                    onTap: () => showMoneyInfo(context, ref, MoneyInfo.splitEdited)),
              ],
            ]),
            SizedBox(height: transaction.splitEdited ? 0 : 8),
            KuberCard(
              padding: const EdgeInsets.all(16),
              child: EmiSplitBar(
                principal: transaction.principalPart!,
                interest: transaction.interestPart!,
                principalText: ref.watch(formatterProvider).formatCurrency(transaction.principalPart!),
                interestText: ref.watch(formatterProvider).formatCurrency(transaction.interestPart!),
              ),
            ),
          ],

          // ── "View note" (Kuber Notes provenance, per 1m) ─────────────────
          if (transaction.sourceNoteId != null) ...[
            const SizedBox(height: KuberSpace.xl - 4),
            _ViewSourceNoteButton(
              sourceNoteId: transaction.sourceNoteId!,
              onTap: _openSourceNote,
            ),
          ],

          // ── Notes ────────────────────────────────────────────────────────
          if (transaction.notes != null && transaction.notes!.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.notesUpper,
              child: Text(
                transaction.notes!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: cs.onSurface),
              ),
            ),

          if (transaction.quickAddNote != null &&
              transaction.quickAddNote!.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.addedUsingPrompt,
              child: Text(
                transaction.quickAddNote!,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: cs.onSurface),
              ),
            ),

          // ── Tags ─────────────────────────────────────────────────────────
          if (tags.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.attachedTags,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    KuberChip(label: '#${tag.name}', icon: Icons.sell_outlined),
                ],
              ),
            ),

          // ── Original SMS ───────────────────────────────────────────────
          if (hasSms)
            _LabeledBlock(
              label: context.l10n.originalSmsLabel,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.lg, vertical: KuberSpace.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: KuberShape.mediumR,
                ),
                child: Text(
                  transaction.importedFromSms!,
                  style: monoFont(
                    fontSize: 12,
                    height: 19 / 12,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // ── Attachments ────────────────────────────────────────────────
          if (transaction.attachmentPaths.isNotEmpty)
            _LabeledBlock(
              label: context.l10n.attachmentsLabel,
              child: SizedBox(
                height: 64,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: transaction.attachmentPaths.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: KuberSpace.sm),
                  itemBuilder: (context, index) {
                    final path = transaction.attachmentPaths[index];
                    final isImage =
                        AttachmentService.getFileType(path) == 'image';
                    return GestureDetector(
                      onTap: () => OpenFilex.open(path),
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: KuberShape.mediumR,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isImage
                            ? Image.file(
                                File(path),
                                fit: BoxFit.cover,
                                width: 64,
                                height: 64,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.broken_image_outlined,
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: cs.error,
                                  size: 28,
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bordered full-width "View note: "title"" button below the info table for
/// transactions created from Kuber Notes (per 1m).
class _ViewSourceNoteButton extends ConsumerWidget {
  final String sourceNoteId;
  final VoidCallback onTap;

  const _ViewSourceNoteButton({
    required this.sourceNoteId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = int.tryParse(sourceNoteId);
    return FutureBuilder(
      future: id == null
          ? Future.value(null)
          : ref.read(notesRepositoryProvider).getById(id),
      builder: (context, snapshot) {
        final note = snapshot.data;
        final label = note == null
            ? 'View note'
            : 'View note: "${note.title.isEmpty ? 'Untitled note' : note.title}"';
        return AppButton(
          label: label,
          icon: Icons.sticky_note_2_outlined,
          type: AppButtonType.outline,
          height: 40,
          fullWidth: true,
          onPressed: onTap,
        );
      },
    );
  }
}

/// Small uppercase-label block used for Notes / Attachments sections below the
/// info table.
class _LabeledBlock extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.xl - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KuberSectionHeader(title: label),
          child,
        ],
      ),
    );
  }
}
