import 'widgets/bs_squircle_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import 'providers/people_provider.dart';
import 'providers/bill_net_provider.dart';
import 'widgets/bs_avatar.dart';

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
    builder: (_) => _PeoplePickerSheet(alreadySelected: alreadySelected),
  );
}

class _PeoplePickerSheet extends ConsumerStatefulWidget {
  final List<String> alreadySelected;
  const _PeoplePickerSheet({required this.alreadySelected});

  @override
  ConsumerState<_PeoplePickerSheet> createState() => _PeoplePickerSheetState();
}

class _PeoplePickerSheetState extends ConsumerState<_PeoplePickerSheet> {
  late Set<String> _selected;
  String _query = '';
  final _searchCtrl = TextEditingController();
  final _addCtrl = TextEditingController();
  bool _showAddField = false;

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.alreadySelected);
    if (!_selected.contains(kYouName)) _selected.add(kYouName);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _addCtrl.dispose();
    super.dispose();
  }

  Future<void> _addNewPerson() async {
    final name = _addCtrl.text.trim();
    if (name.isEmpty) return;
    if (name.toLowerCase() == kYouName.toLowerCase()) {
      showKuberSnackBar(context, '"You" is reserved and always included', isError: true);
      return;
    }
    final people = ref.read(peopleListProvider).valueOrNull ?? [];
    if (people.any((p) => p.name.toLowerCase() == name.toLowerCase())) {
      showKuberSnackBar(context, 'A person named "$name" already exists', isError: true);
      return;
    }
    await ref.read(peopleListProvider.notifier).add(name);
    setState(() {
      _selected.add(name);
      _addCtrl.clear();
      _showAddField = false;
      _query = '';
      _searchCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final peopleAsync = ref.watch(peopleListProvider);
    final people = peopleAsync.valueOrNull ?? [];

    // Build full list: "You" first, then DB people
    final allNames = [kYouName, ...people.map((p) => p.name).where((n) => n != kYouName)];
    final filtered = _query.isEmpty
        ? allNames
        : allNames.where((n) => n.toLowerCase().contains(_query.toLowerCase())).toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, scrollCtrl) => Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainer,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border(top: BorderSide(color: cs.outline), left: BorderSide(color: cs.outline), right: BorderSide(color: cs.outline)),
        ),
        child: Column(
          children: [
            // Drag handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 4),
              child: Center(
                child: Container(
                  width: 36, height: 4,
                  decoration: BoxDecoration(color: cs.outlineVariant, borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select people',
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: cs.onSurface, letterSpacing: -0.4),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${_selected.length} of ${allNames.length} selected · synced with Lent / Borrow',
                          style: GoogleFonts.inter(fontSize: 12, color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  BsSquircleButton(
                    onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
                    icon: Icons.close_rounded,
                  ),
                ],
              ),
            ),

            // Search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: 'Search or type a new name…',
                  hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: cs.onSurfaceVariant),
                  filled: true,
                  fillColor: cs.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.outline)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.outline)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: cs.primary, width: 2)),
                ),
              ),
            ),

            // Grid
            Expanded(
              child: SingleChildScrollView(
                controller: scrollCtrl,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'YOUR PEOPLE',
                      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.1, color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 10),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filtered.length + 1, // +1 for "Add new" tile
                      itemBuilder: (context, i) {
                        if (i == filtered.length) {
                          return _AddPersonTile(
                            onTap: () => setState(() => _showAddField = !_showAddField),
                          );
                        }
                        final name = filtered[i];
                        final isYou = name == kYouName;
                        final isSel = _selected.contains(name);
                        return _PersonTile(
                          name: name,
                          isYou: isYou,
                          isSelected: isSel,
                          onTap: isYou
                              ? null
                              : () => setState(() {
                                    if (isSel) {
                                      _selected.remove(name);
                                    } else {
                                      _selected.add(name);
                                    }
                                  }),
                        );
                      },
                    ),

                    // Add person field — pinned above keyboard using padding
                    if (_showAddField) ...[
                      const SizedBox(height: 16),
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.viewInsetsOf(context).bottom > 0
                              ? MediaQuery.viewInsetsOf(context).bottom + 8
                              : 0,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _addCtrl,
                                autofocus: true,
                                textCapitalization: TextCapitalization.words,
                                style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
                                decoration: InputDecoration(
                                  hintText: 'Name (must be unique)…',
                                  hintStyle: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
                                  filled: true,
                                  fillColor: cs.surfaceContainerHigh,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(KuberRadius.md), borderSide: BorderSide(color: cs.outline)),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(KuberRadius.md), borderSide: BorderSide(color: cs.outline)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(KuberRadius.md), borderSide: BorderSide(color: cs.primary, width: 2)),
                                ),
                                onSubmitted: (_) => _addNewPerson(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _addNewPerson,
                              icon: Icon(Icons.check_rounded, color: cs.primary),
                              style: IconButton.styleFrom(backgroundColor: cs.primaryContainer, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KuberRadius.md))),
                            ),
                            IconButton(
                              onPressed: () => setState(() { _showAddField = false; _addCtrl.clear(); }),
                              icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 18),
                    Divider(height: 1, color: cs.outline),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Names must be unique. Updates here also reflect in Lent / Borrow.',
                            style: GoogleFonts.inter(fontSize: 11, color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer button
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: cs.outline))),
              child: AppButton(
                label: 'Add ${_selected.length} people',
                type: AppButtonType.primary,
                fullWidth: true,
                height: 50,
                onPressed: _selected.isEmpty
                    ? null
                    : () => Navigator.of(context, rootNavigator: true).pop(_selected.toList()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonTile extends StatelessWidget {
  final String name;
  final bool isYou;
  final bool isSelected;
  final VoidCallback? onTap;

  const _PersonTile({required this.name, required this.isYou, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: ShapeDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.12) : cs.surfaceContainerHigh,
          shape: bsSquircle(14, side: BorderSide(color: isSelected ? cs.primary.withValues(alpha: 0.35) : cs.outline),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Align(
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BsAvatar(name: name, size: 48),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      isYou ? 'You' : name.split(' ').first,
                      style: GoogleFonts.inter(
                        fontSize: 11, fontWeight: FontWeight.w600,
                        color: isSelected ? cs.onSurface : cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            // Checkmark badge
            if (isSelected)
              Positioned(
                top: 6, right: 6,
                child: Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(4)),
                  child: Icon(Icons.check_rounded, size: 11, color: Colors.white),
                ),
              ),
            // ME badge for "You"
            if (isYou)
              Positioned(
                top: 6, left: 6,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: cs.surfaceContainer, borderRadius: BorderRadius.circular(4)),
                  child: Text('ME', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: cs.primary)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddPersonTile extends StatelessWidget {
  final VoidCallback onTap;
  const _AddPersonTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: ShapeDecoration(
          color: Colors.transparent,
          shape: bsSquircle(14, side: BorderSide(color: cs.outlineVariant, style: BorderStyle.solid, width: 1.5),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: ShapeDecoration(
                color: cs.surfaceContainerHigh,
                shape: bsSquircle(16, side: BorderSide(color: cs.outline),
                ),
              ),
              child: Icon(Icons.add_rounded, size: 20, color: cs.primary),
            ),
            const SizedBox(height: 6),
            Text('Add new', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: cs.primary)),
          ],
        ),
      ),
    );
  }
}
