import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../data/tag.dart';
import '../providers/tag_providers.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../history/providers/history_filter_provider.dart';

class AddEditTagBottomSheet extends ConsumerStatefulWidget {
  final Tag? tag;
  const AddEditTagBottomSheet({super.key, this.tag});

  @override
  ConsumerState<AddEditTagBottomSheet> createState() => _AddEditTagBottomSheetState();
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
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final normalized = Tag.normalize(name);
    final repo = ref.read(tagRepositoryProvider);

    // Check uniqueness if name changed or new
    if (widget.tag == null || normalized != widget.tag!.name) {
      final existing = await repo.findByName(normalized);
      if (existing != null) {
        setState(() => _errorText = 'Tag already exists');
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

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + KuberSpacing.xl,
        left: KuberSpacing.xl,
        right: KuberSpacing.xl,
        top: KuberSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEdit ? "Edit Tag" : "New Tag",
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: cs.surfaceContainerHigh,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            autofocus: true,
            onChanged: (val) {
              if (_errorText != null) setState(() => _errorText = null);
            },
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: cs.onSurface,
            ),
            decoration: InputDecoration(
              hintText: "Example: weekend, trip-to-goa",
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
              prefixIcon: Container(
                padding: const EdgeInsets.all(12),
                child: Text(
                  "#",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: cs.primary,
                  ),
                ),
              ),
              errorText: _errorText,
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.primary, width: 2),
              ),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: isEdit ? "Update Tag" : "Create Tag",
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: _save,
          ),
        ],
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
    final cs = Theme.of(context).colorScheme;
    final dateStr = DateFormat('MMM dd, yyyy').format(tag.createdAt);

    return KuberBottomSheet(
      title: tag.name,
      subtitle: "CREATED ON ${dateStr.toUpperCase()}",
      leadingIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: cs.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        alignment: Alignment.center,
        child: Text(
          "#",
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: cs.primary,
          ),
        ),
      ),
      actions: AppButton(
        label: 'View Transactions',
        icon: Icons.receipt_long_rounded,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () {
          ref.read(historyFilterProvider.notifier).clearAll();
          ref.read(historyFilterProvider.notifier).setFilters(
                tagIds: {tag.id},
              );
          context.go('/history');
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Last Transaction Activity
          Consumer(
            builder: (context, ref, _) {
              final latestTxnAsync = ref.watch(tagRecentTransactionProvider(tag.id));
              return latestTxnAsync.when(
                data: (txn) => Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 14, color: cs.onSurfaceVariant),
                    const SizedBox(width: 6),
                    Text(
                      txn != null
                          ? 'Last transaction ${DateFormatter.timeAgo(txn.createdAt)}'
                          : 'No transactions yet',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              );
            },
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: "Edit",
                  icon: Icons.edit_outlined,
                  type: AppButtonType.normal,
                  onPressed: () => _edit(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: tag.isEnabled ? "Disable" : "Enable",
                  icon: tag.isEnabled ? Icons.block_flipped : Icons.check_circle_outline_rounded,
                  type: tag.isEnabled ? AppButtonType.danger : AppButtonType.normal,
                  onPressed: () => _toggleEnabled(context, ref),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          AppButton(
            label: "Delete Tag",
            icon: Icons.delete_outline_rounded,
            type: AppButtonType.danger,
            fullWidth: true,
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.sm),
          side: BorderSide(color: cs.outline, width: 1),
        ),
        title: Text(
          'Delete tag?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'The tag "#${tag.name}" will be permanently deleted.',
          style: GoogleFonts.inter(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
            ),
            onPressed: () async {
              await ref.read(tagRepositoryProvider).deleteTag(tag.id);
              ref.invalidate(tagListProvider);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
