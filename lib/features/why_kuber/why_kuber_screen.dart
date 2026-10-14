import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/l10n_ext.dart';
import '../more/more_content.dart' show moreScrollToSignatureProvider;
import '../onboarding/widgets/onboarding_nav_bar.dart';
import 'why_kuber_store.dart';
import 'widgets/why_kuber_page.dart';

/// Why Kuber tour opened from More or the Home card (entry-points.md b, c):
/// 5 dots, Skip on pages 1 to 4 closes, Back on 2 to 5, Next, Done on page
/// 5, and Try it on every page. Animations replay each time it opens.
/// Reaching page 5 marks the tour as seen.
class WhyKuberScreen extends ConsumerStatefulWidget {
  const WhyKuberScreen({super.key});

  @override
  ConsumerState<WhyKuberScreen> createState() => _WhyKuberScreenState();
}

class _WhyKuberScreenState extends ConsumerState<WhyKuberScreen> {
  final _pages = PageController();
  final _played = <int>{};
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPage(int i) {
    setState(() => _page = i);
    if (i == WhyKuberPage.count - 1) WhyKuberStore.markSeen();
  }

  void _go(int i) => _pages.animateToPage(
    i,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final last = _page == WhyKuberPage.count - 1;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: WhyKuberPage.count,
                onPageChanged: _onPage,
                itemBuilder: (context, i) => WhyKuberPage(
                  index: i,
                  active: i == _page,
                  played: _played.contains(i),
                  onPlayed: () => _played.add(i),
                  onSkip: i < WhyKuberPage.count - 1
                      ? () => Navigator.of(context).pop()
                      : null,
                  onTry: () => whyKuberTryIt(context, ref, i),
                ),
              ),
            ),
            Semantics(
              label: l.homeV33TourPageA11y(_page + 1, WhyKuberPage.count),
              child: OnboardingNavBar(
                currentPage: _page,
                pageCount: WhyKuberPage.count,
                showBack: _page > 0,
                onBack: _page == 0 ? null : () => _go(_page - 1),
                primaryLabel: last ? l.homeV33TourDone : l.homeV33TourNext,
                onPrimary: last
                    ? () => Navigator.of(context).pop()
                    : () => _go(_page + 1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Try it on Why Kuber page [i] (entry-points.md b): close the tour, then
/// open the page's screen. Shared by the Home card tour and More's replay.
void whyKuberTryIt(BuildContext context, WidgetRef ref, int i) {
  final router = GoRouter.of(context);
  Navigator.of(context).pop();
  switch (i) {
    case 0:
      router.push('/add-transaction');
    case 1:
      router.push('/more/accounts');
    case 2:
      router.push('/more/upcoming-events');
    case 3:
      router.go('/analytics');
    default:
      router.go('/more');
      ref.read(moreScrollToSignatureProvider.notifier).state++;
  }
}
