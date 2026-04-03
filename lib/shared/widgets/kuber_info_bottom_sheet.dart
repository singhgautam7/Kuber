import 'package:flutter/material.dart';

import '../../core/models/info_config.dart';
import 'app_button.dart';
import 'kuber_bottom_sheet.dart';

class KuberInfoBottomSheet extends StatelessWidget {
  final KuberInfoConfig config;

  const KuberInfoBottomSheet({
    super.key,
    required this.config,
  });

  static Future<void> show(BuildContext context, KuberInfoConfig config) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) => KuberInfoBottomSheet(config: config),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return KuberBottomSheet(
      title: config.title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Description
          Text(
            config.description,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),

          // Items List
          ...config.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon with subtle tint
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        size: 22,
                        color: cs.primary.withValues(alpha: 0.8),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant.withValues(alpha: 0.6),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),

          const SizedBox(height: 8),

          // Got it button
          AppButton(
            label: 'Got it',
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            type: AppButtonType.primary,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
