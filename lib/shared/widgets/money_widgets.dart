// Shared money-schedule components (design money-schedules-v1, Components
// board): EMI split, source chip, calculator links, key-facts grid, the
// summary sheet shell that expands to a full-screen page, and that page.
// Built on the existing shells (KuberBottomSheet, KuberAppBar, KuberCard,
// SheetButtonSection, KuberChip) so they look and move like the rest of Kuber.

import 'package:flutter/material.dart';

import 'kuber_skeleton.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/l10n_ext.dart';
import 'kuber_app_bar.dart';
import 'kuber_bottom_sheet.dart';
import 'kuber_list.dart';
import 'sheet_button_section.dart';

/// Interest colour: the EMI calculator's (colorScheme.error).
Color interestColor(BuildContext context) => Theme.of(context).colorScheme.error;

const _tabular = [FontFeature.tabularFigures()];

/// EMI split bar + legend (components/source-chip.md). Interest-only EMIs
/// (principal 0) draw an all-interest bar.
class EmiSplitBar extends StatelessWidget {
  final double principal;
  final double interest;
  final String principalText;
  final String interestText;
  final String? title;
  final String? totalText;

  const EmiSplitBar({
    super.key,
    required this.principal,
    required this.interest,
    required this.principalText,
    required this.interestText,
    this.title,
    this.totalText,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = context.l10n;
    final total = principal + interest;
    final pFlex = total <= 0 ? 0 : (principal / total * 1000).round();
    final iFlex = total <= 0 ? 1 : 1000 - pFlex;
    Widget dot(Color c, String label, String value) => Expanded(
          child: Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Flexible(
                child: Text(label,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant))),
            const SizedBox(width: 6),
            Text(value, style: tt.titleSmall!.copyWith(fontFeatures: _tabular)),
          ]),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(
                  child: Text(title!,
                      style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant))),
              if (totalText != null)
                Text(totalText!, style: tt.titleSmall!.copyWith(fontFeatures: _tabular)),
            ]),
          ),
        ClipRRect(
          borderRadius: KuberShape.fullR,
          child: SizedBox(
            height: 8,
            child: Row(children: [
              if (pFlex > 0) Expanded(flex: pFlex, child: Container(color: cs.primary)),
              if (pFlex > 0 && iFlex > 0) const SizedBox(width: 4),
              if (iFlex > 0)
                Expanded(flex: iFlex, child: Container(color: interestColor(context))),
            ]),
          ),
        ),
        const SizedBox(height: 8),
        Row(children: [
          dot(cs.primary, l.msLoansPrincipalL, principalText),
          const SizedBox(width: 12),
          dot(interestColor(context), l.msLoansInterestL, interestText),
        ]),
      ],
    );
  }
}

/// Outlined assist chip "From Home loan ›" on the transaction sheet.
class SourceChip extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const SourceChip({super.key, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
          borderRadius: KuberShape.mediumR, side: BorderSide(color: cs.outlineVariant)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 32,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.link_rounded, size: 18, color: cs.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(color: cs.onSurface)),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, size: 18, color: cs.onSurfaceVariant),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

class CalculatorLink {
  final String label;
  final VoidCallback onTap;
  const CalculatorLink(this.label, this.onTap);
}

/// "Open in a calculator" + assist chips (components/calculator-links.md).
class CalculatorLinkChips extends StatelessWidget {
  final List<CalculatorLink> links;
  const CalculatorLinkChips({super.key, required this.links});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(context.l10n.msOpenInCalculator.toUpperCase(),
            style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final link in links)
            ActionChip(
              avatar: Icon(Icons.calculate_outlined, size: 18, color: cs.primary),
              label: Text(link.label),
              labelStyle: tt.labelLarge!.copyWith(color: cs.onSurfaceVariant),
              side: BorderSide(color: cs.outlineVariant),
              shape: const RoundedRectangleBorder(borderRadius: KuberShape.mediumR),
              onPressed: link.onTap,
            ),
        ]),
      ],
    );
  }
}

class KvItem {
  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onInfo;
  const KvItem(this.label, this.value, {this.valueColor, this.onInfo});
}

/// Key facts as a 3-column grid (bodySmall label, titleSmall value).
class KvGrid extends StatelessWidget {
  final List<KvItem> items;
  final int columns;
  const KvGrid({super.key, required this.items, this.columns = 3});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += columns) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = i; j < i + columns; j++)
            Expanded(
              child: j >= items.length
                  ? const SizedBox()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          Flexible(
                            child: Text(items[j].label,
                                style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                          ),
                          if (items[j].onInfo != null)
                            InkResponse(
                              onTap: items[j].onInfo,
                              radius: 20,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 4),
                                child: Icon(Icons.info_outline_rounded,
                                    size: 16, color: cs.onSurfaceVariant),
                              ),
                            ),
                        ]),
                        const SizedBox(height: 2),
                        Text(items[j].value,
                            style: tt.titleSmall!.copyWith(
                                color: items[j].valueColor ?? cs.onSurface,
                                fontFeatures: _tabular)),
                      ],
                    ),
            ),
        ],
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          rows[i],
        ],
      ],
    );
  }
}

/// Headline block: bodyMedium label + headlineMedium tabular value.
class MoneyHeadline extends StatelessWidget {
  final String label;
  final String value;
  final Widget? labelTrailing;
  final Color? color;
  const MoneyHeadline(
      {super.key, required this.label, required this.value, this.labelTrailing, this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(children: [
          Text(label, style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          ?labelTrailing,
        ]),
        Text(value,
            style: tt.headlineMedium!
                .copyWith(color: color ?? cs.onSurface, fontFeatures: _tabular)),
      ],
    );
  }
}

/// The tonal "what's next" block on a sheet (surfaceContainerHigh r16).
class MoneyNextBlock extends StatelessWidget {
  final String caption;
  final Widget child;
  const MoneyNextBlock({super.key, required this.caption, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: cs.surfaceContainerHigh, borderRadius: KuberShape.largeR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(caption.toUpperCase(),
              style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Opens [sheet] (a [MoneySummarySheet]) the standard way.
Future<T?> showMoneySheet<T>(BuildContext context, Widget sheet) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );

/// Summary sheet (components/summary-sheet.md): the essentials, then "View
/// details" (or a drag up) opens [details] as a full-screen page. Actions
/// follow SheetButtonSection.
class MoneySummarySheet extends StatelessWidget {
  final String context_;
  final String title;
  final Widget? leading;
  final List<Widget> body;
  final SheetAction? primary;
  final List<SheetAction> actions;
  final WidgetBuilder? details;

  /// Label of the details link (defaults to "View details").
  final String? detailsLabel;

  /// Opens [details] from the primary button instead of a text link
  /// (loans: the EMI schedule is the main thing to look at).
  final bool detailsAsPrimary;

  const MoneySummarySheet({
    super.key,
    required String contextLabel,
    required this.title,
    this.leading,
    required this.body,
    this.primary,
    this.actions = const [],
    this.details,
    this.detailsLabel,
    this.detailsAsPrimary = false,
  }) : context_ = contextLabel;

  void _openDetails(BuildContext context) {
    final builder = details;
    if (builder == null) return;
    final nav = Navigator.of(context, rootNavigator: true);
    nav.push(PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 400),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (ctx, a, _) => _DeferredDetails(animation: a, builder: builder),
      transitionsBuilder: (ctx, a, _, child) {
        if (MediaQuery.maybeDisableAnimationsOf(ctx) ?? false) {
          return FadeTransition(opacity: a, child: child);
        }
        final curve = CurvedAnimation(
            parent: a,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic);
        return FadeTransition(
          opacity: curve,
          child: SlideTransition(
            position: Tween(begin: const Offset(0, 0.08), end: Offset.zero).animate(curve),
            child: child,
          ),
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final link = detailsLabel ?? context.l10n.msViewDetails;
    final asPrimary = detailsAsPrimary && details != null;
    final main = asPrimary
        ? SheetAction(
            label: link,
            icon: Icons.table_rows_outlined,
            onPressed: () => _openDetails(context))
        : primary;
    return GestureDetector(
      onVerticalDragEnd: (d) {
        if ((d.primaryVelocity ?? 0) < -500) _openDetails(context);
      },
      child: KuberBottomSheet(
        title: title,
        subtitle: context_,
        leadingIcon: leading,
        actions: main == null && actions.isEmpty
            ? null
            : SheetButtonSection(
                primary: main, actions: actions, padding: EdgeInsets.zero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < body.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              body[i],
            ],
            if (details != null && !asPrimary) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () => _openDetails(context),
                  iconAlignment: IconAlignment.end,
                  icon: Icon(Icons.expand_less_rounded, size: 20, color: cs.primary),
                  label: Text(link),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shows a skeleton while the route slides in, then builds the (heavy)
/// details page: an amortization or a long history would otherwise stall the
/// tap before any animation starts.
class _DeferredDetails extends StatefulWidget {
  final Animation<double> animation;
  final WidgetBuilder builder;
  const _DeferredDetails({required this.animation, required this.builder});

  @override
  State<_DeferredDetails> createState() => _DeferredDetailsState();
}

class _DeferredDetailsState extends State<_DeferredDetails> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    if (widget.animation.isCompleted) {
      _ready = true;
    } else {
      widget.animation.addStatusListener(_onStatus);
    }
  }

  void _onStatus(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    widget.animation.removeStatusListener(_onStatus);
    if (mounted) setState(() => _ready = true);
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_onStatus);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.builder(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KuberSpace.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              KuberSkeleton(width: 40, height: 40, borderRadius: 20),
              SizedBox(height: KuberSpace.xl),
              KuberSkeleton(width: 180, height: 20),
              SizedBox(height: KuberSpace.sm),
              KuberSkeleton(width: 240, height: 32),
              SizedBox(height: KuberSpace.xl),
              KuberSkeleton(height: 200, borderRadius: 16),
              SizedBox(height: KuberSpace.lg),
              KuberSkeleton(height: 56, borderRadius: 12),
              SizedBox(height: KuberSpace.sm),
              KuberSkeleton(height: 56, borderRadius: 12),
              SizedBox(height: KuberSpace.sm),
              KuberSkeleton(height: 56, borderRadius: 12),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen page (summary-sheet.md): close, title, overflow; identity
/// row, chart card, list.
class MoneyFullScreen extends StatelessWidget {
  final String title;
  final Widget identity;
  final Widget? chart;
  final List<Widget> list;
  final List<PopupMenuEntry<VoidCallback>> overflow;

  const MoneyFullScreen({
    super.key,
    required this.title,
    required this.identity,
    this.chart,
    required this.list,
    this.overflow = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        title: title,
        showBrand: false,
        actions: [
          if (overflow.isNotEmpty)
            PopupMenuButton<VoidCallback>(
              icon: const Icon(Icons.more_vert_rounded),
              itemBuilder: (_) => overflow,
              onSelected: (cb) => cb(),
            ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(
            20, 4, 20, 32 + MediaQuery.of(context).padding.bottom),
        children: [
          identity,
          if (chart != null) ...[
            const SizedBox(height: 24),
            KuberCard(
              padding: const EdgeInsets.all(16),
              child: chart!,
            ),
          ],
          const SizedBox(height: 24),
          ...list,
        ],
      ),
    );
  }
}

/// Identity row of a full-screen page: tile + caps context, headline, caption.
class MoneyIdentity extends StatelessWidget {
  final Widget tile;
  final String contextLabel;
  final String headline;
  final String? caption;
  final Widget? below;
  const MoneyIdentity(
      {super.key,
      required this.tile,
      required this.contextLabel,
      required this.headline,
      this.caption,
      this.below});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          SizedBox(width: 48, height: 48, child: tile),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(contextLabel.toUpperCase(),
                    style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
                Text(headline,
                    style: tt.headlineMedium!.copyWith(fontFeatures: _tabular)),
                if (caption != null)
                  Text(caption!, style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ]),
        if (below != null) ...[const SizedBox(height: 16), below!],
      ],
    );
  }
}

/// Caps label used for "Ends", "On", section headers inside forms.
class CapsLabel extends StatelessWidget {
  final String text;
  final Widget? trailing;
  const CapsLabel(this.text, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: Row(children: [
        Expanded(
          child: Text(text.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium!
                  .copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.8)),
        ),
        ?trailing,
      ]),
    );
  }
}

/// Row-state pill ("Paused", "Ended", "Closed"): labelMedium on
/// surfaceContainerHigh (components/row-states.md).
class StatePill extends StatelessWidget {
  final String label;
  const StatePill(this.label, {super.key});

  @override
  Widget build(BuildContext context) => KuberPill(label: label, tone: KuberTone.neutral);
}
