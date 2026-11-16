import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../common/ah_motion.dart';

/// Expanded state is remembered for the session (not across launches).
bool _readbackExpanded = false;

/// Collapsible "In plain words".
class ReadbackCard extends StatefulWidget {
  const ReadbackCard({super.key, required this.text});
  final String text;

  @override
  State<ReadbackCard> createState() => _ReadbackCardState();
}

class _ReadbackCardState extends State<ReadbackCard> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final reduced = AhMotion.reduced(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          key: const ValueKey('ahf-readback-toggle'),
          borderRadius: BorderRadius.circular(KuberShape.small),
          onTap: () => setState(() => _readbackExpanded = !_readbackExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l.ahfPlainWords,
                    style: localeFont(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: cs.primary)),
                AnimatedRotation(
                  turns: _readbackExpanded ? 0.5 : 0,
                  duration: reduced ? AhMotion.instant : AhMotion.fast,
                  child: Icon(Icons.expand_more_rounded, color: cs.primary),
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: reduced ? AhMotion.instant : AhMotion.reflow,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _readbackExpanded
              ? Padding(
                  key: const ValueKey('ahf-readback-text'),
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(widget.text,
                      style: localeFont(
                          fontSize: 15, height: 1.45, color: cs.onSurface)),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
