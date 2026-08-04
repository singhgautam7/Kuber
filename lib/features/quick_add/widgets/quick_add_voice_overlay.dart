import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../services/quick_add_voice_controller.dart';
import 'quick_add_waveform.dart';

/// Full-screen voice overlay (listening / processing / error) per
/// voice-states.md. Reads the controller's notifiers so the waveform and
/// transcript update without rebuilding the host page.
class QuickAddVoiceOverlay extends StatelessWidget {
  final QuickAddVoiceController controller;
  final VoidCallback onStop;
  final VoidCallback onCancel;
  final VoidCallback onTypeInstead;
  final VoidCallback onRetry;

  const QuickAddVoiceOverlay({
    super.key,
    required this.controller,
    required this.onStop,
    required this.onCancel,
    required this.onTypeInstead,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reducedMotion = MediaQuery.of(context).disableAnimations;

    return ValueListenableBuilder<VoiceState>(
      valueListenable: controller.state,
      builder: (context, state, _) {
        if (state == VoiceState.idle) return const SizedBox.shrink();
        // Solid opaque base so the page never shows through the overlay; the
        // radial glow is a separate layer painted on top of that base.
        return Positioned.fill(
          child: Container(
            color: cs.surface,
            child: Stack(
              children: [
                if (state == VoiceState.listening)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: const Alignment(0, -0.28),
                          radius: 0.9,
                          colors: [
                            cs.primary.withValues(alpha: 0.28),
                            cs.surface.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(KuberSpacing.lg),
                    child: switch (state) {
                      VoiceState.listening =>
                        _listening(context, cs, reducedMotion),
                      VoiceState.processing => _processing(context, cs),
                      VoiceState.error => _error(context, cs),
                      VoiceState.idle => const SizedBox.shrink(),
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _listening(BuildContext context, ColorScheme cs, bool reducedMotion) {
    return Column(
      children: [
        const Spacer(),
        QuickAddWaveform(
          amplitude: controller.amplitude,
          color: cs.primary,
          reducedMotion: reducedMotion,
        ),
        const SizedBox(height: KuberSpacing.xl),
        ValueListenableBuilder<String>(
          valueListenable: controller.transcript,
          builder: (context, text, _) => Text(
            text.isEmpty ? 'Listening…' : text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              height: 1.35,
              color: text.isEmpty ? cs.onSurfaceVariant : cs.onSurface,
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline_rounded,
                size: 13, color: cs.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'On-device · nothing leaves your phone',
              style: TextStyle(fontSize: 11.5, color: cs.onSurfaceVariant),
            ),
          ],
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Cancel',
                type: AppButtonType.outline,
                height: 56,
                fullWidth: true,
                onPressed: onCancel,
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Okay',
                type: AppButtonType.primary,
                height: 56,
                fullWidth: true,
                onPressed: onStop,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _processing(BuildContext context, ColorScheme cs) {
    return Column(
      children: [
        const Spacer(),
        QuickAddWaveform(
          amplitude: controller.amplitude,
          color: context.kuberColors.borderMuted,
          frozen: true,
        ),
        const SizedBox(height: KuberSpacing.xl),
        SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: cs.primary),
        ),
        const SizedBox(height: KuberSpacing.md),
        Text('Understanding…',
            style: TextStyle(fontSize: 15, color: cs.onSurfaceVariant)),
        const SizedBox(height: KuberSpacing.sm),
        ValueListenableBuilder<String>(
          valueListenable: controller.transcript,
          builder: (context, text, _) => Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 56,
          width: double.infinity,
          child: AppButton(
            label: 'Cancel',
            type: AppButtonType.normal,
            height: 56,
            fullWidth: true,
            onPressed: onCancel,
          ),
        ),
      ],
    );
  }

  Widget _error(BuildContext context, ColorScheme cs) {
    return Column(
      children: [
        const Spacer(),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: cs.error.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            border: Border.all(color: cs.error.withValues(alpha: 0.40)),
          ),
          child: Icon(Icons.mic_off_rounded, size: 36, color: cs.error),
        ),
        const SizedBox(height: KuberSpacing.lg),
        Text('Didn’t catch that',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface)),
        const SizedBox(height: KuberSpacing.sm),
        Text(
          'No speech detected. Try again in a quieter spot, or type it instead.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 1.4, color: cs.onSurfaceVariant),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Type instead',
                type: AppButtonType.outline,
                icon: Icons.keyboard_alt_outlined,
                height: 52,
                fullWidth: true,
                onPressed: onTypeInstead,
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Try again',
                type: AppButtonType.primary,
                icon: Icons.refresh_rounded,
                height: 52,
                fullWidth: true,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ],
    );
  }

}
