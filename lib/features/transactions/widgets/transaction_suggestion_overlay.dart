import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/kuber_autocomplete_overlay.dart';
import '../../categories/providers/category_provider.dart';
import '../data/transaction_suggestion.dart';

/// Renders the dropdown content for the transaction name autocomplete.
/// Uses the shared [KuberAutocompleteOverlay] and [KuberSuggestionTile] widgets.
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
    final catMap = ref.read(categoryMapProvider).valueOrNull ?? {};
    final cs = Theme.of(context).colorScheme;

    return KuberAutocompleteOverlay<TransactionSuggestion>(
      options: options,
      onSelected: onSelected,
      itemBuilder: (context, s) {
        final cat = catMap[int.tryParse(s.categoryId ?? '')];
        final catColor = cat != null
            ? harmonizeCategory(context, Color(cat.colorValue))
            : cs.onSurfaceVariant;
        final catIcon = cat != null
            ? IconMapper.fromString(cat.icon)
            : Icons.category;

        return KuberSuggestionTile(
          title: s.displayName,
          subtitle: cat?.name,
          icon: catIcon,
          iconColor: catColor,
          amount: s.amount,
        );
      },
    );
  }
}
