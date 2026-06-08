import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tutorial/models/tutorial_step_keys.dart';
import '../../ask_kuber/screen/kuber_mark.dart';

/// Replaces the brand wordmark + actions row on the dashboard. Other screens
/// keep `KuberAppBar`. Layout: shimmer "Ask Kuber" pill — spacer — privacy
/// icon — notification bell (with badge).
class HomeHeader extends ConsumerStatefulWidget {
  final int unreadCount;
  final VoidCallback onTapNotifications;

  const HomeHeader({
    super.key,
    required this.unreadCount,
    required this.onTapNotifications,
  });

  @override
  ConsumerState<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends ConsumerState<HomeHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmer;
  late final Animation<double> _shimmerAnim;
  int _runs = 0;
  static const _maxRuns = 7;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) {
          _runs++;
          if (_runs < _maxRuns && mounted) _shimmer.forward(from: 0);
        }
      });
    _shimmerAnim = Tween<double>(begin: -0.18, end: 1.18).animate(_shimmer);
    _shimmer.forward();
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPrivate = ref.watch(privacyModeProvider);

    return SafeArea(
      bottom: false,
      child: SizedBox(
        height: kToolbarHeight,
        child: Padding(
          // Match the surrounding content's horizontal padding so the bell
          // sits at exactly the same right edge as the widget cards below.
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    tooltip: context.l10n.notificationsTooltip,
                    onTap: widget.onTapNotifications,
                  ),
                  if (widget.unreadCount > 0)
                    Positioned(
                      top: -5,
                      right: -5,
                      child: _UnreadBadge(count: widget.unreadCount),
                    ),
                ],
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _shimmerAnim,
                builder: (_, __) {
                  final t = _shimmerAnim.value;
                  // Ask Kuber brand colour is the theme primary (was amber).
                  final gold = Theme.of(context).colorScheme.primary;
                  return GestureDetector(
                    onTap: () => context.push('/more/ask-kuber'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            gold.withValues(alpha: 0.08),
                            gold.withValues(alpha: 0.08),
                            gold.withValues(alpha: 0.30),
                            gold.withValues(alpha: 0.08),
                            gold.withValues(alpha: 0.08),
                          ],
                          stops: [
                            0.0,
                            (t - 0.18).clamp(0.0, 1.0),
                            t.clamp(0.0, 1.0),
                            (t + 0.18).clamp(0.0, 1.0),
                            1.0,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(
                          color: gold.withValues(alpha: 0.55),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          KuberMarkWidget(size: 14, bare: true, color: gold),
                          const SizedBox(width: 5),
                          Text(
                            context.l10n.askKuber,
                            style: localeFont(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: KuberSpacing.sm),
              _HeaderIconButton(
                key: TutorialStepKeys.privacyModeIcon,
                icon: isPrivate
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                accentBorder: isPrivate,
                tooltip: isPrivate
                    ? context.l10n.privacyModeOn
                    : context.l10n.privacyModeOff,
                onTap: () =>
                    ref.read(settingsProvider.notifier).togglePrivacyMode(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool accentBorder;
  const _HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.accentBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Tooltip(
      message: tooltip,
      triggerMode: TooltipTriggerMode.longPress,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: accentBorder
                  ? cs.primary
                  : cs.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: accentBorder ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  final int count;
  const _UnreadBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = count > 9 ? '9+' : '$count';
    final wide = label.length > 1;
    return Container(
      constraints: BoxConstraints(
        minWidth: wide ? 20 : 16,
        minHeight: 16,
      ),
      padding: EdgeInsets.symmetric(horizontal: wide ? 5 : 0),
      decoration: BoxDecoration(
        color: cs.error,
        borderRadius: BorderRadius.circular(KuberRadius.full),
        border: Border.all(color: cs.surface, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: localeFont(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: cs.onError,
          height: 1,
        ),
      ),
    );
  }
}