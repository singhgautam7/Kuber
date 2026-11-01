import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_search_pill.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../more_content.dart';

/// More search (board 3.7): an inline search pill over a grouped list of
/// matching More entries ("Section · subtitle"). Entries come from the single
/// source of truth, built against the More tab's [hostContext] so every tap
/// behaves exactly as it does from the tab.
class MoreSearchScreen extends ConsumerStatefulWidget {
  final BuildContext hostContext;
  const MoreSearchScreen({super.key, required this.hostContext});

  @override
  ConsumerState<MoreSearchScreen> createState() => _MoreSearchScreenState();
}

class _MoreSearchScreenState extends ConsumerState<MoreSearchScreen> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;
    final sections = buildMoreSections(
      widget.hostContext,
      ref,
      isDevMode: isDevMode,
    );
    final q = _query.trim().toLowerCase();
    final results = <(MoreSection, MoreEntry)>[
      if (q.isNotEmpty)
        for (final s in sections)
          for (final e in s.entries)
            if (e.label.toLowerCase().contains(q) ||
                e.subtitle.toLowerCase().contains(q))
              (s, e),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _ExpandIn(
                child: KuberSearchPill(
                  controller: _controller,
                  hint: 'Search More',
                  textInputAction: TextInputAction.done,
                  interceptBack: false,
                  backLabel: 'Back',
                  onChanged: (v) => setState(() => _query = v),
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  0,
                  KuberSpace.screenMargin,
                  KuberSpace.xl,
                ),
                children: [
                  if (q.isNotEmpty) ...[
                    KuberSectionHeader(
                      title: results.length == 1
                          ? '1 result'
                          : '${results.length} results',
                    ),
                    if (results.isNotEmpty)
                      KuberGroup(
                        children: [
                          for (final (s, e) in results)
                            KuberListRow(
                              leading: Icon(
                                e.icon,
                                size: 24,
                                color: cs.primary,
                              ),
                              title: splitTrailingTag(e.label).$1,
                              titleTrailing:
                                  splitTrailingTag(e.label).$2 == null
                                  ? null
                                  : KuberPill(
                                      label: splitTrailingTag(e.label).$2!,
                                    ),
                              subtitle: '${s.title} · ${e.subtitle}',
                              trailing: const KuberChevron(),
                              onTap: () {
                                Navigator.of(context).pop();
                                e.onTap();
                              },
                            ),
                        ],
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-shot entrance: the pill grows from the trailing edge (where the More
/// header's search icon sits) to full width. Reduced motion: fade only.
class _ExpandIn extends StatelessWidget {
  final Widget child;
  const _ExpandIn({required this.child});

  @override
  Widget build(BuildContext context) {
    final reduced = KuberMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduced
          ? KuberMotion.reducedFade
          : const Duration(milliseconds: 250),
      curve: reduced ? Curves.linear : Curves.easeOutCubic,
      child: child,
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: reduced
            ? c
            : ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  widthFactor: t,
                  child: c,
                ),
              ),
      ),
    );
  }
}
