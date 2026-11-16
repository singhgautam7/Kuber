import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../query/query_ast.dart';
import '../../query/query_labels.dart';
import 'value_pickers.dart';

const kPickableFields = [
  QueryField.type,
  QueryField.amount,
  QueryField.category,
  QueryField.account,
  QueryField.tag,
  QueryField.date,
  QueryField.has,
  QueryField.source,
  QueryField.words,
];

String fieldHint(QueryField f, AppLocalizations l) => switch (f) {
      QueryField.type => l.ahfHintType,
      QueryField.amount => l.ahfHintAmount,
      QueryField.category => l.ahfHintCategory,
      QueryField.account => l.ahfHintAccount,
      QueryField.tag => l.ahfHintTag,
      QueryField.date => l.ahfHintDate,
      QueryField.has => l.ahfHintHas,
      QueryField.source => l.ahfHintSource,
      _ => l.ahfHintWords,
    };

String _example(QueryField f) => switch (f) {
      QueryField.type => 'type:expense',
      QueryField.amount => 'amount:>500',
      QueryField.category => 'category:food',
      QueryField.account => 'account:hdfc',
      QueryField.tag => 'tag:trip',
      QueryField.date => 'date:2026-03',
      QueryField.has => 'has:attachment',
      QueryField.source => 'source:sms',
      _ => '"swiggy"',
    };

/// "Add a filter": the nine fields. A tap opens the value picker.
class FieldList extends StatelessWidget {
  const FieldList({super.key, required this.onPick});
  final void Function(QueryField) onPick;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    return Column(
      children: [
        for (final f in kPickableFields)
          Semantics(
            button: true,
            label: '${fieldLabel(f, l)}, ${fieldHint(f, l)}',
            excludeSemantics: true,
            onTap: () => onPick(f),
            child: InkWell(
              key: ValueKey('ahf-field-${f.name}'),
              borderRadius: BorderRadius.circular(KuberShape.medium),
              onTap: () => onPick(f),
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    KuberIconTile(icon: fieldIcon(f), size: 36, glyph: 20),
                    const SizedBox(width: KuberSpace.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(fieldLabel(f, l),
                              style: localeFont(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: cs.onSurface)),
                          Text(fieldHint(f, l),
                              style: localeFont(
                                  fontSize: 13, color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    IconButton(
                      key: ValueKey('ahf-field-info-${f.name}'),
                      tooltip: fieldLabel(f, l),
                      icon: Icon(Icons.info_outline_rounded,
                          size: 20, color: cs.onSurfaceVariant),
                      onPressed: () => showFieldInfo(context, f),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// "i" of a field row: what it is and how to type it.
void showFieldInfo(BuildContext context, QueryField f) {
  final l = context.l10n;
  final cs = Theme.of(context).colorScheme;
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => KuberBottomSheet(
      title: fieldLabel(f, l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(fieldHint(f, l),
              style: localeFont(fontSize: 15, color: cs.onSurface, height: 1.4)),
          const SizedBox(height: KuberSpace.md),
          Text(l.ahfTypeItLike,
              style: localeFont(fontSize: 13, color: cs.onSurfaceVariant)),
          const SizedBox(height: KuberSpace.xs),
          Text(_example(f),
              style: monoFont(fontSize: 14, color: cs.primary)),
        ],
      ),
    ),
  );
}
