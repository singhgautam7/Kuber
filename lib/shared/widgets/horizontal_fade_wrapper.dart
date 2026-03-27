import 'package:flutter/material.dart';

class HorizontalFadeWrapper extends StatelessWidget {
  final Widget child;
  final double fadeWidth;

  const HorizontalFadeWrapper({
    super.key,
    required this.child,
    this.fadeWidth = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            cs.surface,
            Colors.transparent,
            Colors.transparent,
            cs.surface,
          ],
          stops: [
            0.0,
            fadeWidth / bounds.width,
            1.0 - (fadeWidth / bounds.width),
            1.0,
          ],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstOut,
      child: child,
    );
  }
}
