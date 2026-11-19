import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../core/utils/locale_font.dart';
import '../../providers/ah_providers.dart';
import '../../query/query_ast.dart';
import '../../query/query_labels.dart';
import '../../query/query_parser.dart';
import '../../../../core/utils/icon_mapper.dart';
import '../../../../shared/widgets/category_icon.dart';
import '../../../../shared/widgets/kuber_list.dart';
import '../../../categories/data/category.dart';
import '../../../categories/providers/category_provider.dart';
import '../filter/field_list.dart' show fieldHint;
import '../filter/value_pickers.dart' show fieldIcon;
import 'bracket_box.dart';
import 'token_chips.dart';
import 'token_filter_controller.dart';

/// Zero-width sentinel kept at the start of the input. Android IMEs often send
/// nothing for backspace on an empty field; deleting the sentinel is the
/// signal instead (see specs/advanced-history-v1/token-field-notes.md).
const kTokenSentinel = '​';

/// Zero-width end marker after the typed text. With text on both sides of
/// the caret, the keyboard's own cursor controls (Gboard space swipe, arrow
/// keys) can move the caret past either edge, and that moves the cursor
/// between tokens.
const kTokenEnd = '⁠';

class _Box {
  const _Box(this.start, this.end, this.depth, this.explicit);
  final int start, end, depth;
  final bool explicit;
}

/// Reusable token field: sealed filters, joiners, brackets and one inline
/// input at the cursor. Always editable, no modes. Edit it through
/// [controller] (operator bar, field list, example chips).
class TokenFilterField extends ConsumerStatefulWidget {
  const TokenFilterField({
    super.key,
    required this.controller,
    required this.money,
    this.placeholder,
    this.focusedPlaceholder,
    this.onAction,
    this.showSuggestions = true,
  });

  final TokenFilterController controller;

  /// Formats rupees (Indian grouping), e.g. `formatter.formatCurrency`.
  final String Function(double) money;
  final String? placeholder;
  final String? focusedPlaceholder;

  /// Keyboard action key with nothing typed (the page applies the filter).
  final VoidCallback? onAction;
  final bool showSuggestions;

  @override
  ConsumerState<TokenFilterField> createState() => _TokenFilterFieldState();
}

class _TokenFilterFieldState extends ConsumerState<TokenFilterField> {
  final _input = TextEditingController(text: kTokenSentinel + kTokenEnd);
  final _keys = <int, GlobalKey>{};
  // Global so the input (and its IME connection) survives moving in the tree.
  final _slotKey = GlobalKey(debugLabel: 'ahf-input-slot');
  String _prevRaw = kTokenSentinel + kTokenEnd;
  bool _adjusting = false;
  bool _ready = false;
  bool _hadFocus = false;
  int? _lastEditing;
  AhSuggestion? _top;
  AhSuggestionQuery? _query;

  TokenFilterController get c => widget.controller;
  String get _typed => _strip(_input.text);
  static String _strip(String raw) =>
      raw.replaceAll(kTokenSentinel, '').replaceAll(kTokenEnd, '');

  @override
  void initState() {
    super.initState();
    c.addListener(_onController);
    c.focusNode.addListener(_onFocus);
    _input.addListener(_onSelection);
    _reset();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void didUpdateWidget(TokenFilterField old) {
    super.didUpdateWidget(old);
    if (old.controller != c) {
      old.controller.removeListener(_onController);
      old.controller.focusNode.removeListener(_onFocus);
      c.addListener(_onController);
      c.focusNode.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    c.removeListener(_onController);
    c.focusNode.removeListener(_onFocus);
    _input.removeListener(_onSelection);
    _input.dispose();
    super.dispose();
  }

  void _reset([String t = '']) {
    _prevRaw = kTokenSentinel + t + kTokenEnd;
    _adjusting = true;
    _input.value = TextEditingValue(
      text: _prevRaw,
      selection: TextSelection.collapsed(offset: _prevRaw.length - 1),
    );
    _adjusting = false;
  }

  /// The caret went past the start marker (left) or the end marker (right):
  /// seal what is typed and step the cursor one item that way.
  void _onSelection() {
    if (_adjusting) return;
    final v = _input.value;
    final sel = v.selection;
    if (!sel.isValid || !sel.isCollapsed || v.composing.isValid) return;
    final len = v.text.length;
    final int step;
    if (sel.baseOffset == 0 && v.text.startsWith(kTokenSentinel)) {
      step = -1;
    } else if (sel.baseOffset == len && v.text.endsWith(kTokenEnd)) {
      step = 1;
    } else {
      return;
    }
    final had = _typed.trim().isNotEmpty || c.editing != null;
    _commitPending();
    // Sealing put the cursor after the new token: a left step from there
    // lands before it, as the caret did.
    c.moveCursor(c.cursor + (had && step > 0 ? 0 : step));
    _reset();
    if (mounted) setState(() {});
  }

  void _onController() {
    final e = c.editing;
    if (e != _lastEditing) {
      _lastEditing = e;
      if (e != null && e < c.items.length) {
        final t = c.items[e];
        _reset(t is TokenItem ? t.text : '');
        c.focusNode.requestFocus();
      }
    }
    if (mounted) setState(() {});
  }

  void _onFocus() {
    final has = c.focusNode.hasFocus;
    if (_hadFocus && !has) _commitPending();
    _hadFocus = has;
    if (mounted) setState(() {});
  }

  /// Seals what is typed (and an edit in progress) into items.
  void _commitPending() {
    if (c.editing != null) {
      final t = _typed;
      _lastEditing = null;
      _reset();
      c.commitEdit(t);
    } else if (_typed.trim().isNotEmpty) {
      final t = _typed;
      _reset();
      c.insert(tokenize(t));
    }
    c.selected = null;
  }

  // --- typing --------------------------------------------------------------

  /// Index of the last whitespace outside quotes, or -1.
  int _lastSpace(String s) {
    var inQ = false;
    var last = -1;
    for (var i = 0; i < s.length; i++) {
      if (s[i] == '"') inQ = !inQ;
      if (!inQ && s[i].trim().isEmpty) last = i;
    }
    return last;
  }

  bool _quotesBalanced(String s) => '"'.allMatches(s).length.isEven;

  void _onChanged(String raw) {
    final typed = _strip(raw);
    if (!raw.startsWith(kTokenSentinel) && typed.isEmpty) {
      // Sentinel deleted with nothing else typed: backspace on empty.
      _reset();
      c.backspace();
      return;
    }
    // A jump of several characters with a space in it is a paste (typing,
    // swipe and prediction commits end in a space or are single words).
    final pasted = raw.length - _prevRaw.length > 1 && _lastSpace(typed) >= 0;
    c.selected = null;
    String? seal;
    var rest = typed;
    if (_quotesBalanced(typed)) {
      if (pasted) {
        seal = typed;
        rest = '';
      } else if (typed.length > 1 &&
          typed.endsWith('"') &&
          typed.trimLeft().startsWith('"')) {
        seal = typed;
        rest = '';
      } else {
        final ws = _lastSpace(typed);
        if (ws >= 0) {
          seal = typed.substring(0, ws + 1);
          rest = typed.substring(ws + 1);
        }
      }
    }
    if (seal != null && seal.trim().isNotEmpty) {
      _sealText(seal.trim());
      _reset(rest);
    } else if (seal != null) {
      _reset(rest);
    } else {
      if (raw.startsWith(kTokenSentinel) && raw.endsWith(kTokenEnd)) {
        _prevRaw = raw;
      } else {
        // A marker went missing (forward delete, an IME commit): put both
        // back, caret at the end of the typed text.
        _reset(typed);
      }
    }
    setState(() {});
  }

  void _sealText(String text) {
    if (c.editing != null) {
      _lastEditing = null;
      c.commitEdit(text);
    } else {
      c.insert(tokenize(text), trailingAnd: true);
    }
  }

  void _onSubmitted(String _) {
    final t = _typed.trim();
    if (t.isNotEmpty) {
      if (_top != null) {
        _applySuggestion(_top!);
      } else {
        _reset();
        _sealText(t);
      }
      c.focusNode.requestFocus();
      return;
    }
    if (c.editing != null) _commitPending();
    widget.onAction?.call();
  }

  void _applySuggestion(AhSuggestion s) {
    final q = _query;
    if (q == null || q.field == null) {
      // A field name: continue typing its value.
      _reset(s.value);
      setState(() {});
      c.focusNode.requestFocus();
      return;
    }
    final typed = _typed;
    final cut = typed.lastIndexOf(RegExp('[:=,]'));
    final head = cut >= 0 ? typed.substring(0, cut + 1) : '${q.field!.keyword}:';
    _reset();
    _sealText('$head${s.value}');
    c.focusNode.requestFocus();
  }

  // --- taps ------------------------------------------------------------------

  void _onTokenTap(int id) {
    _commitPending();
    final i = c.ids.indexOf(id);
    if (i >= 0) c.startEdit(i);
  }

  void _onBoxTap(TapUpDetails d) {
    // The caret goes to the gap nearest the tap on the tapped line: before
    // the first item to the right of it, or after the line's last item.
    // Brackets are items too, so taps beside a box land outside it.
    final p = d.globalPosition;
    final items = c.items;
    final ids = c.ids;
    final rects = <(int, Rect)>[];
    for (var i = 0; i < items.length; i++) {
      final box = _keys[ids[i]]?.currentContext?.findRenderObject();
      if (box is! RenderBox || !box.attached || !box.hasSize) continue;
      rects.add((i, box.localToGlobal(Offset.zero) & box.size));
    }
    int? slot;
    final line = [
      for (final r in rects)
        if (r.$2.top - 4 <= p.dy && r.$2.bottom + 4 >= p.dy) r
    ];
    if (line.isNotEmpty) {
      for (final r in line) {
        if (r.$2.center.dx > p.dx) {
          slot = r.$1;
          break;
        }
      }
      slot ??= line.last.$1 + 1;
    } else {
      // Between lines or below them: before the first item on a later line.
      for (final r in rects) {
        if (r.$2.top > p.dy) {
          slot = r.$1;
          break;
        }
      }
    }
    _commitPending();
    c.moveCursor((slot ?? items.length).clamp(0, c.items.length));
    if (c.focusNode.hasFocus) {
      // Focused with the keyboard closed (system back): open it again.
      SystemChannels.textInput.invokeMethod<void>('TextInput.show');
    } else {
      c.focusNode.requestFocus();
    }
  }

  // --- layout ------------------------------------------------------------------

  GlobalKey _keyFor(int id) => _keys.putIfAbsent(id, GlobalKey.new);

  Widget _leaf(int i, Set<int> errIdx, Set<int> unmatched, Set<int> deep) {
    final item = c.items[i];
    final id = c.ids[i];
    final removing = c.removing.contains(id);
    final fresh = _ready && c.fresh.contains(id);
    final selected = c.selected == i;
    Widget w;
    switch (item) {
      case TokenItem t:
        w = TokenChip(
          item: t,
          money: widget.money,
          selected: selected,
          editing: false,
          negated: i > 0 && c.items[i - 1] is NotItem,
          flashing: fresh,
          error: errIdx.contains(i),
          onTap: () => _onTokenTap(id),
        );
      case JoinerItem j:
        final ok = i > 0 &&
            i < c.items.length - 1 &&
            c.items[i - 1] is! JoinerItem &&
            c.items[i + 1] is! JoinerItem &&
            c.items[i - 1] is! OpenItem &&
            c.items[i + 1] is! CloseItem;
        w = JoinerChip(
          isOr: j.isOr,
          selected: selected,
          onTap: ok ? () => c.flip(i) : null,
        );
      case NotItem _:
        // A not before a token is drawn inside that token (design: one
        // "not" label); it shows on its own only before a bracket or when
        // backspace has selected it.
        final ownsToken = i + 1 < c.items.length && c.items[i + 1] is TokenItem;
        w = ownsToken && !selected
            ? const SizedBox.shrink()
            : NotLabel(highlight: selected);
      case OpenItem _:
        w = BracketToken(
            open: true,
            error: unmatched.contains(i),
            selected: selected);
      case CloseItem _:
        w = BracketToken(
            open: false,
            error: unmatched.contains(i),
            selected: selected);
    }
    return KeyedSubtree(
      key: _keyFor(id),
      child: TokenEntrance(animate: fresh, removing: removing, child: w),
    );
  }

  Widget _inputSlot(ColorScheme cs, bool focused) {
    final style = localeFont(
        fontSize: 14, fontWeight: FontWeight.w500, color: cs.onSurface);
    final tp = TextPainter(
      text: TextSpan(text: _typed, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout();
    final w = (tp.width + 6).clamp(6.0, 260.0);
    tp.dispose();
    return SizedBox(
      key: _slotKey,
      width: w,
      height: 32,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Taps go to the box, which places the caret between tokens; the
          // field's own tap would move the caret onto a marker instead.
          IgnorePointer(
            child: TextField(
            key: const ValueKey('ahf-input'),
            controller: _input,
            focusNode: c.focusNode,
            style: style,
            cursorColor: cs.primary,
            cursorWidth: 2,
            cursorHeight: 18,
            cursorRadius: const Radius.circular(1),
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.deny(RegExp('[\n\r]')),
            ],
            // Every border spelled out: the app's InputDecorationTheme
            // otherwise draws its focused outline around the inline input.
            decoration: const InputDecoration(
              isCollapsed: true,
              filled: false,
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
            ),
            onChanged: _onChanged,
            onSubmitted: _onSubmitted,
            // The box, its suggestions and the operator bar are one tap
            // region (TextFieldTapRegion); a tap anywhere else closes it.
            onTapOutside: (_) => c.focusNode.unfocus(),
          ),
          ),
          if (!focused)
            IgnorePointer(
              child: Container(
                key: const ValueKey('ahf-caret'),
                width: 2,
                height: 18,
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<_Box> _boxes(List<QueryItem> items, ParseResult parsed, Set<int> unmatched,
      Set<int> deep) {
    final out = <_Box>[];
    final stack = <int>[];
    final pairs = <(int, int, int)>[];
    for (var i = 0; i < items.length; i++) {
      if (items[i] is OpenItem) stack.add(i);
      if (items[i] is CloseItem) {
        if (stack.isEmpty) {
          unmatched.add(i);
        } else {
          pairs.add((stack.removeLast(), i, stack.length + 1));
        }
      }
    }
    unmatched.addAll(stack);
    for (final p in pairs) {
      if (p.$3 <= 3) {
        out.add(_Box(p.$1, p.$2, p.$3, true));
      } else {
        deep..add(p.$1)..add(p.$2);
      }
    }
    for (final b in parsed.boxes) {
      if (!b.implicit) continue;
      if (out.any((o) => o.start == b.start && o.end == b.end)) continue;
      if (b.start > b.end || b.end >= items.length) continue;
      out.add(_Box(b.start, b.end, b.depth, false));
    }
    out.sort((a, b) =>
        a.start != b.start ? a.start - b.start : b.end - a.end);
    return out;
  }

  int _tokensIn(int a, int b) {
    var n = 0;
    for (var i = a; i <= b && i < c.items.length; i++) {
      if (c.items[i] is TokenItem) n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l = context.l10n;
    final items = c.items;
    final focused = c.focusNode.hasFocus;
    final parsed = c.parsed;
    final unmatched = <int>{};
    final deep = <int>{};
    final boxes = _boxes(items, parsed, unmatched, deep);

    // While the cursor sits inside an open bracket no error is shown and a
    // ghost ")" waits; it validates when the cursor leaves.
    final suppressed = <int>{
      if (focused)
        for (final i in unmatched)
          if (items[i] is OpenItem && c.cursor > i) i,
    };
    final shownUnmatched = unmatched.difference(suppressed);
    // The "missing closing bracket" error may point at the open bracket or at
    // the last item; while the ghost waits it is held back either way.
    final errors = [
      for (final e in c.errors)
        if (!(suppressed.isNotEmpty && e.code == QueryErrorCode.missingClose))
          e,
    ];
    final errIdx = <int>{
      for (final e in errors)
        if (e.itemIndex >= 0 && e.itemIndex < items.length) e.itemIndex,
    };
    final ghost = suppressed.isNotEmpty;
    _keys.removeWhere((id, _) => !c.ids.contains(id));

    final cursorHere = c.cursor;
    final slot = _inputSlot(cs, focused);

    List<Widget> layout(int lo, int hi, List<_Box> inside, {required bool end}) {
      final out = <Widget>[];
      var i = lo;
      while (i <= hi) {
        if (cursorHere == i && c.editing == null) out.add(slot);
        _Box? b;
        for (final x in inside) {
          if (x.start == i && x.end <= hi) {
            b = x;
            break;
          }
        }
        if (b != null) {
          final sub = [
            for (final x in inside)
              if (!identical(x, b) && x.start >= b.start && x.end <= b.end) x
          ];
          final a = b.explicit ? b.start + 1 : b.start;
          final z = b.explicit ? b.end - 1 : b.end;
          out.add(BracketBox(
            key: ValueKey(b.explicit
                ? 'box-${c.ids[b.start]}'
                : 'imp-${c.ids[b.start]}-${c.ids[b.end]}'),
            depth: b.depth,
            implicit: !b.explicit,
            animate: _ready,
            filterCount: _tokensIn(b.start, b.end),
            // The ( and ) stay visible at the box edges: they can be
            // selected and deleted, and the caret can sit outside them.
            children: [
              if (b.explicit) _leaf(b.start, errIdx, shownUnmatched, deep),
              ...layout(a, z, sub, end: b.explicit),
              if (b.explicit) _leaf(b.end, errIdx, shownUnmatched, deep),
            ],
          ));
          i = b.end + 1;
          continue;
        }
        if (c.editing == i) {
          out.add(slot);
        } else {
          out.add(_leaf(i, errIdx, shownUnmatched, deep));
        }
        i++;
      }
      if (end && cursorHere == hi + 1 && c.editing == null) out.add(slot);
      return out;
    }

    final content = layout(0, items.length - 1, boxes, end: true);
    if (ghost) {
      content.add(const BracketToken(
          key: ValueKey('ahf-ghost'), open: false, ghost: true));
    }

    final showPlaceholder = items.isEmpty && _typed.isEmpty;
    final hint = focused
        ? (widget.focusedPlaceholder ?? widget.placeholder)
        : widget.placeholder;
    final hasImplicit = parsed.boxes.any((b) => b.implicit) && errors.isEmpty;

    final box = AnimatedContainer(
      duration: KuberMotion.fxFast,
      curve: KuberMotion.curveEffects,
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                if (showPlaceholder && hint != null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          // After the still caret.
                          padding: const EdgeInsets.only(left: 4),
                          child: Text(
                            hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ),
                    ),
                  ),
                ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 32),
                  child: Wrap(
                    key: const ValueKey('ahf-wrap'),
                    spacing: 6,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: content,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    // Suggestions: field names first, then the user's values.
    Widget suggestions = const SizedBox.shrink();
    _top = null;
    // Only once something is typed: the field list already sits below.
    if (widget.showSuggestions && focused && _typed.isNotEmpty) {
      final typed = _typed;
      final colon = typed.indexOf(RegExp('[:=]'));
      final field =
          colon > 0 ? QueryField.fromKeyword(typed.substring(0, colon)) : null;
      final prefix = colon > 0
          ? typed.substring(typed.lastIndexOf(RegExp('[:=,]')) + 1)
          : typed;
      if (colon <= 0 || field != null) {
        _query = AhSuggestionQuery(field, prefix);
        final list = ref.watch(ahSuggestionsProvider(_query!)).valueOrNull ??
            const <AhSuggestion>[];
        final words = field == null && typed.trim().isNotEmpty
            ? typed.trim()
            : null;
        if (list.isNotEmpty) _top = list.first;
        if (list.isNotEmpty || words != null) {
          final cats = field == QueryField.category
              ? {
                  for (final c in ref.watch(categoryListProvider).valueOrNull ??
                      const <Category>[])
                    c.name.toLowerCase(): c,
                }
              : const <String, Category>{};
          suggestions = _SuggestionList(
            field: field,
            categories: cats,
            list: list.take(6).toList(),
            onTap: _applySuggestion,
            words: words,
            onWords: () {
              _reset();
              _sealText('"${words!.replaceAll('"', '')}"');
              c.focusNode.requestFocus();
            },
          );
        }
      }
    }

    return TextFieldTapRegion(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: _onBoxTap,
          child: box,
        ),
        _ErrorLine(
          key: const ValueKey('ahf-error-line'),
          message: errors.isEmpty
              ? null
              : queryErrorMessage(errors.first, l),
        ),
        if (hasImplicit)
          Padding(
            key: const ValueKey('ahf-implicit-note'),
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(
              l.ahfImplicitNote,
              style: localeFont(
                  fontSize: 12.5, height: 1.4, color: cs.onSurfaceVariant),
            ),
          ),
        AnimatedSize(
          duration: KuberMotion.fxFast,
          alignment: Alignment.topCenter,
          child: suggestions,
        ),
      ],
    ));
  }
}

class _ErrorLine extends StatelessWidget {
  const _ErrorLine({super.key, required this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final reduced = KuberMotion.reduced(context);
    return AnimatedSwitcher(
      duration: reduced ? KuberMotion.fxInstant : KuberMotion.fxFast,
      switchInCurve: KuberMotion.curveEffects,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: SlideTransition(
                position: Tween(begin: reduced ? Offset.zero : const Offset(0, -0.3), end: Offset.zero)
                    .animate(a),
                child: child,
              ),
      ),
      child: message == null
          ? const SizedBox.shrink(key: ValueKey('none'))
          : Semantics(
              key: ValueKey(message),
              liveRegion: true,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.error_outline_rounded, size: 16, color: cs.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        message!,
                        style: localeFont(fontSize: 13, color: cs.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Inline suggestions while typing (no sheet): a caps header, then rows with
/// a tile, the name, a hint and the kind on the right. The top row is
/// preselected (the action key inserts it).
class _SuggestionList extends StatelessWidget {
  const _SuggestionList({
    required this.field,
    required this.list,
    required this.onTap,
    this.categories = const {},
    this.words,
    this.onWords,
  });
  final QueryField? field;

  /// Lower-cased name to category, for the category's own icon and colour.
  final Map<String, Category> categories;
  final List<AhSuggestion> list;
  final void Function(AhSuggestion) onTap;
  final String? words;
  final VoidCallback? onWords;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final l = context.l10n;
    final f = field;
    final header = switch (f) {
      null => l.ahfSugFields,
      QueryField.category => l.ahfSugCategories,
      QueryField.account => l.ahfSugAccounts,
      QueryField.tag => l.ahfSugTags,
      _ => l.ahfSugValues,
    };
    final kind = switch (f) {
      null => l.ahfKindField,
      QueryField.category => l.ahdCategory,
      QueryField.account => l.ahdAccount,
      QueryField.tag => l.ahdTag,
      _ => l.ahfKindValue,
    };

    Widget row({
      required Key key,
      required IconData icon,
      Category? category,
      required Widget title,
      String? hint,
      required String kind,
      required bool top,
      required VoidCallback onTap,
    }) =>
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Material(
            color: top ? cs.secondaryContainer : Colors.transparent,
            borderRadius: KuberShape.mediumR,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              key: key,
              onTap: onTap,
              child: Container(
                constraints: const BoxConstraints(minHeight: 52),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    if (category != null)
                      CategoryIcon.square(
                        icon: IconMapper.fromString(category.icon),
                        rawColor: Color(category.colorValue),
                        size: 32,
                      )
                    else
                      KuberIconTile(
                        icon: icon,
                        size: 32,
                        glyph: 18,
                        radius: KuberShape.small,
                        color: cs.surfaceContainerHighest,
                        iconColor: cs.onSurfaceVariant,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          title,
                          if (hint != null)
                            Text(hint,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: tt.bodySmall!
                                    .copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(kind,
                        style: tt.labelSmall!
                            .copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ),
          ),
        );

    Text name(String s, {Color? color, FontWeight? weight}) => Text(s,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.titleSmall!.copyWith(
            color: color ?? cs.onSurface, fontWeight: weight));

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (list.isNotEmpty)
            KuberSectionHeader(
              title: header,
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 2),
            ),
          for (var i = 0; i < list.length; i++)
            () {
              final s = list[i];
              final asField = f == null ? QueryField.fromKeyword(s.label) : null;
              return row(
                key: ValueKey('ahf-suggestion-$i'),
                icon: fieldIcon(asField ?? f ?? QueryField.words),
                category: categories[s.label.toLowerCase()],
                title: asField != null
                    ? name('${s.label}:',
                        color: cs.primary, weight: FontWeight.w600)
                    : name(s.label),
                hint: asField != null
                    ? fieldHint(asField, l)
                    : s.count == null
                        ? null
                        : l.ahdTxnN(s.count!),
                kind: kind,
                top: i == 0,
                onTap: () => onTap(s),
              );
            }(),
          if (words != null)
            row(
              key: const ValueKey('ahf-suggestion-words'),
              icon: Icons.format_quote_rounded,
              title: name(l.ahfSugWords(words!)),
              kind: fieldLabel(QueryField.words, l),
              top: list.isEmpty,
              onTap: onWords!,
            ),
        ],
      ),
    );
  }
}
