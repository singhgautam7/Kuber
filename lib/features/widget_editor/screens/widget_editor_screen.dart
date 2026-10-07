import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import '../models/home_widget_config.dart';
import '../data/widget_catalog.dart';
import '../providers/widget_editor_provider.dart';

/// Full-screen modal for re-ordering and enabling/disabling widgets on
/// either the home dashboard or the analytics screen. Reads the current
/// configuration from `homeWidgetsProvider` / `analyticsWidgetsProvider`,
/// mutates a local working copy, and writes back through
/// [saveWidgetPreferences] on save.
class WidgetEditorScreen extends ConsumerStatefulWidget {
  final WidgetEditorScope scope;
  const WidgetEditorScreen({super.key, required this.scope});

  @override
  ConsumerState<WidgetEditorScreen> createState() => _WidgetEditorScreenState();
}

class _WidgetEditorScreenState extends ConsumerState<WidgetEditorScreen> {
  List<HomeWidgetConfig>? _widgets;
  List<HomeWidgetConfig>? _initial;

  Future<List<HomeWidgetConfig>> get _futureForScope =>
      ref.read(widgetPreferenceRepositoryProvider).readForScope(widget.scope);

  @override
  void initState() {
    super.initState();
    _futureForScope.then((list) {
      if (!mounted) return;
      setState(() {
        _initial = List.of(list);
        _widgets = List.of(list);
      });
    });
  }

  bool get _dirty {
    final w = _widgets;
    final i = _initial;
    if (w == null || i == null) return false;
    if (w.length != i.length) return true;
    for (var k = 0; k < w.length; k++) {
      if (w[k].id != i[k].id || w[k].enabled != i[k].enabled) return true;
    }
    return false;
  }

  void _toggle(int i, bool v) {
    final w = _widgets;
    if (w == null) return;
    if (!v) {
      final remaining = w.where((x) => x.enabled).length;
      if (remaining <= 1) {
        showKuberSnackBar(
          context,
          context.l10n.atLeastOneWidget,
          isError: true,
        );
        return;
      }
    }
    setState(() => w[i] = w[i].copyWith(enabled: v));
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final cs = Theme.of(context).colorScheme;
    final keepEditing = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          context.l10n.discardChangesConfirm,
          style: localeFont(fontWeight: FontWeight.w700),
        ),
        content: Text(
          context.l10n.discardChangesBody,
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              context.l10n.keepEditing,
              style: localeFont(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.discardLabel,
              style: localeFont(fontWeight: FontWeight.w700, color: cs.error),
            ),
          ),
        ],
      ),
    );
    return keepEditing == false;
  }

  Future<void> _save() async {
    final w = _widgets;
    if (w == null) return;
    await saveWidgetPreferences(ref, widget.scope, List.of(w));
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final loaded = _widgets != null;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (await _confirmDiscard()) {
          if (!context.mounted) return;
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        body: KuberScrollAwayHeader(
          header: KuberAppBar(
            showBack: true,
            closeIcon: true,
            title: widget.scope.title,
            onBack: () async {
              if (await _confirmDiscard()) {
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
          ),
          body: loaded
              ? Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        KuberSpace.screenMargin,
                        0,
                        KuberSpace.screenMargin,
                        KuberSpace.md,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Drag the handle to reorder. Toggle to show/hide.',
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          KuberSpace.screenMargin,
                          0,
                          KuberSpace.screenMargin,
                          120,
                        ),
                        buildDefaultDragHandles: false,
                        itemCount: _widgets!.length,
                        onReorder: (oldI, newI) => setState(() {
                          if (newI > oldI) newI -= 1;
                          final w = _widgets!.removeAt(oldI);
                          _widgets!.insert(newI, w);
                        }),
                        proxyDecorator: (child, idx, anim) {
                          return Material(
                            color: Colors.transparent,
                            child: AnimatedBuilder(
                              animation: anim,
                              builder: (ctx, _) {
                                return Container(
                                  decoration: BoxDecoration(
                                    borderRadius: KuberShape.cardR,
                                    color: cs.surfaceContainerHigh,
                                  ),
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        itemBuilder: (ctx, i) {
                          final w = _widgets![i];
                          return _WidgetRow(
                            key: ValueKey(w.id),
                            index: i,
                            isLast: i == _widgets!.length - 1,
                            widget: w,
                            onToggle: (v) => _toggle(i, v),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const Center(child: CircularProgressIndicator()),
        ),
        bottomSheet: loaded
            ? Container(
                padding: EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  12,
                  KuberSpace.screenMargin,
                  24 + systemNavBarInset(context),
                ),
                decoration: BoxDecoration(
                  color: cs.surface,
                  border: Border(top: BorderSide(color: cs.outlineVariant)),
                ),
                child: AppButton(
                  label: context.l10n.saveChanges,
                  type: AppButtonType.primary,
                  fullWidth: true,
                  onPressed: _dirty ? _save : null,
                ),
              )
            : null,
      ),
    );
  }
}

class _WidgetRow extends StatelessWidget {
  final int index;
  final bool isLast;
  final HomeWidgetConfig widget;
  final ValueChanged<bool> onToggle;

  const _WidgetRow({
    super.key,
    required this.index,
    required this.isLast,
    required this.widget,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Rows read as one grouped list (board 3.2c): rounded ends, shared 1dp
    // edges (each row overlaps the previous by its top border).
    const r = Radius.circular(KuberShape.largeIncreased);
    return Transform.translate(
      offset: Offset(0, -index.toDouble()),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.vertical(
            top: index == 0 ? r : Radius.zero,
            bottom: isLast ? r : Radius.zero,
          ),
          border: Border.all(color: cs.outlineVariant),
        ),
        constraints: const BoxConstraints(minHeight: KuberSpace.listItem2),
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 8),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: cs.onSurfaceVariant,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    localizedWidgetName(context, widget.id),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                    ),
                  ),
                  if (widget.description != null)
                    Text(
                      localizedWidgetDesc(context, widget.id) ??
                          widget.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpace.md),
            Switch(value: widget.enabled, onChanged: onToggle),
          ],
        ),
      ),
    );
  }
}
