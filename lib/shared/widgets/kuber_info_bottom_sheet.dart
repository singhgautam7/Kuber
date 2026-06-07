import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/constants/info_l10n.dart';
import 'package:flutter/material.dart';
import '../../../core/models/info_config.dart';
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
          Text(
            displayDescription,
            style: localeFont(
              fontSize: 15,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
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