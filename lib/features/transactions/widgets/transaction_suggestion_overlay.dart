import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../data/transaction_suggestion.dart';

/// Renders the dropdown content for the transaction name autocomplete.
/// Extracted from [AddTransactionScreen] so the same overlay can be reused
/// by any screen that embeds [RawAutocomplete<TransactionSuggestion>].
class TransactionSuggestionOverlay extends ConsumerWidget {
  const TransactionSuggestionOverlay({
    required this.options,
    required this.onSelected,
    super.key,
  });

  final Iterable<TransactionSuggestion> options;
  final void Function(TransactionSuggestion) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final catMap = ref.read(categoryMapProvider).valueOrNull ?? {};

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: KuberSpacing.xs),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          color: cs.surfaceContainerHigh,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: 200,
              maxWidth:
                  MediaQuery.of(context).size.width - 2 * KuberSpacing.lg,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(KuberRadius.md),
              // NotificationListener absorbs scroll events so scrolling inside
              // this overlay does not bubble to the page's ScrollView and
              // accidentally cause the text field to lose focus.
              child: NotificationListener<ScrollNotification>(
                onNotification: (_) => true,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: KuberSpacing.xs,
                  ),
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final s = options.elementAt(index);
                    final cat = catMap[int.tryParse(s.categoryId ?? '')];
                    final catColor = cat != null
                        ? harmonizeCategory(context, Color(cat.colorValue))
                        : cs.onSurfaceVariant;
                    final catIcon = cat != null
                        ? IconMapper.fromString(cat.icon)
                        : Icons.category;

                    return InkWell(
                      onTap: () => onSelected(s),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.md,
                          vertical: KuberSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(catIcon, size: 18, color: catColor),
                            ),
                            const SizedBox(width: KuberSpacing.sm),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    s.displayName,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: cs.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (cat?.name != null)
                                    Text(
                                      cat!.name,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: cs.onSurfaceVariant,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                ],
                              ),
                            ),
                            if (s.amount != null)
                              Text(
                                maskAmount(
                                  ref
                                      .watch(formatterProvider)
                                      .formatCurrency(s.amount!),
                                  ref.watch(privacyModeProvider),
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
