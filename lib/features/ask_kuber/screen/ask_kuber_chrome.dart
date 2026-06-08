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
  final bool canCopy;
  final VoidCallback onHowItWorks;
  final VoidCallback onCopy;
  final VoidCallback onClear;

  const AskKuberHeader({
    super.key,
    required this.pulse,
    required this.thinking,
    required this.canCopy,
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
              elevation: 0,
              menuPadding: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                side: BorderSide(color: cs.outline),
              ),
              onSelected: (v) => switch (v) {
                0 => onHowItWorks(),
                1 => onCopy(),
                _ => onClear(),
              },
              itemBuilder: (context) => [
                _item(cs, 0, Icons.info_outline_rounded, 'How it works'),
                _item(cs, 1, Icons.content_copy_rounded, 'Copy last response',
                    enabled: canCopy),
                const PopupMenuDivider(height: 9),
                _item(cs, 2, Icons.delete_outline_rounded, 'Clear chat',
                    danger: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<int> _item(
    ColorScheme cs,
    int value,
    IconData icon,
    String label, {
    bool enabled = true,
    bool danger = false,
  }) {
    final color = !enabled
        ? cs.onSurfaceVariant.withValues(alpha: 0.4)
        : danger
            ? cs.error
            : cs.onSurface;
    final iconColor = !enabled
        ? cs.onSurfaceVariant.withValues(alpha: 0.4)
        : danger
            ? cs.error
            : cs.onSurfaceVariant;
    return PopupMenuItem(
      value: value,
      enabled: enabled,
      height: 36,
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 10),
          Text(label,
              style: localeFont(
                  fontSize: 13.5, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}

/// The pill input row. Send button animates colour on text changes (150ms) and
/// shows a spinner while a query is processing. The field fades while loading.
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
            child: Opacity(
              opacity: isProcessing ? 0.6 : 1.0,
              child: Container(
                constraints: const BoxConstraints(minHeight: 46),
                decoration: BoxDecoration(
                  color: cs.surfaceContainer,
                  borderRadius: BorderRadius.circular(KuberRadius.lg),
                  border: Border.all(color: cs.outline),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  enabled: !isProcessing,
                  maxLines: 4,
                  minLines: 1,
                  style: localeFont(
                      fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 13),
                    hintText: 'Ask about your money...',
                    hintStyle:
                        localeFont(fontSize: 14, color: cs.onSurfaceVariant),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (controller.text.trim().isNotEmpty) onSend();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final isEmpty = value.text.trim().isEmpty;
              final active = !isProcessing && !isEmpty;
              return GestureDetector(
                onTap: active ? onSend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.surfaceContainer,
                    borderRadius: BorderRadius.circular(KuberRadius.lg),
                    border: Border.all(
                        color: active ? cs.primary : cs.outline),
                  ),
                  child: Center(
                    child: isProcessing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: cs.onSurfaceVariant),
                          )
                        : Icon(Icons.send_rounded,
                            size: 18,
                            color: active ? cs.onPrimary : cs.onSurfaceVariant),
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
