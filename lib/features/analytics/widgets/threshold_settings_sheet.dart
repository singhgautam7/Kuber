import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart' show CurrencyInputFormatter;
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart'
    show
        NumberSystem,
        currencyProvider,
        formatterProvider,
        settingsProvider,
        thresholdCeilingProvider,
        thresholdFloorProvider;

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
    _floorController = TextEditingController(text: _group(floor.toInt()));
    _ceilingController = TextEditingController(text: _group(ceiling.toInt()));
  }

  bool get _isIndian =>
      ref.read(formatterProvider).system == NumberSystem.indian;

  String _group(int v) =>
      CurrencyInputFormatter(isIndian: _isIndian).format(v.toString());

  @override
  void dispose() {
    _floorController.dispose();
    _ceilingController.dispose();
    super.dispose();
  }

  double get _previewFloor =>
      double.tryParse(_floorController.text.replaceAll(',', '').trim()) ??
      ref.read(thresholdFloorProvider);

  double get _previewCeiling =>
      double.tryParse(_ceilingController.text.replaceAll(',', '').trim()) ??
      ref.read(thresholdCeilingProvider);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final symbol = ref.watch(currencyProvider).symbol;
    final keyboardPadding = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardPadding),
      child: KuberBottomSheet(
        title: context.l10n.thresholdSettings,
        actions: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: context.l10n.resetToDefaults,
                    icon: Icons.refresh_rounded,
                    type: AppButtonType.normal,
                    onPressed: () {
                      setState(() {
                        _floorController.text = _group(500);
                        _ceilingController.text = _group(2000);
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: context.l10n.saveLabel,
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
              heading: context.l10n.thresholdFloorHeading,
              description: context.l10n.thresholdSmallDesc,
              controller: _floorController,
              symbol: symbol,
              isIndian: ref.watch(formatterProvider).system == NumberSystem.indian,
              cs: cs,
              onChanged: () => setState(() {}),
            ),
            const SizedBox(height: 28),
            _ThresholdField(
              heading: context.l10n.thresholdCeilingHeading,
              description: context.l10n.thresholdLargeDesc,
              controller: _ceilingController,
              symbol: symbol,
              isIndian: ref.watch(formatterProvider).system == NumberSystem.indian,
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
    final floor = double.tryParse(_floorController.text.replaceAll(',', '').trim()) ?? 500;
    final ceiling = double.tryParse(_ceilingController.text.replaceAll(',', '').trim()) ?? 2000;
    ref.read(settingsProvider.notifier).setThresholds(floor, ceiling);
    Navigator.of(context, rootNavigator: true).pop();
  }
}

class _ThresholdField extends StatelessWidget {
  final String heading;
  final String description;
  final TextEditingController controller;
  final String symbol;
  final bool isIndian;
  final ColorScheme cs;
  final VoidCallback onChanged;

  const _ThresholdField({
    required this.heading,
    required this.description,
    required this.controller,
    required this.symbol,
    required this.isIndian,
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
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter(isIndian: isIndian, decimals: 0)],
          style: localeFont(fontSize: 16, color: cs.onSurface),
          onChanged: (_) => onChanged(),
          decoration: InputDecoration(
            prefixText: '$symbol  ',
            prefixStyle: localeFont(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurface,
            ),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KuberShape.large),
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
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(KuberShape.medium),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.previewLogic,
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurfaceVariant,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 12),
          _PreviewRow(
            label: context.l10n.sizeSmall,
            value: '< ${_fmt(floor)}',
            cs: cs,
          ),
          const SizedBox(height: 8),
          _PreviewRow(
            label: context.l10n.sizeMedium,
            value: '${_fmt(floor)} - ${_fmt(ceiling)}',
            cs: cs,
          ),
          const SizedBox(height: 8),
          _PreviewRow(
            label: context.l10n.sizeLarge,
            value: '> ${_fmt(ceiling)}',
            cs: cs,
          ),
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
          decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(label, style: localeFont(fontSize: 14, color: cs.onSurface)),
        const Spacer(),
        Text(
          value,
          style: localeFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
