import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
        KuberSpacing.xl,
        KuberSpacing.lg,
        KuberSpacing.xl,
        viewPadding > 0 ? viewPadding + KuberSpacing.lg : KuberSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)), // Kept 28 for visual match with image
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
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          
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
          const SizedBox(height: KuberSpacing.sm),

          // Central Icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              size: 48,
              color: cs.primary,
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),

          // Subtitle
          if (subtitle != null)
            Text(
              subtitle!.toUpperCase(),
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: cs.primary,
                letterSpacing: 1.5,
              ),
            ),
          const SizedBox(height: KuberSpacing.xxl),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            child: content ?? Text(
              description ?? '',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 15,
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
                  borderRadius: BorderRadius.circular(KuberRadius.lg),
                ),
              ),
              child: Text(
                buttonText,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
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
