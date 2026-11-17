import 'package:flutter/material.dart';

import 'kuber_button_group.dart';

/// Single-choice segmented selector (40 high), now a thin wrapper over
/// [KuberButtonGroup]; no check for 4+ segments.
///
/// Generalized from `TransactionTypeSelector` so the Quick Actions configure
/// screen (Arrange | Add shortcuts) and the transaction type picker share one
/// primitive.
class KuberSegmentedControl<T> extends StatelessWidget {
  final List<T> values;
  final List<String> labels;
  final T selected;
  final ValueChanged<T> onSelected;
  final bool enabled;
  final double height;

  /// Draw the check on the selected segment (spec: no check for 4+ segments
  /// and for Bar | Line).
  final bool showCheck;

  /// Hug content (in-card toggles) instead of filling the width.
  final bool compact;

  const KuberSegmentedControl({
    super.key,
    required this.values,
    required this.labels,
    required this.selected,
    required this.onSelected,
    this.enabled = true,
    this.height = 48,
    this.showCheck = true,
    this.compact = false,
  }) : assert(values.length == labels.length);

  @override
  Widget build(BuildContext context) {
    // Internals are the v7.0.0 button group (press widening, squeeze, check,
    // weight shift, tick haptic); the API above is unchanged.
    return KuberButtonGroup<T>(
      options: [
        for (var i = 0; i < values.length; i++)
          KuberButtonOption(value: values[i], label: labels[i]),
      ],
      selected: selected,
      onChanged: onSelected,
      enabled: enabled,
      height: height < 48 ? height : 40,
      showCheck: showCheck && values.length < 4,
      expand: !compact,
    );
  }
}
