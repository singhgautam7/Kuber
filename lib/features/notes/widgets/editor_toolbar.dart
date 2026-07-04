import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../core/utils/locale_font.dart';

/// Samsung-Notes-style bottom toolbar for the note editor (screen 1d):
/// Undo | Redo | Bold | Bullet list | Checkbox list | Dismiss keyboard.
/// Entirely hidden (not just disabled) in read-only mode — the parent screen
/// handles that.
class KuberEditorToolbar extends StatefulWidget {
  final QuillController controller;

  const KuberEditorToolbar({
    super.key,
    required this.controller,
  });

  @override
  State<KuberEditorToolbar> createState() => _KuberEditorToolbarState();
}

class _KuberEditorToolbarState extends State<KuberEditorToolbar> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  /// Inline attribute active state (Bold). Reads the current selection style.
  bool _hasInline(Attribute attribute) {
    final attrs = widget.controller.getSelectionStyle().attributes;
    final current = attrs[attribute.key];
    return current != null && current.value == attribute.value;
  }

  /// Block-list active state (bullet / checkbox). Reads the block attribute of
  /// the line at the cursor from the document directly, so it never goes stale
  /// after leaving a list (the selection style's toggledStyle can lag).
  String? _currentListValue() {
    final controller = widget.controller;
    final index = controller.selection.baseOffset.clamp(
      0,
      (controller.document.length - 1).clamp(0, 1 << 30),
    );
    final style = controller.document.collectStyle(index, 0);
    return style.attributes[Attribute.list.key]?.value as String?;
  }

  void _toggleBold() {
    if (_hasInline(Attribute.bold)) {
      widget.controller
          .formatSelection(Attribute.clone(Attribute.bold, null));
    } else {
      widget.controller.formatSelection(Attribute.bold);
    }
  }

  void _toggleList(Attribute target) {
    final active = _currentListValue() == target.value;
    widget.controller.formatSelection(
        active ? Attribute.clone(Attribute.list, null) : target);
  }

  void _moveCursor(int delta) {
    final controller = widget.controller;
    final len = controller.document.length;
    final base = controller.selection.baseOffset;
    final next = (base + delta).clamp(0, (len - 1).clamp(0, 1 << 30));
    controller.updateSelection(
      TextSelection.collapsed(offset: next),
      ChangeSource.local,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = widget.controller;
    final listValue = _currentListValue();

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        border: Border(top: BorderSide(color: cs.outline)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolbarButton(
            icon: Icons.undo_rounded,
            enabled: c.hasUndo,
            onTap: c.undo,
          ),
          _ToolbarButton(
            icon: Icons.redo_rounded,
            enabled: c.hasRedo,
            onTap: c.redo,
          ),
          _ToolbarTextButton(
            label: 'B',
            active: _hasInline(Attribute.bold),
            onTap: _toggleBold,
          ),
          _ToolbarButton(
            icon: Icons.format_list_bulleted_rounded,
            active: listValue == Attribute.ul.value,
            onTap: () => _toggleList(Attribute.ul),
          ),
          _ToolbarButton(
            icon: Icons.checklist_rounded,
            active: listValue == Attribute.unchecked.value ||
                listValue == Attribute.checked.value,
            onTap: () => _toggleList(Attribute.unchecked),
          ),
          // Cursor nudge left / right (replaces the dismiss-keyboard button).
          _ToolbarButton(
            icon: Icons.chevron_left_rounded,
            onTap: () => _moveCursor(-1),
          ),
          _ToolbarButton(
            icon: Icons.chevron_right_rounded,
            onTap: () => _moveCursor(1),
          ),
        ],
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  final IconData icon;
  final bool active;
  final bool enabled;
  final VoidCallback onTap;

  const _ToolbarButton({
    required this.icon,
    required this.onTap,
    this.active = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = !enabled
        ? cs.onSurfaceVariant.withValues(alpha: 0.35)
        : active
            ? cs.primary
            : cs.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }
}

class _ToolbarTextButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToolbarTextButton({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          label,
          style: localeFont(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: active ? cs.primary : cs.onSurface,
          ),
        ),
      ),
    );
  }
}
