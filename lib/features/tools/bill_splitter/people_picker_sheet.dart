import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/person_avatar.dart';
import 'providers/people_provider.dart';

Future<List<String>?> showPeoplePickerSheet(
  BuildContext context,
  List<String> alreadySelected,
) {
  return showModalBottomSheet<List<String>>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (ctx, scrollCtrl) => _PeoplePickerContent(
        alreadySelected: alreadySelected,
        scrollController: scrollCtrl,
      ),
    ),
  );
}

class _PeoplePickerContent extends ConsumerStatefulWidget {
  final List<String> alreadySelected;
  final ScrollController scrollController;

  const _PeoplePickerContent({
    required this.alreadySelected,
    required this.scrollController,
  });

  @override
  ConsumerState<_PeoplePickerContent> createState() =>
      _PeoplePickerContentState();
}

class _PeoplePickerContentState extends ConsumerState<_PeoplePickerContent> {
  late Set<String> _selected;
  String _query = '';
  bool _showAddField = false;
  final _addCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.alreadySelected);
  }

  @override
  void dispose() {
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNewPerson() async {
    final name = _addCtrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(peopleListProvider.notifier).add(name);
    setState(() {
      _selected.add(name);
      _addCtrl.clear();
      _showAddField = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final peopleAsync = ref.watch(peopleListProvider);
    final people = peopleAsync.valueOrNull ?? [];
    final filtered = people
        .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return KuberBottomSheet(
      title: 'Select People',
      subtitle: '${_selected.length} selected',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search
          TextField(
            onChanged: (v) => setState(() => _query = v),
            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
              prefixIcon: Icon(Icons.search_rounded, color: cs.onSurfaceVariant, size: 18),
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(
                vertical: KuberSpacing.sm,
                horizontal: KuberSpacing.md,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
                borderSide: BorderSide(color: cs.primary),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.md),

          // People list
          ...filtered.map((person) {
            final isSelected = _selected.contains(person.name);
            return InkWell(
              onTap: () => setState(() {
                if (isSelected) {
                  _selected.remove(person.name);
                } else {
                  _selected.add(person.name);
                }
              }),
              borderRadius: BorderRadius.circular(KuberRadius.md),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: KuberSpacing.sm,
                  horizontal: KuberSpacing.xs,
                ),
                child: Row(
                  children: [
                    PersonAvatar(name: person.name, size: PersonAvatarSize.small),
                    const SizedBox(width: KuberSpacing.md),
                    Expanded(
                      child: Text(
                        person.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: cs.onSurface,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: isSelected,
                      activeColor: cs.primary,
                      onChanged: (_) => setState(() {
                        if (isSelected) {
                          _selected.remove(person.name);
                        } else {
                          _selected.add(person.name);
                        }
                      }),
                    ),
                  ],
                ),
              ),
            );
          }),

          // Add new person
          const SizedBox(height: KuberSpacing.md),
          if (_showAddField)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _addCtrl,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Person name...',
                      hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
                      filled: true,
                      fillColor: cs.surfaceContainerHigh,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: KuberSpacing.sm,
                        horizontal: KuberSpacing.md,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                        borderSide: BorderSide(color: cs.primary),
                      ),
                    ),
                    onSubmitted: (_) => _addNewPerson(),
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
                IconButton(
                  onPressed: _addNewPerson,
                  icon: Icon(Icons.check_rounded, color: cs.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: cs.primaryContainer,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    _showAddField = false;
                    _addCtrl.clear();
                  }),
                  icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                ),
              ],
            )
          else
            TextButton.icon(
              onPressed: () => setState(() => _showAddField = true),
              icon: Icon(Icons.add_rounded, size: 18, color: cs.primary),
              label: Text(
                'Add New Person',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: cs.primary,
                ),
              ),
            ),

          const SizedBox(height: KuberSpacing.lg),
          AppButton(
            label: 'Confirm (${_selected.length})',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context, rootNavigator: true)
                    .pop(_selected.toList()),
          ),
        ],
      ),
    );
  }
}
