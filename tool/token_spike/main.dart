// H3 spike: Wrap of chips + one inline TextField at the cursor slot.
// Run: flutter run -t tool/token_spike/main.dart -d emulator-5554
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Spike()));

const _s = '​'; // sentinel: backspace on "empty" removes it

class Spike extends StatefulWidget {
  const Spike({super.key});
  @override
  State<Spike> createState() => _SpikeState();
}

class _SpikeState extends State<Spike> {
  final items = <String>['category:food', 'and'];
  int cursor = 2; // slot between items
  int? selected; // highlighted token
  int? editing; // token being edited in place
  final c = TextEditingController(text: _s);
  final f = FocusNode();
  String log = '';

  void _reset([String t = '']) {
    c.value = TextEditingValue(
        text: _s + t, selection: TextSelection.collapsed(offset: 1 + t.length));
  }

  void _insert(List<String> toks) {
    items.insertAll(cursor, toks);
    cursor += toks.length;
  }

  void _onChanged(String raw) {
    setState(() {
      if (raw.isEmpty || !raw.startsWith(_s)) {
        // backspace on empty input
        final typed = raw.replaceAll(_s, '');
        _reset(typed);
        if (editing != null && typed.isEmpty) {
          log = 'backspace in empty edit';
        } else if (typed.isEmpty) {
          log = 'backspace sentinel';
          if (selected != null) {
            items.removeAt(selected!);
            if (cursor > selected!) cursor--;
            selected = null;
          } else if (cursor > 0) {
            selected = cursor - 1;
          }
        }
        return;
      }
      selected = null;
      final t = raw.substring(1);
      if (t.contains(' ')) {
        final parts = t.split(' ').where((p) => p.isNotEmpty).toList();
        // composing text is only sealed once the space arrives
        if (editing != null) {
          items[editing!] = parts.first;
          cursor = editing! + 1;
          editing = null;
          parts.removeAt(0);
        }
        for (final p in parts) {
          _insert([p, 'and']);
        }
        log = 'sealed ${parts.length}';
        _reset();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final input = SizedBox(
      width: 140,
      child: TextField(
        key: const ValueKey('input'),
        controller: c,
        focusNode: f,
        autocorrect: true,
        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
        onChanged: _onChanged,
        onSubmitted: (_) {
          setState(() {
            final t = c.text.replaceAll(_s, '');
            if (t.isNotEmpty) _insert([t]);
            _reset();
          });
          f.requestFocus();
        },
      ),
    );
    final kids = <Widget>[];
    for (var i = 0; i <= items.length; i++) {
      if (i == cursor && editing == null) kids.add(input);
      if (i == items.length) break;
      if (editing == i) {
        kids.add(input);
      } else {
        kids.add(GestureDetector(
          onTap: () => setState(() {
            editing = i;
            _reset(items[i]);
            f.requestFocus();
          }),
          child: Chip(
            label: Text(items[i]),
            backgroundColor: selected == i ? cs.primary : null,
          ),
        ));
      }
    }
    return Scaffold(
      appBar: AppBar(title: const Text('token spike')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Container(
            padding: const EdgeInsets.all(8),
            color: cs.surfaceContainerHigh,
            child: Wrap(spacing: 6, runSpacing: 6, children: kids)),
        Text('log: $log  items=${items.join("|")} cursor=$cursor sel=$selected edit=$editing',
            key: const ValueKey('log')),
        Wrap(spacing: 8, children: [
          OutlinedButton(
              onPressed: () => setState(() => _insert(['(']) ),
              child: const Text('insert (')),
          OutlinedButton(
              onPressed: () => setState(() => cursor = 0),
              child: const Text('cursor 0')),
          OutlinedButton(
              onPressed: () => _onChanged('$_s${'amount:>500 or tag:trip '}'),
              child: const Text('paste')),
        ]),
      ]),
    );
  }
}
