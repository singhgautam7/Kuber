import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/constants/info_l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/models/info_config.dart';
import '../../core/theme/app_theme.dart';
import 'kuber_bottom_sheet.dart';
import 'app_button.dart';

class KuberInfoBottomSheet extends StatelessWidget {
  final KuberInfoConfig config;

  const KuberInfoBottomSheet({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = AppLocale.current.languageCode;
    final localizedMap = localizedInfoConfigs[config.title]?[lang];

    final displayTitle = localizedMap?['title'] as String? ?? config.title;
    final displayDescription = localizedMap?['description'] as String? ?? config.description;

    return KuberBottomSheet(
      title: displayTitle,
      actions: AppButton(
        label: config.actionLabel ?? context.l10n.doneLabel,
        type: config.actionLabel != null
            ? AppButtonType.normal
            : AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayDescription.trim().isNotEmpty) ...[
            Text(
              displayDescription,
              style: localeFont(
                fontSize: 16,
                color: cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
          ],
          ...List.generate(config.items.length, (index) {
            final item = config.items[index];
            final localizedItemMap = (localizedMap?['items'] as List?)?[index];
            final displayItemTitle = localizedItemMap?['title'] as String? ?? item.title;
            final displayItemDescription = localizedItemMap?['description'] as String? ?? item.description;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      borderRadius: KuberShape.mediumR,
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: cs.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(width: KuberSpace.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayItemTitle,
                          style: localeFont(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurface,
                            height: 1.5,
                          ),
                        ),
                        Text(
                          displayItemDescription,
                          style: localeFont(
                            fontSize: 14,
                            color: cs.onSurfaceVariant,
                            height: 20 / 14,
                          ),
                        ),
                        if (item.example != null) ...[
                          const SizedBox(height: 9),
                          _ExampleBox(example: item.example!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          if (config.exampleBlock != null) ...[
            _ExampleBlock(block: config.exampleBlock!),
            const SizedBox(height: 8),
          ],
          if (config.customChild != null) ...[
            config.customChild!,
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  static void show(BuildContext context, KuberInfoConfig config) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => KuberInfoBottomSheet(config: config),
    );
  }
}

/// Boxed worked example: input line, then trigger word + a highlighted result
/// chip. Used by info sheets (e.g. About Kuber Notes arithmetic examples).
class _ExampleBox extends StatelessWidget {
  final KuberInfoExample example;

  const _ExampleBox({required this.example});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.mediumR,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.expression,
            style: localeFont(
              fontSize: 14,
              color: cs.onSurface,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                example.trigger,
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(KuberShape.small),
                ),
                child: Text(
                  example.result,
                  style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onPrimary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
/// Money "i" sheet example: surfaceContainerHigh r16 pad 16 gap 12, caps
/// label, sentence, label / value rows (highlight in primary), closing line.
class _ExampleBlock extends StatelessWidget {
  final KuberInfoExampleBlock block;
  const _ExampleBlock({required this.block});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final gap = <Widget>[];
    void add(Widget w) {
      if (gap.isNotEmpty) gap.add(const SizedBox(height: 12));
      gap.add(w);
    }

    add(Text(block.label.toUpperCase(),
        style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)));
    if (block.sentence != null) {
      add(Text(block.sentence!, style: tt.bodyMedium!.copyWith(color: cs.onSurface)));
    }
    for (final r in block.rows) {
      final labelText = Text(r.label, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant));
      final valueStyle = tt.titleSmall!.copyWith(
          color: r.highlight ? cs.primary : cs.onSurface,
          fontFeatures: const [FontFeature.tabularFigures()]);
      // Short values (an amount) sit on the right; sentence-like values
      // ("Saves ₹1,74,682 interest · ends 17 months earlier") go under the
      // label so neither gets squeezed.
      add(r.value.length > 18
          ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              labelText,
              const SizedBox(height: 2),
              Text(r.value, style: valueStyle),
            ])
          : Row(children: [
              Expanded(child: labelText),
              const SizedBox(width: 12),
              Flexible(child: Text(r.value, textAlign: TextAlign.end, style: valueStyle)),
            ]));
    }
    if (block.after != null) {
      add(Text(block.after!, style: tt.bodyMedium!.copyWith(color: cs.onSurface)));
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHigh, borderRadius: KuberShape.largeR),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: gap),
    );
  }
}
