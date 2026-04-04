import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/info_config.dart';
import 'kuber_bottom_sheet.dart';
import 'app_button.dart';

class KuberInfoBottomSheet extends StatelessWidget {
  final KuberInfoConfig config;

  const KuberInfoBottomSheet({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: config.title,
      subtitle: "LEARN MORE",
      actions: AppButton(
        label: 'Got it',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            config.description,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ...config.items.map((item) => Padding(
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
                            item.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.description,
                            style: GoogleFonts.inter(
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
              )),
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
