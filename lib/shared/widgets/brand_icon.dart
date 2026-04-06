import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class BrandIcon extends StatelessWidget {
  final double size;
  final double? radius;
  final bool useImage;

  const BrandIcon({
    super.key,
    this.size = 80,
    this.radius,
    this.useImage = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(radius ?? KuberRadius.xl),
      ),
      child: useImage 
        ? Image.asset(
            'android/play_store_512.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          )
        : Icon(
            Icons.account_balance_wallet_rounded,
            size: size * 0.5,
            color: cs.primary,
          ),
    );
  }
}
