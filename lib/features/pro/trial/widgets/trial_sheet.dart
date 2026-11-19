import 'dart:math' show min;

import 'package:flutter/material.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/kuber_chips.dart';
import '../../../../shared/widgets/sheet_button_section.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/motion/motion.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../shared/widgets/kuber_comparison_table.dart';
import '../../paywall/pro_page_extras.dart' show kProComparisonRows;
import '../trial_state.dart';
import '../trial_suggestions.dart';
import 'trial_celebration.dart';
import 'trial_common.dart';

/// Set as setup ends; Home opens the sheet once it has painted (owner,
/// 19 Nov: never over the last setup page).
final pendingTrialSheetProvider = StateProvider<TrialStartOutcome?>((ref) => null);

/// Opens the trial sheet for [outcome]: started (new user / after claim),
/// continued (restored with days left), already used. No-op for notEligible.
/// "See Kuber Pro" opens `/pro` after the sheet closes, unless [openPro] is
/// false (the caller navigates first, e.g. the end of Welcome); returns
/// whether it was tapped.
Future<bool> showTrialSheet(BuildContext context, TrialStartOutcome outcome,
    {bool openPro = true}) async {
  if (outcome == TrialStartOutcome.notEligible) return false;
  TrialSession.sheetShown = true;
  final router = GoRouter.maybeOf(context);
  final go = await showModalBottomSheet<bool>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => TrialSheet(outcome: outcome),
  );
  if (go == true && openPro) router?.push('/pro');
  return go == true;
}

/// "Free until 2 Dec" pill (secondaryContainer, 32 dp).
class TrialDatePill extends StatelessWidget {
  const TrialDatePill(this.text, {super.key});
  final String text;

  // Shared chip, selected style (secondaryContainer), not tappable.
  @override
  Widget build(BuildContext context) =>
      KuberChip(label: text, icon: Icons.event_available_rounded, selected: true, showCheck: false, shrink: true);
}

/// "WHAT KUBER PRO OFFERS": full-bleed 56 dp row, line above, chevron.
class TrialOffersHeader extends StatelessWidget {
  const TrialOffersHeader({super.key, required this.expanded, required this.onTap});
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    return Semantics(
      button: true,
      label: expanded ? l.trialSheetOffersExpanded : l.trialSheetOffersCollapsed,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.fromLTRB(24, 4, 16, 4),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outlineVariant))),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  l.trialSheetOffers.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium!.copyWith(
                        letterSpacing: .8,
                        color: cs.onSurface,
                      ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: cs.surfaceContainerHigh, shape: BoxShape.circle),
                child: ChevronTurn(expanded: expanded, openDegrees: 180, color: cs.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fade + 8 dp rise at [index] of the opening moment (motion.md).
class _Rise extends StatelessWidget {
  const _Rise({required this.index, required this.progress, required this.level, required this.child});
  final int index;
  final Animation<double> progress;
  final MotionLevel level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (level == MotionLevel.off) return child;
    return AnimatedBuilder(
      animation: progress,
      child: child,
      builder: (context, child) {
        final ms = progress.value * trialMomentMs(level);
        if (level == MotionLevel.subtle) {
          return Opacity(opacity: ((ms - 120) / 200).clamp(0.0, 1.0), child: child);
        }
        final fm = ms - 280 - min(index, 5) * 30;
        return Opacity(
          opacity: (fm / 150).clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, (1 - trialSpring(KuberMotion.defaultCurve, fm)) * 8), child: child),
        );
      },
    );
  }
}

class _RowIn extends StatelessWidget {
  const _RowIn({required this.index, required this.anim, required this.level, required this.child});
  final int index;
  final AnimationController anim;
  final MotionLevel level;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (level == MotionLevel.off) return child;
    return AnimatedBuilder(
      animation: anim,
      child: child,
      builder: (context, child) {
        if (anim.value >= 1) return child!;
        if (level == MotionLevel.subtle) return Opacity(opacity: anim.value, child: child);
        final ms = anim.value * 360;
        final start = 60 + min(index, 5) * 30;
        return Opacity(
          opacity: ((ms - start) / 150).clamp(0.0, 1.0),
          child: Transform.translate(
              offset: Offset(0, (1 - trialSpring(KuberMotion.defaultCurve, ms - start)) * 8),
              child: child),
        );
      },
    );
  }
}

class TrialSheet extends ConsumerStatefulWidget {
  const TrialSheet({super.key, required this.outcome});
  final TrialStartOutcome outcome;

  @override
  ConsumerState<TrialSheet> createState() => _TrialSheetState();
}

class _TrialSheetState extends ConsumerState<TrialSheet> with TickerProviderStateMixin {
  late final AnimationController _moment = AnimationController(vsync: this);
  late final AnimationController _rows = AnimationController(vsync: this, value: 1);
  late final AnimationController _scrollSpring = AnimationController.unbounded(vsync: this);
  final _scroll = ScrollController();
  final _headerKey = GlobalKey();
  bool _expanded = false;
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _scrollSpring.addListener(() {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scrollSpring.value.clamp(0.0, _scroll.position.maxScrollExtent));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    final level = KuberMotion.levelOf(context);
    final ms = trialMomentMs(level);
    if (ms == 0) {
      _moment.value = 1;
    } else {
      _moment.duration = Duration(milliseconds: ms);
      _moment.forward();
    }
  }

  @override
  void dispose() {
    _moment.dispose();
    _rows.dispose();
    _scrollSpring.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _toggle() {
    final level = KuberMotion.levelOf(context);
    final open = !_expanded;
    setState(() => _expanded = open);
    if (open && level != MotionLevel.off) {
      _rows.duration = Duration(milliseconds: level == MotionLevel.expressive ? 360 : 200);
      _rows.forward(from: 0);
    }
    double target = 0;
    if (open) {
      final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        target = RenderAbstractViewport.of(box).getOffsetToReveal(box, 0).offset;
      }
    }
    if (level == MotionLevel.off) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.jumpTo(target.clamp(0.0, _scroll.position.maxScrollExtent));
        }
      });
      return;
    }
    _scrollSpring.value = _scroll.hasClients ? _scroll.offset : 0;
    _scrollSpring.springTo(
        target,
        KuberMotion.spatial(level, open ? KuberMotion.springDefault : KuberMotion.springStandard));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final mq = MediaQuery.of(context);
    final level = KuberMotion.levelOf(context);
    final info = ref.watch(proTrialProvider);
    final big = mq.textScaler.scale(1) >= 1.4;
    final used = widget.outcome == TrialStartOutcome.alreadyUsed;
    final continued = widget.outcome == TrialStartOutcome.continued;
    final end = info.endAt ?? info.now.add(kTrialLength);
    final until = trialDate(context, end);

    final title = used
        ? l.trialUsedTitle
        : continued
            ? l.trialRestoredTitle
            : l.trialSheetTitle;
    final body = used ? l.trialUsedBody : l.trialSheetBody;
    final pill = continued
        ? l.trialRestoredUntil('${info.daysLeft}', until)
        : l.trialSheetUntil(until);

    Widget rise(int i, Widget c) => _Rise(index: i, progress: _moment, level: level, child: c);

    final head = Column(
      children: [
        if (used)
          Container(
            width: 56,
            height: 56,
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: KuberShape.largeR),
            child: Icon(Icons.workspace_premium_rounded, size: 28, color: cs.onSurfaceVariant),
          )
        else
          TrialCelebration(
            progress: _moment,
            level: level,
            burst: !continued,
            size: continued ? (big ? 72 : 88) : (big ? 88 : 112),
          ),
        const SizedBox(height: 12),
        rise(
          0,
          Column(
            children: [
              Text(title, textAlign: TextAlign.center, style: tt.headlineSmall!.copyWith(color: cs.onSurface)),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: head),
        if (!used) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: rise(
              1,
              Column(
                children: [
                  TrialDatePill(pill),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(l.trialSheetNote,
                        textAlign: TextAlign.center,
                        style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        rise(2, TrialOffersHeader(key: _headerKey, expanded: _expanded, onTap: _toggle)),
        ExpandCollapse(
          expanded: _expanded,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: KuberComparisonTable(
              rows: kProComparisonRows,
              entryBuilder: (i, row) => _RowIn(index: i, anim: _rows, level: level, child: row),
            ),
          ),
        ),
      ],
    );

    // Shared sheet action row: one primary, the other below it.
    final actions = rise(
      3,
      SheetButtonSection(
        padding: EdgeInsets.zero,
        primary: SheetAction(
          label: used ? l.trialSheetSeePro : l.trialSheetCta,
          icon: used ? Icons.workspace_premium_rounded : Icons.explore_rounded,
          onPressed: () => Navigator.of(context).pop(used),
        ),
        actions: [
          SheetAction(
            label: used ? l.commonNotNow : l.trialSheetSeePro,
            icon: used ? Icons.close_rounded : Icons.workspace_premium_rounded,
            onPressed: () => Navigator.of(context).pop(!used),
          ),
        ],
      ),
    );

    // Common sheet shell (CLAUDE.md rule 11): headerless, the headline is part
    // of the body. Expanded, the sheet grows to max height (screen − status
    // bar − 24 dp) and the body scrolls inside it.
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: mq.size.height - mq.padding.top - 24),
      child: KuberBottomSheet(
        showClose: false,
        scrollController: _scroll,
        reflow: false, // ExpandCollapse animates the table and the scroll follows it
        bodyPadding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
        actions: actions,
        child: content,
      ),
    );
  }
}
