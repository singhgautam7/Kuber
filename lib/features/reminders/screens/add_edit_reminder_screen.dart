import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import 'package:flutter/services.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/reminder.dart';
import '../providers/reminders_provider.dart';

/// Add / Edit Reminder full screen (screens 2b collapsed / 2c expanded).
/// Universal pattern header, no FAB (form screen).
class AddEditReminderScreen extends ConsumerStatefulWidget {
  final Reminder? existing;

  const AddEditReminderScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditReminderScreen> createState() =>
      _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends ConsumerState<AddEditReminderScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  String _transactionType = 'expense';
  int? _categoryId;
  String? _repeat;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _titleController.text = e.title;
      _notesController.text = e.notes ?? '';
      if (e.amount != null) {
        _amountController.text = e.amount == e.amount!.truncateToDouble()
            ? e.amount!.toInt().toString()
            : e.amount!.toStringAsFixed(2);
      }
      _dueDate = e.dueAt;
      _dueTime = TimeOfDay.fromDateTime(e.dueAt);
      _transactionType = e.transactionType ?? 'expense';
      _categoryId = int.tryParse(e.categoryId ?? '');
      _repeat = e.repeat;
    } else {
      final now = DateTime.now().add(const Duration(hours: 1));
      _dueDate = now;
      _dueTime = TimeOfDay(hour: now.hour, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  DateTime get _dueAt => DateTime(
    _dueDate.year,
    _dueDate.month,
    _dueDate.day,
    _dueTime.hour,
    _dueTime.minute,
  );

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) setState(() => _dueTime = picked);
  }

  void _pickCategory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => CategoryPickerSheet(
        selectedCategoryId: _categoryId,
        defaultType: _transactionType,
        onSelected: (id) {
          setState(() => _categoryId = id);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      showKuberSnackBar(context, 'Enter a reminder title', isError: true);
      return;
    }

    final amountText = _amountController.text.trim().replaceAll(',', '');
    final amount = amountText.isEmpty ? null : double.tryParse(amountText);
    if (amountText.isNotEmpty && (amount == null || amount <= 0)) {
      showKuberSnackBar(context, 'Enter a valid amount', isError: true);
      return;
    }

    final reminder = widget.existing ?? Reminder()
      ..createdAt = widget.existing?.createdAt ?? DateTime.now()
      ..status = widget.existing?.status ?? ReminderStatus.pending;
    reminder
      ..title = title
      ..notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim()
      ..dueAt = _dueAt
      ..amount = amount
      ..transactionType = amount == null ? null : _transactionType
      ..categoryId = _categoryId?.toString()
      ..repeat = _repeat;
    if (!reminder.isCompleted && !_isEditing) {
      reminder.status = ReminderStatus.pending;
    }

    await ref.read(remindersRepositoryProvider).save(reminder);
    if (!mounted) return;
    Navigator.of(context).pop();
    showKuberSnackBar(
      context,
      _isEditing ? 'Reminder updated' : 'Reminder saved',
    );
  }

  Future<void> _delete() async {
    final e = widget.existing;
    if (e == null) return;
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete reminder?'),
        content: Text('"${e.title}" will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await ref.read(remindersRepositoryProvider).delete(e.id);
    if (mounted) {
      Navigator.of(context).pop();
      showKuberSnackBar(context, 'Reminder deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final category = ref.watch(
      categoryListProvider.select(
        (async) =>
            async.valueOrNull?.firstWhereOrNull((c) => c.id == _categoryId),
      ),
    );

    final tt = Theme.of(context).textTheme;
    Widget section(String title, Widget child) => Padding(
      padding: const EdgeInsets.only(top: KuberSpace.sectionGap - 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberSectionHeader(title: title),
          child,
        ],
      ),
    );
    String repeatLabel(String? v) => switch (v) {
      ReminderRepeat.daily => 'Daily',
      ReminderRepeat.weekly => 'Weekly',
      ReminderRepeat.monthly => 'Monthly',
      ReminderRepeat.yearly => 'Yearly',
      _ => 'Never',
    };

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: _isEditing ? 'Edit reminder' : 'New reminder',
        showBack: true,
        closeIcon: true,
        actions: [
          if (_isEditing)
            AppIconButton(
              icon: Icons.delete_outline_rounded,
              kind: AppIconButtonKind.danger,
              semanticLabel: 'Delete reminder',
              onPressed: _delete,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                0,
                KuberSpace.screenMargin,
                KuberSpace.lg,
              ),
              children: [
                TextField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  style: tt.bodyLarge!.copyWith(color: cs.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    hintText: 'e.g. Pay maid salary',
                  ),
                ),
                const SizedBox(height: KuberSpace.md),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  style: tt.bodyLarge!.copyWith(color: cs.onSurface),
                  decoration: const InputDecoration(
                    labelText: 'Amount · optional',
                    prefixText: '₹',
                  ),
                ),
                const SizedBox(height: KuberSpace.md),
                KuberSegmentedControl<String>(
                  values: const ['expense', 'income'],
                  labels: const ['Expense', 'Income'],
                  selected: _transactionType,
                  onSelected: (t) => setState(() => _transactionType = t),
                  height: 40,
                ),
                section(
                  'When',
                  KuberGroup(
                    children: [
                      KuberListRow(
                        leading: const KuberIconTile(
                          icon: Icons.calendar_month_rounded,
                        ),
                        title: DateFormat('EEE, MMM d, y').format(_dueDate),
                        subtitle: 'Date',
                        trailing: const KuberChevron(),
                        onTap: _pickDate,
                      ),
                      KuberListRow(
                        leading: const KuberIconTile(
                          icon: Icons.schedule_rounded,
                        ),
                        title: _dueTime.format(context),
                        subtitle: 'Time',
                        trailing: const KuberChevron(),
                        onTap: _pickTime,
                      ),
                    ],
                  ),
                ),
                section(
                  'Repeat',
                  Wrap(
                    spacing: KuberSpace.sm,
                    runSpacing: KuberSpace.sm,
                    children: [
                      for (final v in [null, ...ReminderRepeat.all])
                        KuberChip(
                          label: repeatLabel(v),
                          selected: _repeat == v,
                          onTap: () => setState(() => _repeat = v),
                        ),
                    ],
                  ),
                ),
                section(
                  'Category',
                  KuberGroup(
                    children: [
                      KuberListRow(
                        leading: const KuberIconTile(
                          icon: Icons.category_outlined,
                        ),
                        title: category?.name ?? 'Pick a category',
                        subtitle: 'Optional',
                        trailing: const KuberChevron(),
                        onTap: _pickCategory,
                      ),
                    ],
                  ),
                ),
                section(
                  'Notes',
                  TextField(
                    controller: _notesController,
                    minLines: 1,
                    maxLines: 4,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    style: tt.bodyLarge!.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Optional · anything worth remembering',
                      prefixIcon: Icon(
                        Icons.notes_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          KuberSaveButton(label: 'Save reminder', onPressed: _save),
        ],
      ),
    );
  }
}
