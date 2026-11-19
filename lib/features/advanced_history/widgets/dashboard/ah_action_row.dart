import 'package:flutter/material.dart';
import 'package:kuber/shared/widgets/animated_amount.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../common/ah_common.dart';
import '../saved/ah_saved_sheet.dart';
import '../saved/ah_saved_state.dart';
import 'ah_sheets.dart';

const _outerR = 28.0;
const _innerR = 6.0;

/// Clear all: confirm in the common sheet, then back to the start screen.
/// KPI choice is kept; saved views are never touched.
Future<void> ahConfirmClearAll(BuildContext context, WidgetRef ref) {
  return ahShowSheet<void>(
    context,
    (ctx) {
      final l = ctx.l10n;
      final cs = Theme.of(ctx).colorScheme;
      return KuberBottomSheet(
        title: l.ahdClearTitle,
        showClose: false,
        actions: Row(
          children: [
            Expanded(
              child: AppButton(
                label: l.cancelLabel,
                type: AppButtonType.outline,
                fullWidth: true,
                onPressed: () => Navigator.of(ctx, rootNavigator: true).pop(),
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            Expanded(
              child: AppButton(
                label: l.ahdClearAll,
                type: AppButtonType.danger,
                filled: true,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(ctx, rootNavigator: true).pop();
                  ref.read(ahViewProvider.notifier).clearAll();
                },
              ),
            ),
          ],
        ),
        child: Text(l.ahdClearBody,
            style: localeFont(fontSize: 16, color: cs.onSurfaceVariant)),
      );
    },
  );
}

/// Action row 3a: Filter + Clear all, then the connected Group | Sort | Saved.
class AhActionRow extends ConsumerWidget {
  const AhActionRow({super.key, this.compact = false});

  /// The pinned bar once the page scrolls: one 44 dp row, Filter shows its
  /// icon and count only and the segments show their value only.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final v = ref.watch(ahViewProvider.select((v) => (
          ahFilterCount(v.node),
          v.hasAnything,
          v.groupBy,
          v.sort,
        )));
    final count = v.$1, any = v.$2, group = v.$3, sort = v.$4;
    final saved = ref.watch(ahOpenSavedProvider);
    final edited = ref.watch(ahChangesProvider.select((c) => c.isNotEmpty));
    final l = context.l10n;

    if (compact) {
      const h = 44.0, r = Radius.circular(h / 2);
      return Row(
        children: [
          _FilterButton(count: count, compact: true),
          const SizedBox(width: KuberSpace.sm),
          _Segment(
            compact: true,
            radius: const BorderRadius.horizontal(
                left: r, right: Radius.circular(_innerR)),
            set: group != AhGroupBy.none,
            icon: Icons.category_outlined,
            filledIcon: Icons.category_rounded,
            label: l.ahdGroup,
            value: group == AhGroupBy.none ? null : ahGroupName(l, group),
            onTap: () => ahShowSheet<void>(context, (_) => const AhGroupSheet()),
          ),
          const SizedBox(width: 2),
          _Segment(
            compact: true,
            radius: BorderRadius.circular(_innerR),
            set: false,
            icon: Icons.sort_rounded,
            filledIcon: Icons.sort_rounded,
            label: l.ahdSort,
            value: ahSortFieldLabel(l, sort.field),
            trailingIcon: sort.descending
                ? Icons.arrow_downward_rounded
                : Icons.arrow_upward_rounded,
            onTap: () => ahShowSheet<void>(context, (_) => const AhSortSheet()),
          ),
          const SizedBox(width: 2),
          Expanded(
            child: _Segment(
              compact: true,
              radius: const BorderRadius.horizontal(
                  left: Radius.circular(_innerR), right: r),
              set: saved != null,
              icon: Icons.bookmarks_outlined,
              filledIcon: Icons.bookmarks_rounded,
              label: l.ahdSaved,
              value: saved?.name,
              expand: true,
              onTap: () => showAhSavedSheet(context),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // Row 1 is a connected pair like row 2: Filter (round left) and
        // Clear all (round right), which looks disabled until something is set.
        Row(
          children: [
            Expanded(child: _FilterButton(count: count)),
            const SizedBox(width: 2),
            _Segment(
              key: const ValueKey('ahd-clear-all'),
              radius: const BorderRadius.horizontal(
                  left: Radius.circular(_innerR),
                  right: Radius.circular(_outerR)),
              set: false,
              disabled: !any,
              icon: Icons.close_rounded,
              filledIcon: Icons.close_rounded,
              label: l.ahdClearAll,
              onTap: () => ahConfirmClearAll(context, ref),
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.sm),
        Row(
          children: [
            _Segment(
              radius: const BorderRadius.horizontal(
                  left: Radius.circular(_outerR),
                  right: Radius.circular(_innerR)),
              set: group != AhGroupBy.none,
              icon: Icons.category_outlined,
              filledIcon: Icons.category_rounded,
              label: l.ahdGroup,
              value: group == AhGroupBy.none ? null : ahGroupName(l, group),
              onTap: () => ahShowSheet<void>(context, (_) => const AhGroupSheet()),
            ),
            const SizedBox(width: 2),
            _Segment(
              radius: BorderRadius.circular(_innerR),
              set: false,
              icon: Icons.sort_rounded,
              filledIcon: Icons.sort_rounded,
              label: l.ahdSort,
              value: ahSortFieldLabel(l, sort.field),
              trailingIcon: sort.descending
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              onTap: () => ahShowSheet<void>(context, (_) => const AhSortSheet()),
            ),
            const SizedBox(width: 2),
            Expanded(
              child: _Segment(
                radius: const BorderRadius.horizontal(
                    left: Radius.circular(_innerR),
                    right: Radius.circular(_outerR)),
                set: saved != null,
                icon: Icons.bookmarks_outlined,
                filledIcon: Icons.bookmarks_rounded,
                label: saved != null && edited ? l.ahdSavedEdited : l.ahdSaved,
                value: saved?.name,
                expand: true,
                onTap: () => showAhSavedSheet(context),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FilterButton extends StatefulWidget {
  const _FilterButton({required this.count, this.compact = false});
  final int count;
  final bool compact;

  @override
  State<_FilterButton> createState() => _FilterButtonState();
}

class _FilterButtonState extends State<_FilterButton> {
  int _last = 1;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final set = widget.count > 0;
    if (set) _last = widget.count;
    final reduced = KuberMotion.reduced(context);
    final fg = set ? cs.onSecondaryContainer : cs.onSurface;
    final compact = widget.compact;
    return AhPill(
      color: set ? cs.secondaryContainer : cs.surfaceContainer,
      radius: compact
          ? BorderRadius.circular(22)
          : const BorderRadius.horizontal(
              left: Radius.circular(_outerR), right: Radius.circular(_innerR)),
      height: compact ? 44 : 56,
      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 16),
      semanticLabel: l.ahdFilter,
      onTap: () => context.push('/advanced-history/filter'),
      child: Row(
        mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_list_rounded,
              size: compact ? 20 : 24, color: set ? fg : cs.onSurfaceVariant),
          if (!compact) ...[
            const SizedBox(width: 10),
            Text(l.ahdFilter,
                style: localeFont(
                    fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
          ],
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.centerLeft,
              widthFactor: set ? 1 : 0,
              duration:
                  reduced ? KuberMotion.fxInstant : KuberMotion.standardCurve.settle,
              curve: reduced ? Curves.linear : KuberMotion.standardCurve.clamped,
              child: AnimatedScale(
                scale: set ? 1 : 0.6,
                curve: reduced ? Curves.linear : KuberMotion.fastCurve,
                duration:
                    reduced ? KuberMotion.fxInstant : KuberMotion.fastCurve.settle,
                child: AnimatedOpacity(
                  opacity: set ? 1 : 0,
                  duration: KuberMotion.of(context, KuberMotion.fxFast),
                  child: Padding(
                    padding: EdgeInsets.only(left: compact ? 6 : 10),
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 24),
                      height: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                          color: cs.onSecondaryContainer,
                          borderRadius: KuberShape.fullR),
                      child: AnimatedAmount(
                          value: _last.toDouble(),
                          format: (v) => '${v.round()}',
                          animateIn: false,
                          style: localeFont(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: cs.secondaryContainer)),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.radius,
    required this.set,
    required this.icon,
    required this.filledIcon,
    required this.label,
    required this.onTap,
    this.value,
    this.trailingIcon,
    this.expand = false,
    this.compact = false,
    this.disabled = false,
    super.key,
  });
  final bool compact;

  /// onSurface 10% / 38%, not tappable.
  final bool disabled;
  final BorderRadius radius;
  final bool set;
  final IconData icon;
  final IconData filledIcon;
  final String label;
  final String? value;
  final IconData? trailingIcon;
  final bool expand;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fg = disabled
        ? cs.onSurface.withValues(alpha: 0.38)
        : set
            ? cs.onSecondaryContainer
            : cs.onSurface;
    final reduced = KuberMotion.reduced(context);
    if (compact) {
      final text = value ?? label;
      return _wrap(
        reduced,
        AhPill(
          color: set ? cs.secondaryContainer : cs.surfaceContainer,
          radius: radius,
          height: 44,
          onTap: onTap,
          semanticLabel: value == null ? label : '$label, $value',
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall!.copyWith(color: fg)),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 2),
                Icon(trailingIcon, size: 14, color: fg),
              ],
            ],
          ),
        ),
      );
    }
    final content = AnimatedSwitcher(
      duration: KuberMotion.of(context, KuberMotion.fxFast),
      child: Row(
        key: ValueKey('$label|$value|$set'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(set ? filledIcon : icon,
              size: 20, color: set || disabled ? fg : cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Flexible(
            child: value == null
                ? Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.titleSmall!.copyWith(color: fg))
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: tt.labelSmall!.copyWith(color: fg)),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(value!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.titleSmall!.copyWith(color: fg)),
                          ),
                          if (trailingIcon != null) ...[
                            const SizedBox(width: 2),
                            Icon(trailingIcon, size: 14, color: fg),
                          ],
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
    final pill = AhPill(
      color: disabled
          ? cs.onSurface.withValues(alpha: 0.10)
          : set
              ? cs.secondaryContainer
              : cs.surfaceContainer,
      radius: radius,
      onTap: disabled ? null : onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Align(alignment: Alignment.centerLeft, child: content),
    );
    return _wrap(reduced, pill);
  }

  Widget _wrap(bool reduced, Widget pill) {
    if (expand) return pill;
    return AnimatedSize(
      duration: reduced ? KuberMotion.fxInstant : KuberMotion.standardCurve.settle,
      curve: reduced ? Curves.linear : KuberMotion.standardCurve.clamped,
      child: pill,
    );
  }
}
