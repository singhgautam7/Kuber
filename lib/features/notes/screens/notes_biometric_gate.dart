import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/notes_provider.dart';

/// Biometric gate for Kuber Notes (screen 1l). Wraps any Notes entry point
/// (landing or a direct note deep link). Prompts once per app session — the
/// in-memory session flag mirrors the app-wide biometric semantics.
class NotesBiometricGate extends ConsumerStatefulWidget {
  final Widget child;

  const NotesBiometricGate({super.key, required this.child});

  @override
  ConsumerState<NotesBiometricGate> createState() =>
      _NotesBiometricGateState();
}

class _NotesBiometricGateState extends ConsumerState<NotesBiometricGate> {
  final _biometric = BiometricService();
  bool _promptTriggered = false;

  bool get _gateNeeded {
    final requireNotes = ref.read(notesBiometricRequiredProvider);
    final appWide =
        ref.read(settingsProvider).valueOrNull?.biometricsEnabled ?? false;
    final unlocked = ref.read(notesUnlockedThisSessionProvider);
    return requireNotes && appWide && !unlocked;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePrompt());
  }

  Future<void> _maybePrompt() async {
    if (!mounted || !_gateNeeded || _promptTriggered) return;
    _promptTriggered = true;
    await _authenticate();
  }

  Future<void> _authenticate() async {
    final success = await _biometric.authenticate();
    if (!mounted) return;
    if (success) {
      ref.read(notesUnlockedThisSessionProvider.notifier).state = true;
    }
    setState(() => _promptTriggered = false);
  }

  @override
  Widget build(BuildContext context) {
    final requireNotes = ref.watch(notesBiometricRequiredProvider);
    final appWide = ref.watch(settingsProvider
        .select((s) => s.valueOrNull?.biometricsEnabled ?? false));
    final unlocked = ref.watch(notesUnlockedThisSessionProvider);

    if (!requireNotes || !appWide || unlocked) return widget.child;

    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                border: Border(top: BorderSide(color: cs.outline)),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(KuberRadius.lg)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: cs.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: cs.primary.withValues(alpha: 0.3)),
                    ),
                    child: Icon(Icons.fingerprint_rounded,
                        size: 30, color: cs.primary),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Unlock Kuber Notes',
                    style: localeFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Confirm your identity to view your notes',
                    textAlign: TextAlign.center,
                    style: localeFont(
                      fontSize: 12.5,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _authenticate,
                    child: Container(
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: cs.outline),
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Text(
                        'Use PIN instead',
                        style: localeFont(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
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
