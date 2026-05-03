import 'package:flutter/material.dart';

class KuberPageHeader extends StatelessWidget {
  final String title;
  final String description;
  final IconData actionIcon;
  final VoidCallback? onAction;
  final String? actionTooltip;
  final bool isLoading;

  const KuberPageHeader({
    super.key,
    required this.title,
    required this.description,
    this.actionIcon = Icons.add_rounded,
    this.onAction,
    this.actionTooltip,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                    height: 1.15,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // Action Button
          if (onAction != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Tooltip(
                message: actionTooltip ?? '',
                child: GestureDetector(
                  onTap: isLoading ? null : onAction,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isLoading
                          ? cs.onSurface.withValues(alpha: 0.38)
                          : cs.primary,
                      shape: BoxShape.circle,
                      boxShadow: isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: cs.primary.withValues(alpha: 0.2),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(14.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Icon(
                            actionIcon,
                            color: Colors.white,
                            size: 26,
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
