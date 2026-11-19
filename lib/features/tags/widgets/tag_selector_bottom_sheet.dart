import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:kuber/shared/widgets/kuber_chips.dart';
import 'package:kuber/shared/widgets/app_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../data/tag.dart';
import '../providers/tag_providers.dart';
import '../../../shared/widgets/kuber_shape_loader.dart';

class TagSelectorBottomSheet extends ConsumerStatefulWidget {
  final List<Tag> initialSelectedTags;
  final Function(List<Tag>) onDone;

  const TagSelectorBottomSheet({
    super.key,
    required this.initialSelectedTags,
    required this.onDone,
  });

  @override
  ConsumerState<TagSelectorBottomSheet> createState() =>
      _TagSelectorBottomSheetState();
}

class _TagSelectorBottomSheetState
    extends ConsumerState<TagSelectorBottomSheet> {
  late List<Tag> _selectedTags;
  String _searchQuery = "";
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _selectedTags = List.from(widget.initialSelectedTags);
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleTag(Tag tag) {
    setState(() {
      if (_selectedTags.any((t) => t.id == tag.id)) {
        _selectedTags.removeWhere((t) => t.id == tag.id);
      } else {
        _selectedTags.add(tag);
      }
    });
  }

  Future<void> _createAndSelectTag(String name) async {
    final normalized = Tag.normalize(name);
    if (normalized.isEmpty) return;

    final repo = ref.read(tagRepositoryProvider);
    var tag = await repo.findByName(normalized);

    if (tag == null) {
      tag = Tag()
        ..name = normalized
        ..createdAt = DateTime.now();
      final id = await repo.saveTag(tag);
      tag.id = id;
    }

    if (tag.isEnabled) {
      _toggleTag(tag);
      setState(() {
        _searchQuery = "";
        _searchController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tagsAsync = ref.watch(tagListProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.selectTags,
                    style: localeFont(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  AppButton(
                    label: context.l10n.doneLabel,
                    height: 40,
                    onPressed: () {
                      widget.onDone(_selectedTags);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: context.l10n.searchOrCreateTagHint,
                  prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberShape.large),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Tag list
            Expanded(
              child: tagsAsync.when(
                loading: () => const Center(child: KuberShapeLoader(size: 40)),
                error: (e, _) => Center(
                  child: Text(context.l10n.errorWithDetails(e.toString())),
                ),
                data: (tags) {
                  final filteredTags = tags
                      .where(
                        (t) =>
                            t.name.contains(_searchQuery.toLowerCase().trim()),
                      )
                      .toList();

                  final queryExists = tags.any(
                    (t) => t.name == Tag.normalize(_searchQuery),
                  );

                  return ListView(
                    controller: scrollController,
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 20,
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                    ),
                    children: [
                      if (_searchQuery.trim().isNotEmpty && !queryExists)
                        _TagActionTile(
                          name: _searchQuery,
                          onTap: () => _createAndSelectTag(_searchQuery),
                        ),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredTags.map((tag) {
                          final isSelected = _selectedTags.any(
                            (t) => t.id == tag.id,
                          );
                          return _TagChip(
                            tag: tag,
                            isSelected: isSelected,
                            onTap: () {
                              if (tag.isEnabled) {
                                _toggleTag(tag);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      context.l10n.tagDisabledMessage,
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TagChip extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final VoidCallback onTap;

  const _TagChip({
    required this.tag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return KuberChip(
      label: '#${tag.name}',
      selected: isSelected,
      emphasis: true,
      dimmed: !tag.isEnabled,
      onTap: onTap,
    );
  }
}

class _TagActionTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;

  const _TagActionTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final normalized = Tag.normalize(name);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberShape.medium),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.add_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                "Add \"$normalized\"",
                style: localeFont(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
