import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingFit extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Alignment alignment;

  const OnboardingFit({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: KuberSpacing.xl),
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth - padding.horizontal;
        return Padding(
          padding: padding,
          child: Align(
            alignment: alignment,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: alignment,
              child: SizedBox(width: width.clamp(280.0, 520.0), child: child),
            ),
          ),
        );
      },
    );
  }
}
