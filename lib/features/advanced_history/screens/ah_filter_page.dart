import 'dart:async';
import 'package:kuber/core/motion/route_styles.dart';


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../tags/providers/tag_providers.dart';
import '../../settings/providers/settings_provider.dart';
import '../providers/ah_providers.dart';
import '../query/query_ast.dart';
import '../query/query_labels.dart';
import '../query/query_parser.dart';
import '../widgets/common/ah_common.dart';
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
      animationStyle: kuberDialogStyle(context),
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

  List<(String, IconData, List<QueryItem>)> _examples(AppLocalizations l) {
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
    final exCats = ahExampleCategories(
        ref.watch(categoryListProvider).valueOrNull ?? const []);
    final money = ref.watch(formatterProvider).formatCurrency;
    return [
      if (exCats.isNotEmpty)
        (
          l.ahExCatOver(exCats.first, money(500)),
          Icons.payments_outlined,
          all([
            cond(QueryField.category, QueryOp.eq, [exCats.first]),
            cond(QueryField.amount, QueryOp.gt, ['500']),
            cond(QueryField.date, QueryOp.eq, ['thisyear']),
          ])
        ),
      (
        l.ahfExAttachment,
        Icons.attach_file_rounded,
        all([cond(QueryField.has, QueryOp.eq, ['attachment'])])
      ),
      (
        l.ahfExUntagged,
        Icons.label_off_outlined,
        all([
          cond(QueryField.type, QueryOp.eq, ['expense']),
          cond(QueryField.tag, QueryOp.eq, ['none']),
        ])
      ),
      if (cards.isNotEmpty)
        (
          l.ahfExCard,
          Icons.credit_card_rounded,
          all([
            cond(QueryField.account, QueryOp.eq, cards),
            cond(QueryField.type, QueryOp.eq, ['expense']),
            cond(QueryField.date, QueryOp.eq, ['lastmonth']),
          ])
        ),
    ];
  }

  /// "How to use": every keyword with an example, shown from the header
  /// and from "How it works" in the menu.
  KuberInfoConfig _info(AppLocalizations l, ColorScheme cs) {
    final tt = Theme.of(context).textTheme;
    Widget row(String code, String desc) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 156,
                child: Text(code,
                    style: monoFont(fontSize: 13, color: cs.primary)),
              ),
              Expanded(
                child: Text(desc,
                    style: tt.bodyMedium!.copyWith(color: cs.onSurface)),
              ),
            ],
          ),
        );
    Widget section(String title, List<Widget> rows) => Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [KuberSectionHeader(title: title), ...rows],
          ),
        );
    return KuberInfoConfig(
      title: l.ahfHowUse,
      description: l.ahfInfo1,
      customChild: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          section(l.ahfHowBasics, [
            row('category:food', l.ahfSyn1),
            row('category=food', l.ahfSynEq),
            row('category:food,travel', l.ahfSyn2),
            row('"swiggy"', l.ahfSyn5),
          ]),
          section(l.ahfHowCompare, [
            row('amount>500', l.ahfSynGt),
            row('amount<500', l.ahfSynLt),
            row('amount>=500', l.ahfSynGte),
            row('amount<=500', l.ahfSynLte),
            row('amount=500', l.ahfSynExact),
            row('amount:500..2000', l.ahfSynRange),
            row('date:2026-03', l.ahfSyn4),
            row('date>2026-03', l.ahfSynDateAfter),
          ]),
          section(l.ahfHowCombine, [
            row('a and b', l.ahfSynAnd),
            row('a or b', l.ahfSynOr),
            row('(a or b) and c', l.ahfSynBrackets),
            row('not tag:trip', l.ahfSyn8),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(l.ahfSynOrder,
                  style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
            ),
          ]),
          section(l.ahfHowFields, [
            for (final f in kPickableFields) row(fieldExample(f), fieldHint(f, l)),
          ]),
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
      // `category:food` also matches a category group named Food (the
      // engine does); without these a valid group filter showed an error.
      categoryGroups: [
        for (final g
            in ref.watch(categoryGroupListProvider).valueOrNull ?? const [])
          g.name,
      ],
    );
    final money = ref.watch(formatterProvider).formatCurrency;
    String fmt(double v) => money(v);
    final n = _c.filterCount;
    final node = _c.validNode;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _close();
      },
      child: _KbScope(
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
                          child: TextButton.icon(
                            key: const ValueKey('ahf-how-to-use'),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              shape: const StadiumBorder(),
                            ),
                            onPressed: () =>
                                KuberInfoBottomSheet.show(context, _info(l, cs)),
                            icon: Icon(Icons.help_outline_rounded,
                                size: 18, color: cs.primary),
                            label: Text(l.ahfHowUse,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(color: cs.primary)),
                          ),
                        ),
                        const Spacer(),
                        AnimatedOpacity(
                          opacity: _c.items.isEmpty ? 0 : 1,
                          duration: KuberMotion.fxFast,
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
                  // Keyboard down: operator bar, readback, examples and the
                  // field list. Keyboard up: only the inline suggestions (the
                  // bar docks above the keyboard).
                  _InsetsBuilder(
                    builder: (context, kbOpen) => kbOpen
                        ? const SizedBox.shrink()
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 12),
                              OperatorBar(controller: _c),
                              if (node != null && !_c.isEmpty && _c.isValid)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: ReadbackCard(
                                        text: readbackOf(node, l, fmt)),
                                  ),
                                ),
                              if (_c.items.isEmpty) ...[
                                const SizedBox(height: 16),
                                KuberSectionHeader(title: l.ahfTryOne),
                                // One row that scrolls sideways, edge to edge.
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  clipBehavior: Clip.none,
                                  child: Row(children: [
                                    for (final e in _examples(l)) ...[
                                      KuberChip(
                                        label: e.$1,
                                        icon: e.$2,
                                        onTap: () => _c.setItems(e.$3),
                                      ),
                                      const SizedBox(width: KuberSpace.sm),
                                    ],
                                  ]),
                                ),
                              ],
                              const SizedBox(height: 16),
                              KuberSectionHeader(title: l.ahfAddFilter),
                              FieldList(onPick: _pick),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            _InsetsBuilder(
              builder: (context, kbOpen) {
                if (kbOpen) {
                  return TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: KuberMotion.fxFast,
                    builder: (context, v, child) =>
                        Opacity(opacity: v, child: child),
                    child: OperatorBar(
                      controller: _c,
                      docked: true,
                      onHideKeyboard: () => _c.focusNode.unfocus(),
                    ),
                  );
                }
                // CTA bar: hairline on top, 12 / 20 / 24.
                return DecoratedBox(
                  decoration: BoxDecoration(
                    color: cs.surface,
                    border: Border(top: BorderSide(color: cs.outlineVariant)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin,
                          12, KuberSpace.screenMargin, KuberSpace.xl),
                      child: _bottomButton(l),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      )),
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

/// Reads the keyboard inset ABOVE the Scaffold (the Scaffold strips it from
/// its body's MediaQuery when it resizes for the keyboard) and hands down only
/// open / closed, so the page doesn't rebuild on every keyboard frame.
class _KbScope extends StatelessWidget {
  const _KbScope({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      _Kb(open: MediaQuery.viewInsetsOf(context).bottom > 0, child: child);
}

class _Kb extends InheritedWidget {
  const _Kb({required this.open, required super.child});
  final bool open;

  @override
  bool updateShouldNotify(_Kb old) => old.open != open;
}

/// Rebuilds only its subtree when the keyboard opens or closes.
class _InsetsBuilder extends StatelessWidget {
  const _InsetsBuilder({required this.builder});
  final Widget Function(BuildContext, bool kbOpen) builder;

  @override
  Widget build(BuildContext context) => builder(context,
      context.dependOnInheritedWidgetOfExactType<_Kb>()?.open ?? false);
}
