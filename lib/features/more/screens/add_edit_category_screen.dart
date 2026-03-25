import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/category_presets.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../categories/data/category.dart';
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
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 32),

            // [G] Save button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _canSave ? _save : null,
                child: Text(
                  widget.existingCategory != null
                      ? 'Save Changes'
                      : 'Save Category',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupSelector() {
    final cs = Theme.of(context).colorScheme;
    final groupsAsync = ref.watch(categoryGroupListProvider);

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
        groupsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => const Text('Error loading groups'),
          data: (groups) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline, width: 1),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int?>(
                value: _selectedGroupId,
                isExpanded: true,
                dropdownColor: cs.surfaceContainerHigh,
                hint: Text('None', style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text('None', style: GoogleFonts.inter(color: cs.onSurface)),
                  ),
                  ...groups.map((g) => DropdownMenuItem<int?>(
                        value: g.id,
                        child: Text(g.name, style: GoogleFonts.inter(color: cs.onSurface)),
                      )),
                ],
                onChanged: (val) => setState(() => _selectedGroupId = val),
              ),
            ),
          ),
        ),
      ],
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
