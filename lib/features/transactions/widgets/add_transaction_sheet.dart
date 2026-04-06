import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_filex/open_filex.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/services/attachment_service.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart' show currencyProvider;
import '../data/transaction.dart';
import '../providers/suggestion_provider.dart';
import '../providers/transaction_provider.dart';
import 'suggestion_list.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/timed_snackbar.dart';

class AddTransactionSheet extends ConsumerStatefulWidget {
  final Transaction? transaction;

  const AddTransactionSheet({super.key, this.transaction});

  @override
  ConsumerState<AddTransactionSheet> createState() =>
      _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String _type = 'expense';
  int? _selectedCategoryId;
  int? _selectedAccountId;
  DateTime _selectedDate = DateTime.now();
  bool _shouldAutofocus = true;

  // Attachment state
  List<String> _attachmentPaths = []; // existing saved paths (edit mode)
  final List<String> _pendingAttachments = []; // newly picked, not yet copied
  final Set<String> _removedAttachments = {}; // staged for deletion on save
  bool _isPickingFile = false;

  bool get _isEditing => widget.transaction != null;

  int get _totalAttachmentCount =>
      _attachmentPaths.length +
      _pendingAttachments.length -
      _removedAttachments.length;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final t = widget.transaction!;
      _nameController.text = t.name;
      _amountController.text = t.amount.toString();
      _notesController.text = t.notes ?? '';
      _type = t.type;
      _selectedCategoryId = int.tryParse(t.categoryId);
      _selectedAccountId = int.tryParse(t.accountId);
      _selectedDate = t.createdAt;
      _attachmentPaths = List.from(t.attachmentPaths);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final suggestions = ref.watch(suggestionProvider);
    final categories = ref.watch(categoryListProvider);
    final accounts = ref.watch(accountListProvider);

    // Show skeleton while providers are loading (rare cold-load case)
    if (categories.isLoading || accounts.isLoading) {
      return const FormSheetSkeleton();
    }

    // Listen for pending account selection from Add Account flow
    ref.listen<int?>(pendingAccountSelectionProvider, (_, accId) {
      if (accId != null) {
        setState(() => _selectedAccountId = accId);
        ref.read(pendingAccountSelectionProvider.notifier).state = null;
      }
    });

    // Listen for pending category selection from Add Category flow
    ref.listen<int?>(pendingCategorySelectionProvider, (_, catId) {
      if (catId != null) {
        setState(() => _selectedCategoryId = catId);
        ref.read(pendingCategorySelectionProvider.notifier).state = null;
      }
    });

    // After the first build, we stop auto-focussing to prevent focus jumps on rebuilds
    if (_shouldAutofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _shouldAutofocus = false);
      });
    }

    return Padding(
      padding: EdgeInsets.only(
        left: KuberSpacing.lg,
        right: KuberSpacing.lg,
        top: KuberSpacing.lg,
        bottom: MediaQuery.of(context).viewInsets.bottom + KuberSpacing.lg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),
            Text(
              _isEditing ? 'Edit Transaction' : 'Add Transaction',
              style: textTheme.titleLarge,
            ),
            const SizedBox(height: KuberSpacing.lg),

            // 1. Name field
            TextField(
              controller: _nameController,
              autofocus: !_isEditing && _shouldAutofocus,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Transaction Name',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                ref.read(suggestionQueryProvider.notifier).state = value;
              },
            ),

            // Suggestion list
            if (!_isEditing)
              suggestions.when(
                loading: () => const SizedBox.shrink(),
                error: (e, st) => const SizedBox.shrink(),
                data: (list) => Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: KuberSpacing.xs),
                  child: SuggestionList(
                    suggestions: list,
                    onSelected: _applySuggestion,
                  ),
                ),
              ),

            const SizedBox(height: KuberSpacing.md),

            // 2. Amount
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount',
                border: const OutlineInputBorder(),
                prefixText: '${ref.watch(currencyProvider).symbol} ',
              ),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 3. Type toggle
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'expense', label: Text('Expense')),
                ButtonSegment(value: 'income', label: Text('Income')),
              ],
              selected: {_type},
              onSelectionChanged: (v) => setState(() => _type = v.first),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 4. Category chips
            categories.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (cats) => Wrap(
                spacing: KuberSpacing.sm,
                runSpacing: KuberSpacing.sm,
                children: cats.map((c) {
                  final selected = _selectedCategoryId == c.id;
                  final harmonized =
                      harmonizeCategory(context, Color(c.colorValue));
                  return ChoiceChip(
                    selected: selected,
                    label: Text(c.name),
                    avatar: Icon(
                      IconMapper.fromString(c.icon),
                      size: 18,
                      color: selected ? colorScheme.onPrimaryContainer : harmonized,
                    ),
                    onSelected: (_) {
                      setState(() => _selectedCategoryId = c.id);
                      FocusScope.of(context).unfocus();
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 5. Account dropdown
            accounts.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (accs) => DropdownButtonFormField<int>(
                initialValue: _selectedAccountId,
                decoration: const InputDecoration(
                  labelText: 'Account',
                  border: OutlineInputBorder(),
                ),
                items: accs
                    .map((a) => DropdownMenuItem(
                          value: a.id,
                          child: Text(a.name),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedAccountId = v);
                  FocusScope.of(context).unfocus();
                },
              ),
            ),
            const SizedBox(height: KuberSpacing.md),

            // 6. Date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),

            // 7. Notes
            TextField(
              controller: _notesController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: KuberSpacing.lg),

            // 8. Attachments
            _buildAttachmentsSection(colorScheme, textTheme),
            const SizedBox(height: KuberSpacing.xl),

            // Actions
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: AppButton(
                    label: _isEditing
                        ? (_type == 'expense'
                            ? 'Update Expense'
                            : _type == 'income'
                                ? 'Update Income'
                                : 'Update Transfer')
                        : (_type == 'expense'
                            ? 'Save Expense'
                            : _type == 'income'
                                ? 'Save Income'
                                : 'Save Transfer'),
                    type: AppButtonType.primary,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
            const SizedBox(height: KuberSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentsSection(ColorScheme cs, TextTheme textTheme) {
    // All visible attachments: existing (minus removed) + pending
    final visible = <_AttachmentItem>[
      for (final p in _attachmentPaths)
        if (!_removedAttachments.contains(p))
          _AttachmentItem(path: p, isPending: false),
      for (final p in _pendingAttachments)
        _AttachmentItem(path: p, isPending: true),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ATTACHMENTS',
          style: textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: KuberSpacing.sm),
        if (_isPickingFile)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: KuberSpacing.md),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else if (visible.isEmpty)
          TextButton.icon(
            onPressed: _pickAttachment,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('ADD IMAGE OR PDF'),
            style: TextButton.styleFrom(
              foregroundColor: cs.primary,
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
            ),
          )
        else
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: visible.length + (visible.length < AttachmentService.maxAttachments ? 1 : 0),
              separatorBuilder: (_, __) => const SizedBox(width: KuberSpacing.sm),
              itemBuilder: (context, index) {
                if (index == visible.length) {
                  // Add button
                  return GestureDetector(
                    onTap: _pickAttachment,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        border: Border.all(color: cs.outline),
                      ),
                      child: Icon(Icons.add, color: cs.primary),
                    ),
                  );
                }

                final item = visible[index];
                final isImage = AttachmentService.getFileType(item.path) == 'image';

                return GestureDetector(
                  onTap: () => OpenFilex.open(item.path),
                  child: Stack(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          border: Border.all(color: cs.outline),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: isImage
                            ? Image.file(
                                File(item.path),
                                fit: BoxFit.cover,
                                width: 72,
                                height: 72,
                              )
                            : Center(
                                child: Icon(
                                  Icons.picture_as_pdf,
                                  color: cs.primary,
                                  size: 32,
                                ),
                              ),
                      ),
                      Positioned(
                        top: 2,
                        right: 2,
                        child: GestureDetector(
                          onTap: () => _removeAttachment(item),
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 12,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _pickAttachment() async {
    if (_totalAttachmentCount >= AttachmentService.maxAttachments) {
      if (mounted) {
        showKuberSnackBar(context, 'Maximum ${AttachmentService.maxAttachments} attachments allowed',
            isError: true);
      }
      return;
    }

    setState(() => _isPickingFile = true);

    try {
      // Show picker choice
      final choice = await showModalBottomSheet<String>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Pick Image'),
                onTap: () => Navigator.pop(ctx, 'image'),
              ),
              ListTile(
                leading: const Icon(Icons.picture_as_pdf),
                title: const Text('Pick PDF'),
                onTap: () => Navigator.pop(ctx, 'pdf'),
              ),
            ],
          ),
        ),
      );

      if (choice == null || !mounted) {
        setState(() => _isPickingFile = false);
        return;
      }

      String? pickedPath;

      if (choice == 'image') {
        final picker = ImagePicker();
        final image = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 1920,
          maxHeight: 1920,
        );
        pickedPath = image?.path;
      } else {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
        );
        pickedPath = result?.files.single.path;
      }

      if (pickedPath != null && mounted) {
        // Check file size
        final fileSize = await File(pickedPath).length();
        if (fileSize > AttachmentService.maxFileSizeBytes) {
          if (mounted) {
            showKuberSnackBar(context, 'File size exceeds 5MB limit',
                isError: true);
          }
        } else {
          setState(() => _pendingAttachments.add(pickedPath!));
        }
      }
    } catch (_) {
      if (mounted) {
        showKuberSnackBar(context, 'Failed to pick file', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isPickingFile = false);
    }
  }

  void _removeAttachment(_AttachmentItem item) {
    setState(() {
      if (item.isPending) {
        _pendingAttachments.remove(item.path);
        // In add mode, delete the temp file immediately (image_picker temp)
        // Don't delete — it's a temp file managed by the OS
      } else {
        _removedAttachments.add(item.path);
      }
    });
  }

  void _applySuggestion(Transaction suggestion) {
    setState(() {
      _nameController.text = suggestion.name;
      _amountController.text = suggestion.amount.toString();
      _type = suggestion.type;
      _selectedCategoryId = int.tryParse(suggestion.categoryId);
      _selectedAccountId = int.tryParse(suggestion.accountId);
      _notesController.text = suggestion.notes ?? '';
    });
    // Clear suggestions
    ref.read(suggestionQueryProvider.notifier).state = '';
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty) {
      showKuberSnackBar(context, 'Please enter a transaction name', isError: true);
      return;
    }
    if (amount == null || amount <= 0) {
      showKuberSnackBar(context, 'Please enter a valid amount', isError: true);
      return;
    }
    if (_selectedCategoryId == null) {
      showKuberSnackBar(context, 'Please select a category', isError: true);
      return;
    }
    if (_selectedAccountId == null) {
      showKuberSnackBar(context, 'Please select an account', isError: true);
      return;
    }

    final attachmentService = ref.read(attachmentServiceProvider);
    final notifier = ref.read(transactionListProvider.notifier);

    final t = _isEditing ? widget.transaction! : Transaction();
    t.name = name;
    t.amount = amount;
    t.type = _type;
    t.categoryId = _selectedCategoryId.toString();
    t.accountId = _selectedAccountId.toString();
    t.notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    t.nameLower = name.toLowerCase();
    if (!_isEditing) {
      t.createdAt = _selectedDate;
    }
    t.updatedAt = DateTime.now();

    if (_isEditing) {
      // Delete removed attachments
      for (final path in _removedAttachments) {
        await attachmentService.deleteAttachment(path);
      }
      // Copy pending attachments
      final kept = _attachmentPaths
          .where((p) => !_removedAttachments.contains(p))
          .toList();
      for (final source in _pendingAttachments) {
        final saved = await attachmentService.saveAttachment(
            t.id, source, kept.length);
        kept.add(saved);
      }
      t.attachmentPaths = kept;
      await notifier.updateTransaction(t);
    } else {
      // Save transaction first to get the ID
      final id = await notifier.add(t);
      // Copy pending attachments with the new ID
      if (_pendingAttachments.isNotEmpty) {
        final paths = <String>[];
        for (final source in _pendingAttachments) {
          final saved = await attachmentService.saveAttachment(
              id, source, paths.length);
          paths.add(saved);
        }
        t.id = id;
        t.attachmentPaths = paths;
        await notifier.updateTransaction(t);
      }
    }

    if (mounted) Navigator.pop(context);
  }
}

class _AttachmentItem {
  final String path;
  final bool isPending;
  const _AttachmentItem({required this.path, required this.isPending});
}
