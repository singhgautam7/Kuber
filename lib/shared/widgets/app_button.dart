import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

enum AppButtonType {
  primary,   // accent fill (submit)
  normal,    // default neutral
  outline,   // bordered
  danger,    // red (delete)
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final IconData? icon;
  final bool fullWidth;
  final double? width;
  final double height;
  final bool isLoading;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.type = AppButtonType.normal,
    this.icon,
    this.fullWidth = false,
    this.width,
    this.height = 52,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    // Style configuration
    final Color backgroundColor;
    final Color foregroundColor;
    final BorderSide? borderSide;
    
    switch (type) {
      case AppButtonType.primary:
        backgroundColor = cs.primary;
        foregroundColor = Colors.white;
        borderSide = null;
        break;
      case AppButtonType.normal:
        backgroundColor = cs.surfaceContainerHigh;
        foregroundColor = cs.onSurface;
        borderSide = BorderSide(color: cs.outline.withValues(alpha: 0.1));
        break;
      case AppButtonType.outline:
        backgroundColor = Colors.transparent;
        foregroundColor = cs.onSurface;
        borderSide = BorderSide(color: cs.outline.withValues(alpha: 0.3));
        break;
      case AppButtonType.danger:
        backgroundColor = Colors.transparent;
        foregroundColor = cs.error;
        borderSide = BorderSide(color: cs.error.withValues(alpha: 0.5));
        break;
    }

    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.md),
        side: borderSide ?? BorderSide.none,
      ),
      disabledBackgroundColor: backgroundColor.withValues(alpha: 0.12),
      disabledForegroundColor: foregroundColor.withValues(alpha: 0.38),
    );

    final content = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: buttonStyle,
        child: content,
      ),
    );
  }
}
