import 'package:local_auth/local_auth.dart';

class BiometricService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> canAuthenticate() async {
    try {
      final isSupported = await auth.isDeviceSupported();
      final canCheck = await auth.canCheckBiometrics;
      // return true if the device is capable of either biometrics or device lock
      return isSupported || canCheck;
    } catch (_) {
      return false;
    }
  }

  /// A fingerprint or face is set up. `canAuthenticate` can be true without
  /// one: it only says the hardware or a device lock could do the job.
  Future<bool> hasEnrolled() async {
    try {
      return (await auth.getAvailableBiometrics()).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await auth.authenticate(
        localizedReason: 'Unlock Kuber to continue',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
