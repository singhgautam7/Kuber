import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/locale_font.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../tags/data/tag.dart';

/// Shared tags display and selector tile used by both normal and transfer forms.
class TagsTile extends StatelessWidget {
  final List<Tag> selectedTags;
  final VoidCallback onTap;

  const TagsTile({super.key, required this.selectedTags, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return KuberListRow(
      onTap: onTap,
      leading: const KuberIconTile(icon: Icons.sell_outlined),
      title: selectedTags.isEmpty
          ? context.l10n.noTagsSelected
          : context.l10n.tagsSelectedCount('${selectedTags.length}'),
      subtitle: sentenceCase(context.l10n.tagsUpper),
      below: selectedTags.isEmpty
          ? null
          : Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final tag in selectedTags)
                    KuberChip(label: '#${tag.name}'),
                ],
              ),
            ),
      trailing: const KuberChevron(),
    );
  }
}
