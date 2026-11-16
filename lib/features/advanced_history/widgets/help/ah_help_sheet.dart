import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../dashboard/ah_sheets.dart';

Future<void> showAhHelpSheet(BuildContext context) =>
    ahShowSheet<void>(context, (_) => const AhHelpSheet());

/// How this page works: a picture of the action row, then five rows.
class AhHelpSheet extends StatelessWidget {
  const AhHelpSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final rows = [
      (Icons.filter_list_rounded, l.ahdFilter, l.ahdHelpFilter),
      (Icons.category_outlined, l.ahdGroup, l.ahdHelpGroup),
      (Icons.sort_rounded, l.ahdSort, l.ahdHelpSort),
      (Icons.add_chart_rounded, l.ahdCharts, l.ahdHelpCharts),
      (Icons.bookmarks_outlined, l.ahdSaved, l.ahdHelpSaved),
    ];
    Widget chip(IconData i, String t, {bool wide = false}) => Expanded(
          flex: wide ? 3 : 2,
          child: Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
                color: cs.surfaceContainerHigh, borderRadius: KuberShape.fullR),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(i, size: 16, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(t,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(fontSize: 12, color: cs.onSurface)),
                ),
              ],
            ),
          ),
        );
    return KuberBottomSheet(
      title: l.ahdHelpTitle,
      actions: AppButton(
        label: l.doneLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A small picture of the action row, numbered like the rows below.
          Container(
            padding: const EdgeInsets.all(KuberSpace.md),
            decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: KuberShape.largeR,
                border: Border.all(color: cs.outlineVariant)),
            child: Column(
              children: [
                Row(children: [
                  chip(Icons.filter_list_rounded, l.ahdFilter, wide: true),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  chip(Icons.category_outlined, l.ahdGroup),
                  chip(Icons.sort_rounded, l.ahdSort),
                  chip(Icons.bookmarks_outlined, l.ahdSaved),
                ]),
              ],
            ),
          ),
          const SizedBox(height: KuberSpace.lg),
          for (var i = 0; i < rows.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: KuberSpace.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                        color: cs.secondaryContainer,
                        borderRadius: KuberShape.mediumR),
                    child: Icon(rows[i].$1,
                        size: 20, color: cs.onSecondaryContainer),
                  ),
                  const SizedBox(width: KuberSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(rows[i].$2,
                            style: localeFont(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface)),
                        const SizedBox(height: 2),
                        Text(rows[i].$3,
                            style: localeFont(
                                fontSize: 14,
                                color: cs.onSurfaceVariant,
                                height: 1.4)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
