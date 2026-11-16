import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/ah_providers.dart';
import '../query/query_ast.dart';
import '../query/query_labels.dart';
import '../query/query_parser.dart';
import '../widgets/common/ah_motion.dart';
import '../widgets/filter/field_list.dart';
import '../widgets/filter/live_count_button.dart';
import '../widgets/filter/readback_card.dart';
import '../widgets/filter/value_pickers.dart';
import '../widgets/token_field/operator_bar.dart';
import '../widgets/token_field/token_filter_controller.dart';
import '../widgets/token_field/token_filter_field.dart';

/// Full-screen Filter page. Edits a draft of the view's filter and applies it
/// with "Show N transactions" (or "Done" for an empty box).
class AhFilterPage extends ConsumerStatefulWidget {
  const AhFilterPage({super.key});

  @override
  ConsumerState<AhFilterPage> createState() => _AhFilterPageState();
}

class _AhFilterPageState extends ConsumerState<AhFilterPage> {
  late final TokenFilterController _c;
  late final String _initial;
  Timer? _debounce;
  QueryNode? _countNode;

  @override
  void initState() {
    super.initState();
    _c = TokenFilterController(
        items: tokenize(ref.read(ahViewProvider).queryText));
    _initial = _c.text;
    _countNode = _c.validNode;
    _c.addListener(_onChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _c.removeListener(_onChanged);
    _c.dispose();
    super.dispose();
  }

  bool get _dirty => _c.text != _initial;

  void _onChanged() {
    _debounce?.cancel();
    if (_c.isEmpty) {
      _countNode = null;
    } else {
      _debounce = Timer(const Duration(milliseconds: 300), () {
        if (mounted) setState(() => _countNode = _c.validNode);
      });
    }
    if (mounted) setState(() {});
  }

  void _apply() {
    if (!ref.read(ahViewProvider.notifier).setFilter(_c.text)) return;
    Navigator.of(context).pop();
  }

  Future<void> _close() async {
    if (!_dirty) return Navigator.of(context).pop();
    final discard = await _confirmDiscard();
    if (discard == true && mounted) Navigator.of(context).pop();
  }

  Future<bool?> _confirmDiscard() {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.ahfDiscardTitle,
            style: localeFont(fontWeight: FontWeight.w600, fontSize: 20)),
        content: Text(l.ahfDiscardBody, style: localeFont(fontSize: 15)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.ahfKeepEditing, style: localeFont()),
          ),
          TextButton(
            key: const ValueKey('ahf-discard'),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l.ahfDiscard, style: localeFont(color: cs.error)),
          ),
        ],
      ),
    );
  }

  void _clearAll() {
    final l = context.l10n;
    final saved = _c.items;
    _c.clear();
    showKuberSnackBar(
      context,
      l.ahfCleared,
      actionLabel: l.ahfUndo,
      onAction: () => _c.setItems(saved),
      duration: const Duration(seconds: 7),
    );
  }

  Future<void> _pick(QueryField f) async {
    final items = await showFieldPicker(context, f);
    if (items != null && mounted) _c.insert(items, trailingAnd: true);
  }

  List<(String, List<QueryItem>)> _examples(AppLocalizations l) {
    ConditionNode cond(QueryField f, QueryOp o, List<String> v) =>
        ConditionNode(f, o, v);
    List<QueryItem> all(List<ConditionNode> cs) => [
          for (var i = 0; i < cs.length; i++) ...[
            if (i > 0) const JoinerItem(isOr: false),
            ...itemsOf(cs[i]),
          ]
        ];
    final cards = [
      for (final a in ref.watch(accountListProvider).valueOrNull ?? const [])
        if (a.isCreditCard as bool) a.name as String
    ];
    return [
      (
        l.ahfExFood,
        all([
          cond(QueryField.category, QueryOp.eq, ['Food']),
          cond(QueryField.amount, QueryOp.gt, ['500']),
          cond(QueryField.date, QueryOp.eq, ['thisyear']),
        ])
      ),
      (
        l.ahfExAttachment,
        all([cond(QueryField.has, QueryOp.eq, ['attachment'])])
      ),
      (
        l.ahfExUntagged,
        all([
          cond(QueryField.type, QueryOp.eq, ['expense']),
          cond(QueryField.tag, QueryOp.eq, ['none']),
        ])
      ),
      if (cards.isNotEmpty)
        (
          l.ahfExCard,
          all([
            cond(QueryField.account, QueryOp.eq, cards),
            cond(QueryField.type, QueryOp.eq, ['expense']),
            cond(QueryField.date, QueryOp.eq, ['lastmonth']),
          ])
        ),
    ];
  }

  KuberInfoConfig _info(AppLocalizations l, ColorScheme cs) {
    Widget row(String code, String desc) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 132,
                child: Text(code,
                    style: monoFont(fontSize: 13, color: cs.primary)),
              ),
              Expanded(
                child: Text(desc,
                    style: localeFont(
                        fontSize: 14, height: 1.4, color: cs.onSurface)),
              ),
            ],
          ),
        );
    return KuberInfoConfig(
      title: l.ahfTitle,
      description: l.ahfInfo1,
      items: [
        KuberInfoItem(
            icon: Icons.join_inner_rounded,
            title: 'and / or',
            description: l.ahfInfo2),
        KuberInfoItem(
            icon: Icons.data_array_rounded,
            title: '( )  not',
            description: l.ahfInfo3),
      ],
      customChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.ahfHowTitle,
              style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface)),
          const SizedBox(height: 12),
          row('category:food', l.ahfSyn1),
          row('category:food,travel', l.ahfSyn2),
          row('amount:>500', l.ahfSyn3),
          row('date:2026-03', l.ahfSyn4),
          row('"swiggy"', l.ahfSyn5),
          row('a and b / a or b', l.ahfSyn6),
          row('( )', l.ahfSyn7),
          row('not tag:trip', l.ahfSyn8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    _c.lookup = AhLookup(
      categories: [
        for (final c in ref.watch(categoryListProvider).valueOrNull ?? const [])
          c.name as String
      ],
      accounts: [
        for (final a in ref.watch(accountListProvider).valueOrNull ?? const [])
          a.name as String
      ],
      tags: [
        for (final t in ref.watch(tagListProvider).valueOrNull ?? const [])
          t.name as String
      ],
    );
    final money = ref.watch(formatterProvider).formatCurrency;
    String fmt(double v) => money(v);
    final n = _c.filterCount;
    final node = _c.validNode;
    final reduced = AhMotion.reduced(context);

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: KuberAppBar(
          title: l.ahfTitle,
          showBack: true,
          closeIcon: true,
          showBrand: false,
          onBack: _close,
          infoConfig: _info(l, cs),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin, 0, KuberSpace.screenMargin, 24),
                children: [
                  SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Semantics(
                          liveRegion: true,
                          label: n == 0 ? l.ahfNoFilters : l.ahfCountSemantics(n),
                          excludeSemantics: true,
                          child: n == 0
                              ? Text(l.ahfNoFilters,
                                  style: localeFont(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurfaceVariant))
                              : Row(children: [
                                  AnimatedSwitcher(
                                    duration: reduced
                                        ? AhMotion.instant
                                        : AhMotion.digitRoll,
                                    switchInCurve: AhMotion.decelerate,
                                    transitionBuilder: (child, a) =>
                                        FadeTransition(
                                      opacity: a,
                                      child: SlideTransition(
                                              position: Tween(
                                                      begin: reduced ? Offset.zero : const Offset(0, 0.6),
                                                      end: Offset.zero)
                                                  .animate(a),
                                              child: child),
                                    ),
                                    child: Text('$n',
                                        key: ValueKey(n),
                                        style: localeFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface,
                                          fontFeatures: const [
                                            FontFeature.tabularFigures()
                                          ],
                                        )),
                                  ),
                                  Text(
                                      ' ${n == 1 ? l.ahfFilterOne : l.ahfFilterMany}',
                                      style: localeFont(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: cs.onSurface)),
                                ]),
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: _c.items.isEmpty ? 0 : 1,
                          duration: AhMotion.fast,
                          child: IgnorePointer(
                            ignoring: _c.items.isEmpty,
                            child: TextButton(
                              key: const ValueKey('ahf-clear-all'),
                              onPressed: _clearAll,
                              child: Text(l.ahfClearAll,
                                  style: localeFont(
                                      fontWeight: FontWeight.w600,
                                      color: cs.primary)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  TokenFilterField(
                    controller: _c,
                    money: fmt,
                    placeholder: l.ahfPlaceholder,
                    focusedPlaceholder: l.ahfPlaceholderFocused,
                    onAction: _canApply ? _apply : null,
                  ),
                  const SizedBox(height: 8),
                  _InsetsBuilder(
                    builder: (context, kbOpen) => AnimatedOpacity(
                      opacity: kbOpen ? 0 : 1,
                      duration: AhMotion.instant,
                      child: IgnorePointer(
                        ignoring: kbOpen,
                        child: OperatorBar(controller: _c),
                      ),
                    ),
                  ),
                  if (node != null && !_c.isEmpty && _c.isValid)
                    ReadbackCard(text: readbackOf(node, l, fmt)),
                  if (_c.items.isEmpty) ...[
                    const SizedBox(height: 16),
                    Text(l.ahfTryOne,
                        style: localeFont(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: cs.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: [
                      for (final e in _examples(l))
                        KuberChip(
                          label: e.$1,
                          onTap: () => _c.setItems(e.$2),
                        ),
                    ]),
                  ],
                  const SizedBox(height: 20),
                  Text(l.ahfAddFilter,
                      style: localeFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  FieldList(onPick: _pick),
                ],
              ),
            ),
            _InsetsBuilder(
              builder: (context, kbOpen) {
                if (kbOpen) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: AhMotion.fast,
                    builder: (context, v, child) =>
                        Opacity(opacity: v, child: child),
                    child: OperatorBar(
                      controller: _c,
                      docked: true,
                      onHideKeyboard: () => _c.focusNode.unfocus(),
                    ),
                  );
                }
                return SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        KuberSpace.screenMargin, 8, KuberSpace.screenMargin, 16),
                    child: _bottomButton(l),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  bool get _canApply => _c.isEmpty || (_c.isValid && _c.validNode != null);

  Widget _bottomButton(AppLocalizations l) {
    if (_c.isEmpty) {
      return AppButton(
        key: const ValueKey('ahf-done'),
        label: l.ahfDone,
        type: AppButtonType.normal,
        fullWidth: true,
        onPressed: _apply,
      );
    }
    final node = _countNode;
    if (node == null) {
      return AppButton(
        label: l.ahfShowCounting,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: null,
      );
    }
    return LiveCountButton(
        node: node, enabled: _c.isValid, onApply: _apply);
  }
}

/// Rebuilds only its subtree as the keyboard animates (no setState per frame).
class _InsetsBuilder extends StatelessWidget {
  const _InsetsBuilder({required this.builder});
  final Widget Function(BuildContext, bool kbOpen) builder;

  @override
  Widget build(BuildContext context) =>
      builder(context, MediaQuery.viewInsetsOf(context).bottom > 0);
}
