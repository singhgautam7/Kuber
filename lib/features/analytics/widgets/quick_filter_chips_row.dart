import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/analytics_provider.dart';

class QuickFilterChipsRow extends StatelessWidget {
  final FilterType selectedType;
  final ValueChanged<FilterType> onTypeSelected;

  const QuickFilterChipsRow({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final types = FilterType.values.where((t) => t != FilterType.custom).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'QUICK FILTERS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: types.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final type = types[index];
              final isSelected = selectedType == type;
              return _FilterChip(
                label: _typeLabel(type),
                selected: isSelected,
                onTap: () => onTypeSelected(type),
              );
            },
          ),
        ),
      ],
    );
  }

  String _typeLabel(FilterType t) {
    return t.name.toUpperCase().replaceAll('THIS', 'THIS ').replaceAll('LAST', 'LAST ');
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
