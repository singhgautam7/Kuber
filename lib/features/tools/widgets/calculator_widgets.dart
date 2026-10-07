import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_segmented_control.dart';
import '../../../core/utils/formatters.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, NumberSystem;

class ToolInputCard extends StatelessWidget {
  final List<Widget> children;
  const ToolInputCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class ToolResultCard extends StatelessWidget {
  final List<Widget> children;
  const ToolResultCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
        border: Border.all(color: cs.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class ToolInputLabel extends StatelessWidget {
  final String text;
  const ToolInputLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Text(
      sentenceCase(text),
      style: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
    );
  }
}

class ToolTextField extends ConsumerWidget {
  final TextEditingController controller;
  final String? label;
  final String? prefix;
  final String? suffix;
  final ValueChanged<String>? onChanged;
  final bool formatAsAmount;

  const ToolTextField({
    super.key,
    required this.controller,
    this.label,
    this.prefix,
    this.suffix,
    this.onChanged,
    this.formatAsAmount = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final isIndian = formatAsAmount
        ? ref.watch(formatterProvider).system == NumberSystem.indian
        : false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          ToolInputLabel(label!),
          const SizedBox(height: KuberSpace.sm),
        ],
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: formatAsAmount
              ? [CurrencyInputFormatter(isIndian: isIndian)]
              : null,
          onChanged: onChanged,
          style: localeFont(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: cs.onSurface,
          ),
          decoration: InputDecoration(
            prefixText: prefix != null ? '$prefix ' : null,
            prefixStyle: localeFont(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: cs.onSurfaceVariant,
            ),
            suffixText: suffix,
            suffixStyle: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
            filled: true,
            fillColor: cs.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: KuberSpace.md,
              vertical: KuberSpace.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KuberShape.large),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KuberShape.large),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(KuberShape.large),
              borderSide: BorderSide(color: cs.primary),
            ),
          ),
        ),
      ],
    );
  }
}

class ToolSegmentedControl extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const ToolSegmentedControl({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // The shared M3 segmented button (board 3.32).
    return KuberSegmentedControl<int>(
      values: [for (var i = 0; i < labels.length; i++) i],
      labels: labels,
      selected: selectedIndex,
      onSelected: onChanged,
      height: 40,
    );
  }
}

class ToolHeroResult extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const ToolHeroResult({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: localeFont(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cs.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: localeFont(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class ToolStatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const ToolStatRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: localeFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? cs.onSurface,
          ),
        ),
      ],
    );
  }
}

class ToolEmptyResult extends StatelessWidget {
  final String message;
  const ToolEmptyResult({
    super.key,
    this.message = 'Enter values to calculate',
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder in the hero slot until inputs are complete: the hero's
    // radius-28 shape on a neutral fill.
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.screenMargin),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Row(
        children: [
          Icon(Icons.calculate_outlined, color: cs.onSurfaceVariant),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}

class ToolSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  /// False for the result hero section: no card and no title; it sits right
  /// below the inputs.
  final bool framed;

  const ToolSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.framed = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // The result slot cross-fades between the "enter values" placeholder and
    // the hero when the inputs become valid (review round 3).
    if (!framed) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(child is ToolEmptyResult),
          child: child,
        ),
      );
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: KuberShape.cardR,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium!.copyWith(color: cs.onSurface),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
            ),
          const SizedBox(height: KuberSpace.md),
          child,
        ],
      ),
    );
  }
}

/// A labelled numeric field with an optional slider bound to the same value.
/// Dragging the slider updates the text and vice-versa. While dragging, the
/// thumb tracks a local value for instant feedback, so the parent's (debounced)
/// recompute never makes the slider feel laggy.
class ToolSliderField extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? prefix;
  final String? suffix;
  final String? helper;
  final bool formatAsAmount;
  final ValueChanged<String> onChanged;

  /// Slider range. When null the slider is hidden (plain field).
  final double? min;
  final double? max;
  final int? divisions;

  const ToolSliderField({
    super.key,
    required this.controller,
    required this.label,
    required this.onChanged,
    this.prefix,
    this.suffix,
    this.helper,
    this.formatAsAmount = false,
    this.min,
    this.max,
    this.divisions,
  });

  @override
  ConsumerState<ToolSliderField> createState() => _ToolSliderFieldState();
}

class _ToolSliderFieldState extends ConsumerState<ToolSliderField> {
  double? _dragValue; // non-null while the user is dragging

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final showSlider = widget.min != null && widget.max != null;
    final raw =
        double.tryParse(widget.controller.text.replaceAll(',', '')) ??
        widget.min ??
        0;
    final sliderValue = showSlider
        ? (_dragValue ?? raw).clamp(widget.min!, widget.max!).toDouble()
        : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ToolTextField(
          controller: widget.controller,
          label: widget.label,
          prefix: widget.prefix,
          suffix: widget.suffix,
          formatAsAmount: widget.formatAsAmount,
          onChanged: widget.onChanged,
        ),
        if (widget.helper != null) ...[
          const SizedBox(height: 5),
          Text(
            widget.helper!,
            style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
          ),
        ],
        if (showSlider)
          Padding(
            padding: const EdgeInsets.only(top: KuberSpace.sm),
            // M3 Expressive slider (board 3.32): 2024 shape (handle bar,
            // gapped track, stop indicator).
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: cs.primary,
                inactiveTrackColor: cs.secondaryContainer,
                thumbColor: cs.primary,
                padding: EdgeInsets.zero,
              ),
              child: Slider(
                // ignore: deprecated_member_use
                year2023: false,
                value: sliderValue,
                min: widget.min!,
                max: widget.max!,
                divisions: widget.divisions,
                onChanged: (v) {
                  final text = widget.formatAsAmount
                      ? v.round().toString()
                      : (v == v.roundToDouble()
                            ? v.round().toString()
                            : v.toStringAsFixed(1));
                  widget.controller.text = text;
                  widget.controller.selection = TextSelection.collapsed(
                    offset: widget.controller.text.length,
                  );
                  // Local setState keeps the thumb smooth; parent recompute is
                  // debounced via onChanged.
                  setState(() => _dragValue = v);
                  widget.onChanged(text);
                },
                onChangeEnd: (_) => setState(() => _dragValue = null),
              ),
            ),
          ),
      ],
    );
  }
}
