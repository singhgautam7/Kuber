import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/motion/motion.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';

/// "Always" / "When scrolling up" / "When scrolling stops" / "Off".
String floatingHeaderName(AppLocalizations l, FloatingHeaderMode m) => switch (m) {
      FloatingHeaderMode.always => l.floatingHeaderAlways,
      FloatingHeaderMode.scrollUp => l.floatingHeaderScrollUp,
      FloatingHeaderMode.scrollStop => l.floatingHeaderScrollStop,
      FloatingHeaderMode.off => l.floatingHeaderOff,
    };

const _modes = [
  FloatingHeaderMode.always,
  FloatingHeaderMode.scrollUp,
  FloatingHeaderMode.scrollStop,
];

/// Floating header setting sheet (v7.0.0-c board v7c.S): an on / off switch and
/// three option cards, each with a live mini page showing what the header does.
/// A choice applies at once; the sheet stays open so people can compare.
class FloatingHeaderSheet extends ConsumerStatefulWidget {
  const FloatingHeaderSheet({super.key});

  static Future<void> show(BuildContext context) => showModalBottomSheet<void>(
        sheetAnimationStyle: kuberSheetStyle(context),
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        useRootNavigator: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const FloatingHeaderSheet(),
      );

  @override
  ConsumerState<FloatingHeaderSheet> createState() => _FloatingHeaderSheetState();
}

class _FloatingHeaderSheetState extends ConsumerState<FloatingHeaderSheet>
    with SingleTickerProviderStateMixin {
  /// Script length: 500 + 1100 + 900 + 450 + 900 + 1000 + 700 ms.
  late final AnimationController _loop =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 5550));

  /// Last chosen mode, restored when the switch goes back on.
  late FloatingHeaderMode _last = () {
    final m = ref.read(floatingHeaderProvider);
    return m == FloatingHeaderMode.off ? FloatingHeaderMode.always : m;
  }();
  bool _still = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _still = MediaQuery.disableAnimationsOf(context);
    if (_still) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  void _choose(FloatingHeaderMode m) {
    KuberHaptics.tick();
    if (m != FloatingHeaderMode.off) _last = m;
    ref.read(floatingHeaderProvider.notifier).set(m);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final cur = ref.watch(floatingHeaderProvider);
    final on = cur != FloatingHeaderMode.off;
    final selected = on ? cur : _last;

    return KuberBottomSheet(
      title: l.floatingHeaderTitle,
      description: l.floatingHeaderSubtitle,
      bodyPadding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberGroup(children: [
            KuberListRow(
              title: l.floatingHeaderTitle,
              subtitle: on ? l.floatingHeaderSwitchOn : l.floatingHeaderSwitchOff,
              onTap: () => _choose(on ? FloatingHeaderMode.off : _last),
              trailing: Switch(
                value: on,
                onChanged: (v) => _choose(v ? _last : FloatingHeaderMode.off),
                activeTrackColor: cs.primary,
              ),
            ),
          ]),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(l.floatingHeaderSection.toUpperCase(),
                style: localeFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: cs.onSurfaceVariant)),
          ),
          const SizedBox(height: 8),
          for (final m in _modes) ...[
            _OptionCard(
              label: floatingHeaderName(l, m),
              selected: on && selected == m,
              enabled: on,
              onTap: () => _choose(m),
              preview: _MiniPage(
                mode: on ? m : FloatingHeaderMode.off,
                loop: _loop,
                still: _still,
              ),
            ),
            if (m != _modes.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    required this.preview,
  });

  final String label;
  final bool selected, enabled;
  final VoidCallback onTap;
  final Widget preview;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
      side: BorderSide(
        color: selected ? cs.primary : cs.outlineVariant,
        width: selected ? 2 : 1,
      ),
    );
    return Opacity(
      opacity: enabled ? 1 : 0.38,
      child: Semantics(
        container: true,
        excludeSemantics: true,
        button: true,
        enabled: enabled,
        selected: selected,
        checked: selected,
        inMutuallyExclusiveGroup: true,
        label: context.l10n.floatingHeaderPreviewLabel(label),
        onTap: enabled ? onTap : null,
        child: Material(
          color: selected ? cs.secondaryContainer : cs.surfaceContainer,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            customBorder: shape,
            overlayColor: kuberPressedLayer(cs),
            child: Padding(
              // 1 dp / 2 dp border + padding = 5/13/13/5 either way.
              padding: selected
                  ? const EdgeInsets.fromLTRB(3, 3, 11, 11)
                  : const EdgeInsets.fromLTRB(4, 4, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minHeight: 48),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: Icon(
                            selected
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 22,
                            color: selected ? cs.primary : cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: KuberSpace.sm),
                        Expanded(
                          child: Text(label,
                              style: localeFont(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: selected ? cs.onSecondaryContainer : cs.onSurface)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: preview,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scroll script of the previews: (end ms, offset dp) from the previous point.
const _script = <(int, double)>[
  (500, 0),
  (1600, 300),
  (2500, 300),
  (2950, 220),
  (3850, 220),
  (4850, 0),
  (5550, 0),
];

double _scriptOffset(double t) {
  final ms = t * 5550;
  var t0 = 0, y0 = 0.0;
  for (final (t1, y1) in _script) {
    if (ms <= t1) {
      if (y1 == y0) return y0;
      return y0 + (y1 - y0) * Curves.easeInOutCubic.transform((ms - t0) / (t1 - t0));
    }
    t0 = t1;
    y0 = y1;
  }
  return 0;
}

/// The real header engine on a 360 x 553 mini page, drawn at 300 / 360 and
/// clipped to its top 300 x 72 (board v7c.S `mini`). Scrolled by [loop] with
/// `jumpTo`, which emits the scroll notifications the header listens to.
class _MiniPage extends StatefulWidget {
  const _MiniPage({required this.mode, required this.loop, required this.still});

  final FloatingHeaderMode mode;
  final Animation<double> loop;
  final bool still;

  @override
  State<_MiniPage> createState() => _MiniPageState();
}

class _MiniPageState extends State<_MiniPage> {
  final _sc = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.loop.addListener(_tick);
    if (widget.still) _settle();
  }

  @override
  void didUpdateWidget(_MiniPage old) {
    super.didUpdateWidget(old);
    if (widget.still && !old.still) _settle();
  }

  // Remove animations: the final state of the script's first scroll down.
  void _settle() => WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.still && _sc.hasClients) _sc.jumpTo(300);
      });

  void _tick() {
    if (!widget.still && _sc.hasClients) _sc.jumpTo(_scriptOffset(widget.loop.value));
  }

  @override
  void dispose() {
    widget.loop.removeListener(_tick);
    _sc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final mq = MediaQuery.of(context);
    const top = EdgeInsets.only(top: 16);
    final tones = [cs.primary, cs.secondary, cs.tertiary, cs.error];
    return ExcludeSemantics(
      child: IgnorePointer(
        child: Container(
          width: 300,
          height: 72,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KuberShape.medium),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: 360,
            maxWidth: 360,
            minHeight: 553,
            maxHeight: 553,
            child: Transform.scale(
              scale: 300 / 360,
              alignment: Alignment.topLeft,
              child: MediaQuery(
                data: mq.copyWith(
                  size: const Size(360, 553),
                  padding: top,
                  viewPadding: top,
                  viewInsets: EdgeInsets.zero,
                  textScaler: TextScaler.noScaling,
                ),
                child: Material(
                  color: cs.surface,
                  child: KuberHeaderPage(
                    mode: widget.mode,
                    header: KuberAppBar(
                      title: 'Categories',
                      showBack: true,
                      actions: [
                        AppIconButton(icon: Icons.search_rounded, semanticLabel: '', onPressed: () {}),
                        AppIconButton(icon: Icons.more_vert_rounded, semanticLabel: '', onPressed: () {}),
                      ],
                    ),
                    body: ListView(
                      controller: _sc,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        KuberHeaderPage.gap(),
                        for (var i = 0; i < 12; i++) _row(cs, i, tones[i % 4]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static Widget _row(ColorScheme cs, int i, Color tone) {
    const r = Radius.circular(KuberShape.largeIncreased);
    const s = Radius.circular(4);
    final radius = BorderRadius.vertical(
      top: i % 4 == 0 ? r : s,
      bottom: i % 4 == 3 ? r : s,
    );
    return Container(
      height: 64,
      margin: EdgeInsets.only(bottom: i % 4 == 3 ? 24 : 2),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: radius,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.24),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FractionallySizedBox(
                  widthFactor: (60 + (i * 37) % 40) / 100,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.onSurface.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FractionallySizedBox(
                  widthFactor: 0.4,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
