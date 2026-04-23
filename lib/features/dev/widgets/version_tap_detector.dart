import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/dev_mode_provider.dart';

class VersionTapDetector extends ConsumerStatefulWidget {
  final Widget child;

  const VersionTapDetector({super.key, required this.child});

  @override
  ConsumerState<VersionTapDetector> createState() => _VersionTapDetectorState();
}

class _VersionTapDetectorState extends ConsumerState<VersionTapDetector> {
  int _tapCount = 0;
  Timer? _debounceTimer;

  void _handleTap() async {
    final devModeAsync = ref.read(devModeProvider);
    final isDevModeUnlocked = devModeAsync.valueOrNull ?? false;

    if (isDevModeUnlocked) {
      showKuberSnackBar(
        context,
        "You already have Dev Tools unlocked 🛠️",
      );
      return;
    }

    _tapCount++;

    // Cancel existing debounce timer
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _tapCount = 0;
        });
      }
    });

    if (_tapCount >= 3 && _tapCount < 7) {
      final stepsAway = 7 - _tapCount;
      showKuberSnackBar(
        context,
        "$stepsAway steps away from unlocking Dev Tools",
      );
    } else if (_tapCount == 7) {
      _debounceTimer?.cancel();
      _tapCount = 0;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kuber_dev_mode', true);
      ref.invalidate(devModeProvider);

      if (mounted) {
        showKuberSnackBar(
          context,
          "You are now a developer! 🛠️",
        );
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
      child: widget.child,
    );
  }
}
