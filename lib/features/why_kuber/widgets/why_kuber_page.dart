import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../onboarding/widgets/onboarding_fit.dart';
import '../../onboarding/widgets/onboarding_skip_button.dart';
import 'page_accounts.dart';
import 'page_analytics.dart';
import 'page_features.dart';
import 'page_modules.dart';
import 'page_notebook.dart';

/// One Why Kuber page (storyboards.md), the same in Welcome, More and the
/// Home card. [onSkip] null keeps the Skip slot empty so the stage does not
/// move; [onTry] null hides Try it (Welcome).
class WhyKuberPage extends ConsumerWidget {
  final int index;
  final bool active;
  final bool played;
  final VoidCallback? onPlayed;
  final VoidCallback? onSkip;
  final VoidCallback? onTry;

  const WhyKuberPage({
    super.key,
    required this.index,
    required this.active,
    required this.played,
    this.onPlayed,
    this.onSkip,
    this.onTry,
  });

  static const count = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args = PageArgs(active, played, onPlayed, onTry);
    final body = switch (index) {
      0 => NotebookPage(args),
      1 => AccountsPage(args),
      2 => ModulesPage(args),
      3 => AnalyticsPage(args),
      _ => FeaturesPage(args),
    };
    return Column(
      children: [
        if (onSkip != null)
          OnboardingSkipButton(onSkip: onSkip!)
        else
          const SizedBox(height: 56),
        Expanded(
          child: OnboardingFit(alignment: Alignment.center, child: body),
        ),
      ],
    );
  }
}

/// What every page body receives from [WhyKuberPage].
class PageArgs {
  final bool active;
  final bool played;
  final VoidCallback? onPlayed;
  final VoidCallback? onTry;
  const PageArgs(this.active, this.played, this.onPlayed, this.onTry);
}

/// Stage, headline, subhead and Try it, centred (board HV33.1).
class PageLayout extends StatelessWidget {
  final Widget stage;
  final String title;
  final Widget sub;
  final String tryLabel;
  final VoidCallback? onTry;

  const PageLayout({
    super.key,
    required this.stage,
    required this.title,
    required this.sub,
    required this.tryLabel,
    this.onTry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        stage,
        const SizedBox(height: KuberSpace.xl),
        Text(
          title,
          textAlign: TextAlign.center,
          style: tt.headlineSmall!.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: KuberSpace.md),
        sub,
        if (onTry != null) ...[
          const SizedBox(height: KuberSpace.lg),
          TextButton.icon(
            onPressed: onTry,
            icon: const Icon(Icons.arrow_outward_rounded, size: 18),
            label: Text(tryLabel),
          ),
        ],
      ],
    );
  }
}

/// Centred bodyLarge subhead.
Widget pageSub(BuildContext context, String text) => Text(
  text,
  textAlign: TextAlign.center,
  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
    color: Theme.of(context).colorScheme.onSurfaceVariant,
  ),
);
