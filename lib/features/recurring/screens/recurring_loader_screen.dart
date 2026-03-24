import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../shared/widgets/loading_widgets.dart';

class RecurringLoaderScreen extends ConsumerStatefulWidget {
  const RecurringLoaderScreen({super.key});

  @override
  ConsumerState<RecurringLoaderScreen> createState() =>
      _RecurringLoaderScreenState();
}

class _RecurringLoaderScreenState extends ConsumerState<RecurringLoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted && !_navigating) {
        _navigating = true;
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(recurringProcessResultProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SweepRingWidget(controller: _controller),
              const SizedBox(height: KuberSpacing.xl),

              Text(
                'Processing Recurring',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                'Creating missed transactions...',
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Status pills
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const StatusPill(label: 'NETWORK', value: 'Local Only'),
                  const SizedBox(width: KuberSpacing.md),
                  StatusPill(
                    label: 'PROCESSED',
                    value: '$count transaction${count == 1 ? '' : 's'}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
