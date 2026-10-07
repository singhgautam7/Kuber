import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: KuberShape.fullR,
                  border: Border.all(color: cs.primary, width: 2),
                ),
                child: Row(
                  children: [
                    AppIconButton(
                      icon: Icons.arrow_back_rounded,
                      kind: AppIconButtonKind.plain,
                      semanticLabel: 'Back',
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        autofocus: true,
                        textAlignVertical: TextAlignVertical.center,
                        onChanged: (v) => setState(() => _query = v),
                        style: theme.textTheme.bodyLarge,
                        decoration: InputDecoration(
                          hintText: 'Search More',
                          hintStyle: theme.textTheme.bodyLarge!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          filled: false,
                          isCollapsed: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      AppIconButton(
                        icon: Icons.close_rounded,
                        kind: AppIconButtonKind.plain,
                        semanticLabel: 'Clear',
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                      ),
                  ],
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
