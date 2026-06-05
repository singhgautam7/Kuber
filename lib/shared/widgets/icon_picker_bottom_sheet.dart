import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/icon_mapper.dart';
import 'kuber_bottom_sheet.dart';

Future<void> showIconPicker({
  required BuildContext context,
  required List<String> iconKeys,
  required Map<String, List<String>> tags,
  required String? selected,
  required ValueChanged<String> onSelected,
}) {
  final cs = Theme.of(context).colorScheme;

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: cs.surfaceContainer,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
    ),
    builder: (_) => _IconPickerSheet(
      iconKeys: iconKeys,
      tags: tags,
      selected: selected,
      onSelected: onSelected,
    ),
  );
}

class _IconPickerSheet extends StatefulWidget {
  final List<String> iconKeys;
  final Map<String, List<String>> tags;
  final String? selected;
  final ValueChanged<String> onSelected;

  const _IconPickerSheet({
    required this.iconKeys,
    required this.tags,
    required this.selected,
    required this.onSelected,
  });

  @override
  State<_IconPickerSheet> createState() => _IconPickerSheetState();
}

class _IconPickerSheetState extends State<_IconPickerSheet> {
  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  late List<String> _filtered = widget.iconKeys;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filtered = widget.iconKeys;
        return;
      }

      _filtered = widget.iconKeys.where((key) {
        if (key.toLowerCase().contains(q)) return true;
        if (IconMapper.labelFor(key).toLowerCase().contains(q)) return true;
        return (widget.tags[key] ?? const <String>[]).any(
          (tag) => tag.toLowerCase().contains(q),
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final columns = MediaQuery.of(context).size.width >= 600 ? 5 : 4;

    return KuberBottomSheet(
      title: 'Choose icon',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _searchCtrl,
            focusNode: _searchFocus,
            autofocus: false,
            onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
            onChanged: _onSearch,
            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'Search by name or tag',
              hintStyle: GoogleFonts.inter(
                fontSize: 14,
                color: cs.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                size: 20,
                color: cs.onSurfaceVariant,
              ),
              suffixIcon: _searchCtrl.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        size: 18,
                        color: cs.onSurfaceVariant,
                      ),
                      onPressed: () {
                        _searchCtrl.clear();
                        _onSearch('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
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
                borderSide: BorderSide(color: cs.outline),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.md),
          if (_filtered.isEmpty)
            _IconPickerEmpty(query: _searchCtrl.text)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: KuberSpacing.sm,
                crossAxisSpacing: KuberSpacing.sm,
                childAspectRatio: 0.95,
              ),
              itemCount: _filtered.length,
              itemBuilder: (_, index) {
                final key = _filtered[index];
                return _IconCell(
                  iconKey: key,
                  label: IconMapper.labelFor(key),
                  isSelected: key == widget.selected,
                  onTap: () {
                    widget.onSelected(key);
                    Navigator.of(context, rootNavigator: true).pop();
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class _IconCell extends StatelessWidget {
  final String iconKey;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _IconCell({
    required this.iconKey,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? cs.primary.withValues(alpha: 0.10)
                : cs.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(
              color: isSelected ? cs.primary : cs.outline,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                IconMapper.fromString(iconKey),
                size: 22,
                color: isSelected ? cs.primary : cs.onSurface,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? cs.primary : cs.onSurfaceVariant,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconPickerEmpty extends StatelessWidget {
  final String query;

  const _IconPickerEmpty({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 32,
            color: cs.onSurfaceVariant.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'No icons match ',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                TextSpan(
                  text: '"$query"',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            'Try a different word, or clear the search.',
            style: GoogleFonts.inter(
              fontSize: 12.5,
              color: cs.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
