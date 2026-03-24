import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/prefs_keys.dart';

enum AppPermissionStatus {
  granted,
  denied,
  notRequired,
}

class PermissionStates {
  final AppPermissionStatus notifications;
  final AppPermissionStatus storage;
  final bool isBiometricAvailable;
  final bool isBiometricEnabled;

  const PermissionStates({
    required this.notifications,
    required this.storage,
    required this.isBiometricAvailable,
    required this.isBiometricEnabled,
  });

  PermissionStates copyWith({
    AppPermissionStatus? notifications,
    AppPermissionStatus? storage,
    bool? isBiometricAvailable,
    bool? isBiometricEnabled,
  }) {
    return PermissionStates(
      notifications: notifications ?? this.notifications,
      storage: storage ?? this.storage,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
    );
  }
}

final permissionProvider =
    AsyncNotifierProvider<PermissionNotifier, PermissionStates>(
  PermissionNotifier.new,
);

class PermissionNotifier extends AsyncNotifier<PermissionStates> {
  final _auth = LocalAuthentication();

  @override
  Future<PermissionStates> build() async {
    return _checkAll();
  }

  Future<PermissionStates> _checkAll() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check Notifications
    final notificationStatus = await Permission.notification.status;
    
    // Check Storage
    // On Android 13+, READ_EXTERNAL_STORAGE is deprecated. 
    // Usually MediaStore doesn't need runtime permission for app-specific files.
    // For general file picking, we check storage permission.
    AppPermissionStatus storageStatus;
    if (Platform.isAndroid) {
      // Simplification: Android 13+ (SDK 33) doesn't use STORAGE permission for many things
      // We'll check the manageExternalStorage for a broader check if needed, 
      // but usually 'storage' is enough for basic needs or 'notRequired'.
      final status = await Permission.storage.status;
      storageStatus = status.isGranted ? AppPermissionStatus.granted : AppPermissionStatus.denied;
    } else {
      storageStatus = AppPermissionStatus.notRequired;
    }

    // Check Biometrics
    final isAvailable = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
    final isEnabled = prefs.getBool(PrefsKeys.biometricsEnabled) ?? false;

    return PermissionStates(
      notifications: notificationStatus.isGranted 
          ? AppPermissionStatus.granted 
          : AppPermissionStatus.denied,
      storage: storageStatus,
      isBiometricAvailable: isAvailable,
      isBiometricEnabled: isEnabled,
    );
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _checkAll());
  }

  Future<void> requestNotification() async {
    await Permission.notification.request();
    await refresh();
  }

  Future<void> requestStorage() async {
    await Permission.storage.request();
    await refresh();
  }
}
