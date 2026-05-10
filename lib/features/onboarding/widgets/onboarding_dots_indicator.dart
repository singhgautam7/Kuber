import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class OnboardingDotsIndicator extends StatelessWidget {
  final int totalPages;
  final int currentPage;

  const OnboardingDotsIndicator({
    super.key,
    required this.totalPages,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalPages, (index) {
        final isActive = index == currentPage;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isActive ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: isActive ? cs.primary : cs.outline,
              borderRadius: BorderRadius.circular(KuberRadius.full),
            ),
          ),
        );
      }),
    );
  }
}
