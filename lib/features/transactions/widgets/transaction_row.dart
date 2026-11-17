import 'package:flutter/material.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../accounts/data/account.dart';
import '../../categories/data/category.dart';
import '../../history/providers/selection_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../sms_import/widgets/sms_badge.dart';
import '../data/transaction.dart';

/// State layer inset inside a row (concentric with the 20 dp day card).
const double _kRowInset = 4;

class DateGroupHeader extends ConsumerWidget {
  final String label;
  final double dayTotal;

  const DateGroupHeader({
    super.key,
    required this.label,
    required this.dayTotal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final formatter = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final isPositive = dayTotal >= 0;
    final totalText = maskAmount(
      isPositive
          ? '+${formatter.formatCurrency(dayTotal)}'
          : '−${formatter.formatCurrency(dayTotal.abs())}',
      isPrivate,
    );
    // Day header = section header (board 3.5): caps label, total trailing.
    return Padding(
      padding: const EdgeInsets.only(
        top: KuberSpace.sm,
        bottom: KuberSpace.sectionHeaderGap,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelMedium?.copyWith(
                letterSpacing: 0.8,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: KuberSpace.sm),
          Text(
            totalText,
            style: textTheme.labelLarge?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class TransactionDayCard extends StatefulWidget {
  final List<Transaction> transactions;
  final void Function(Transaction) onDelete;
  final void Function(Transaction) onTap;
  final void Function(Transaction) onEdit;

  /// Tap that also gets the tapped row's global rect (null when unknown), for
  /// the container transform into the detail sheet. Wins over [onTap].
  final void Function(Transaction, Rect?)? onOpen;

  /// Rows that appear (new id) or disappear (id gone) while this card stays
  /// mounted grow in / shrink out. Off for the first build, bulk changes
  /// (more than [_maxChange] rows) and while a filter is being applied.
  final bool animateChanges;

  final AppFormatter formatter;
  final Map<int, Category> categoryMap;
  final Map<int, Account> accountMap;

  /// Transaction id → the paired transfer leg's accountId. Built once by the
  /// caller (see `buildTransferPairAccountIds`) so rows don't scan the list.
  final Map<int, String> transferPairAccountId;
  final Map<int, List<String>> tagNamesMap;

  const TransactionDayCard({
    super.key,
    required this.transactions,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
    this.onOpen,
    this.animateChanges = false,
    required this.formatter,
    required this.categoryMap,
    required this.accountMap,
    this.transferPairAccountId = const {},
    this.tagNamesMap = const {},
  });

  @override
  State<TransactionDayCard> createState() => _TransactionDayCardState();
}

class _Ghost {
  _Ghost(this.transaction, this.index);
  final Transaction transaction;
  final int index;
}

class _TransactionDayCardState extends State<TransactionDayCard> {
  /// More changed rows than this at once is a bulk change (import, filter,
  /// bulk delete): no per-row motion.
  static const _maxChange = 3;

  late Set<int> _ids;

  /// Ids whose row carries the insert wrapper. Only rows that were inserted
  /// while the card was mounted; every other row is the bare row (nothing
  /// extra per row at rest).
  final _inserted = <int>{};

  /// Rows removed from the data, kept until their exit motion ends.
  final _ghosts = <int, _Ghost>{};

  /// Swipe-deleted ids: the Dismissible already animates those out.
  final _swiped = <int>{};

  @override
  void initState() {
    super.initState();
    _ids = {for (final t in widget.transactions) t.id};
  }

  @override
  void didUpdateWidget(TransactionDayCard old) {
    super.didUpdateWidget(old);
    if (identical(old.transactions, widget.transactions)) return;
    final now = {for (final t in widget.transactions) t.id};
    final added = now.difference(_ids);
    final removed = _ids.difference(now);
    for (final id in added) {
      _ghosts.remove(id);
    }
    if (widget.animateChanges &&
        added.length <= _maxChange &&
        removed.length <= _maxChange) {
      _inserted.addAll(added);
      for (var i = 0; i < old.transactions.length; i++) {
        final t = old.transactions[i];
        if (removed.contains(t.id) && !_swiped.contains(t.id)) {
          _ghosts[t.id] = _Ghost(t, i);
        }
      }
    }
    _swiped.removeAll(removed);
    _ids = now;
  }

  Widget _row(Transaction t, {bool ghost = false}) {
    final w = widget;
    return TransactionRow(
      key: ghost ? null : ValueKey(t.id),
      ghost: ghost,
      transaction: t,
      onDelete: () {
        _swiped.add(t.id);
        w.onDelete(t);
      },
      onTap: () => w.onTap(t),
      onTapRect: w.onOpen == null ? null : (r) => w.onOpen!(t, r),
      onEdit: () => w.onEdit(t),
      formatter: w.formatter,
      category: w.categoryMap[int.tryParse(t.categoryId)],
      account: w.accountMap[int.tryParse(t.accountId)],
      accountMap: w.accountMap,
      transferPairAccountId: w.transferPairAccountId,
      tagNames: w.tagNamesMap[t.id] ?? const [],
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final t in widget.transactions) (t, false),
    ];
    final ghosts = _ghosts.values.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    for (final g in ghosts) {
      items.insert(
        g.index.clamp(0, items.length),
        (g.transaction, true),
      );
    }
    // One grouped list per day, rows divided by 1dp outlineVariant (grouping
    // over boxing, density-audit #1).
    return KuberGroup(
      children: [
        for (final (t, isGhost) in items)
          if (isGhost)
            KuberAnimatedListItem(
              key: ValueKey('exit${t.id}'),
              present: false,
              onRemoved: () {
                if (mounted) setState(() => _ghosts.remove(t.id));
              },
              child: IgnorePointer(child: _row(t, ghost: true)),
            )
          else if (_inserted.contains(t.id))
            KuberAnimatedListItem(
              key: ValueKey(t.id),
              animateIn: true,
              child: _row(t),
            )
          else
            _row(t),
      ],
    );
  }
}

class TransactionRow extends ConsumerWidget {
  final Transaction transaction;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onEdit;

  /// Like [onTap] but with the row's global rect (the container transform's
  /// source). Read at tap time, so no GlobalKey is allocated per row.
  final void Function(Rect? rect)? onTapRect;

  /// A row that is leaving (kept for its exit motion): no swipe actions.
  final bool ghost;
  final AppFormatter formatter;
  final Category? category;
  final Account? account;
  final Map<int, Account> accountMap;

  /// Transaction id → the paired transfer leg's accountId (O(1) lookup).
  final Map<int, String> transferPairAccountId;
  final List<String> tagNames;

  const TransactionRow({
    super.key,
    required this.transaction,
    required this.onDelete,
    required this.onTap,
    required this.onEdit,
    this.onTapRect,
    this.ghost = false,
    required this.formatter,
    this.category,
    this.account,
    required this.accountMap,
    this.transferPairAccountId = const {},
    this.tagNames = const [],
  });

  /// Builds the secondary indicator text showing attachment count and/or tags.
  /// Returns null when there's nothing to show.
  bool _hasIndicator() {
    final hasAttachments = transaction.attachmentPaths.isNotEmpty;
    final hasNotes = transaction.notes?.isNotEmpty == true;
    final hasTags = tagNames.isNotEmpty;
    return hasAttachments || hasNotes || hasTags;
  }

  /// Tags (labelMedium primary) and 20-high badge pills (attachments count,
  /// note), per components/transaction-item.md.
  Widget _buildIndicatorRow(BuildContext context, ThemeData theme) {
    final cs = theme.colorScheme;
    final hasAttachments = transaction.attachmentPaths.isNotEmpty;
    final hasNotes = transaction.notes?.isNotEmpty == true;
    final hasTags = tagNames.isNotEmpty;
    final pillText = theme.textTheme.labelSmall!.copyWith(
      color: cs.onSurfaceVariant,
      height: 1.0,
    );

    Widget pill(IconData icon, [String? count]) => Container(
      height: 20,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.fullR,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          if (count != null) ...[
            const SizedBox(width: 2),
            Text(count, style: pillText),
          ],
        ],
      ),
    );

    final tagText = hasTags
        ? [
            tagNames.take(2).map((t) => '#$t').join(' '),
            if (tagNames.length > 2)
              context.l10n.tagsMoreCount('${tagNames.length - 2}'),
          ].join(' ')
        : null;

    return Row(
      children: [
        if (hasAttachments) ...[
          pill(
            Icons.attach_file_rounded,
            '${transaction.attachmentPaths.length}',
          ),
          const SizedBox(width: 4),
        ],
        if (hasNotes) ...[pill(Icons.notes_rounded), const SizedBox(width: 4)],
        if (tagText != null)
          Flexible(
            child: Text(
              tagText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium!.copyWith(color: cs.primary),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cache theme lookups — this widget renders per-row in the History list,
    // so five separate Theme.of(context).textTheme walks per row adds up.
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSelectionMode = ref.watch(isSelectionModeProvider);
    // Watch only this row's membership so toggling one selection rebuilds only
    // the affected row, not every visible row.
    final isSelected = ref.watch(
      transactionSelectionProvider.select((s) => s.contains(transaction.id)),
    );
    final isTransfer = transaction.isTransfer;
    final isAdjustment = transaction.isBalanceAdjustment;

    // Transfer-specific: look up FROM and TO accounts via the precomputed map.
    String? fromName;
    String? toName;
    if (isTransfer) {
      // This is the expense (FROM) leg; the map gives the income (TO) leg's id.
      final pairAccountId = transferPairAccountId[transaction.id];

      fromName = accountMap[int.tryParse(transaction.accountId)]?.name;
      toName = pairAccountId != null
          ? accountMap[int.tryParse(pairAccountId)]?.name
          : null;
    }

    final isIncome = transaction.type == 'income';

    // Adjustment-specific styling
    final IconData iconData;
    final Color iconColor;
    final String displayName;
    final String subtitle;
    final Color amountColor;
    final String amountPrefix;

    if (transaction.isLoanDisbursement) {
      // Loan money reaching an account: its own look, not a correction.
      iconData = Icons.south_west_rounded;
      iconColor = cs.primary;
      displayName = transaction.name;
      subtitle = account?.name ?? context.l10n.unknownLabel;
      amountColor = context.kuberMoney.income;
      amountPrefix = '+';
    } else if (isAdjustment) {
      iconData = Icons.account_balance_rounded;
      iconColor = cs.onSurfaceVariant;
      displayName = transaction.name;
      subtitle = context.l10n.accountCorrectionSubtitle;
      // Income (+) adjustments read green like any other inflow; expense stays
      // neutral.
      amountColor = isIncome ? context.kuberMoney.income : cs.onSurface;
      amountPrefix = isIncome ? '+' : '-';
    } else if (isTransfer) {
      iconData = Icons.swap_horiz_rounded;
      iconColor = cs.onSurfaceVariant;
      displayName =
          '${fromName ?? context.l10n.unknownLabel} → ${toName ?? context.l10n.unknownLabel}';
      subtitle =
          '${context.l10n.transferLabel} · ${toName ?? context.l10n.unknownLabel}';
      amountColor = cs.onSurface;
      amountPrefix = '';
    } else {
      iconData = category != null
          ? IconMapper.fromString(category!.icon)
          : Icons.category;
      iconColor = category != null
          ? harmonizeCategory(context, Color(category!.colorValue))
          : cs.primary;
      displayName = transaction.name;
      subtitle =
          '${category?.name ?? context.l10n.unknownLabel} · ${account?.name ?? context.l10n.unknownLabel}';
      amountColor = isIncome
          ? context.kuberMoney.income
          : context.kuberMoney.expense;
      amountPrefix = isIncome ? '+' : '-';
    }

    final swipeMode = ref.watch(
      settingsProvider.select(
        (async) => async.valueOrNull?.swipeMode ?? SwipeMode.changeTabs,
      ),
    );

    final hasIndicator = _hasIndicator();
    final Widget lead = isSelectionMode && isSelected
        ? Container(
            key: const ValueKey('check'),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: cs.onPrimary, size: 22),
          )
        : (isTransfer || isAdjustment)
        ? Container(
            key: const ValueKey('neutral'),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: cs.onSurfaceVariant, size: 22),
          )
        : CategoryIcon.square(
            key: const ValueKey('icon'),
            icon: iconData,
            rawColor: iconColor,
          );

    final level = KuberMotion.levelOf(context);
    final expressive = level == MotionLevel.expressive;
    final fill = level == MotionLevel.off
        ? KuberMotion.fxInstant
        : KuberMotion.fxFast;
    final minH = (hasIndicator ? KuberSpace.listItem3 : KuberSpace.listItem2);

    // Press (P1): scale .98 on the whole row, state layer inset 4 dp with 16 dp
    // corners (concentric with the 20 dp day card). Pressable has no
    // controller until the first press.
    final content = Pressable(
      kind: PressKind.row,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: minH),
        child: Padding(
          padding: const EdgeInsets.all(_kRowInset),
          child: AnimatedContainer(
            duration: fill,
            decoration: BoxDecoration(
              color: isSelected ? cs.secondaryContainer : Colors.transparent,
              borderRadius: KuberShape.largeR,
            ),
            child: InkWell(
              borderRadius: KuberShape.largeR,
              overlayColor: kuberPressedLayer(cs),
              onTap: () {
                if (isSelectionMode) {
                  KuberHaptics.tick();
                  ref
                      .read(transactionSelectionProvider.notifier)
                      .toggle(transaction.id);
                } else if (onTapRect != null) {
                  final box = context.findRenderObject();
                  onTapRect!(
                    box is RenderBox && box.attached && box.hasSize
                        ? (box.localToGlobal(Offset.zero) & box.size)
                            .deflate(_kRowInset)
                        : null,
                  );
                } else {
                  onTap();
                }
              },
              onLongPress: () {
                KuberHaptics.longPress();
                ref
                    .read(transactionSelectionProvider.notifier)
                    .toggle(transaction.id);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.listRowPadH - _kRowInset,
                  vertical: KuberSpace.listRowPadV - _kRowInset,
                ),
                child: Row(
            children: [
              AnimatedSwitcher(
                duration: fill,
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  // Square tile <-> circle check swap (Expressive): the new
                  // one springs in from .7.
                  child: expressive
                      ? ScaleTransition(
                          scale: Tween(begin: .7, end: 1.0).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: KuberMotion.fastCurve.clamped,
                            ),
                          ),
                          child: child,
                        )
                      : child,
                ),
                child: lead,
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayName,
                            style: textTheme.titleMedium?.copyWith(
                              color: isSelected
                                  ? cs.onSecondaryContainer
                                  : cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (transaction.importSource == 'sms') ...[
                          const SizedBox(width: 6),
                          SmsBadge(
                            onTap: transaction.importedFromSms == null
                                ? null
                                : () => showRawSmsSheet(
                                    context,
                                    rawSms: transaction.importedFromSms!,
                                  ),
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            subtitle,
                            style: textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? cs.onSecondaryContainer
                                  : cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isAdjustment) ...[
                          const SizedBox(width: 6),
                          Container(
                            height: 20,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: KuberShape.fullR,
                              border: Border.all(color: cs.outlineVariant),
                            ),
                            child: Text(
                              context.l10n.adjustmentLabel,
                              style: textTheme.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                height: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (hasIndicator) ...[
                      const SizedBox(height: 2),
                      _buildIndicatorRow(context, theme),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    maskAmount(
                      '$amountPrefix${formatter.formatCurrency(transaction.amount)}',
                      ref.watch(privacyModeProvider),
                    ),
                    style: textTheme.titleMedium?.copyWith(color: amountColor),
                  ),
                  Text(
                    DateFormatter.time(transaction.createdAt),
                    style: textTheme.bodySmall?.copyWith(
                      color: isSelected
                          ? cs.onSecondaryContainer
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
              ),
            ),
          ),
        ),
      ),
    );

    if (swipeMode == SwipeMode.performActions && !ghost) {
      return Dismissible(
        key: ValueKey(transaction.id),
        direction: DismissDirection.horizontal,
        background: Container(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: KuberSpace.xl),
          color: cs.secondaryContainer,
          child: Icon(Icons.edit_outlined, color: cs.onSecondaryContainer),
        ),
        secondaryBackground: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: KuberSpace.xl),
          color: cs.errorContainer,
          child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            onDelete();
            return true;
          } else {
            onEdit();
            return false;
          }
        },
        child: content,
      );
    }

    return content;
  }
}
