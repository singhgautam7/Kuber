import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../models/home_widget_config.dart';
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
  ConsumerState<WidgetEditorScreen> createState() =>
      _WidgetEditorScreenState();
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
          'At least one widget must be enabled',
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
          'Discard changes?',
          style: localeFont(fontWeight: FontWeight.w800),
        ),
        content: Text(
          'You have unsaved changes to your widgets. '
          'Leaving now will discard them.',
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              'Keep editing',
              style: localeFont(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Discard',
              style: localeFont(
                fontWeight: FontWeight.w700,
                color: cs.error,
              ),
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
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
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
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () async {
              if (await _confirmDiscard()) {
                if (!context.mounted) return;
                Navigator.pop(context);
              }
            },
          ),
          title: Text(
            widget.scope.title,
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
        ),
        body: loaded
            ? Column(
                children: [
                  const SizedBox(height: KuberSpacing.sm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                        vertical: KuberSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.drag_indicator_rounded,
                            size: 14,
                            color: cs.onSurfaceVariant
                                .withValues(alpha: 0.7)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Drag the handle to reorder. Toggle to show/hide.',
                            style: localeFont(
                              fontSize: 12,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ReorderableListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          KuberSpacing.lg, 8, KuberSpacing.lg, 120),
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
                                  borderRadius:
                                      BorderRadius.circular(KuberRadius.md),
                                  border: Border.all(
                                      color: cs.primary, width: 1.5),
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
                          widget: w,
                          onToggle: (v) => _toggle(i, v),
                        );
                      },
                    ),
                  ),
                ],
              )
            : const Center(child: CircularProgressIndicator()),
        bottomSheet: loaded
            ? SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(
                      KuberSpacing.lg, 12, KuberSpacing.lg, 12),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(
                      top: BorderSide(
                          color: cs.outline.withValues(alpha: 0.4)),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: _dirty ? _save : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        disabledBackgroundColor: cs.surfaceContainerHigh,
                        disabledForegroundColor:
                            cs.onSurfaceVariant.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(KuberRadius.md),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: localeFont(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _WidgetRow extends StatelessWidget {
  final int index;
  final HomeWidgetConfig widget;
  final ValueChanged<bool> onToggle;

  const _WidgetRow({
    super.key,
    required this.index,
    required this.widget,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: cs.outline),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.sm,
          vertical: KuberSpacing.sm,
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.drag_indicator_rounded,
                  color: cs.onSurfaceVariant,
                  size: 22,
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
                    widget.name,
                    style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (widget.description != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      widget.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            Switch(
              value: widget.enabled,
              onChanged: onToggle,
              activeTrackColor: cs.primary,
            ),
          ],
        ),
      ),
    );
  }
}