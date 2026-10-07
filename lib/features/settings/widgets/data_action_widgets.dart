import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:kuber/shared/widgets/kuber_list.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widgets.dart';

// ---------------------------------------------------------------------------
// Confirmation bottom sheet
// ---------------------------------------------------------------------------

class ConfirmActionSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String confirmLabel;
  final bool destructive;
  final bool warnDescription;
  final VoidCallback onConfirm;

  const ConfirmActionSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.onConfirm,
    this.destructive = false,
    this.warnDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        KuberSpace.xl,
        KuberSpace.lg,
        KuberSpace.xl,
        viewPadding > 0 ? viewPadding + KuberSpace.lg : KuberSpace.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberShape.extraLarge),
        ),
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
              borderRadius: BorderRadius.circular(KuberShape.full),
            ),
          ),
          const SizedBox(height: KuberSpace.xl),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: destructive
                  ? cs.error.withValues(alpha: 0.1)
                  : cs.secondaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: destructive ? cs.error : cs.primary,
            ),
          ),
          const SizedBox(height: KuberSpace.lg),

          // Title
          Text(
            title,
            style: localeFont(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KuberSpace.sm),

          // Description
          if (warnDescription)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KuberSpace.lg),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
                border: Border.all(color: cs.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
                  const SizedBox(width: KuberSpace.md),
                  Expanded(
                    child: Text(
                      description,
                      style: localeFont(
                        fontSize: 12,
                        color: cs.error,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              description,
              style: localeFont(
                fontSize: 14,
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: KuberSpace.xl),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: destructive ? cs.error : cs.primary,
                foregroundColor: destructive ? cs.onError : cs.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberShape.medium),
                ),
              ),
              child: Text(
                confirmLabel,
                style: localeFont(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: KuberSpace.md),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.surfaceContainerHigh,
                foregroundColor: cs.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberShape.medium),
                  side: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Text(
                context.l10n.cancelLabel,
                style: localeFont(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row / card widget
// ---------------------------------------------------------------------------

class DataActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final bool destructive;

  /// Something needs attention (e.g. last backup failed): error tile and an
  /// error-coloured description.
  final bool alert;

  const DataActionRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    this.destructive = false,
    this.alert = false,
  });

  /// One row of a [KuberGroup] (board 3.12): tone tile, title, description,
  /// chevron. Destructive rows use an errorContainer tile and error title.
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final danger = destructive || alert;
    return InkWell(
      onTap: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpace.lg,
          vertical: KuberSpace.md,
        ),
        child: Row(
          children: [
            KuberIconTile(
              icon: icon,
              tone: danger ? KuberTone.error : KuberTone.secondary,
            ),
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: tt.titleMedium!.copyWith(
                      color: destructive ? cs.error : cs.onSurface,
                    ),
                  ),
                  Text(
                    description,
                    style: tt.bodyMedium!.copyWith(
                      color: alert ? cs.error : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.sm),
            const KuberChevron(),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Full-screen loading overlay
// ---------------------------------------------------------------------------

class DataLoadingOverlay extends StatefulWidget {
  final String message;
  const DataLoadingOverlay({super.key, required this.message});

  @override
  State<DataLoadingOverlay> createState() => _DataLoadingOverlayState();
}

class _DataLoadingOverlayState extends State<DataLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SweepRingWidget(controller: _controller),
              const SizedBox(height: KuberSpace.lg),
              Text(
                widget.message,
                style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
