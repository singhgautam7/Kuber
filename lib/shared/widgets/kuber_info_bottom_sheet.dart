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
        label: context.l10n.doneLabel,
        type: AppButtonType.primary,
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
                fontSize: 15,
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
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: cs.primary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayItemTitle,
                          style: localeFont(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayItemDescription,
                          style: localeFont(
                            fontSize: 13,
                            color: cs.onSurfaceVariant,
                            height: 1.4,
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
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            example.expression,
            style: localeFont(
              fontSize: 13,
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
                  fontSize: 13,
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
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  example.result,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
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