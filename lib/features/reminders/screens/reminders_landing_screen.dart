import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../pro/feature_gates/gate_sheet_reminders.dart';
import '../../pro/feature_gates/pro_gate.dart';
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
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: 'New reminder',
        onPressed: () {
          if (proGate(context, ref, showRemindersGateSheet)) {
            context.push('/reminders/add');
          }
        },
      ),
      floatingActionButtonLocation: kuberFabLocation,
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: KuberAppBar(
          title: 'Reminders',
          showBack: true,
          infoConfig: kAboutRemindersInfoConfig,
          search: KuberHeaderSearch(
            controller: _searchController,
            hint: 'Search reminders',
            onChanged: (v) =>
                ref.read(remindersSearchProvider.notifier).state = v,
          ),
        ),
        body: !loaded
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  0,
                  KuberSpace.screenMargin,
                  KuberExtendedFab.clearance,
                ),
                children: [
                  _FilterChips(
                    selected: filter,
                    onSelected: (f) =>
                        ref.read(remindersFilterProvider.notifier).state = f,
                  ),
                  if (sections.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: KuberEmptyState(
                        icon: Icons.notifications_active_outlined,
                        title: 'No reminders yet',
                        description:
                            'Set your first reminder to never miss a '
                            'payment or collection.',
                      ),
                    )
                  else ...[
                    if (sections.overdue.isNotEmpty)
                      _section('Overdue', sections.overdue, error: true),
                    if (sections.today.isNotEmpty)
                      _section('Today', sections.today),
                    if (sections.thisWeek.isNotEmpty)
                      _section('This week', sections.thisWeek),
                    if (sections.later.isNotEmpty)
                      _section('Later', sections.later),
                    if (sections.completed.isNotEmpty) ...[
                      const SizedBox(height: KuberSpace.lg),
                      KuberSectionHeader(
                        title: 'Completed · ${sections.completed.length}',
                        onTitleTap: () => setState(
                          () => _completedExpanded = !_completedExpanded,
                        ),
                        trailing: AppIconButton(
                          icon: _completedExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.keyboard_arrow_down_rounded,
                          kind: AppIconButtonKind.plain,
                          size: 32,
                          semanticLabel: _completedExpanded
                              ? 'Hide completed'
                              : 'Show completed',
                          onPressed: () => setState(
                            () => _completedExpanded = !_completedExpanded,
                          ),
                        ),
                      ),
                      if (_completedExpanded)
                        KuberGroup(
                          children: sections.completed.map(_row).toList(),
                        ),
                    ],
                  ],
                ],
              ),
      ),
    );
  }

  /// Caps header (error-coloured for Overdue) over a grouped list.
  Widget _section(String title, List<Reminder> items, {bool error = false}) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: KuberSpace.sectionHeaderGap),
            child: Text(
              title.toUpperCase(),
              style: error
                  ? sectionHeaderStyle(context).copyWith(color: cs.error)
                  : sectionHeaderStyle(context),
            ),
          ),
          KuberGroup(children: items.map(_row).toList()),
        ],
      ),
    );
  }

  Widget _row(Reminder r) =>
      ReminderRow(reminder: r, onTap: () => showReminderViewSheet(context, r));
}

class _FilterChips extends StatelessWidget {
  final RemindersFilter selected;
  final ValueChanged<RemindersFilter> onSelected;

  const _FilterChips({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
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
        separatorBuilder: (_, _) => const SizedBox(width: KuberSpace.sm),
        itemBuilder: (_, i) {
          final (filter, label) = entries[i];
          return KuberChip(
            label: label,
            selected: filter == selected,
            onTap: () => onSelected(filter),
          );
        },
      ),
    );
  }
}
