import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../data/widget_catalog.dart';

/// Opens the widget detail sheet for [entry].
Future<void> showWidgetDetailSheet(BuildContext context, WidgetCatalogEntry entry) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _WidgetDetailSheet(entry: entry),
  );
}

class _WidgetDetailSheet extends StatelessWidget {
  final WidgetCatalogEntry entry;
  const _WidgetDetailSheet({required this.entry});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isSmall = entry.sizeLabel.startsWith('2');

    return KuberBottomSheet(
      title: entry.name,
      subtitle: entry.description,
      // ignore: sort_child_properties_last
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isSmall ? 200 : double.infinity),
              child: entry.preview(context),
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(KuberRadius.sm),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Text(entry.sizeLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
              ),
              if (entry.needsConfig) ...[
                const SizedBox(width: 8),
                Text('Setup on placement', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
              ],
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          Text(entry.info, style: TextStyle(fontSize: 13.5, height: 1.5, color: cs.onSurfaceVariant)),
        ],
      ),
      actions: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _addToHome(context),
              icon: const Icon(Icons.add_to_home_screen_outlined, size: 20),
              label: const Text('Add to Home'),
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addToHome(BuildContext context) async {
    final navigator = Navigator.of(context);
    final supported = await WidgetPinService.isPinSupported();
    if (!supported) {
      if (context.mounted) _showFallback(context);
      return;
    }
    final ok = await WidgetPinService.requestPin(entry.providerClass);
    if (!ok) {
      if (context.mounted) _showFallback(context);
      return;
    }
    // The launcher now shows its own confirmation dialog; close the sheet.
    navigator.pop();
  }

  void _showFallback(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add from your home screen'),
        content: const Text(
          "Your launcher doesn't support adding widgets directly. Long-press an "
          "empty spot on your home screen, tap Widgets, and find Kuber in the list.",
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Got it')),
        ],
      ),
    );
  }
}
