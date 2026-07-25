import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';

enum VoiceState {
  listening,
  failed,
  unsupported,
}

class VoiceOverlay extends StatefulWidget {
  final ValueChanged<String> onTranscriptCaptured;
  final VoidCallback onCancel;

  const VoiceOverlay({
    super.key,
    required this.onTranscriptCaptured,
    required this.onCancel,
  });

  @override
  State<VoiceOverlay> createState() => _VoiceOverlayState();
}

class _VoiceOverlayState extends State<VoiceOverlay>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  VoiceState _state = VoiceState.listening;
  String _currentTranscript = '';
  double _soundLevel = 0.0;

  late AnimationController _pulseController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onError: (val) {
          if (mounted && _currentTranscript.trim().isEmpty) {
            setState(() => _state = VoiceState.failed);
          }
        },
        onStatus: (status) {
          if (status == 'done' || status == 'notListening') {
            if (mounted && _currentTranscript.trim().isEmpty && _state == VoiceState.listening) {
              setState(() => _state = VoiceState.failed);
            }
          }
        },
      );

      if (available) {
        _startListening();
      } else {
        if (mounted) setState(() => _state = VoiceState.unsupported);
      }
    } catch (_) {
      if (mounted) setState(() => _state = VoiceState.failed);
    }
  }

  void _startListening() {
    setState(() {
      _state = VoiceState.listening;
      _currentTranscript = '';
    });
    _speech.listen(
      onResult: (val) {
        if (mounted) {
          setState(() {
            _currentTranscript = val.recognizedWords;
          });
        }
      },
      onSoundLevelChange: (level) {
        if (mounted) {
          setState(() {
            _soundLevel = level.clamp(0.0, 10.0) / 10.0;
          });
        }
      },
    );
  }

  void _stopAndCommit() async {
    await _speech.stop();
    if (_currentTranscript.trim().isNotEmpty) {
      widget.onTranscriptCaptured(_currentTranscript.trim());
    } else {
      setState(() => _state = VoiceState.failed);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpacing.lg,
            vertical: KuberSpacing.md,
          ),
          child: Column(
            children: [
              // Top space / Header
              const SizedBox(height: KuberSpacing.xl),

              // Main body area
              Expanded(
                child: _state == VoiceState.listening
                    ? _buildListeningView(cs)
                    : _buildFailedView(cs),
              ),

              // Privacy guarantee footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 13, color: cs.onSurfaceVariant),
                  const SizedBox(width: 6),
                  Text(
                    'On-device · private, nothing leaves your phone',
                    style: localeFont(
                      fontSize: 11.5,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListeningView(ColorScheme cs) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Mic orb with staggered pulse rings
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            final scale = 1.0 + (_pulseController.value * 0.08);
            return Stack(
              alignment: Alignment.center,
              children: [
                // Outer ring 2
                Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.4),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withValues(
                        alpha: 0.15 * (1.0 - _pulseController.value),
                      ),
                    ),
                  ),
                ),
                // Outer ring 1
                Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.2),
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: cs.primary.withValues(
                        alpha: 0.25 * (1.0 - _pulseController.value),
                      ),
                    ),
                  ),
                ),
                // Main Mic Orb
                Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mic_rounded,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: KuberSpacing.xl),

        // 32-bar waveform animation
        SizedBox(
          height: 36,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(32, (index) {
              final offset = (index % 8) / 8.0;
              return AnimatedBuilder(
                animation: _waveController,
                builder: (context, child) {
                  double waveValue = ((_waveController.value + offset) % 1.0);
                  double barHeight = 6.0 +
                      (24.0 * waveValue * (_soundLevel > 0.05 ? _soundLevel * 2 : 0.4));
                  return Container(
                    width: 3,
                    height: barHeight.clamp(4.0, 32.0),
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    decoration: BoxDecoration(
                      color: cs.primary,
                      borderRadius: BorderRadius.circular(KuberRadius.full),
                    ),
                  );
                },
              );
            }),
          ),
        ),

        const SizedBox(height: KuberSpacing.xl),

        // Live transcript
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 60),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: _currentTranscript.isEmpty
                      ? 'Listening...'
                      : _currentTranscript,
                  style: localeFont(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: _currentTranscript.isEmpty
                        ? cs.onSurfaceVariant
                        : cs.onSurface,
                  ),
                ),
                WidgetSpan(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _pulseController.value > 0.5 ? 1.0 : 0.0,
                        child: Container(
                          width: 2,
                          height: 20,
                          margin: const EdgeInsets.only(left: 4),
                          color: cs.primary,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const Spacer(),

        // Controls row (Cancel X / Done Check)
        Row(
          children: [
            // Cancel button
            GestureDetector(
              onTap: widget.onCancel,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: cs.outline),
                ),
                child: Icon(Icons.close_rounded,
                    size: 24, color: cs.onSurface),
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            // Done button
            Expanded(
              child: AppButton(
                label: 'Done',
                icon: Icons.check_rounded,
                type: AppButtonType.primary,
                onPressed: _stopAndCommit,
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.lg),
      ],
    );
  }

  Widget _buildFailedView(ColorScheme cs) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Muted mic circle
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            shape: BoxShape.circle,
            border: Border.all(color: cs.outline),
          ),
          child: Icon(
            Icons.mic_off_rounded,
            size: 40,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: KuberSpacing.lg),

        Text(
          "Didn't catch that",
          style: localeFont(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: KuberSpacing.xs),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
          child: Text(
            'No speech detected. Try again in a quieter spot, or type it instead.',
            textAlign: TextAlign.center,
            style: localeFont(
              fontSize: 14,
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),

        const Spacer(),

        // Action buttons
        Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'Type instead',
                icon: Icons.keyboard_outlined,
                type: AppButtonType.outline,
                onPressed: widget.onCancel,
              ),
            ),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: AppButton(
                label: 'Try again',
                icon: Icons.mic_rounded,
                type: AppButtonType.primary,
                onPressed: _startListening,
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.lg),
      ],
    );
  }
}
