import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../data/tag.dart';
import '../providers/tag_providers.dart';

class TagSelectorBottomSheet extends ConsumerStatefulWidget {
  final List<Tag> initialSelectedTags;
  final Function(List<Tag>) onDone;

  const TagSelectorBottomSheet({
    super.key,
    required this.initialSelectedTags,
    required this.onDone,
  });

  @override
  ConsumerState<TagSelectorBottomSheet> createState() => _TagSelectorBottomSheetState();
}

class _TagSelectorBottomSheetState extends ConsumerState<TagSelectorBottomSheet> {
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
                    "Select Tags",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () {
                      widget.onDone(_selectedTags);
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.sm),
                      ),
                    ),
                    child: const Text("Done"),
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
                  hintText: "Search or create tag...",
                  prefixIcon: Icon(Icons.search_rounded, color: cs.primary),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Tag list
            Expanded(
              child: tagsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text("Error: $e")),
                data: (tags) {
                  final filteredTags = tags.where((t) => 
                    t.name.contains(_searchQuery.toLowerCase().trim())).toList();

                  final queryExists = tags.any((t) => 
                    t.name == Tag.normalize(_searchQuery));

                  return ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(20),
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
                          final isSelected = _selectedTags.any((t) => t.id == tag.id);
                          return _TagChip(
                            tag: tag,
                            isSelected: isSelected,
                            onTap: () {
                              if (tag.isEnabled) {
                                _toggleTag(tag);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Tag is disabled. Enable it from More → Tags."),
                                    duration: Duration(seconds: 2),
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
    final cs = Theme.of(context).colorScheme;
    final isEnabled = tag.isEnabled;
    
    return FilterChip(
      label: Text("#${tag.name}"),
      selected: isSelected,
      onSelected: isEnabled ? (_) => onTap() : null,
      backgroundColor: Colors.transparent,
      selectedColor: cs.primary,
      checkmarkColor: cs.onPrimary,
      showCheckmark: true,
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: !isEnabled 
          ? cs.onSurfaceVariant.withValues(alpha: 0.3)
          : isSelected 
            ? cs.onPrimary 
            : cs.onSurface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KuberRadius.sm),
        side: BorderSide(
          color: !isEnabled
            ? cs.outline.withValues(alpha: 0.2)
            : isSelected 
              ? cs.primary 
              : cs.outline.withValues(alpha: 0.5),
        ),
      ),
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
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cs.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(Icons.add_rounded, color: cs.primary, size: 20),
              const SizedBox(width: 12),
              Text(
                "Add \"$normalized\"",
                style: GoogleFonts.inter(
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
