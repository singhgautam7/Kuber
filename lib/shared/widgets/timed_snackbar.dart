import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

Flushbar? _currentFlushbar;

void showKuberSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  _currentFlushbar?.dismiss();

  final barColor = isError ? KuberColors.expense : KuberColors.income;

  _currentFlushbar = Flushbar(
    message: message,
    messageColor: KuberColors.textPrimary,
    messageSize: 14,
    duration: const Duration(seconds: 7),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    borderRadius: BorderRadius.circular(KuberRadius.md),
    backgroundColor: KuberColors.surfaceCard,
    borderColor: isError ? KuberColors.expense : KuberColors.border,
    borderWidth: 1,
    icon: Icon(
      isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
      color: barColor,
      size: 22,
    ),
    leftBarIndicatorColor: barColor,
    showProgressIndicator: true,
    progressIndicatorBackgroundColor: KuberColors.border,
    progressIndicatorValueColor:
        AlwaysStoppedAnimation<Color>(KuberColors.primary),
    mainButton: actionLabel != null
        ? TextButton(
            onPressed: () {
              _currentFlushbar?.dismiss();
              onAction?.call();
            },
            child: Text(
              actionLabel,
              style: const TextStyle(
                color: KuberColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : null,
    boxShadows: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
    isDismissible: true,
    dismissDirection: FlushbarDismissDirection.HORIZONTAL,
  )..show(context);
}
