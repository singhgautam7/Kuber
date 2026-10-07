import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class WIPBottomSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? description;
  final Widget? content;
  final String buttonText;

  const WIPBottomSheet({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle = 'WORK IN PROGRESS',
    this.description,
    this.content,
    this.buttonText = 'Got it',
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        KuberSpace.xl,
        KuberSpace.lg,
        KuberSpace.xl,
        viewPadding > 0 ? viewPadding + KuberSpace.lg : KuberSpace.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(KuberShape.extraLarge)), // Kept 28 for visual match with image
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(KuberShape.full),
            ),
          ),
          const SizedBox(height: KuberSpace.lg),
          
          // Close button row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, size: 18, color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.sm),

          // Central Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(KuberShape.medium),
            ),
            child: Icon(
              icon,
              size: 48,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: KuberSpace.xl),

          // Title
          Text(
            title,
            style: localeFont(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: KuberSpace.sm),

          // Subtitle
          if (subtitle != null)
            Text(
              subtitle!.toUpperCase(),
              style: localeFont(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: cs.primary,
                letterSpacing: 1.5,
              ),
            ),
          const SizedBox(height: KuberSpace.xxl),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg),
            child: content ?? Text(
              description ?? '',
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 16,
                height: 1.6,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // CTA Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: cs.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberShape.medium),
                ),
              ),
              child: Text(
                buttonText,
                style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showWIPBottomSheet({
  required BuildContext context,
  required IconData icon,
  required String title,
  String? subtitle,
  String? description,
  Widget? content,
  String buttonText = 'Got it',
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WIPBottomSheet(
      icon: icon,
      title: title,
      subtitle: subtitle,
      description: description,
      content: content,
      buttonText: buttonText,
    ),
  );
}