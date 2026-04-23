import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class RecordDetailSheet extends StatefulWidget {
  final Map<String, dynamic> recordMap;

  const RecordDetailSheet({super.key, required this.recordMap});

  @override
  State<RecordDetailSheet> createState() => _RecordDetailSheetState();
}

class _RecordDetailSheetState extends State<RecordDetailSheet> {
  int _viewModeIndex = 0; // 0 = Key-Value, 1 = JSON

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Segmented Control
        Center(
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('Key-Value'),
                icon: Icon(Icons.list_alt_rounded),
              ),
              ButtonSegment(
                value: 1,
                label: Text('JSON'),
                icon: Icon(Icons.data_object_rounded),
              ),
            ],
            selected: {_viewModeIndex},
            onSelectionChanged: (set) {
              setState(() {
                _viewModeIndex = set.first;
              });
            },
            style: SegmentedButton.styleFrom(
              backgroundColor: cs.surfaceContainerHigh,
              selectedBackgroundColor: cs.primary.withValues(alpha: 0.15),
              selectedForegroundColor: cs.primary,
              textStyle: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: KuberSpacing.xl),

        // Content
        if (_viewModeIndex == 0) _buildKeyValueView(cs) else _buildJsonView(cs),
      ],
    );
  }

  Widget _buildKeyValueView(ColorScheme cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.recordMap.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: KuberSpacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  entry.key,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 13,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                flex: 3,
                child: _buildValueWidget(entry.value, cs),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildValueWidget(dynamic value, ColorScheme cs) {
    if (value == null) {
      return Text(
        'null',
        style: GoogleFonts.inter(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: cs.onSurfaceVariant.withValues(alpha: 0.6),
        ),
      );
    } else if (value is bool) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: value
                ? Colors.green.withValues(alpha: 0.15)
                : Colors.red.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: value
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.red.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            value.toString(),
            style: GoogleFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: value ? Colors.green : Colors.red,
            ),
          ),
        ),
      );
    } else {
      String displayStr = value.toString();
      // Try to format ISO 8601 dates manually to 'dd MMM yyyy, HH:mm:ss'
      // If it looks like a datetime string
      if (value is String && value.length >= 19 && value.contains('T')) {
        final dt = DateTime.tryParse(value);
        if (dt != null) {
          // simple formatting fallback to avoid adding intl if it's not present,
          // but we can just show original or simple formatting.
          displayStr = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
        }
      }

      return SelectableText(
        displayStr,
        style: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: cs.onSurface,
        ),
      );
    }
  }

  Widget _buildJsonView(ColorScheme cs) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(widget.recordMap);
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: SelectableText(
        jsonStr,
        style: GoogleFonts.jetBrainsMono(
          fontSize: 13,
          color: cs.onSurface,
        ),
      ),
    );
  }
}
