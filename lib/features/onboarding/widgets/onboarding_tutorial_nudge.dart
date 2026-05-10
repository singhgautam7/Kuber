import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/widgets/settings_widgets.dart';

class OnboardingTutorialNudge extends StatefulWidget {
  final Widget child;

  const OnboardingTutorialNudge({super.key, required this.child});

  @override
  State<OnboardingTutorialNudge> createState() =>
      _OnboardingTutorialNudgeState();
}

class _OnboardingTutorialNudgeState extends State<OnboardingTutorialNudge> {
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIfPending());
  }

  @override
  void didUpdateWidget(covariant OnboardingTutorialNudge oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showIfPending());
  }

  Future<void> _showIfPending() async {
    if (!mounted || _checking) return;
    _checking = true;
    final prefs = await SharedPreferences.getInstance();
    final pending =
        prefs.getBool(PrefsKeys.onboardingTutorialNudgePending) ?? false;
    if (!pending || !mounted) {
      _checking = false;
      return;
    }
    await prefs.setBool(PrefsKeys.onboardingTutorialNudgePending, false);
    _checking = false;
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const _TutorialNudgeSheet(),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _TutorialNudgeSheet extends StatelessWidget {
  const _TutorialNudgeSheet();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return KuberBottomSheet(
      title: 'Just so you know',
      leadingIcon: SquircleIcon(icon: Icons.school_rounded, color: cs.primary),
      actions: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton(
          onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
          child: Text(
            'Got it',
            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
      child: Column(
        children: const [
          _NudgeRow(
            icon: Icons.touch_app_rounded,
            title: 'You can explore at your own pace',
            body:
                'Kuber is built to feel familiar, so you can start logging right away.',
          ),
          SizedBox(height: KuberSpacing.md),
          _NudgeRow(
            icon: Icons.map_rounded,
            title: 'A walkthrough is always nearby',
            body:
                'Open More, then App Tutorial, whenever you want a quick guided tour.',
          ),
        ],
      ),
    );
  }
}

class _NudgeRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _NudgeRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SquircleIcon(icon: icon, color: cs.primary),
        const SizedBox(width: KuberSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpacing.xs),
              Text(
                body,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  height: 1.45,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
