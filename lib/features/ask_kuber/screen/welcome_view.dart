import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import 'kuber_mark.dart';

/// One starter prompt: a label plus a registry (Material) icon.
class _StarterPrompt {
  final String text;
  final IconData icon;
  const _StarterPrompt(this.text, this.icon);
}

/// Empty-chat treatment: a static primary glow, the pulsing Kuber mark, a
/// time-of-day greeting, a subline, and a randomized stack of starter cards.
/// Tapping a card fills the input and sends in one gesture. Shown only when no
/// user message exists (first open / after Clear chat); never with history.
class WelcomeView extends StatefulWidget {
  /// Pre-composed, time-of-day + name greeting (computed once at screen mount).
  final String greeting;

  /// Shared pulse controller value (idle pulse) driving the centerpiece mark.
  final Animation<double> pulse;

  /// Tap handler: fills the input and sends [prompt].
  final void Function(String prompt) onSend;

  const WelcomeView({
    super.key,
    required this.greeting,
    required this.pulse,
    required this.onSend,
  });

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with SingleTickerProviderStateMixin {
  // Canonical pool. Six are picked at random per mount.
  static const _all = [
    _StarterPrompt('How much did I spend this month?', Icons.currency_rupee_rounded),
    _StarterPrompt('Top spending category', Icons.bar_chart_rounded),
    _StarterPrompt("What's my net worth?", Icons.account_balance_wallet_rounded),
    _StarterPrompt('Show my loans', Icons.account_balance_rounded),
    _StarterPrompt('How do I add a transaction?', Icons.add_rounded),
    _StarterPrompt('Tell me something interesting', Icons.lightbulb_outline_rounded),
    _StarterPrompt('Am I overspending anywhere?', Icons.warning_amber_rounded),
    _StarterPrompt('How do I set a budget?', Icons.flag_outlined),
    _StarterPrompt("What's my biggest expense?", Icons.trending_up_rounded),
    _StarterPrompt('How much did I spend this week?', Icons.calendar_today_rounded),
  ];

  late final List<_StarterPrompt> _cards;
  late final AnimationController _entry;
  late final Animation<double> _entryAnim;

  @override
  void initState() {
    super.initState();
    // Pre-shuffle once on creation, not in build().
    _cards = (List.of(_all)..shuffle()).take(6).toList();
    _entry = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 320));
    _entryAnim = CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic);
    _entry.forward();
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        // Static primary glow behind everything.
        Positioned.fill(
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.16),
                  radius: 0.85,
                  colors: [
                    cs.primary.withValues(alpha: 0.30),
                    cs.primary.withValues(alpha: 0.06),
                    cs.primary.withValues(alpha: 0.0),
                  ],
                  stops: const [0.0, 0.5, 0.72],
                ),
              ),
            ),
          ),
        ),
        FadeTransition(
          opacity: _entryAnim,
          child: AnimatedBuilder(
            animation: _entryAnim,
            builder: (context, child) => Transform.translate(
              offset: Offset(0, (1 - _entryAnim.value) * 6),
              child: child,
            ),
            // Centered, and scroll-resilient so short screens never overflow.
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.lg, vertical: KuberSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          PulsingKuberMark(size: 84, pulse: widget.pulse),
                          const SizedBox(height: KuberSpacing.lg),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 320),
                            child: Text(
                              widget.greeting,
                              textAlign: TextAlign.center,
                              style: localeFont(
                                // Compressed: large body title, not a screen header.
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: Text(
                              'Your on-device finance assistant. Ask me anything.',
                              textAlign: TextAlign.center,
                              style: localeFont(
                                  fontSize: 13.5, color: cs.onSurfaceVariant),
                            ),
                          ),
                          const SizedBox(height: KuberSpacing.xl),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 360),
                            child: Column(
                              children: [
                                for (final card in _cards)
                                  _StarterCard(
                                    prompt: card,
                                    cs: cs,
                                    onTap: () => widget.onSend(card.text),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StarterCard extends StatelessWidget {
  final _StarterPrompt prompt;
  final ColorScheme cs;
  final VoidCallback onTap;
  const _StarterCard(
      {required this.prompt, required this.cs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: cs.surfaceContainer.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(KuberRadius.full),
            border: Border.all(color: cs.outline.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
                ),
                child: Icon(prompt.icon, size: 16, color: cs.primary),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Text(
                  prompt.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: localeFont(
                      fontSize: 13.5, fontWeight: FontWeight.w500, color: cs.onSurface),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
