// =============================================================================
// add_edit_category_screen.dart  — POLISHED
//
// Drop-in replacement for lib/features/more/screens/add_edit_category_screen.dart.
// =============================================================================

import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/icon_color_picker_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/color_palette.dart';
import '../../../shared/widgets/kuber_form_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../categories/providers/category_provider.dart';

// From the pickers-and-setup pass:

class CategoryRouteArgs {
  final Category? category;
  final String? defaultType;
  final bool returnToCategoryPicker;
  final bool hideGroup; // NEW — set true when opened from Advanced Setup.
  const CategoryRouteArgs({
    this.category,
    this.defaultType,
    this.returnToCategoryPicker = false,
    this.hideGroup = false,
  });
}

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final Category? existingCategory;
  final String? defaultType;
  final bool returnToCategoryPicker;
  final bool hideGroup;
  final bool showGroupSelector;
  final ValueChanged<Category>? onSaveLocal;
  final String? saveLabel;

  const AddEditCategoryScreen({
    super.key,
    this.existingCategory,
    this.defaultType,
    this.returnToCategoryPicker = false,
    this.hideGroup = false,
    this.showGroupSelector = true,
    this.onSaveLocal,
    this.saveLabel,
  });

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState extends ConsumerState<AddEditCategoryScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = Color(AppColorPalette.kVibrant.first);
  String _selectedIcon = IconMapper.kCategoryIconKeys.first;
  String _selectedType = 'expense';
  int? _selectedGroupId;

  bool get _canSave => _nameController.text.trim().isNotEmpty;
  bool get _isEditing => widget.existingCategory != null;
  bool get _shouldShowGroup => !widget.hideGroup && widget.showGroupSelector;

  @override
  void initState() {
    super.initState();
    if (widget.existingCategory != null) {
      final cat = widget.existingCategory!;
      _nameController.text = cat.name;
      _selectedIcon = cat.icon;
      _selectedColor = Color(cat.colorValue);
      _selectedType = cat.effectiveType;
      _selectedGroupId = cat.groupId;
    } else if (widget.defaultType != null) {
      _selectedType = widget.defaultType!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        closeIcon: true,
        onBack: () => context.pop(),
        title: _isEditing
            ? context.l10n.editCategory
            : context.l10n.newCategory,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Board 3.16: live preview first, then Identity (name + group).
              _LivePreview(
                name: _nameController.text,
                iconKey: _selectedIcon,
                color: _selectedColor,
                type: _selectedType,
              ),
              KuberFormSection(
                label: context.l10n.identity,
                children: [
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    onTapOutside: (_) =>
                        FocusManager.instance.primaryFocus?.unfocus(),
                    onChanged: (_) => setState(() {}),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge!.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(
                      labelText: sentenceCase(context.l10n.categoryNameLabel),
                      hintText: context.l10n.categoryNameHint,
                    ),
                  ),
                  if (_shouldShowGroup)
                    Consumer(
                      builder: (context, ref, _) {
                        final groupsAsync = ref.watch(
                          categoryGroupListProvider,
                        );
                        final groupName = _selectedGroupId == null
                            ? context.l10n.noneLabel
                            : (groupsAsync.value
                                      ?.firstWhere(
                                        (g) => g.id == _selectedGroupId,
                                        orElse: () =>
                                            CategoryGroup()
                                              ..name = context.l10n.noneLabel,
                                      )
                                      .name ??
                                  context.l10n.noneLabel);
                        return KuberPickerRow(
                          leading: KuberLeadingSwatch(
                            color: cs.surfaceContainerHigh,
                            icon: Icons.folder_outlined,
                            empty: true,
                          ),
                          label:
                              '${sentenceCase(context.l10n.groupLabel)} · ${context.l10n.optionalLabel.toLowerCase()}',
                          value: groupName,
                          valueIsPlaceholder: _selectedGroupId == null,
                          onTap: _openGroupPicker,
                        );
                      },
                    ),
                ],
              ),

              // ── APPEARANCE ───────────────────────────────────────────
              KuberFormSection(
                label: context.l10n.appearance,
                children: [
                  IconColorPickerRow(
                    iconKey: _selectedIcon,
                    colorValue: _selectedColor.toARGB32(),
                    label: context.l10n.iconAndColour,
                    onTap: () => showIconColorPicker(
                      context: context,
                      iconKeys: IconMapper.kCategoryIconKeys,
                      tags: IconMapper.kIconTags,
                      iconKey: _selectedIcon,
                      colorValue: _selectedColor.toARGB32(),
                      onDone: (icon, color) => setState(() {
                        _selectedIcon = icon;
                        _selectedColor = Color(color);
                      }),
                    ).unfocusOnComplete(context),
                  ),
                ],
              ),

              // ── TYPE ─────────────────────────────────────────────────
              KuberFormSection(
                label: context.l10n.typeLabel,
                children: [
                  KuberSegmented<String>(
                    groupValue: _selectedType,
                    onChanged: (v) => setState(() => _selectedType = v),
                    segments: [
                      KuberSegment(
                        value: 'expense',
                        label: context.l10n.expenseLabel,
                        icon: Icons.arrow_outward_rounded,
                        tone: SegmentTone.expense,
                      ),
                      KuberSegment(
                        value: 'income',
                        label: context.l10n.incomeLabel,
                        icon: Icons.south_west_rounded,
                        tone: SegmentTone.income,
                      ),
                      KuberSegment(
                        value: 'both',
                        label: context.l10n.bothLabel,
                        icon: Icons.swap_vert_rounded,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: KuberSaveButton(
        label: widget.existingCategory != null
            ? widget.saveLabel ?? context.l10n.saveChanges
            : widget.saveLabel ?? context.l10n.saveCategory,
        onPressed: _canSave ? _save : null,
      ),
    );
  }

  void _openGroupPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GroupPickerSheet(
        selectedGroupId: _selectedGroupId,
        onSelected: (id) => setState(() => _selectedGroupId = id),
      ),
    ).unfocusOnComplete(context);
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (widget.onSaveLocal != null) {
      final cat = widget.existingCategory ?? Category();
      cat
        ..name = name
        ..icon = _selectedIcon
        ..colorValue = _selectedColor.toARGB32()
        ..isDefault = widget.existingCategory?.isDefault ?? false
        ..type = _selectedType
        ..groupId = _shouldShowGroup ? _selectedGroupId : null;
      widget.onSaveLocal!(cat);
      if (!mounted) return;
      Navigator.of(context).pop();
      return;
    }

    if (widget.existingCategory != null) {
      final cat = widget.existingCategory!;
      cat.name = name;
      cat.icon = _selectedIcon;
      cat.colorValue = _selectedColor.toARGB32();
      cat.type = _selectedType;
      cat.groupId = _shouldShowGroup ? _selectedGroupId : null;
      await ref.read(categoryRepositoryProvider).save(cat);
    } else {
      final cat = Category()
        ..name = name
        ..icon = _selectedIcon
        ..colorValue = _selectedColor.toARGB32()
        ..isDefault = false
        ..type = _selectedType
        ..groupId = _shouldShowGroup ? _selectedGroupId : null;
      await ref.read(categoryRepositoryProvider).save(cat);
      if (widget.returnToCategoryPicker) {
        final allCats = await ref.read(categoryRepositoryProvider).getAll();
        final saved = allCats.lastWhere((c) => c.name == name);
        ref.read(pendingCategorySelectionProvider.notifier).state = saved.id;
      }
    }
    ref.invalidate(categoryListProvider);
    if (!mounted) return;
    context.pop();
    if (!widget.returnToCategoryPicker) {
      showKuberSnackBar(
        context,
        _isEditing ? context.l10n.categoryUpdated : context.l10n.categoryAdded,
      );
    }
  }
}

// ── Live preview ────────────────────────────────────────────────────
class _LivePreview extends StatelessWidget {
  final String name;
  final String iconKey;
  final Color color;
  final String type;
  const _LivePreview({
    required this.name,
    required this.iconKey,
    required this.color,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayName = name.trim().isEmpty
        ? context.l10n.categoryNameLabel
        : name;
    final typeLabel = type == 'both'
        ? context.l10n.bothLabel
        : type == 'income'
        ? context.l10n.incomeLabel
        : context.l10n.expenseLabel;
    final tt = Theme.of(context).textTheme;
    final tones = categoryTones(context, color);
    // Board 3.16: tile + name + type, "Live preview" pill on the right.
    return KuberCard(
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tones.container,
              borderRadius: KuberShape.mediumR,
            ),
            child: Icon(
              IconMapper.fromString(iconKey),
              color: tones.fg,
              size: 20,
            ),
          ),
          const SizedBox(width: KuberSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: tt.titleMedium!.copyWith(
                    color: name.trim().isEmpty
                        ? cs.onSurfaceVariant
                        : cs.onSurface,
                  ),
                ),
                Text(
                  typeLabel,
                  style: tt.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          KuberPill(
            label: sentenceCase(context.l10n.livePreview),
            tone: KuberTone.neutral,
          ),
        ],
      ),
    );
  }
}

// ── Group picker sheet ─────────────────────────
class _GroupPickerSheet extends ConsumerStatefulWidget {
  final int? selectedGroupId;
  final ValueChanged<int?> onSelected;

  const _GroupPickerSheet({
    required this.selectedGroupId,
    required this.onSelected,
  });

  @override
  ConsumerState<_GroupPickerSheet> createState() => _GroupPickerSheetState();
}

class _GroupPickerSheetState extends ConsumerState<_GroupPickerSheet> {
  final _groupNameController = TextEditingController();
  bool _isAdding = false;

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  void _addGroup() async {
    final raw = _groupNameController.text;
    final name = raw.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) return;

    final group = CategoryGroup()..name = name;
    final id = await ref.read(categoryGroupListProvider.notifier).add(group);

    if (mounted) {
      widget.onSelected(id);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final groupsAsync = ref.watch(categoryGroupListProvider);
    final groups = groupsAsync.valueOrNull ?? [];

    final name = _groupNameController.text.trim();
    final isDuplicate = groups.any(
      (g) => g.name.toLowerCase() == name.toLowerCase(),
    );
    final canAdd = name.isNotEmpty && !isDuplicate;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(KuberShape.extraLarge),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              children: [
                Text(
                  context.l10n.selectGroup,
                  style: localeFont(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List
          Flexible(
            child: groupsAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(context.l10n.errorWithDetails(e.toString())),
              ),
              data: (groups) {
                final sortedGroups = groups.toList()
                  ..sort((a, b) => a.name.compareTo(b.name));

                return ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    _buildOption(
                      context,
                      id: null,
                      name: context.l10n.noneLabel,
                      isSelected: widget.selectedGroupId == null,
                    ),
                    ...sortedGroups.map(
                      (g) => _buildOption(
                        context,
                        id: g.id,
                        name: g.name,
                        isSelected: widget.selectedGroupId == g.id,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          const Divider(height: 1),

          // Footer / Add Group
          Padding(
            padding: const EdgeInsets.all(16),
            child: _isAdding
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _groupNameController,
                              autofocus: true,
                              maxLength: 15,
                              textCapitalization: TextCapitalization.words,
                              decoration: InputDecoration(
                                hintText: context.l10n.groupNameShortHint,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorText: (name.isNotEmpty && isDuplicate)
                                    ? context.l10n.groupAlreadyExists
                                    : null,
                                counterText:
                                    '${_groupNameController.text.length} / 15',
                                counterStyle: localeFont(
                                  fontSize: 11,
                                  color: _groupNameController.text.length >= 15
                                      ? cs.error
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              onSubmitted: (_) => canAdd ? _addGroup() : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton.filled(
                            onPressed: canAdd ? _addGroup : null,
                            icon: const Icon(Icons.check_rounded),
                          ),
                          IconButton(
                            onPressed: () => setState(() {
                              _isAdding = false;
                              _groupNameController.clear();
                            }),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                    ],
                  )
                : AppButton(
                    label: context.l10n.addNewGroup,
                    icon: Icons.add_rounded,
                    type: AppButtonType.outline,
                    fullWidth: true,
                    onPressed: () => setState(() => _isAdding = true),
                  ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required int? id,
    required String name,
    required bool isSelected,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        widget.onSelected(id);
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        color: isSelected ? cs.primary.withValues(alpha: 0.1) : null,
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: localeFont(
                  fontSize: 16,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurface,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: cs.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
