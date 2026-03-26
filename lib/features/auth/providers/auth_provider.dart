import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/services/biometric_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<bool> with WidgetsBindingObserver {
  final Ref _ref;
  final _biometricService = BiometricService();
  bool _isAppActive = true;
  bool _isAuthenticatedInSession = false;

  AuthNotifier(this._ref) : super(false) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  void _initialize() async {
    final settings = await _ref.read(settingsProvider.future);
    if (settings.biometricsEnabled) {
      // Check if biometrics is still available at system level
      final isAvailable = await _biometricService.canAuthenticate();
      if (!isAvailable) {
        // Auto-disable if not available anymore
        await _ref.read(settingsProvider.notifier).setBiometricsEnabled(false);
        return;
      }
      
      // Start locked on launch
      state = true;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _isAppActive = true;
      _handleAppResume();
    } else if (state == AppLifecycleState.paused) {
      _isAppActive = false;
    }
  }

  void _handleAppResume() async {
    final settings = _ref.read(settingsProvider).valueOrNull;
    if (settings?.biometricsEnabled == true) {
      final canAuth = await _biometricService.canAuthenticate();

      if (!canAuth) {
        // Auto-disable biometric lock in app if not available anymore
        await _ref.read(settingsProvider.notifier).setBiometricsEnabled(false);
        return;
      }

      if (!_isAuthenticatedInSession) {
        // Add a small delay as requested
        await Future.delayed(const Duration(milliseconds: 400));
        if (_isAppActive) {
          state = true;
        }
      }
    }
  }

  Future<void> authenticate() async {
    final success = await _biometricService.authenticate();
    if (success) {
      state = false;
      _isAuthenticatedInSession = true;
    }
  }

  void resetSessionAuth() {
    _isAuthenticatedInSession = false;
  }
}
