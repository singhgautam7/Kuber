import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_icon_button.dart';

/// M3 search bar: a 48dp full-radius pill with a leading back button, the
/// field and an animated clear button. Shared by the header search
/// (`KuberAppBar`) and the More search screen.
class KuberSearchPill extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;
  final bool autofocus;
  final TextInputAction textInputAction;

  /// When true, the system back gesture calls [onClose] instead of popping.
  final bool interceptBack;
  final String backLabel;

  const KuberSearchPill({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    required this.onClose,
    this.autofocus = true,
    this.textInputAction = TextInputAction.search,
    this.interceptBack = true,
    this.backLabel = 'Close search',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final pill = Container(
      height: 48,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: KuberShape.fullR,
      ),
      child: Row(
        children: [
          AppIconButton(
            icon: Icons.arrow_back_rounded,
            kind: AppIconButtonKind.plain,
            semanticLabel: backLabel,
            onPressed: onClose,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              autofocus: autofocus,
              textAlignVertical: TextAlignVertical.center,
              textInputAction: textInputAction,
              onChanged: onChanged,
              cursorColor: cs.primary,
              style: theme.textTheme.bodyLarge!.copyWith(color: cs.onSurface),
              decoration: InputDecoration(
                isCollapsed: true,
                // The theme's inputDecorationTheme padding would push the
                // text off-centre in a 48dp pill.
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: hint,
                hintStyle: theme.textTheme.bodyLarge!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, v, __) => AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: v.text.isEmpty
                  ? const SizedBox(width: 8, key: ValueKey('none'))
                  : AppIconButton(
                      key: const ValueKey('clear'),
                      icon: Icons.close_rounded,
                      kind: AppIconButtonKind.plain,
                      semanticLabel: 'Clear',
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                    ),
            ),
          ),
        ],
      ),
    );
    if (!interceptBack) return pill;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onClose();
      },
      child: pill,
    );
  }
}
