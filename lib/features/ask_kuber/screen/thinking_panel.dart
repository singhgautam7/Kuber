import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../models/thinking_info.dart';

/// Splits `**bold**` markers into alternating normal/bold spans.
List<InlineSpan> markerSpans(String text, TextStyle base, TextStyle bold) {
  final parts = text.split('**');
  final spans = <InlineSpan>[];
  for (int i = 0; i < parts.length; i++) {
    if (parts[i].isEmpty) continue;
    spans.add(TextSpan(text: parts[i], style: i.isOdd ? bold : base));
  }
  return spans;
}

/// The time + "Show / Hide thinking" toggle row beneath a Kuber message.
class ThinkingMetaRow extends StatelessWidget {
  final String time;
  final bool expanded;
  final VoidCallback onToggle;
  const ThinkingMetaRow(
      {super.key,
      required this.time,
      required this.expanded,
      required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(time, style: localeFont(fontSize: 11, color: cs.onSurfaceVariant)),
          GestureDetector(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.fromLTRB(7, 5, 9, 5),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: BorderRadius.circular(KuberRadius.sm),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedRotation(
                    turns: expanded ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.chevron_right_rounded,
                        size: 11, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    expanded ? 'HIDE THINKING' : 'SHOW THINKING',
                    style: localeFont(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Expanded reasoning trace: an inner card with numbered steps.
class ThinkingPanel extends StatelessWidget {
  final ThinkingInfo thinking;
  const ThinkingPanel({super.key, required this.thinking});

  /// Falls back to synthesized steps for chat history saved before steps existed.
  List<ThinkingStep> get _steps {
    if (thinking.steps.isNotEmpty) return thinking.steps;
    final out = <ThinkingStep>[];
    if (thinking.dateFilter.isNotEmpty) {
      out.add(ThinkingStep('Parsed time range: **${thinking.dateFilter}**.'));
    }
    if (thinking.scanned.isNotEmpty) {
      out.add(ThinkingStep('Scanned **${thinking.scanned.join(', ')}**.'));
    }
    if (out.isEmpty) {
      out.add(const ThinkingStep('Computed result from the scanned data.'));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final base = localeFont(fontSize: 12, color: cs.onSurfaceVariant, height: 1.45);
    final bold = base.copyWith(color: cs.onSurface, fontWeight: FontWeight.w500);
    final steps = _steps;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (int i = 0; i < steps.length; i++)
              Padding(
                padding: EdgeInsets.only(top: i == 0 ? 0 : 9),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text('${i + 1}',
                          style: localeFont(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: cs.primary)),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text.rich(TextSpan(
                          children: markerSpans(steps[i].text, base, bold))),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 7x14 primary block, binary blink at 900ms (no smooth fade), per design.
class BlinkingCaret extends StatefulWidget {
  final Color color;
  const BlinkingCaret({super.key, required this.color});

  @override
  State<BlinkingCaret> createState() => _BlinkingCaretState();
}

class _BlinkingCaretState extends State<BlinkingCaret>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) => Opacity(
        opacity: _ctrl.value < 0.5 ? 1.0 : 0.0,
        child: Container(
          width: 7,
          height: 14,
          margin: const EdgeInsets.only(left: 2),
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }
}
