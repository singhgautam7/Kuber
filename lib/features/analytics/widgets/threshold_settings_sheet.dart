import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, settingsProvider, thresholdCeilingProvider, thresholdFloorProvider;

class ThresholdSettingsSheet extends ConsumerStatefulWidget {
  const ThresholdSettingsSheet({super.key});

  @override
  ConsumerState<ThresholdSettingsSheet> createState() =>
      _ThresholdSettingsSheetState();
}

class _ThresholdSettingsSheetState
    extends ConsumerState<ThresholdSettingsSheet> {
  late TextEditingController _floorController;
  late TextEditingController _ceilingController;

  @override
  void initState() {
    super.initState();
    final floor = ref.read(thresholdFloorProvider);
    final ceiling = ref.read(thresholdCeilingProvider);
    _floorController =
        TextEditingController(text: floor.toInt().toString());
    _ceilingController =
        TextEditingController(text: ceiling.toInt().toString());
  }

  @override
  void dispose() {
    _floorController.dispose();
    _ceilingController.dispose();
    super.dispose();
  }

  double get _previewFloor =>
      double.tryParse(_floorController.text.trim()) ??
      ref.read(thresholdFloorProvider);

  double get _previewCeiling =>
      double.tryParse(_ceilingController.text.trim()) ??
      ref.read(thresholdCeilingProvider);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final keyboardPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: KuberBottomSheet(
      title: 'Threshold Settings',
      actions: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Reset to Defaults',
                  icon: Icons.refresh_rounded,
                  type: AppButtonType.normal,
                  onPressed: () {
                    setState(() {
                      _floorController.text = '500';
                      _ceilingController.text = '2000';
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Save',
                  icon: Icons.check_rounded,
                  type: AppButtonType.primary,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ThresholdField(
            heading: 'Small/Medium Boundary (Floor)',
            description: 'Amount below which transactions are marked as Small.',
            controller: _floorController,
            symbol: symbol,
            cs: cs,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 28),
          _ThresholdField(
            heading: 'Medium/Large Boundary (Ceiling)',
            description:
                'Amount above which transactions are marked as Large.',
            controller: _ceilingController,
            symbol: symbol,
            cs: cs,
            onChanged: () => setState(() {}),
          ),
          const SizedBox(height: 28),
          _PreviewLogic(
            floor: _previewFloor,
            ceiling: _previewCeiling,
            symbol: symbol,
            cs: cs,
          ),
        ],
      ),
      ),
    );
  }

  void _save() {
    final floor = double.tryParse(_floorController.text.trim()) ?? 500;
    final ceiling = double.tryParse(_ceilingController.text.trim()) ?? 2000;
    ref.read(settingsProvider.notifier).setThresholds(floor, ceiling);
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _ThresholdField extends StatelessWidget {
  final String heading;
  final String description;
  final TextEditingController controller;
  final String symbol;
  final ColorScheme cs;
  final VoidCallback onChanged;

  const _ThresholdField({
    required this.heading,
    required this.description,
    required this.controller,
    required this.symbol,
    required this.cs,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: cs.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: GoogleFonts.inter(fontSize: 16, color: cs.onSurface),
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            prefixText: '$symbol  ',
            prefixStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KuberRadius.md),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _PreviewLogic extends StatelessWidget {
  final double floor;
  final double ceiling;
  final String symbol;
  final ColorScheme cs;

  const _PreviewLogic({
    required this.floor,
    required this.ceiling,
    required this.symbol,
    required this.cs,
  });

  String _fmt(double v) {
    if (v == v.roundToDouble()) return '$symbol${v.toInt()}';
    return '$symbol$v';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PREVIEW LOGIC',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _PreviewRow(label: 'Small', value: '< ${_fmt(floor)}', cs: cs),
          const SizedBox(height: 8),
          _PreviewRow(
              label: 'Medium',
              value: '${_fmt(floor)} - ${_fmt(ceiling)}',
              cs: cs),
          const SizedBox(height: 8),
          _PreviewRow(label: 'Large', value: '> ${_fmt(ceiling)}', cs: cs),
        ],
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;

  const _PreviewRow({
    required this.label,
    required this.value,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurface,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
