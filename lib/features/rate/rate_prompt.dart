import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/router/app_router.dart' show rootNavigatorKey;
import '../../core/utils/prefs_keys.dart';
import '../../main.dart' show onOpenBatchReadyProvider;
import '../notifications/providers/notification_provider.dart';
import '../tutorial/providers/tutorial_provider.dart';
import 'rate_decision.dart';
import 'rate_sheet.dart';

/// What `main.dart` knew before the first frame, read from the prefs it had
/// already loaded (no extra I/O). [launch] is this cold start's number.
class RateBoot {
  final int launch;
  final bool openedExternally;
  const RateBoot({this.launch = 0, this.openedExternally = true});
}

final rateBootProvider = Provider<RateBoot>((ref) => const RateBoot());

/// Written after the first frame; the number was computed at boot.
Future<void> recordRateLaunch(int launch) async {
  if (launch <= 0) return;
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(PrefsKeys.ratePromptLaunchCount, launch);
  } catch (_) {}
}

Future<void> markRateTapped() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.rateTapped, true);
  } catch (_) {}
}

/// Opens the Play listing (market:// first, https fallback) and remembers it.
Future<void> rateOnPlayStore() async {
  await markRateTapped();
  const id = 'com.grs.kuber';
  try {
    if (await launchUrl(Uri.parse('market://details?id=$id'),
        mode: LaunchMode.externalApplication)) {
      return;
    }
  } catch (_) {}
  try {
    await launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$id'),
        mode: LaunchMode.externalApplication);
  } catch (_) {}
}

final _attempted = StateProvider<bool>((ref) => false);

/// Called by Home. Once the on-open batch is ready, waits 600 ms and shows the
/// sheet if [shouldShowRatePrompt] says so. Evaluated once per cold start.
void scheduleRatePrompt(WidgetRef ref, BuildContext Function() homeContext) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
  final boot = ref.read(rateBootProvider);
  if (!rateLaunches.contains(boot.launch) || boot.openedExternally) return;
  void go() async {
    if (ref.read(_attempted)) return;
    ref.read(_attempted.notifier).state = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    BuildContext ctx;
    try {
      ctx = homeContext();
      if (!ctx.mounted) return;
    } catch (_) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!ctx.mounted) return;
    final nav = Navigator.of(ctx);
    final busy = rootNavigatorKey.currentState?.canPop() == true ||
        nav.canPop() ||
        ModalRoute.of(ctx)?.isCurrent != true ||
        GoRouter.of(ctx).routeInformationProvider.value.uri.path != '/' ||
        (ref.read(pendingDeeplinkProvider)?.isNotEmpty ?? false);
    final welcome = !(prefs.getBool(PrefsKeys.onboarded) ?? false) ||
        (prefs.getBool(PrefsKeys.onboardingTutorialNudgePending) ?? false) ||
        ref.read(tutorialNotifierProvider).isActive;
    final show = shouldShowRatePrompt(
      launchCount: boot.launch,
      neverShow: prefs.getBool(PrefsKeys.ratePromptDone) ?? false,
      rateTapped: prefs.getBool(PrefsKeys.rateTapped) ?? false,
      inWelcomeFlow: welcome,
      openedExternally: boot.openedExternally,
      somethingOnTop: busy,
    );
    if (show) await showRateSheet(ctx);
  }

  if (ref.read(onOpenBatchReadyProvider)) {
    go();
  } else {
    ref.listenManual<bool>(onOpenBatchReadyProvider, (_, ready) {
      if (ready) go();
    });
  }
}
