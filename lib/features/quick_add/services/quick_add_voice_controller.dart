import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// The four voice UI states from voice-states.md.
enum VoiceState { idle, listening, processing, error }

/// Microphone permission outcome, distinguishing "ask again" from "must open
/// system settings" so the pill can route correctly.
enum MicPermission { granted, denied, permanentlyDenied }

/// Owns the on-device speech engine and exposes granular [ValueNotifier]s so the
/// waveform, transcript and overlay rebuild independently — never a whole-page
/// setState per amplitude tick. Plain object (not Riverpod) because it wraps
/// native resources tied to the page's lifecycle.
class QuickAddVoiceController {
  final _speech = stt.SpeechToText();
  bool _initialized = false;

  final state = ValueNotifier<VoiceState>(VoiceState.idle);

  /// Mic amplitude normalized to 0..1, drives the waveform bars.
  final amplitude = ValueNotifier<double>(0);

  /// Live (partial + final) transcript.
  final transcript = ValueNotifier<String>('');

  /// Error tag for the error overlay copy (null when none).
  final errorMessage = ValueNotifier<String?>(null);

  Future<MicPermission> checkPermission() =>
      _map(Permission.microphone.status);

  Future<MicPermission> requestPermission() =>
      _map(Permission.microphone.request());

  Future<MicPermission> _map(Future<PermissionStatus> future) async {
    final status = await future;
    if (status.isGranted || status.isLimited) return MicPermission.granted;
    if (status.isPermanentlyDenied || status.isRestricted) {
      return MicPermission.permanentlyDenied;
    }
    return MicPermission.denied;
  }

  /// Starts a listening session. [onTranscript] fires with each partial/final
  /// result so the page can stream it into the shared text field (unified
  /// parser). Returns false if the engine could not start.
  Future<bool> start({required void Function(String text) onTranscript}) async {
    if (!_initialized) {
      _initialized = await _speech.initialize(
        onStatus: _onStatus,
        onError: (e) {
          errorMessage.value = e.errorMsg;
          state.value = VoiceState.error;
        },
        debugLogging: false,
      );
    }
    if (!_initialized) {
      errorMessage.value = 'unavailable';
      state.value = VoiceState.error;
      return false;
    }

    transcript.value = '';
    errorMessage.value = null;
    amplitude.value = 0;
    state.value = VoiceState.listening;

    await _speech.listen(
      onResult: (r) {
        transcript.value = r.recognizedWords;
        onTranscript(r.recognizedWords);
      },
      onSoundLevelChange: (level) {
        // Android reports roughly -2..10; normalize to 0..1 for the bars.
        amplitude.value = ((level + 2) / 12).clamp(0.0, 1.0);
      },
      // Auto-finalize ~2.5s after the user stops speaking, and cap a session at
      // 30s. Without pauseFor the engine keeps listening and the overlay would
      // never dismiss on its own once speech was captured.
      listenOptions: stt.SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.dictation,
        pauseFor: const Duration(milliseconds: 2500),
        listenFor: const Duration(seconds: 30),
      ),
    );
    return true;
  }

  void _onStatus(String status) {
    switch (status) {
      case 'notListening':
        if (state.value == VoiceState.listening) {
          state.value = VoiceState.processing;
        }
        break;
      case 'done':
        // Recognition fully finished: success if we heard anything, else error.
        if (state.value == VoiceState.error) return;
        if (transcript.value.trim().isEmpty) {
          errorMessage.value = 'no_speech';
          state.value = VoiceState.error;
        } else {
          amplitude.value = 0;
          state.value = VoiceState.idle;
        }
        break;
    }
  }

  /// User tapped Stop: finalize the session.
  Future<void> stop() async {
    if (state.value == VoiceState.listening) {
      state.value = VoiceState.processing;
    }
    await _speech.stop();
  }

  /// User tapped X / cancel: discard and reset.
  Future<void> cancel() async {
    await _speech.cancel();
    reset();
  }

  void reset() {
    state.value = VoiceState.idle;
    transcript.value = '';
    amplitude.value = 0;
    errorMessage.value = null;
  }

  void dispose() {
    _speech.cancel();
    state.dispose();
    amplitude.dispose();
    transcript.dispose();
    errorMessage.dispose();
  }
}
