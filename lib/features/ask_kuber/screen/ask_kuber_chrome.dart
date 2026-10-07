import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/services/shortcut_pin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_menu.dart';
import 'kuber_mark.dart';

/// Pin spec for the Ask Kuber home-screen shortcut (overflow > Add to home
/// screen). Mirrors the static `ask_kuber` shortcut in shortcuts.xml.
const _kAskKuberPinSpec = PinShortcutSpec(
  shortcutId: 'ask_kuber',
  shortLabel: 'Ask Kuber',
  longLabel: 'Ask Kuber',
  iconDrawable: 'ic_shortcut_ask',
  deepLink: 'kuber://app/ask-kuber',
);

/// Ask Kuber top bar: the pulsing Kuber mark, the title, and the overflow menu
/// (How it works / Copy last response / Clear chat).
class AskKuberHeader extends StatelessWidget {
  final Animation<double> pulse;
  final bool thinking;
  final bool canCopy;
  final VoidCallback onHowItWorks;
  final VoidCallback onCopy;
  final VoidCallback onFeedback;
  final VoidCallback onClear;

  const AskKuberHeader({
    super.key,
    required this.pulse,
    required this.thinking,
    required this.canCopy,
    required this.onHowItWorks,
    required this.onCopy,
    required this.onFeedback,
    required this.onClear,
  });

  Future<void> _openMenu(BuildContext anchor) async {
    final v = await showKuberMenu<int>(
      context: anchor,
      entries: [
        const KuberMenuEntry(
          value: 0,
          icon: Icons.info_outline_rounded,
          label: 'How it works',
        ),
        if (canCopy)
          const KuberMenuEntry(
            value: 1,
            icon: Icons.content_copy_rounded,
            label: 'Copy last response',
          ),
        const KuberMenuEntry(
          value: 2,
          icon: Icons.feedback_outlined,
          label: 'Share Feedback',
        ),
        const KuberMenuEntry(
          value: 4,
          icon: Icons.add_to_home_screen_rounded,
          label: 'Add to home screen',
        ),
        const KuberMenuEntry.divider(),
        const KuberMenuEntry(
          value: 3,
          icon: Icons.delete_outline_rounded,
          label: 'Clear chat',
          destructive: true,
        ),
      ],
    );
    if (v == null || !anchor.mounted) return;
    switch (v) {
      case 0:
        onHowItWorks();
      case 1:
        onCopy();
      case 2:
        onFeedback();
      case 4:
        requestPinShortcut(anchor, _kAskKuberPinSpec);
      default:
        onClear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Board 3.8: back, mark + title/subline, overflow.
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Row(
          children: [
            AppIconButton(
              icon: Icons.arrow_back_rounded,
              semanticLabel: 'Back',
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 6),
            PulsingKuberMark(size: 32, pulse: pulse, thinking: thinking),
            const SizedBox(width: KuberSpace.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ask Kuber',
                    maxLines: 1,
                    style: tt.titleLarge!.copyWith(color: cs.onSurface),
                  ),
                  Text(
                    'On-device • No internet required',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Builder(
              builder: (anchor) => AppIconButton(
                icon: Icons.more_vert_rounded,
                semanticLabel: 'More options',
                onPressed: () => _openMenu(anchor),
              ),
            ),
          ],
        ),
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
        KuberSpace.screenMargin,
        KuberSpace.sm,
        KuberSpace.screenMargin,
        math.max(KuberSpace.md, MediaQuery.of(context).padding.bottom),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Opacity(
              opacity: isProcessing ? 0.6 : 1.0,
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                alignment: Alignment.centerLeft,
                child: TextField(
                  controller: controller,
                  enabled: !isProcessing,
                  maxLines: 4,
                  minLines: 1,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(color: cs.onSurface),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    isDense: true,
                    // The pill is the field; no theme fill inside it.
                    filled: false,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    hintText: 'Ask about your money...',
                    hintStyle: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (controller.text.trim().isNotEmpty) onSend();
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: KuberSpace.sm),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              final isEmpty = value.text.trim().isEmpty;
              final active = !isProcessing && !isEmpty;
              return GestureDetector(
                onTap: active ? onSend : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: active ? cs.primary : cs.surfaceContainerHigh,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isProcessing
                        ? SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: cs.onSurfaceVariant,
                            ),
                          )
                        : KuberSendIcon(
                            size: 18,
                            color: active ? cs.onPrimary : cs.onSurfaceVariant,
                          ),
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

/// The Ask Kuber send glyph from the design set: a filled paper-plane pointing
/// up-right. Material's `Icons.send_rounded` points horizontally, so we draw the
/// design's exact path (`M3 12l18-8-7 18-3-8-8-2z` on a 24x24 viewBox).
class KuberSendIcon extends StatelessWidget {
  final Color color;
  final double size;
  const KuberSendIcon({super.key, required this.color, this.size = 18});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _SendIconPainter(color),
    );
  }
}

class _SendIconPainter extends CustomPainter {
  final Color color;
  const _SendIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0; // scale from the 24x24 design viewBox
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    // M3 12 l18 -8 l-7 18 l-3 -8 (closes back to 3,12)
    final path = Path()
      ..moveTo(3 * s, 12 * s)
      ..lineTo(21 * s, 4 * s)
      ..lineTo(14 * s, 22 * s)
      ..lineTo(11 * s, 14 * s)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SendIconPainter oldDelegate) =>
      oldDelegate.color != color;
}
