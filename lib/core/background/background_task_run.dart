import 'package:isar_community/isar.dart';

part 'background_task_run.g.dart';

/// One run of the launch task queue (due occurrences, maturity checks,
/// automatic backup). Feeds the progress snackbar, the Background tasks
/// notification and Dev tools > Background tasks. The last 30 are kept.
@collection
class BackgroundTaskRun {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String runId;

  /// 'coldStart' | 'resume' | 'retry' | 'manual'.
  late String trigger;

  @Index()
  late DateTime startedAt;
  late DateTime heartbeatAt;

  /// Process that runs it. The worker and the UI share the app process, so
  /// a "running" row from another process was killed mid-way.
  int ownerPid = 0;
  DateTime? finishedAt;

  /// 'running' | 'done' | 'failed'.
  @Index()
  late String status;

  /// 'processing' | 'maturity' | 'backup' | 'done'.
  String step = 'processing';
  int stepDone = 0;
  int stepTotal = 0;

  int postedRecurring = 0;
  int postedEmis = 0;
  int postedSips = 0;
  int maturedCount = 0;
  int failedOccurrences = 0;

  /// 'notDue' | 'running' | 'done' | 'failed'.
  String backupStatus = 'notDue';
  String? backupError;

  /// Items being processed right now: '{sourceType}:{sourceId}'. Their
  /// editors show "Processing, try again in a moment".
  List<String> busySourceKeys = [];

  List<String> log = [];

  /// The user swiped the progress snackbar away ("Continues in the
  /// background"): the result is still shown when the run finishes.
  bool snackbarDismissed = false;

  /// The result snackbar was shown (so it is shown once).
  bool resultShown = false;
}
