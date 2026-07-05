import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../data/reminder.dart';
import '../providers/reminders_provider.dart';
import '../widgets/about_reminders_info_sheet.dart';
import '../widgets/reminder_row.dart';
import '../widgets/reminder_view_sheet.dart';

/// Reminders landing page (screen 2a). Universal landing pattern with
/// Overdue / Today / This week / Later / Completed sections.
class RemindersLandingScreen extends ConsumerStatefulWidget {
  /// When set (notification deep link), the matching reminder's view sheet
  /// opens right after the first frame.
  final int? openReminderId;

  const RemindersLandingScreen({super.key, this.openReminderId});

  @override
  ConsumerState<RemindersLandingScreen> createState() =>
      _RemindersLandingScreenState();
}

class _RemindersLandingScreenState
    extends ConsumerState<RemindersLandingScreen> {
  final _searchController = TextEditingController();
  bool _completedExpanded = false;
  bool _openedFromLink = false;

  @override
  void initState() {
    super.initState();
    if (widget.openReminderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openFromLink());
    }
  }

  Future<void> _openFromLink() async {
    if (_openedFromLink || !mounted) return;
    _openedFromLink = true;
    final reminder = await ref
        .read(remindersRepositoryProvider)
        .getById(widget.openReminderId!);
    if (reminder != null && mounted) {
      showReminderViewSheet(context, reminder);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sections = ref.watch(reminderSectionsProvider);
    final filter = ref.watch(remindersFilterProvider);
    final loaded = ref.watch(remindersStreamProvider).hasValue;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        showHome: true,
        showBrand: false,
        infoConfig: kAboutRemindersInfoConfig,
      ),
      body: Column(
        children: [
          KuberPageHeader(
            title: 'Reminders',
            description: 'Set reminders for anything money-related',
            actionTooltip: 'New reminder',
            onAction: () => context.push('/reminders/add'),
          ),
          Expanded(
            child: !loaded
                ? const SizedBox.shrink()
                : ListView(
                    padding: EdgeInsets.only(
                      left: KuberSpacing.lg,
                      right: KuberSpacing.lg,
                      bottom: navBarBottomPadding(context),
                    ),
                    children: [
                      _SearchField(
                        controller: _searchController,
                        onChanged: (v) => ref
                            .read(remindersSearchProvider.notifier)
                            .state = v,
                      ),
                      const SizedBox(height: 12),
                      _FilterChips(
                        selected: filter,
                        onSelected: (f) => ref
                            .read(remindersFilterProvider.notifier)
                            .state = f,
                      ),
                      const SizedBox(height: 4),
                      if (sections.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 56),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.notifications_active_outlined,
                                    size: 40,
                                    color: cs.onSurfaceVariant
                                        .withValues(alpha: 0.5)),
                                const SizedBox(height: 14),
                                Text(
                                  'Set your first reminder to never miss a '
                                  'payment or collection.',
                                  textAlign: TextAlign.center,
                                  style: localeFont(
                                    fontSize: 13,
                                    color: cs.onSurfaceVariant,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else ...[
                        if (sections.overdue.isNotEmpty) ...[
                          _SectionHeader(
                            label: 'OVERDUE',
                            color: cs.error,
                            count: sections.overdue.length,
                          ),
                          ...sections.overdue.map(_row),
                        ],
                        if (sections.today.isNotEmpty) ...[
                          const _SectionHeader(label: 'TODAY'),
                          ...sections.today.map(_row),
                        ],
                        if (sections.thisWeek.isNotEmpty) ...[
                          const _SectionHeader(label: 'THIS WEEK'),
                          ...sections.thisWeek.map(_row),
                        ],
                        if (sections.later.isNotEmpty) ...[
                          const _SectionHeader(label: 'LATER'),
                          ...sections.later.map(_row),
                        ],
                        if (sections.completed.isNotEmpty) ...[
                          _CompletedHeader(
                            count: sections.completed.length,
                            expanded: _completedExpanded,
                            onToggle: () => setState(() =>
                                _completedExpanded = !_completedExpanded),
                          ),
                          if (_completedExpanded)
                            ...sections.completed.map(_row),
                        ],
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _row(Reminder r) => ReminderRow(
        reminder: r,
        onTap: () => showReminderViewSheet(context, r),
      );
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        onTapOutside: (_) =>
            FocusManager.instance.primaryFocus?.unfocus(),
        style: localeFont(fontSize: 13.5, color: cs.onSurface),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          prefixIcon: Icon(Icons.search_rounded,
              size: 17, color: cs.onSurfaceVariant),
          hintText: 'Search reminders',
          hintStyle: localeFont(
            fontSize: 13.5,
            color: cs.onSurfaceVariant.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  final RemindersFilter selected;
  final ValueChanged<RemindersFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const entries = [
      (RemindersFilter.all, 'All'),
      (RemindersFilter.overdue, 'Overdue'),
      (RemindersFilter.today, 'Today'),
      (RemindersFilter.thisWeek, 'This week'),
      (RemindersFilter.completed, 'Completed'),
    ];
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: entries.length,
        separatorBuilder: (_, _) => const SizedBox(width: 7),
        itemBuilder: (_, i) {
          final (filter, label) = entries[i];
          final active = filter == selected;
          return GestureDetector(
            onTap: () => onSelected(filter),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: active
                    ? cs.primary.withValues(alpha: 0.12)
                    : cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(
                  color: active
                      ? cs.primary.withValues(alpha: 0.4)
                      : cs.outline,
                ),
              ),
              child: Text(
                label,
                style: localeFont(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  color: active ? cs.primary : cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color? color;
  final int? count;

  const _SectionHeader({required this.label, this.color, this.count});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final c = color ?? cs.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 14, 2, 10),
      child: Row(
        children: [
          Text(
            label,
            style: localeFont(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.4,
              color: c,
            ),
          ),
          if (count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: c.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Text(
                '$count',
                style: localeFont(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              height: 1,
              color: color != null
                  ? color!.withValues(alpha: 0.2)
                  : cs.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletedHeader extends StatelessWidget {
  final int count;
  final bool expanded;
  final VoidCallback onToggle;

  const _CompletedHeader({
    required this.count,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onToggle,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(2, 14, 2, 8),
        child: Row(
          children: [
            Icon(
              expanded
                  ? Icons.keyboard_arrow_down_rounded
                  : Icons.chevron_right_rounded,
              size: 15,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: 6),
            Text(
              'COMPLETED',
              style: localeFont(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.sm),
              ),
              child: Text(
                '$count',
                style: localeFont(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
