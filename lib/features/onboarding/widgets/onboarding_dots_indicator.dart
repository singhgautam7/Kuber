import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int currentPage;
  final int pageCount;

  const OnboardingDotsIndicator({
    super.key,
    required this.currentPage,
    this.pageCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(pageCount, (index) {
        final active = index == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: active ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? cs.primary : cs.outline,
            borderRadius: BorderRadius.circular(KuberRadius.full),
          ),
        );
      }),
    );
  }
}
