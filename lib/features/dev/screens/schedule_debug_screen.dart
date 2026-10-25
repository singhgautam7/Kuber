// Dev tools > Schedule debug (board X.3). English only, like the rest of Dev
// tools. Every rule, EMI and SIP: sentence, next 12 dates (* = moved to the
// month's last day) and migration status.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/schedule/schedule.dart';
import '../../../core/schedule/schedule_engine.dart';
import '../../../core/schedule/schedule_text.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../investments/data/investment.dart';
import '../../loans/data/loan.dart';
import '../../recurring/data/recurring_rule.dart';

class ScheduleDebugItem {
  final String kind; // Rule | EMI | SIP
  final String name;
  final Schedule schedule;
  const ScheduleDebugItem(this.kind, this.name, this.schedule);

  String get note => schedule.migrationNote ?? 'OK';
  bool get flagged => note.contains('Flagged');
  bool get migrated => note.contains('Migrated');
}

final scheduleDebugProvider = FutureProvider.autoDispose<List<ScheduleDebugItem>>((ref) async {
  final isar = ref.watch(isarProvider);
  return [
    for (final r in await isar.recurringRules.where().findAll())
      if (r.schedule != null) ScheduleDebugItem('Rule', r.name, r.schedule!),
    for (final l in await isar.loans.where().findAll())
      if (l.schedule != null) ScheduleDebugItem('EMI', l.name, l.schedule!),
    for (final i in await isar.investments.where().findAll())
      if (i.sip != null) ScheduleDebugItem('SIP', i.name, i.sip!),
  ];
});

class ScheduleDebugScreen extends ConsumerStatefulWidget {
  const ScheduleDebugScreen({super.key});

  @override
  ConsumerState<ScheduleDebugScreen> createState() => _ScheduleDebugScreenState();
}

class _ScheduleDebugScreenState extends ConsumerState<ScheduleDebugScreen> {
  int _filter = 0; // 0 all, 1 flagged, 2 migrated

  String _dates(Schedule s) {
    if (s.paused) return 'No dates while paused';
    final f = DateFormat('d MMM yy');
    final next = upcomingOccurrences(s, fromKey: todayKey(), limit: 12);
    if (next.isEmpty) return 'Ended';
    return next
        .map((o) => '${f.format(dayOf(o.day))}${isClampedDay(s, o.day) ? '*' : ''}')
        .join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final items = ref.watch(scheduleDebugProvider).valueOrNull ?? const [];
    final shown = switch (_filter) {
      1 => items.where((i) => i.flagged).toList(),
      2 => items.where((i) => i.migrated).toList(),
      _ => items,
    };
    final l = context.l10n;
    String dump() => [
          for (final i in shown)
            '${i.kind} · ${i.name}\n${scheduleSentence(l, i.schedule, emis: i.kind == 'EMI')}\n${_dates(i.schedule)}\n${i.note}\n'
        ].join('\n');
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: KuberAppBar(
        showBack: true,
        title: 'Schedule debug',
        actions: [
          IconButton(
            icon: const Icon(Icons.content_copy_rounded),
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: dump()));
              if (context.mounted) showKuberSnackBar(context, 'Copied');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            KuberSpace.screenMargin, 0, KuberSpace.screenMargin, KuberSpace.xl),
        children: [
          Wrap(spacing: 8, children: [
            KuberChip(
                label: 'All · ${items.length}',
                selected: _filter == 0,
                showCheck: true,
                onTap: () => setState(() => _filter = 0)),
            KuberChip(
                label: 'Flagged · ${items.where((i) => i.flagged).length}',
                selected: _filter == 1,
                showCheck: true,
                onTap: () => setState(() => _filter = 1)),
            KuberChip(
                label: 'Migrated · ${items.where((i) => i.migrated).length}',
                selected: _filter == 2,
                showCheck: true,
                onTap: () => setState(() => _filter = 2)),
          ]),
          const SizedBox(height: KuberSpace.lg),
          KuberGroup(children: [
            for (final i in shown)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(i.kind.toUpperCase(),
                        style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
                    Text(i.name, style: tt.titleMedium),
                    const SizedBox(height: 4),
                    Text(scheduleSentence(l, i.schedule, emis: i.kind == 'EMI'),
                        style: tt.bodyMedium),
                    const SizedBox(height: 4),
                    Text(_dates(i.schedule),
                        style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Text(i.note,
                        style: tt.labelMedium!.copyWith(
                            color: i.flagged ? context.kuberMoney.warning : cs.primary)),
                  ],
                ),
              ),
          ]),
        ],
      ),
    );
  }
}
