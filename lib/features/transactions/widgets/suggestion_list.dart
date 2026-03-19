import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction.dart';

class SuggestionList extends ConsumerWidget {
  final List<Transaction> suggestions;
  final ValueChanged<Transaction> onSelected;

  const SuggestionList({
    super.key,
    required this.suggestions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final categoryMap = ref.watch(categoryMapProvider);

    return AnimatedOpacity(
      opacity: suggestions.isEmpty ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: suggestions.isEmpty
          ? const SizedBox.shrink()
          : Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(KuberSpacing.md),
              ),
              child: categoryMap.when(
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
                data: (categories) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: suggestions.map((t) {
                    final catId = int.tryParse(t.categoryId);
                    final category =
                        catId != null ? categories[catId] : null;
                    final rawColor = category != null
                        ? Color(category.colorValue)
                        : colorScheme.outline;
                    final harmonized = harmonizeCategory(context, rawColor);
                    final icon = category != null
                        ? IconMapper.fromString(category.icon)
                        : Icons.category;

                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: harmonized.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(icon, size: 18, color: harmonized),
                      ),
                      title:
                          Text(t.name, style: textTheme.bodyMedium),
                      trailing: Text(
                        CurrencyFormatter.format(t.amount),
                        style: textTheme.labelMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onTap: () => onSelected(t),
                    );
                  }).toList(),
                ),
              ),
            ),
    );
  }
}
