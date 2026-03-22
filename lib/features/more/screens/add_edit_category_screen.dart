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
    return Scaffold(
      backgroundColor: KuberColors.background,
      appBar: AppBar(
        backgroundColor: KuberColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: KuberColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.existingCategory != null ? 'Edit Category' : 'Add Category',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: KuberColors.textPrimary,
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

            // [E] Category Type
            _buildTypeSelector(),
            const SizedBox(height: 32),

            // [F] Save button
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

  Widget _buildLivePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: KuberColors.border, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('LIVE PREVIEW',
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: KuberColors.textSecondary,
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
                          ? KuberColors.textSecondary
                          : KuberColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${_selectedType[0].toUpperCase()}${_selectedType.substring(1)} Category',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: KuberColors.textSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Name',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: KuberColors.textSecondary,
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
                  color: KuberColors.textSecondary,
                )),
            Text('Scroll to see more icons',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: KuberColors.textSecondary,
                )),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: KuberColors.surfaceCard,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: KuberColors.border, width: 1),
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
                        : KuberColors.surfaceMuted,
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
                        : KuberColors.textSecondary,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accent Color',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: KuberColors.textSecondary,
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
                          ? KuberColors.textPrimary
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Category Type',
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: KuberColors.textSecondary,
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
    final isSelected = _selectedType == value;
    return Container(
      decoration: BoxDecoration(
        color: KuberColors.surfaceCard,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(
          color: isSelected ? KuberColors.primary : KuberColors.border,
          width: 1,
        ),
      ),
      child: RadioListTile<String>(
        value: value,
        activeColor: KuberColors.primary,
        title: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: KuberColors.textPrimary,
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
      await ref.read(categoryRepositoryProvider).save(cat);
    } else {
      final cat = Category()
        ..name = name
        ..icon = _selectedIcon
        ..colorValue = _selectedColor.toARGB32()
        ..isDefault = false
        ..type = _selectedType;
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
