import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../providers/notes_provider.dart';

/// Fullscreen advanced filter for Notes (mirrors the History advanced filter):
/// categories, tags and a created-date range, with a Clear all action.
class NotesFilterScreen extends ConsumerStatefulWidget {
  const NotesFilterScreen({super.key});

  @override
  ConsumerState<NotesFilterScreen> createState() =>
      _NotesFilterScreenState();
}

class _NotesFilterScreenState extends ConsumerState<NotesFilterScreen> {
  late Set<String> _categoryIds;
  late Set<String> _tagIds;
  DateTime? _from;
  DateTime? _to;

  @override
  void initState() {
    super.initState();
    final f = ref.read(notesFilterProvider);
    _categoryIds = {...f.categoryIds};
    _tagIds = {...f.tagIds};
    _from = f.createdFrom;
    _to = f.createdTo;
  }

  bool get _hasAny =>
      _categoryIds.isNotEmpty ||
      _tagIds.isNotEmpty ||
      _from != null ||
      _to != null;

  void _apply() {
    ref.read(notesFilterProvider.notifier).state = NotesFilterState(
      categoryIds: _categoryIds,
      tagIds: _tagIds,
      createdFrom: _from,
      createdTo: _to,
    );
    Navigator.of(context).pop();
  }

  void _clearAll() {
    setState(() {
      _categoryIds = {};
      _tagIds = {};
      _from = null;
      _to = null;
    });
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: now,
      initialDateRange: _from != null && _to != null
          ? DateTimeRange(start: _from!, end: _to!)
          : null,
    );
    if (range != null) {
      setState(() {
        _from = range.start;
        _to = range.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final categories = ref.watch(categoryListProvider).valueOrNull ?? const [];
    final tags = ref.watch(tagListProvider).valueOrNull ?? const [];

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, showBrand: false),
      body: Column(
        children: [
          const KuberPageHeader(
            title: 'Filter notes',
            description: 'Narrow by category, tag or created date',
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                _SectionLabel('CREATED DATE'),
                GestureDetector(
                  onTap: _pickRange,
                  child: Container(
                    height: 48,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                      border: Border.all(color: cs.outline),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_rounded,
                            size: 16, color: cs.onSurfaceVariant),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _from == null
                                ? 'Any date'
                                : '${DateFormat('d MMM yyyy').format(_from!)} - ${DateFormat('d MMM yyyy').format(_to!)}',
                            style: localeFont(
                              fontSize: 13.5,
                              color: _from == null
                                  ? cs.onSurfaceVariant
                                  : cs.onSurface,
                            ),
                          ),
                        ),
                        if (_from != null)
                          GestureDetector(
                            onTap: () =>
                                setState(() => _from = _to = null),
                            child: Icon(Icons.close_rounded,
                                size: 16, color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionLabel('CATEGORIES'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in categories)
                        _Chip(
                          label: c.name,
                          icon: IconMapper.fromString(c.icon),
                          color: harmonizeCategory(
                              context, Color(c.colorValue)),
                          selected: _categoryIds.contains(c.id.toString()),
                          onTap: () => setState(() {
                            final id = c.id.toString();
                            _categoryIds.contains(id)
                                ? _categoryIds.remove(id)
                                : _categoryIds.add(id);
                          }),
                        ),
                    ],
                  ),
                ],
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _SectionLabel('TAGS'),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in tags)
                        _Chip(
                          label: '#${t.name}',
                          color: cs.primary,
                          selected: _tagIds.contains(t.id.toString()),
                          onTap: () => setState(() {
                            final id = t.id.toString();
                            _tagIds.contains(id)
                                ? _tagIds.remove(id)
                                : _tagIds.add(id);
                          }),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Clear all',
                      type: AppButtonType.outline,
                      fullWidth: true,
                      onPressed: _hasAny ? _clearAll : null,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: AppButton(
                      label: 'Apply',
                      type: AppButtonType.primary,
                      fullWidth: true,
                      onPressed: _apply,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 10),
      child: Text(
        label,
        style: localeFont(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.0,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _Chip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.14)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(color: selected ? color : cs.outline),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? color : cs.onSurfaceVariant),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: localeFont(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? color : cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
