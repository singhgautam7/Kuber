import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import 'package:kuber/shared/widgets/kuber_list.dart';
import '../../../../shared/widgets/kuber_home_widget_title.dart';
import '../../ask_kuber/screen/kuber_mark.dart';

/// One suggestion: label shown on the chip + the query actually sent.
class _Suggestion {
  final String label;
  final IconData icon;
  const _Suggestion(this.label, this.icon);
}

const _pool = <_Suggestion>[
  _Suggestion('This month so far', Icons.currency_rupee_rounded),
  _Suggestion('Top category', Icons.bar_chart_rounded),
  _Suggestion('Net worth', Icons.account_balance_wallet_rounded),
  _Suggestion('Biggest expense', Icons.trending_up_rounded),
  _Suggestion('Am I overspending?', Icons.warning_amber_rounded),
  _Suggestion('Upcoming dues', Icons.event_rounded),
];

/// Full home-tab surface for Ask Kuber. Redesigned per review: a centered
/// mark + label read as one balanced unit (rather than the previous
/// mark-left/input-right split that felt lopsided), and the 4 suggestions
/// sit in a single horizontally-scrolling row instead of a wrap, so the
/// widget never grows past a fixed, predictable height. Registered in the
/// home widget editor as `ask_kuber_widget`.
///
/// Suggestion taps push `/more/ask-kuber` with the query as route `extra`.
/// Wiring the target screen to read that and auto-send it is a small
/// follow-up noted in HANDOFF.md (`AskKuberScreen` currently takes no
/// constructor args).
class AskKuberHomeWidget extends StatefulWidget {
  const AskKuberHomeWidget({super.key});

  @override
  State<AskKuberHomeWidget> createState() => _AskKuberHomeWidgetState();
}

class _AskKuberHomeWidgetState extends State<AskKuberHomeWidget>
    with WidgetsBindingObserver {
  late List<_Suggestion> _picks;

  @override
  void initState() {
    super.initState();
    _picks = _shuffled();
    // Android usually keeps the process warm, so a plain initState shuffle
    // would freeze the same 4 picks for the app's whole lifetime. Reshuffle
    // each time the app returns to the foreground so "close and reopen" always
    // shows a fresh set.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() => _picks = _shuffled());
    }
  }

  List<_Suggestion> _shuffled() =>
      (List.of(_pool)..shuffle(Random())).take(4).toList();

  void _open(BuildContext context, [String? query]) {
    context.push('/more/ask-kuber', extra: query);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Board 3.2a: card pad 12, a 48 prompt pill with a filled 36 arrow, then
    // a scrolling row of assist chips.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const KuberHomeWidgetTitle(title: 'Ask Kuber'),
        KuberCard(
          padding: const EdgeInsets.all(KuberSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: cs.surfaceContainerHigh,
                shape: const StadiumBorder(),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _open(context),
                  child: SizedBox(
                    height: 48,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 6),
                      child: Row(
                        children: [
                          KuberMarkWidget(
                            size: 20,
                            bare: true,
                            color: cs.primary,
                          ),
                          const SizedBox(width: KuberSpace.md),
                          Expanded(
                            child: Text(
                              'Ask about your money…',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyLarge!.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 18,
                              color: cs.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpace.md),
              SizedBox(
                height: 32,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _picks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, i) => _SuggestionChip(
                    suggestion: _picks[i],
                    onTap: () => _open(context, _picks[i].label),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final _Suggestion suggestion;
  final VoidCallback onTap;
  const _SuggestionChip({required this.suggestion, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // M3 assist chip: h32, radius 8, 1dp outlineVariant, 18 primary icon.
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: KuberShape.smallR,
        side: BorderSide(color: cs.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(suggestion.icon, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                suggestion.label,
                style: theme.textTheme.labelLarge!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
