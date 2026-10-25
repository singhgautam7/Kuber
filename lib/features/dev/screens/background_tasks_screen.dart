// Dev tools > Background tasks: last runs (trigger, duration, counts,
// failures, log), the vNext migration report, and Run now / seed buttons.
// English only.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/background/background_run_controller.dart';
import '../../../core/background/background_task_run.dart';
import '../../../core/background/background_tasks.dart';
import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../services/dev_schedule_tools.dart';

final _runsProvider = StreamProvider.autoDispose<List<BackgroundTaskRun>>((ref) {
  final isar = ref.watch(isarProvider);
  return isar.backgroundTaskRuns
      .where()
      .sortByStartedAtDesc()
      .watch(fireImmediately: true);
});

final _migrationReportProvider = FutureProvider.autoDispose<String?>((ref) async =>
    (await SharedPreferences.getInstance()).getString(PrefsKeys.vnextMigrationReport));

class BackgroundTasksScreen extends ConsumerWidget {
  const BackgroundTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final runs = ref.watch(_runsProvider).valueOrNull ?? const [];
    final report = ref.watch(_migrationReportProvider).valueOrNull;
    final f = DateFormat('d MMM, HH:mm:ss');
    final isar = ref.read(isarProvider);
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, title: 'Background tasks'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
            KuberSpace.screenMargin, 0, KuberSpace.screenMargin, KuberSpace.xl),
        children: [
          AppButton(
            label: 'Run now',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () async {
              final started = await BackgroundTasks.start(isar, context.l10n,
                  trigger: 'manual', force: true);
              if (started) {
                ref.read(backgroundRunWatchProvider.notifier).watchFrom(DateTime.now());
              }
            },
          ),
          const SizedBox(height: KuberSpace.md),
          AppButton(
            label: 'Seed due schedule test items',
            type: AppButtonType.normal,
            fullWidth: true,
            onPressed: () async {
              final n = await seedDueScheduleItems(isar);
              if (context.mounted) showKuberSnackBar(context, 'Added $n test items');
            },
          ),
          if (report != null) ...[
            const SizedBox(height: KuberSpace.lg),
            Text('MIGRATION', style: tt.labelMedium!.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(report, style: tt.bodySmall),
          ],
          const SizedBox(height: KuberSpace.lg),
          KuberGroup(children: [
            for (final r in runs)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${r.trigger} · ${r.status} · ${f.format(r.startedAt)}',
                        style: tt.titleSmall!.copyWith(
                            color: r.status == 'failed' ? cs.error : cs.onSurface)),
                    Text(
                        '${r.finishedAt == null ? 'running' : '${r.finishedAt!.difference(r.startedAt).inMilliseconds} ms'}'
                        ' · recurring ${r.postedRecurring} · EMIs ${r.postedEmis}'
                        ' · SIPs ${r.postedSips} · matured ${r.maturedCount}'
                        ' · failed ${r.failedOccurrences} · backup ${r.backupStatus}'
                        '${r.backupError == null ? '' : ' (${r.backupError})'}',
                        style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    for (final line in r.log)
                      Text(line, style: tt.bodySmall),
                  ],
                ),
              ),
          ]),
        ],
      ),
    );
  }
}
