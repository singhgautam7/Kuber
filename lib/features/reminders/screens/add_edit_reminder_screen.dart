import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../categories/providers/category_provider.dart';
import '../../transactions/widgets/category_picker_sheet.dart';
import '../data/reminder.dart';
import '../providers/reminders_provider.dart';
import '../widgets/reminder_form_fields.dart';
import '../widgets/reminder_details_section.dart';

/// Add / Edit Reminder full screen (screens 2b collapsed / 2c expanded).
/// Universal pattern header, no FAB (form screen).
class AddEditReminderScreen extends ConsumerStatefulWidget {
  final Reminder? existing;

  const AddEditReminderScreen({super.key, this.existing});

  @override
  ConsumerState<AddEditReminderScreen> createState() =>
      _AddEditReminderScreenState();
}

class _AddEditReminderScreenState
    extends ConsumerState<AddEditReminderScreen> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _amountController = TextEditingController();

  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  bool _detailsExpanded = false;
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
      _detailsExpanded = e.notes != null ||
          e.amount != null ||
          e.categoryId != null ||
          e.repeat != null;
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
    final picked =
        await showTimePicker(context: context, initialTime: _dueTime);
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
        context, _isEditing ? 'Reminder updated' : 'Reminder saved');
  }

  Future<void> _delete() async {
    final e = widget.existing;
    if (e == null) return;
    final cs = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.lg),
          side: BorderSide(color: cs.outline),
        ),
        title: Text('Delete reminder?',
            style: localeFont(fontWeight: FontWeight.w700, fontSize: 18)),
        content: Text(
          '"${e.title}" will be permanently deleted.',
          style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel',
                style: localeFont(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Delete',
                style: localeFont(
                    color: cs.error, fontWeight: FontWeight.w700)),
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
    final category = ref.watch(categoryListProvider.select(
      (async) =>
          async.valueOrNull?.firstWhereOrNull((c) => c.id == _categoryId),
    ));

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, showHome: true, showBrand: false),
      body: Column(
        children: [
          KuberPageHeader(
            title: _isEditing ? 'Edit reminder' : 'New reminder',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const ReminderFieldLabel('Title'),
                ReminderTextField(
                  controller: _titleController,
                  hint: 'e.g. Pay maid salary',
                ),
                const SizedBox(height: 16),
                const ReminderFieldLabel('Date & time'),
                Row(
                  children: [
                    Expanded(
                      flex: 14,
                      child: ReminderPickerField(
                        icon: Icons.calendar_month_rounded,
                        label: DateFormat('EEE, d MMM').format(_dueDate),
                        onTap: _pickDate,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      flex: 10,
                      child: ReminderPickerField(
                        icon: Icons.schedule_rounded,
                        label: _dueTime.format(context),
                        onTap: _pickTime,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ReminderDetailsSection(
                  expanded: _detailsExpanded,
                  onToggle: () =>
                      setState(() => _detailsExpanded = !_detailsExpanded),
                  notesController: _notesController,
                  amountController: _amountController,
                  transactionType: _transactionType,
                  onTypeChanged: (t) =>
                      setState(() => _transactionType = t),
                  categoryName: category?.name,
                  onCategoryTap: _pickCategory,
                  repeat: _repeat,
                  onRepeatChanged: (r) => setState(() => _repeat = r),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppButton(
                    label: 'Save reminder',
                    type: AppButtonType.primary,
                    fullWidth: true,
                    onPressed: _save,
                  ),
                  if (_isEditing) ...[
                    const SizedBox(height: 10),
                    AppButton(
                      label: 'Delete reminder',
                      icon: Icons.delete_outline_rounded,
                      type: AppButtonType.danger,
                      height: 46,
                      fullWidth: true,
                      onPressed: _delete,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
