import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../providers/notes_provider.dart';

/// Fullscreen advanced filter for Notes (mirrors the History advanced filter):
/// categories, tags and a created-date range, with a Clear all action.
class NotesFilterScreen extends ConsumerStatefulWidget {
  const NotesFilterScreen({super.key});

  @override
  ConsumerState<NotesFilterScreen> createState() => _NotesFilterScreenState();
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

    final dateLabel = _from == null
        ? 'Any date'
        : '${DateFormat('d MMM yyyy').format(_from!)} - '
              '${DateFormat('d MMM yyyy').format(_to!)}';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        title: 'Filter notes',
        showBack: true,
        closeIcon: true,
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
                const KuberSectionHeader(title: 'Created date'),
                KuberGroup(
                  children: [
                    KuberListRow(
                      leading: const KuberIconTile(
                        icon: Icons.calendar_month_rounded,
                      ),
                      title: dateLabel,
                      onTap: _pickRange,
                      trailing: _from == null
                          ? const KuberChevron()
                          : AppIconButton(
                              icon: Icons.close_rounded,
                              kind: AppIconButtonKind.plain,
                              semanticLabel: 'Clear date',
                              onPressed: () =>
                                  setState(() => _from = _to = null),
                            ),
                    ),
                  ],
                ),
                if (categories.isNotEmpty) ...[
                  const SizedBox(height: KuberSpace.sectionGap),
                  const KuberSectionHeader(title: 'Categories'),
                  Wrap(
                    spacing: KuberSpace.sm,
                    runSpacing: KuberSpace.sm,
                    children: [
                      for (final c in categories)
                        KuberChip(
                          label: c.name,
                          icon: IconMapper.fromString(c.icon),
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
                  const SizedBox(height: KuberSpace.sectionGap),
                  const KuberSectionHeader(title: 'Tags'),
                  Wrap(
                    spacing: KuberSpace.sm,
                    runSpacing: KuberSpace.sm,
                    children: [
                      for (final t in tags)
                        KuberChip(
                          label: '#${t.name}',
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
          Divider(height: 1, thickness: 1, color: cs.outlineVariant),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                KuberSpace.md,
                KuberSpace.screenMargin,
                KuberSpace.lg,
              ),
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
                  const SizedBox(width: KuberSpace.md),
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
