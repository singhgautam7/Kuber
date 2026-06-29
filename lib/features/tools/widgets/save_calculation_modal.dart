import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../saved/providers/saved_calculations_provider.dart';

/// The "Save this calculation" bottom sheet. Collects a memorable name and
/// persists a new [SavedCalculation], then shows a snackbar with a View action.
class SaveCalculationSheet extends ConsumerStatefulWidget {
  final String tool;
  final String defaultName;
  final String placeholder;
  final String inputsJson;
  final String summary;

  const SaveCalculationSheet({
    super.key,
    required this.tool,
    required this.defaultName,
    required this.placeholder,
    required this.inputsJson,
    required this.summary,
  });

  /// Shows the sheet. Standard Kuber bottom-sheet presentation.
  static Future<void> show(
    BuildContext context, {
    required String tool,
    required String defaultName,
    required String placeholder,
    required String inputsJson,
    required String summary,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SaveCalculationSheet(
        tool: tool,
        defaultName: defaultName,
        placeholder: placeholder,
        inputsJson: inputsJson,
        summary: summary,
      ),
    );
  }

  @override
  ConsumerState<SaveCalculationSheet> createState() =>
      _SaveCalculationSheetState();
}

class _SaveCalculationSheetState extends ConsumerState<SaveCalculationSheet> {
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.defaultName);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _ctrl.text.trim();
    if (name.isEmpty) return;
    await ref.read(savedCalculationsProvider.notifier).create(
          tool: widget.tool,
          name: name,
          inputsJson: widget.inputsJson,
          summary: widget.summary,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showKuberSnackBar(
      context,
      'Calculation saved. View in Saved Calculations.',
      actionLabel: 'View',
      onAction: () => context.push(
        '/more/tools/saved-calculations?tool=${widget.tool}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return KuberBottomSheet(
      title: 'Save this calculation',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Give it a memorable name so you can find it later in Saved Calculations.',
            style: localeFont(fontSize: 12.5, color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Text(
            'NAME THIS CALCULATION',
            style: localeFont(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: KuberSpacing.sm),
          TextField(
            controller: _ctrl,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            style: localeFont(
                fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _save(),
            decoration: InputDecoration(
              hintText: widget.placeholder,
              hintStyle:
                  localeFont(fontSize: 15, color: cs.onSurfaceVariant),
              filled: true,
              fillColor: cs.surfaceContainerHigh,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.md, vertical: KuberSpacing.md),
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
                borderSide: BorderSide(color: cs.primary),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          FilledButton(
            onPressed: _ctrl.text.trim().isEmpty ? null : _save,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
            ),
            child: Text('Save',
                style:
                    localeFont(fontSize: 14.5, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: KuberSpacing.sm),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel',
                style: localeFont(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}
