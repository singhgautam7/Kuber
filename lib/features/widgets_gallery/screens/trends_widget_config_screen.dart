import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

const _configChannel = MethodChannel('com.grs.kuber/widget_config');

/// Flutter configuration screen for the Trends widget. Rendered inside
/// [TrendsRangeConfigActivity]; picks the default 7D / 4W / 6M range.
class TrendsWidgetConfigScreen extends StatefulWidget {
  final int widgetId;
  const TrendsWidgetConfigScreen({super.key, required this.widgetId});

  @override
  State<TrendsWidgetConfigScreen> createState() => _TrendsWidgetConfigScreenState();
}

class _TrendsWidgetConfigScreenState extends State<TrendsWidgetConfigScreen> {
  static const _ranges = [
    ('7D', 'Last 7 days'),
    ('4W', 'Last 4 weeks'),
    ('6M', 'Last 6 months'),
  ];
  String _selected = '7D';

  Future<void> _confirm() => _configChannel.invokeMethod('confirm', {'value': _selected});
  Future<void> _cancel() => _configChannel.invokeMethod('cancel');

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              KuberAppBar(
                title: 'Configure Trends Widget',
                showBack: true,
                showBrand: false,
                onBack: _cancel,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, KuberSpacing.lg),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: KuberSpacing.sm),
                      child: Text(
                        'Pick the default range this widget shows. You can still switch it with the chips on the widget itself.',
                        style: TextStyle(fontSize: 12.5, height: 1.5, color: cs.onSurfaceVariant),
                      ),
                    ),
                    for (final (code, label) in _ranges) _rangeRow(context, code, label),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(onPressed: _confirm, child: const Text('Confirm')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rangeRow(BuildContext context, String code, String label) {
    final cs = Theme.of(context).colorScheme;
    final selected = _selected == code;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        onTap: () => setState(() => _selected = code),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Text(code, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: selected ? cs.primary : cs.onSurface)),
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant))),
              Icon(selected ? Icons.check_circle : Icons.circle_outlined, size: 20, color: selected ? cs.primary : cs.onSurfaceVariant.withValues(alpha: 0.4)),
            ],
          ),
        ),
      ),
    );
  }
}
