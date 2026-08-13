import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../shared/widgets/timed_snackbar.dart';

/// Describes a launcher shortcut the user can pin to their home screen from a
/// screen's app bar overflow. Passed to [KuberAppBar.pinShortcut].
class PinShortcutSpec {
  /// Stable id, e.g. `kuber_cards`.
  final String shortcutId;

  /// Short launcher label, e.g. `Cards`.
  final String shortLabel;

  /// Long launcher label, e.g. `Kuber Cards`.
  final String longLabel;

  /// Android drawable resource name (no extension), e.g. `ic_shortcut_cards`.
  final String iconDrawable;

  /// Deep link the pinned shortcut opens, e.g. `kuber://app/cards`.
  final String deepLink;

  const PinShortcutSpec({
    required this.shortcutId,
    required this.shortLabel,
    required this.longLabel,
    required this.iconDrawable,
    required this.deepLink,
  });
}

/// Thin wrapper over the native `com.grs.kuber/shortcuts` method channel, which
/// pins a launcher shortcut via `ShortcutManagerCompat.requestPinShortcut`
/// (Android 8.0+, launchers that opt in). All calls are async and platform-side
/// instant, so they never block the UI thread. Best-effort: any failure
/// resolves to `false` rather than throwing.
class ShortcutPinService {
  const ShortcutPinService();

  static const MethodChannel _channel = MethodChannel('com.grs.kuber/shortcuts');

  /// Whether the current launcher supports user-triggered pinning.
  Future<bool> isSupported() async {
    try {
      return await _channel.invokeMethod<bool>('isPinShortcutSupported') ??
          false;
    } catch (_) {
      return false;
    }
  }

  /// Requests the launcher pin [spec]. Returns true when the request was
  /// accepted for display (the launcher then shows its own confirm dialog);
  /// false when unsupported or the request failed. We do not track whether the
  /// user ultimately accepted — Android does not report that reliably.
  Future<bool> pin(PinShortcutSpec spec) async {
    try {
      return await _channel.invokeMethod<bool>('pinShortcut', {
        'id': spec.shortcutId,
        'shortLabel': spec.shortLabel,
        'longLabel': spec.longLabel,
        'icon': spec.iconDrawable,
        'deepLink': spec.deepLink,
      }) ??
          false;
    } catch (_) {
      return false;
    }
  }
}

/// Runs the full "Add to home screen" flow with Kuber-styled feedback: checks
/// launcher support, requests the pin, and shows the right snackbar. Reused by
/// [KuberAppBar]'s overflow item and by screens that host their own overflow
/// menu (Ask Kuber, History, Add Transaction). Best-effort throughout.
Future<void> requestPinShortcut(
  BuildContext context,
  PinShortcutSpec spec,
) async {
  const service = ShortcutPinService();
  final supported = await service.isSupported();
  if (!context.mounted) return;
  if (!supported) {
    showKuberSnackBar(
      context,
      'Your launcher does not support pinning shortcuts.',
      isError: true,
    );
    return;
  }
  final ok = await service.pin(spec);
  if (!context.mounted) return;
  showKuberSnackBar(
    context,
    ok
        ? 'Shortcut request sent to your launcher'
        : 'Could not add the shortcut. Try again.',
    isError: !ok,
  );
}
