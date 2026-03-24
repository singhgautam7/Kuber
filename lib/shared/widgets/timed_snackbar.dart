import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

Flushbar? _currentFlushbar;

void _dismissInstantly() {
  final route = _currentFlushbar?.flushbarRoute;
  if (route != null && route.navigator != null) {
    route.navigator!.removeRoute(route);
  }
  _currentFlushbar = null;
}

void showKuberSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  String? actionLabel,
  VoidCallback? onAction,
  String? secondaryActionLabel,
  VoidCallback? onSecondaryAction,
}) {
  final cs = Theme.of(context).colorScheme;

  _currentFlushbar?.dismiss();

  final barColor = isError ? cs.error : cs.tertiary;
  bool actionFired = false;

  final closeButton = IconButton(
    icon: const Icon(Icons.close, size: 18),
    color: cs.onSurfaceVariant,
    onPressed: _dismissInstantly,
  );

  final Widget mainButton;
  if (actionLabel != null || secondaryActionLabel != null) {
    mainButton = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (secondaryActionLabel != null)
          TextButton(
            onPressed: () {
              if (actionFired) return;
              actionFired = true;
              _dismissInstantly();
              onSecondaryAction?.call();
            },
            child: Text(
              secondaryActionLabel,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        if (actionLabel != null)
          TextButton(
            onPressed: () {
              if (actionFired) return;
              actionFired = true;
              _dismissInstantly();
              onAction?.call();
            },
            child: Text(
              actionLabel,
              style: TextStyle(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        closeButton,
      ],
    );
  } else {
    mainButton = closeButton;
  }

  _currentFlushbar = Flushbar(
    messageText: TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(seconds: 7),
      builder: (context, value, child) {
        final innerCs = Theme.of(context).colorScheme;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(
                color: innerCs.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: value,
              minHeight: 2,
              valueColor:
                  AlwaysStoppedAnimation<Color>(innerCs.primary),
              backgroundColor: innerCs.outline,
              borderRadius: BorderRadius.circular(1),
            ),
          ],
        );
      },
    ),
    duration: const Duration(seconds: 7),
    flushbarPosition: FlushbarPosition.TOP,
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    borderRadius: BorderRadius.circular(KuberRadius.md),
    backgroundColor: cs.surfaceContainer,
    borderColor: isError ? cs.error : cs.outline,
    borderWidth: 1,
    icon: Icon(
      isError
          ? Icons.error_outline_rounded
          : Icons.check_circle_outline_rounded,
      color: barColor,
      size: 22,
    ),
    leftBarIndicatorColor: barColor,
    showProgressIndicator: false,
    mainButton: mainButton,
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
