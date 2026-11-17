import 'package:flutter/material.dart';
import 'package:kuber/core/motion/route_styles.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/l10n_ext.dart';
import '../../shared/widgets/app_button.dart';
import '../../shared/widgets/kuber_bottom_sheet.dart';
import '../../shared/widgets/kuber_list.dart';
import '../../core/utils/prefs_keys.dart';
import 'rate_prompt.dart' show rateOnPlayStore;

/// "Enjoying Kuber?" (Screen 36). Any close with the box checked, or Rate,
/// means never again; Refer and Maybe later keep the schedule.
Future<void> showRateSheet(BuildContext context) async {
  var never = false;
  await showModalBottomSheet<void>(
      sheetAnimationStyle: kuberSheetStyle(context),
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    // Root navigator: the sheet covers the bottom nav like every other sheet.
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RateSheet(onNever: (v) => never = v),
  );
  if (never) {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(PrefsKeys.ratePromptDone, true);
    } catch (_) {}
  }
}

class _RateSheet extends StatefulWidget {
  final ValueChanged<bool> onNever;
  const _RateSheet({required this.onNever});

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  bool _never = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    void close() {
      widget.onNever(_never);
      Navigator.of(context).pop();
    }

    return KuberBottomSheet(
      title: l.rateTitle,
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppButton(
            label: l.rateCta,
            icon: Icons.star_rounded,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () {
              widget.onNever(true);
              Navigator.of(context).pop();
              rateOnPlayStore();
            },
          ),
          const SizedBox(height: KuberSpace.md),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: l.rateRefer,
                  icon: Icons.share_rounded,
                  fullWidth: true,
                  onPressed: () {
                    close();
                    SharePlus.instance.share(ShareParams(text: l.shareMessage));
                  },
                ),
              ),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: AppButton(
                  label: l.rateLater,
                  type: AppButtonType.outline,
                  fullWidth: true,
                  onPressed: close,
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.9, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: const Cubic(0.05, 0.7, 0.1, 1),
              builder: (_, v, child) => Transform.scale(scale: v, child: child),
              child: KuberIconTile(
                icon: Icons.currency_rupee_rounded,
                size: 72,
                glyph: 40,
                radius: 21,
                color: cs.primary,
                iconColor: cs.onPrimary,
              ),
            ),
          ),
          const SizedBox(height: KuberSpace.lg),
          Text(l.rateBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: KuberSpace.xl),
          // Same switch row as Settings, not a loose checkbox.
          KuberGroup(
            children: [
              KuberListRow(
                leading: const KuberIconTile(icon: Icons.notifications_off_outlined, tone: KuberTone.secondary),
                title: l.rateNever,
                onTap: () => _setNever(!_never),
                trailing: Switch(
                  value: _never,
                  onChanged: _setNever,
                  activeTrackColor: cs.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _setNever(bool v) {
    setState(() => _never = v);
    widget.onNever(v);
  }
}
