import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/overflow_config.dart';
import '../saved/providers/recent_use_provider.dart';
import '../saved/providers/saved_calculations_provider.dart';
import 'calculator_screen_scaffold.dart';
import 'save_calculation_modal.dart';

/// Wires the shared calculator-screen behaviour: recently-used tracking,
/// loading a saved calculation, the saved-indicator banner state machine and
/// the save / update / save-as-new / discard actions.
///
/// A screen mixes this in, implements the small set of hooks below, and calls
/// [initCalculatorSupport] from `initState`.
mixin CalculatorSupport<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  int? _savedId;
  String? _loadedJson;
  String _loadedName = '';
  Timer? _recomputeTimer;

  /// Debounced rebuild for live recomputation. Heavy sections (charts, schedule)
  /// only recompute once typing/dragging settles, keeping input smooth. Use
  /// this for text/slider `onChanged`; discrete toggles can call setState
  /// directly.
  void scheduleRecompute() {
    _recomputeTimer?.cancel();
    _recomputeTimer = Timer(const Duration(milliseconds: 140), () {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _recomputeTimer?.cancel();
    super.dispose();
  }

  /// Tool route key, e.g. 'emi-calculator'.
  String get toolKey;

  /// The `?savedId=` passed into the screen (null for a fresh calculation).
  int? get initialSavedId;

  /// Serialize the current inputs to a JSON-able map.
  Map<String, dynamic> collectInputs();

  /// Restore inputs from a previously saved map (update controllers/state).
  void applyInputs(Map<String, dynamic> json);

  /// One-line summary stored with the save for the list card.
  String buildSummary();

  String get defaultSaveName;
  String get savePlaceholder;

  String currentInputsJson() => jsonEncode(collectInputs());

  bool get hasSaved => _savedId != null;
  bool get isModified =>
      hasSaved && _loadedJson != null && currentInputsJson() != _loadedJson;

  void initCalculatorSupport() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(recentCalculatorsProvider.notifier).touch(toolKey);
    });
    final id = initialSavedId;
    if (id != null) _loadSaved(id);
  }

  Future<void> _loadSaved(int id) async {
    final rec = await ref.read(savedCalculationsProvider.notifier).getById(id);
    if (rec == null || !mounted) return;
    applyInputs(jsonDecode(rec.inputsJson) as Map<String, dynamic>);
    setState(() {
      _savedId = id;
      _loadedJson = rec.inputsJson;
      _loadedName = rec.name;
    });
  }

  void openSaveSheet() {
    SaveCalculationSheet.show(
      context,
      tool: toolKey,
      defaultName: defaultSaveName,
      placeholder: savePlaceholder,
      inputsJson: currentInputsJson(),
      summary: buildSummary(),
    );
  }

  Future<void> _updateSaved() async {
    final id = _savedId;
    if (id == null) return;
    await ref.read(savedCalculationsProvider.notifier).updateRecord(
          id,
          inputsJson: currentInputsJson(),
          summary: buildSummary(),
        );
    if (!mounted) return;
    setState(() => _loadedJson = currentInputsJson());
  }

  void _discard() {
    final j = _loadedJson;
    if (j == null) return;
    applyInputs(jsonDecode(j) as Map<String, dynamic>);
    setState(() {});
  }

  /// The saved-indicator banner, or null when this is a fresh calculation.
  Widget? buildSavedBanner() {
    if (!hasSaved) return null;
    return SavedIndicatorBanner(
      name: _loadedName,
      isModified: isModified,
      onUpdate: _updateSaved,
      onSaveAsNew: openSaveSheet,
      onDiscard: _discard,
    );
  }

  /// Overflow config exposing "View saved {label} calculations".
  KuberOverflowConfig savedOverflowConfig(String label) => KuberOverflowConfig(
        items: [
          KuberOverflowItem(
            icon: Icons.bookmark_outline_rounded,
            label: 'View saved $label calculations',
            onTap: () => context.push(
              '/more/tools/saved-calculations?tool=$toolKey',
            ),
          ),
        ],
      );
}

/// Helpers for reading/formatting inputs from controllers in a uniform way.
double parseAmount(String s) =>
    double.tryParse(s.replaceAll(',', '').trim()) ?? 0;

double parseNum(String s) => double.tryParse(s.trim()) ?? 0;
