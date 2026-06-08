import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import 'kuber_mark.dart';

/// Ask Kuber top bar: the pulsing Kuber mark, the title, and the overflow menu
/// (How it works / Copy last response / Clear chat).
class AskKuberHeader extends StatelessWidget {
  final Animation<double> pulse;
  final bool thinking;
  final VoidCallback onHowItWorks;
  final VoidCallback onCopy;
  final VoidCallback onClear;

  const AskKuberHeader({
    super.key,
    required this.pulse,
    required this.thinking,
    required this.onHowItWorks,
    required this.onCopy,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            KuberSpacing.md, KuberSpacing.sm, KuberSpacing.sm, KuberSpacing.sm),
        child: Row(
          children: [
            PulsingKuberMark(size: 34, pulse: pulse, thinking: thinking),
            const SizedBox(width: KuberSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ask Kuber',
                      style: localeFont(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface)),
                  Text('On-device • No internet required',
                      style: localeFont(
                          fontSize: 11, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            PopupMenuButton<int>(
              icon: Icon(Icons.more_vert_rounded, color: cs.onSurfaceVariant),
              color: cs.surfaceContainer,
              onSelected: (v) => switch (v) {
                0 => onHowItWorks(),
                1 => onCopy(),
                _ => onClear(),
              },
              itemBuilder: (context) => [
                _item(cs, 0, 'How it works'),
                _item(cs, 1, 'Copy last response'),
                _item(cs, 2, 'Clear chat'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _item(ColorScheme cs, int value, String label) {
    return PopupMenuItem(
      value: value,
      child: Text(label, style: localeFont(fontSize: 14, color: cs.onSurface)),
    );
  }
}

/// The pill input row with a send button that animates colour on text changes
/// and shows a spinner while a query is processing.
class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isProcessing;
  final VoidCallback onSend;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.isProcessing,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: cs.surface,
      padding: EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        KuberSpacing.sm,
        KuberSpacing.lg,
        math.max(KuberSpacing.md, MediaQuery.of(context).padding.bottom),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isProcessing,
              maxLines: 4,
              minLines: 1,
              style: localeFont(fontSize: 15, color: cs.onSurface),
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              decoration: InputDecoration(
                hintText: 'Ask about your spending...',
                hintStyle: localeFont(
                    fontSize: 15,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) {
                if (controller.text.trim().isNotEmpty) onSend();
              },
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final isEmpty = value.text.trim().isEmpty;
              final isDisabled = isProcessing || isEmpty;
              return GestureDetector(
                onTap: isDisabled ? null : onSend,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isDisabled
                        ? cs.onSurfaceVariant.withValues(alpha: 0.2)
                        : cs.primary,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                  ),
                  child: Center(
                    child: isProcessing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: cs.onSurfaceVariant),
                          )
                        : Icon(Icons.send_rounded,
                            size: 22,
                            color: isDisabled
                                ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                : cs.onPrimary),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
