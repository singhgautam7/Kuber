import 'package:kuber/core/motion/kuber_haptics.dart';
import 'package:kuber/core/motion/route_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../../shared/widgets/timed_snackbar.dart';
import '../../data/saved_filter.dart';
import '../../models/ah_view.dart';
import '../../providers/ah_providers.dart';
import '../common/ah_common.dart';

enum AhNameMode { save, saveAsNew, rename }

/// Save this view / Save as new / Rename.
Future<void> showAhNameSheet(
  BuildContext context, {
  required AhNameMode mode,
  String initialName = '',
  SavedFilter? renaming,
}) {
  return showModalBottomSheet<void>(
      sheetAnimationStyle: kuberSheetStyle(context),
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AhNameSheet(
      mode: mode,
      initialName: initialName,
      renaming: renaming,
      host: context,
    ),
  );
}

class AhNameSheet extends ConsumerStatefulWidget {
  const AhNameSheet({
    super.key,
    required this.mode,
    this.initialName = '',
    this.renaming,
    this.host,
  });
  final AhNameMode mode;
  final String initialName;
  final SavedFilter? renaming;

  /// Context of the page, for the snackbar after the sheet closes.
  final BuildContext? host;

  @override
  ConsumerState<AhNameSheet> createState() => _AhNameSheetState();
}

class _AhNameSheetState extends ConsumerState<AhNameSheet> {
  late final TextEditingController _c =
      TextEditingController(text: widget.initialName);
  bool _taken = false;
  bool _touched = false;
  bool _busy = false;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialName.isNotEmpty) _check(widget.initialName);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _check(String raw) async {
    final seq = ++_seq;
    final name = raw.trim();
    if (name.isEmpty) {
      setState(() => _taken = false);
      return;
    }
    final taken = await ref
        .read(savedFilterRepositoryProvider)
        .nameTaken(name, exceptId: widget.renaming?.id);
    if (mounted && seq == _seq) setState(() => _taken = taken);
  }

  bool get _valid => _c.text.trim().isNotEmpty && !_taken;

  Future<void> _submit() async {
    if (!_valid || _busy) return;
    setState(() => _busy = true);
    final name = _c.text.trim();
    final repo = ref.read(savedFilterRepositoryProvider);
    final host = widget.host;
    final l = context.l10n;
    final nav = Navigator.of(context, rootNavigator: true);
    try {
      if (widget.mode == AhNameMode.rename) {
        await repo.rename(widget.renaming!.id, name);
      } else {
        final f = await repo.saveNew(name, ref.read(ahViewProvider));
        ref.read(ahViewProvider.notifier).markSaved(f.id);
        if (host != null && host.mounted) {
          showKuberSnackBar(host, l.ahdSavedSnack(name));
        }
      }
    } on SavedFilterNameException catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _taken = e.problem == SavedFilterNameProblem.taken;
        });
      }
      return;
    }
    KuberHaptics.confirm();
    nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isRename = widget.mode == AhNameMode.rename;
    final view = isRename ? null : ref.watch(ahViewProvider);
    final String? error = _taken
        ? l.ahdNameTaken(_c.text.trim())
        : (_touched && _c.text.trim().isEmpty ? l.ahdNameHint : null);

    return KuberBottomSheet(
      title: isRename
          ? l.ahdRenameTitle
          : (widget.mode == AhNameMode.saveAsNew
              ? l.ahdSaveAsNew
              : l.ahdSaveTitle),
      actions: AppButton(
        label: isRename ? l.ahdRename : l.saveLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        isLoading: _busy,
        onPressed: _valid ? _submit : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _c,
            autofocus: true,
            maxLength: kAhNameMax,
            inputFormatters: [LengthLimitingTextInputFormatter(kAhNameMax)],
            textInputAction: TextInputAction.done,
            style: localeFont(fontSize: 16, color: cs.onSurface),
            decoration: InputDecoration(
              labelText: l.ahdName,
              hintText: l.ahdNameHint,
              errorText: error,
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: KuberShape.largeR,
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) {
              _touched = true;
              setState(() {});
              _check(v);
            },
            onSubmitted: (_) => _submit(),
          ),
          if (view != null) ...[
            const SizedBox(height: KuberSpace.sm),
            Text(
              ahSummaryLine(
                l,
                filters: ahFilterCount(view.node),
                group: view.groupBy,
                sort: view.sort,
                charts: view.charts.length,
              ),
              style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: KuberSpace.lg),
            Text(l.ahdWhatSaved.toUpperCase(),
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                    letterSpacing: 0.8, color: cs.onSurfaceVariant)),
            const SizedBox(height: KuberSpace.sm),
            _WsRow(l.ahdWsFilter, _filterValue(context, view)),
            _WsRow(
                l.ahdWsGroup,
                view.groupBy == AhGroupBy.none
                    ? l.ahdNotSet
                    : ahGroupName(l, view.groupBy)),
            _WsRow(
                l.ahdWsSort,
                '${ahSortFieldLabel(l, view.sort.field)}, '
                '${ahOrderLabel(l, view.sort).toLowerCase()}'),
            _WsRow(
                l.ahdWsCharts,
                view.charts.isEmpty
                    ? l.ahdNotSet
                    : l.ahdSumCharts(view.charts.length)),
            _WsRow(l.ahdWsKpis, l.ahdKpisShown(view.kpis.length)),
            const SizedBox(height: KuberSpace.md),
            Row(children: [
              Icon(Icons.backup_outlined, size: 16, color: cs.onSurfaceVariant),
              const SizedBox(width: KuberSpace.sm),
              Expanded(
                child: Text(l.ahdBackupNote,
                    style:
                        localeFont(fontSize: 13, color: cs.onSurfaceVariant)),
              ),
            ]),
          ],
        ],
      ),
    );
  }

  String _filterValue(BuildContext context, AhView v) {
    final n = ahFilterCount(v.node);
    return n == 0 ? context.l10n.ahdNotSet : context.l10n.ahdSumFilters(n);
  }
}

class _WsRow extends StatelessWidget {
  const _WsRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 104,
            child: Text(label,
                style: localeFont(fontSize: 14, color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface)),
          ),
        ],
      ),
    );
  }
}
