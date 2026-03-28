import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_presets.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../categories/data/category.dart';
import '../../categories/data/category_group.dart';
import '../../categories/providers/category_provider.dart';

class CategoryRouteArgs {
  final Category? category;
  final String? defaultType;
  final bool returnToCategoryPicker;

  const CategoryRouteArgs({
    this.category,
    this.defaultType,
    this.returnToCategoryPicker = false,
  });
}

class AddEditCategoryScreen extends ConsumerStatefulWidget {
  final Category? existingCategory;
  final String? defaultType;
  final bool returnToCategoryPicker;

  const AddEditCategoryScreen({
    super.key,
    this.existingCategory,
    this.defaultType,
    this.returnToCategoryPicker = false,
  });

  @override
  ConsumerState<AddEditCategoryScreen> createState() =>
      _AddEditCategoryScreenState();
}

class _AddEditCategoryScreenState
    extends ConsumerState<AddEditCategoryScreen> {
  final _nameController = TextEditingController();
  Color _selectedColor = kCategoryColors[0];
  String _selectedIcon = kCategoryIcons[0]['name'] as String;
  String _selectedType = 'expense';
  int? _selectedGroupId;

  bool get _canSave => _nameController.text.trim().isNotEmpty;

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
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.existingCategory != null ? 'Edit Category' : 'Add Category',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // [A] Live Preview
            _buildLivePreview(),
            const SizedBox(height: 24),

            // [B] Category Name
            _buildNameField(),
            const SizedBox(height: 20),

            // [C] Select Icon
            _buildIconSelector(),
            const SizedBox(height: 20),

            // [D] Accent Color
            _buildColorSelector(),
            const SizedBox(height: 20),

            // [E] Category Group
            _buildGroupSelector(),
            const SizedBox(height: 20),

            // [F] Category Type
            _buildTypeSelector(),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                label: widget.existingCategory != null
                    ? 'Save Changes'
                    : 'Save Category',
                type: AppButtonType.primary,
                fullWidth: true,
                onPressed: _canSave ? _save : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    final cs = Theme.of(context).colorScheme;
    final groupsAsync = ref.watch(categoryGroupListProvider);

    String groupName = 'None';
    if (_selectedGroupId != null && groupsAsync.hasValue) {
      final groups = groupsAsync.value!;
      final group = groups.firstWhere((g) => g.id == _selectedGroupId,
          orElse: () => CategoryGroup()..name = 'None');
      groupName = group.name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Group (Optional)',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            )),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _showGroupPickerSheet(context),
          borderRadius: BorderRadius.circular(KuberRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    groupName,
                    style: GoogleFonts.inter(
                      color: _selectedGroupId == null
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(Icons.keyboard_arrow_down_rounded, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showGroupPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _GroupPickerSheet(
        selectedGroupId: _selectedGroupId,
        onSelected: (id) => setState(() => _selectedGroupId = id),
      ),
    );
  }

  Widget _buildLivePreview() {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIVE PREVIEW',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.0,
              )),
          const SizedBox(height: 12),
          Row(children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _selectedColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                IconMapper.fromString(_selectedIcon),
                color: _selectedColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _nameController.text.isEmpty
                        ? 'Category Name'
                        : _nameController.text,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _nameController.text.isEmpty
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                    ),
                  ),
                  Text(
                    '${_selectedType[0].toUpperCase()}${_selectedType.substring(1)}',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildNameField() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Name',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            )),
        const SizedBox(height: 8),
        TextField(
          controller: _nameController,
          onChanged: (_) => setState(() {}),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            hintText: 'e.g. Groceries, Rent, Salary...',
          ),
        ),
      ],
    );
  }

  Widget _buildIconSelector() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Select Icon',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: cs.onSurfaceVariant,
                )),
            Text('Scroll to see more icons',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: cs.onSurfaceVariant,
                )),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: cs.outline, width: 1),
          ),
          child: GridView.builder(
            padding: const EdgeInsets.all(10),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: kCategoryIcons.length,
            itemBuilder: (ctx, i) {
              final cs = Theme.of(ctx).colorScheme;
              final item = kCategoryIcons[i];
              final iconName = item['name'] as String;
              final isSelected = _selectedIcon == iconName;
              return GestureDetector(
                onTap: () => setState(() => _selectedIcon = iconName),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _selectedColor.withValues(alpha: 0.15)
                        : cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? _selectedColor : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    item['icon'] as IconData,
                    color: isSelected
                        ? _selectedColor
                        : cs.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorSelector() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accent Color',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            )),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: kCategoryColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () => setState(() => _selectedColor = color),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 10),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? cs.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: color.withValues(alpha: 0.5),
                              blurRadius: 8,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Type',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            )),
        const SizedBox(height: 10),
        RadioGroup<String>(
          groupValue: _selectedType,
          onChanged: (val) => setState(() => _selectedType = val!),
          child: Column(
            children: [
              _buildTypeRadioTile('expense', 'Expense'),
              const SizedBox(height: KuberSpacing.sm),
              _buildTypeRadioTile('income', 'Income'),
              const SizedBox(height: KuberSpacing.sm),
              _buildTypeRadioTile('both', 'Both'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeRadioTile(String value, String label) {
    final cs = Theme.of(context).colorScheme;
    final isSelected = _selectedType == value;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: isSelected ? cs.primary : cs.outline,
          width: 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        activeColor: cs.primary,
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: cs.onSurface,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        dense: true,
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();

    if (widget.existingCategory != null) {
      final cat = widget.existingCategory!;
      cat.name = name;
      cat.icon = _selectedIcon;
      cat.colorValue = _selectedColor.toARGB32();
      cat.type = _selectedType;
      cat.groupId = _selectedGroupId;
      await ref.read(categoryRepositoryProvider).save(cat);
    } else {
      final cat = Category()
        ..name = name
        ..icon = _selectedIcon
        ..colorValue = _selectedColor.toARGB32()
        ..isDefault = false
        ..type = _selectedType
        ..groupId = _selectedGroupId;
      await ref.read(categoryRepositoryProvider).save(cat);

      // If returning to category picker flow, signal the pending selection
      if (widget.returnToCategoryPicker) {
        // Re-fetch to get the saved ID
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
        widget.existingCategory != null ? 'Category updated' : 'Category added',
      );
    }
  }
}

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
    final isDuplicate = groups.any((g) => g.name.toLowerCase() == name.toLowerCase());
    final canAdd = name.isNotEmpty && !isDuplicate;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  'Select Group',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
                child: Text('Error: $e'),
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
                      name: 'None',
                      isSelected: widget.selectedGroupId == null,
                    ),
                    ...sortedGroups.map((g) => _buildOption(
                          context,
                          id: g.id,
                          name: g.name,
                          isSelected: widget.selectedGroupId == g.id,
                        )),
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
                                hintText: 'Group name...',
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                errorText: (name.isNotEmpty && isDuplicate) ? 'This group already exists' : null,
                                counterText: '${_groupNameController.text.length} / 15',
                                counterStyle: GoogleFonts.inter(
                                  fontSize: 10,
                                  color: _groupNameController.text.length >= 15 ? cs.error : cs.onSurfaceVariant,
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
                    label: 'Add New Group',
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
                style: GoogleFonts.inter(
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
