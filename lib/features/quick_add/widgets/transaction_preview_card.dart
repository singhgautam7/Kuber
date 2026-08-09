import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_form_widgets.dart' show KuberCallout;
import '../../settings/providers/settings_provider.dart' show formatterProvider;
import '../services/quick_add_resolver.dart';

/// The one parsed-preview card, shared by the Quick Add page (Feature 1) and the
/// Ask Kuber transaction preview (Feature 2). Pure presentation over a
/// [QuickAddDraft] plus callbacks; all colours resolve from `colorScheme` /
/// `context.kuberColors`, so it adapts to every theme family in light and dark.
class TransactionPreviewCard extends ConsumerWidget {
  final QuickAddDraft draft;

  /// Compact size (36px icon / 14px title) used inside the Ask Kuber chat
  /// bubble; false gives the roomier Quick Add page card (40px / 15px).
  final bool compact;

  /// Shows the bordered edit affordance (category swap) on the page list.
  final VoidCallback? onEdit;

  /// New-category action: open the picker to choose an existing category
  /// instead of creating one. The new category itself is created only on
  /// confirm, so there is no separate "create" action here.
  final VoidCallback? onPickCategory;

  /// Missing-account deep link.
  final VoidCallback? onSetDefaultAccount;

  /// Confirmed-state undo (Ask Kuber).
  final VoidCallback? onUndo;

  const TransactionPreviewCard({
    super.key,
    required this.draft,
    this.compact = false,
    this.onEdit,
    this.onPickCategory,
    this.onSetDefaultAccount,
    this.onUndo,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final kc = context.kuberColors;
    final isIncome = draft.type == 'income';

    final iconSize = compact ? 36.0 : 40.0;
    final titleSize = compact ? 14.0 : 15.0;

    // Per-status border + fill.
    final Color borderColor;
    Color fillColor = cs.surfaceContainerHigh;
    switch (draft.status) {
      case QuickAddDraftStatus.newCategory:
        borderColor = kc.warning.withValues(alpha: 0.35);
        break;
      case QuickAddDraftStatus.missingAccount:
        borderColor = cs.error.withValues(alpha: 0.40);
        break;
      case QuickAddDraftStatus.unparseable:
        borderColor = cs.error.withValues(alpha: 0.40);
        break;
      case QuickAddDraftStatus.confirmed:
        fillColor = cs.tertiary.withValues(alpha: 0.06);
        borderColor = cs.tertiary.withValues(alpha: 0.40);
        break;
      case QuickAddDraftStatus.cancelled:
        borderColor = cs.outline.withValues(alpha: 0.4);
        break;
      case QuickAddDraftStatus.ready:
        borderColor = cs.outline;
        break;
    }

    final dim = draft.status == QuickAddDraftStatus.cancelled;

    Widget card = Container(
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(KuberSpacing.md),
            child: Row(
              children: [
                _leadingIcon(context, iconSize),
                const SizedBox(width: KuberSpacing.md),
                Expanded(child: _titleBlock(context, titleSize)),
                const SizedBox(width: KuberSpacing.sm),
                _amount(context, ref, isIncome),
                if (onEdit != null &&
                    draft.status != QuickAddDraftStatus.confirmed &&
                    draft.status != QuickAddDraftStatus.cancelled) ...[
                  const SizedBox(width: KuberSpacing.sm),
                  _editButton(context),
                ],
              ],
            ),
          ),
          if (draft.status == QuickAddDraftStatus.newCategory)
            _newCategoryFooter(context),
          if (draft.status == QuickAddDraftStatus.missingAccount &&
              onSetDefaultAccount != null)
            _missingAccountFooter(context),
          if (draft.status == QuickAddDraftStatus.confirmed)
            _confirmedFooter(context),
        ],
      ),
    );

    if (dim) {
      card = Opacity(opacity: 0.55, child: card);
    }
    return card;
  }

  Widget _leadingIcon(BuildContext context, double size) {
    final cs = Theme.of(context).colorScheme;
    final kc = context.kuberColors;
    if (draft.status == QuickAddDraftStatus.unparseable) {
      return _tintedSquare(size, cs.error, Icons.error_outline_rounded);
    }
    if (draft.status == QuickAddDraftStatus.newCategory) {
      return _tintedSquare(size, kc.warning, Icons.add_rounded);
    }
    if (draft.categoryColor != null && draft.categoryIcon != null) {
      return CategoryIcon.square(
        icon: IconMapper.fromString(draft.categoryIcon!),
        rawColor: harmonizeCategory(context, Color(draft.categoryColor!)),
        size: size,
      );
    }
    return _tintedSquare(size, cs.primary, Icons.category_rounded);
  }

  Widget _tintedSquare(double size, Color color, IconData icon) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Icon(icon, color: color, size: size * 0.5),
    );
  }

  Widget _titleBlock(BuildContext context, double titleSize) {
    final cs = Theme.of(context).colorScheme;
    final kc = context.kuberColors;

    final String title;
    final String subtitle;
    Color subtitleColor = cs.onSurfaceVariant;

    switch (draft.status) {
      case QuickAddDraftStatus.unparseable:
        title = 'Couldn’t read this line';
        subtitle = '"${draft.rawText}"';
        break;
      case QuickAddDraftStatus.newCategory:
        title = (draft.categoryHint ?? 'New category').toTitleCase();
        subtitle = '${draft.accountName ?? 'Account'} · New category';
        subtitleColor = kc.warning;
        break;
      case QuickAddDraftStatus.missingAccount:
        title = draft.categoryName ?? (draft.categoryHint ?? 'Transaction');
        subtitle = 'No account set';
        subtitleColor = cs.error;
        break;
      default:
        final isIncome = draft.type == 'income';
        title = draft.categoryName ?? (isIncome ? 'Income' : 'Expense');
        final acct = draft.accountName ?? 'Account';
        subtitle = isIncome ? '$acct · Income' : '$acct · $title';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 12, color: subtitleColor),
        ),
      ],
    );
  }

  Widget _amount(BuildContext context, WidgetRef ref, bool isIncome) {
    final cs = Theme.of(context).colorScheme;
    if (draft.amount == null) return const SizedBox.shrink();
    final formatted = ref.watch(formatterProvider).formatCurrency(draft.amount!);
    final sign = isIncome ? '+' : '−';
    final color = isIncome ? cs.tertiary : cs.error;
    return Text(
      '$sign$formatted',
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w800,
        color: draft.status == QuickAddDraftStatus.confirmed
            ? color.withValues(alpha: 0.7)
            : color,
      ),
    );
  }

  Widget _editButton(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(KuberRadius.sm),
          border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
        ),
        child: Icon(Icons.edit_outlined, size: 15, color: cs.onSurfaceVariant),
      ),
    );
  }

  Widget _newCategoryFooter(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final kc = context.kuberColors;
    final name = (draft.categoryHint ?? 'General').toTitleCase();
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: kc.warning.withValues(alpha: 0.20)),
        ),
      ),
      padding: const EdgeInsets.all(KuberSpacing.sm),
      child: Column(
        children: [
          // Info area (same warning callout used on the entity-create screens).
          // The category is created only when the user confirms the add.
          KuberCallout(
            child: Text(
              'Creating a new category named "$name"',
              style: TextStyle(fontSize: 12.5, height: 1.4, color: cs.onSurface),
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: 'Select different category',
              type: AppButtonType.outline,
              height: 40,
              onPressed: onPickCategory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _missingAccountFooter(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.error.withValues(alpha: 0.20)),
        ),
      ),
      padding: const EdgeInsets.all(KuberSpacing.sm),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          label: 'Set default account',
          type: AppButtonType.primary,
          icon: Icons.arrow_forward_rounded,
          iconAfterLabel: true,
          height: 40,
          onPressed: onSetDefaultAccount,
        ),
      ),
    );
  }

  Widget _confirmedFooter(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: cs.tertiary.withValues(alpha: 0.20)),
        ),
      ),
      padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: cs.tertiary.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 14, color: cs.tertiary),
          ),
          const SizedBox(width: KuberSpacing.sm),
          Expanded(
            child: Text(
              draft.accountName != null
                  ? 'Added to ${draft.accountName}'
                  : 'Added',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cs.tertiary,
              ),
            ),
          ),
          if (onUndo != null)
            GestureDetector(
              onTap: onUndo,
              child: Text(
                'Undo',
                style: TextStyle(
                  fontSize: 11.5,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
