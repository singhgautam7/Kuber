import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../data/add_action_catalog.dart';

/// Opens the FAB long-press "Add New" sheet — a vertical list of add-entry
/// shortcuts. The three core actions (expense/income/transfer) always lead;
/// the customizable tail comes from [addMenuActionsProvider].
Future<void> showAddNewSheet(BuildContext context) {
  HapticFeedback.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const KuberBottomSheet(
      title: 'Add New',
      description: 'Choose what to log',
      child: _AddNewSheetBody(),
    ),
  );
}

class _AddNewSheetBody extends ConsumerWidget {
  const _AddNewSheetBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The sheet renders exactly the configured list, so it stays in sync with
    // the Customize Add Menu screen.
    final ids = ref.watch(addMenuActionsProvider);
    final actions = ids.map(addActionById).whereType<AddActionMeta>().toList();

    // Board 3.2d: Edit Actions on top, the add actions as a 4-column grid of
    // 56 tiles in the accent container.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/settings/add-menu');
            },
            icon: const Icon(Icons.edit_outlined, size: 20),
            label: const Text('Edit Actions'),
          ),
        ),
        const SizedBox(height: KuberSpace.sm),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: KuberSpace.lg,
          crossAxisSpacing: KuberSpace.sm,
          childAspectRatio: 0.72,
          children: [
            for (final a in actions)
              _AddActionRow(
                meta: a,
                onTap: () {
                  Navigator.of(context).pop();
                  context.push(a.route);
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _AddActionRow extends StatelessWidget {
  final AddActionMeta meta;
  final VoidCallback onTap;

  const _AddActionRow({required this.meta, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    // Every action in the default accent container (no income / expense
    // tint).
    final bg = cs.secondaryContainer;
    final fg = cs.onSecondaryContainer;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: KuberShape.largeR,
            ),
            child: Icon(meta.icon, size: 24, color: fg),
          ),
          const SizedBox(height: KuberSpace.sm),
          Text(
            meta.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium!.copyWith(color: cs.onSurface),
          ),
        ],
      ),
    );
  }
}
