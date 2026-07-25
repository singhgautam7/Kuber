import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/color_harmonizer.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/utils/locale_font.dart';
import '../../features/accounts/data/account.dart';
import '../../features/accounts/providers/account_provider.dart';
import '../../features/categories/data/category.dart';
import '../../features/dashboard/utils/quick_add_parser.dart';
import '../../features/settings/providers/settings_provider.dart';
import '../../shared/utils/category_fuzzy_matcher.dart';

enum PreviewCardDisplayState {
  normal,
  fuzzyMatch,
  newCategory,
  edit,
  errorMissingAccount,
  errorAmbiguousCategory,
}

class TransactionPreviewCard extends ConsumerWidget {
  final QuickAddParsedItem item;
  final bool dense;
  final bool isEditing;
  final VoidCallback? onEditToggle;
  final VoidCallback? onOverrideCategory;
  final VoidCallback? onCreateCategory;
  final VoidCallback? onPickCategory;
  final VoidCallback? onPickAccount;
  final ValueChanged<Category>? onSelectAmbiguousCategory;

  const TransactionPreviewCard({
    super.key,
    required this.item,
    this.dense = false,
    this.isEditing = false,
    this.onEditToggle,
    this.onOverrideCategory,
    this.onCreateCategory,
    this.onPickCategory,
    this.onPickAccount,
    this.onSelectAmbiguousCategory,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? [];

    // Resolve category & account
    Category? matchedCat = item.matchResult.category;
    Account? matchedAcc;

    if (item.accountHint != null && item.accountHint!.isNotEmpty) {
      final hint = item.accountHint!.toLowerCase();
      matchedAcc = accounts.where((a) => a.name.toLowerCase().contains(hint)).firstOrNull;
    }
    if (matchedAcc == null) {
      final settings = ref.watch(settingsProvider).valueOrNull;
      final defaultAccId = settings?.defaultAccountId;
      if (defaultAccId != null) {
        matchedAcc = accounts.where((a) => a.id.toString() == defaultAccId).firstOrNull;
      }
    }

    final isIncome = item.type == 'income';
    final amountVal = item.amount ?? 0.0;
    final formattedAmount = amountVal % 1 == 0
        ? amountVal.toInt().toString()
        : amountVal.toStringAsFixed(2);
    final amountSign = isIncome ? '+' : '−'; // U+2212 minus sign
    final amountStr = '$amountSign$symbol$formattedAmount';
    final amountColor = isIncome ? cs.tertiary : cs.error;

    // Determine state
    PreviewCardDisplayState state;
    if (isEditing) {
      state = PreviewCardDisplayState.edit;
    } else if (matchedAcc == null) {
      state = PreviewCardDisplayState.errorMissingAccount;
    } else if (item.matchResult.kind == CategoryMatchKind.fuzzy) {
      state = PreviewCardDisplayState.fuzzyMatch;
    } else if (item.matchResult.kind == CategoryMatchKind.noMatch &&
        item.categoryCandidate != null &&
        item.categoryCandidate!.isNotEmpty) {
      state = PreviewCardDisplayState.newCategory;
    } else {
      state = PreviewCardDisplayState.normal;
    }

    // Border & Background colors based on state
    Color borderColor = cs.outline;
    Color iconBgColor = cs.primary.withValues(alpha: 0.16);
    IconData cardIcon = Icons.category_outlined;
    Color iconColor = cs.primary;

    if (state == PreviewCardDisplayState.edit) {
      borderColor = cs.primary;
    } else if (state == PreviewCardDisplayState.fuzzyMatch) {
      borderColor = cs.outline;
    } else if (state == PreviewCardDisplayState.newCategory) {
      borderColor = KuberColors.warning.withValues(alpha: 0.35);
      iconBgColor = KuberColors.warning.withValues(alpha: 0.16);
      cardIcon = Icons.add_rounded;
      iconColor = KuberColors.warning;
    } else if (state == PreviewCardDisplayState.errorMissingAccount) {
      borderColor = cs.error.withValues(alpha: 0.40);
      iconBgColor = cs.error.withValues(alpha: 0.14);
      cardIcon = Icons.warning_amber_rounded;
      iconColor = cs.error;
    } else if (matchedCat != null) {
      iconColor = harmonizeCategory(context, Color(matchedCat.colorValue));
      iconBgColor = iconColor.withValues(alpha: 0.16);
      cardIcon = IconMapper.fromString(matchedCat.icon);
    }

    final categoryName = matchedCat?.name ??
        (item.categoryCandidate?.isNotEmpty == true
            ? item.categoryCandidate!
            : 'Uncategorized');
    final accountName = matchedAcc?.name ?? 'No account';

    final tileIconSize = dense ? 34.0 : 40.0;
    final tileInnerIconSize = dense ? 16.0 : 18.0;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: borderColor, width: isEditing ? 2.0 : 1.0),
      ),
      padding: EdgeInsets.all(dense ? KuberSpacing.sm : KuberSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Icon Tile
              Container(
                width: tileIconSize,
                height: tileIconSize,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Icon(cardIcon, size: tileInnerIconSize, color: iconColor),
              ),
              const SizedBox(width: KuberSpacing.sm),
              // Title & Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      categoryName,
                      style: localeFont(
                        fontSize: dense ? 14 : 15,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            '$accountName · $categoryName',
                            style: localeFont(
                              fontSize: 12,
                              color: state == PreviewCardDisplayState.errorMissingAccount
                                  ? cs.error
                                  : cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (state == PreviewCardDisplayState.fuzzyMatch) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.check_circle_rounded, size: 12, color: cs.primary),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.xs),
              // Amount & Edit pencil
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    amountStr,
                    style: localeFont(
                      fontSize: dense ? 14 : 16,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                    ),
                  ),
                  if (onEditToggle != null) ...[
                    const SizedBox(width: KuberSpacing.xs),
                    IconButton(
                      icon: Icon(
                        isEditing ? Icons.close_rounded : Icons.edit_outlined,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: onEditToggle,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    ),
                  ],
                ],
              ),
            ],
          ),

          // ── Sub-sections for states ──
          if (state == PreviewCardDisplayState.fuzzyMatch) ...[
            const SizedBox(height: KuberSpacing.sm),
            Divider(height: 1, color: cs.outline),
            const SizedBox(height: KuberSpacing.xs),
            Row(
              children: [
                Icon(Icons.check_rounded, size: 14, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  'Matched to ',
                  style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                ),
                Text(
                  matchedCat?.name ?? '',
                  style: localeFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onPickCategory,
                  child: Text(
                    'Override',
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (state == PreviewCardDisplayState.newCategory) ...[
            const SizedBox(height: KuberSpacing.sm),
            Divider(height: 1, color: cs.outline),
            const SizedBox(height: KuberSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Create new: ${item.categoryCandidate}?',
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onPickCategory,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Pick existing',
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 4),
                ElevatedButton(
                  onPressed: onCreateCategory,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: KuberColors.warning,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                  ),
                  child: Text(
                    'Create',
                    style: localeFont(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ] else if (state == PreviewCardDisplayState.edit) ...[
            const SizedBox(height: KuberSpacing.md),
            // Picker row: Category
            InkWell(
              onTap: onPickCategory,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Text(
                      'CATEGORY',
                      style: localeFont(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      categoryName,
                      style: localeFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.xs),
            // Picker row: Account
            InkWell(
              onTap: onPickAccount,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Row(
                  children: [
                    Text(
                      'ACCOUNT',
                      style: localeFont(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      accountName,
                      style: localeFont(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
