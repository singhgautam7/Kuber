import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../data/tag.dart';
import '../providers/tag_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/info_table.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/sheet_button_section.dart';
import '../../history/providers/history_filter_provider.dart';

class AddEditTagBottomSheet extends ConsumerStatefulWidget {
  final Tag? tag;
  const AddEditTagBottomSheet({super.key, this.tag});

  @override
  ConsumerState<AddEditTagBottomSheet> createState() =>
      _AddEditTagBottomSheetState();
}

class _AddEditTagBottomSheetState extends ConsumerState<AddEditTagBottomSheet> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final tagExistsMsg = context.l10n.tagAlreadyExists;
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final normalized = Tag.normalize(name);
    final repo = ref.read(tagRepositoryProvider);

    // Check uniqueness if name changed or new
    if (widget.tag == null || normalized != widget.tag!.name) {
      final existing = await repo.findByName(normalized);
      if (existing != null) {
        setState(() => _errorText = tagExistsMsg);
        return;
      }
    }

    final tag = widget.tag ?? Tag();
    tag.name = normalized;
    if (widget.tag == null) {
      tag.createdAt = DateTime.now();
    }

    await repo.saveTag(tag);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.tag != null;

    // Board 3.17 Add / Edit Tag: shared sheet, filled "Tag name" field with a
    // # prefix, Save pinned.
    return KuberBottomSheet(
      title: isEdit ? context.l10n.editTag : context.l10n.newTag,
      actions: AppButton(
        label: isEdit ? context.l10n.updateTag : context.l10n.createTag,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: _save,
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: (val) {
          if (_errorText != null) setState(() => _errorText = null);
        },
        style: Theme.of(
          context,
        ).textTheme.bodyLarge!.copyWith(color: cs.onSurface),
        decoration: InputDecoration(
          labelText: 'Tag name',
          hintText: context.l10n.tagNameHint,
          prefixText: '#',
          errorText: _errorText,
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
      ),
    );
  }
}

class ViewTagBottomSheet extends ConsumerWidget {
  final Tag tag;
  const ViewTagBottomSheet({super.key, required this.tag});

  void _edit(BuildContext context) {
    Navigator.of(context).pop();
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddEditTagBottomSheet(tag: tag),
    );
  }

  Future<void> _toggleEnabled(BuildContext context, WidgetRef ref) async {
    await ref.read(tagRepositoryProvider).setTagEnabled(tag.id, !tag.isEnabled);
    if (context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM dd, yyyy').format(tag.createdAt);

    final count = ref.watch(tagTransactionCountProvider(tag.id)).valueOrNull;
    final firstTxn = ref.watch(tagFirstTransactionProvider(tag.id)).valueOrNull;
    final lastTxn = ref.watch(tagRecentTransactionProvider(tag.id)).valueOrNull;

    String fmtDate(DateTime dt) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final d = DateTime(dt.year, dt.month, dt.day);
      if (d == today) return 'Today • ${DateFormatter.time(dt)}';
      return DateFormat('MMM d, yyyy').format(dt);
    }

    final rows = <InfoTableRow>[
      InfoTableDataRow(
        label: context.l10n.usageCountLabel,
        value: context.l10n.transactionsCountValue(count ?? 0),
      ),
      if (firstTxn != null)
        InfoTableDataRow(
          label: context.l10n.firstUsedLabel,
          value: fmtDate(firstTxn.createdAt),
        ),
      if (lastTxn != null)
        InfoTableDataRow(
          label: context.l10n.lastUsedLabel,
          value: fmtDate(lastTxn.createdAt),
        ),
    ];

    return KuberBottomSheet(
      title: '#${tag.name}',
      subtitle: context.l10n.createdOnUpper(dateStr.toUpperCase()),
      leadingIcon: Builder(
        builder: (context) {
          final palette = context.kuberChart.categorical;
          final tones = categoryTones(
            context,
            palette[tag.id % palette.length],
          );
          return Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tones.container,
              borderRadius: KuberShape.mediumR,
            ),
            child: Icon(Icons.sell_rounded, size: 24, color: tones.fg),
          );
        },
      ),
      actions: SheetButtonSection(
        padding: EdgeInsets.zero,
        primary: SheetAction(
          label: context.l10n.viewTaggedTransactions,
          icon: Icons.receipt_long_rounded,
          onPressed: () {
            ref.read(historyFilterProvider.notifier).clearAll();
            ref
                .read(historyFilterProvider.notifier)
                .setFilters(tagIds: {tag.id});
            context.go('/history');
          },
        ),
        actions: [
          SheetAction(
            label: context.l10n.editLabel,
            icon: Icons.edit_outlined,
            onPressed: () => _edit(context),
          ),
          SheetAction(
            label: tag.isEnabled
                ? context.l10n.disableLabel
                : context.l10n.enableLabel,
            icon: tag.isEnabled
                ? Icons.block_flipped
                : Icons.check_circle_outline_rounded,
            onPressed: () => _toggleEnabled(context, ref),
          ),
          SheetAction(
            label: context.l10n.deleteTag,
            icon: Icons.delete_outline_rounded,
            destructive: true,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [InfoTable(rows: rows)],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberShape.extraLarge),
          side: BorderSide(color: cs.outlineVariant, width: 1),
        ),
        title: Text(
          context.l10n.deleteTagConfirm,
          style: localeFont(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        content: Text(
          context.l10n.deleteTagBody(tag.name),
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.cancelLabel, style: localeFont()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberShape.small),
              ),
            ),
            onPressed: () async {
              await ref.read(tagRepositoryProvider).deleteTag(tag.id);
              ref.invalidate(tagListProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: Text(context.l10n.deleteLabel),
          ),
        ],
      ),
    );
  }
}
