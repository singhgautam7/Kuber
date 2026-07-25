import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/kuber_autocomplete_overlay.dart';
import '../providers/ledger_provider.dart';

/// Dropdown overlay for person name autocomplete in Add/Edit Ledger.
/// Uses the shared [KuberAutocompleteOverlay] and [KuberSuggestionTile] widgets.
class LedgerSuggestionOverlay extends ConsumerWidget {
  const LedgerSuggestionOverlay({
    required this.options,
    required this.onSelected,
    super.key,
  });

  final Iterable<LedgerPersonSuggestion> options;
  final void Function(LedgerPersonSuggestion) onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return KuberAutocompleteOverlay<LedgerPersonSuggestion>(
      options: options,
      onSelected: onSelected,
      itemBuilder: (context, s) {
        final icon =
            s.isSettled ? Icons.check_circle_outline_rounded : Icons.person_rounded;
        final iconColor = s.isSettled ? cs.onSurfaceVariant : cs.primary;
        final subtitle = s.isSettled ? 'SETTLED' : 'UNSETTLED';

        return KuberSuggestionTile(
          title: s.personName,
          subtitle: subtitle,
          icon: icon,
          iconColor: iconColor,
          amount: s.remainingAmount,
        );
      },
    );
  }
}
