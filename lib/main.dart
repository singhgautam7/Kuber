import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'app.dart';
import 'core/database/isar_service.dart';
import 'core/database/migrations.dart';
import 'core/database/seed_service.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'features/notifications/providers/notification_provider.dart';
import 'features/backups/data/backup_config.dart';
import 'features/recurring/data/recurring_processor.dart';
import 'features/reminders/data/reminder_action_handler.dart';
import 'features/stories/services/welcome_story.dart';


final recurringProcessResultProvider = StateProvider<int>((ref) {
  return 0;
});

final automaticBackupDueProvider = StateProvider<bool>((ref) {
  return false;
});


class RestartWidget extends StatefulWidget {
  const RestartWidget({super.key, required this.child});

  final Widget child;

  static void restartApp(BuildContext context) {
    context.findAncestorStateOfType<_RestartWidgetState>()?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(key: key, child: widget.child);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Android 15 (SDK 35) enforces edge-to-edge. Opt in explicitly so Flutter
  // draws behind the system bars and drives bar appearance via the modern
  // WindowInsetsController path (not the deprecated Window.setStatusBarColor /
  // setNavigationBarColor APIs). Inset-aware layouts (SafeArea /
  // MediaQuery.viewPadding) keep content clear of the bars.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  await _bootstrap();
}

/// Opens the database, runs migrations and on-open processing, then launches
/// the app. A failure in the critical phase (database open / seed / migrate)
/// shows a recoverable error screen instead of crashing to a blank window —
/// real users have real data, so a corrupt DB or a throwing migration must not
/// be a dead end. On-open processing (notifications, recurring, reminders) is
/// best-effort and never blocks launch.
Future<void> _bootstrap() async {
  // Critical phase — the app cannot run without this.
  late final Isar isar;
  try {
    isar = await IsarService.open();
    await SeedService().seedInitialData(isar);
    await MigrationService.runAll(isar);
  } catch (e, stack) {
    debugPrint('Kuber: fatal startup failure (database): $e\n$stack');
    runApp(KuberStartupErrorApp(onRetry: _bootstrap));
    return;
  }

  // Best-effort on-open processing. A failure here must not prevent launch.
  String? coldStartPayload;
  int missedCount = 0;
  bool backupDue = false;
  try {
    // NotificationService captures a cold-start payload internally; the
    // foreground-tap callback is wired below. Both eventually land in
    // `pendingDeeplinkProvider` which the dashboard consumes after first frame.
    String? capturedPayload;
    await NotificationService().init(
      onTap: (payload) => capturedPayload = payload,
      // Reminder notification action buttons (Mark done / Snooze 1 hour)
      // apply directly, matching quick-action semantics.
      onAction: (actionId, payload) {
        handleReminderNotificationAction(isar, actionId, payload)
            .catchError((Object e) {
          debugPrint('Kuber: reminder action failed (non-fatal): $e');
        });
      },
    );
    // Prefer cold-start payload (set during init) over any captured later.
    coldStartPayload =
        NotificationService().consumeColdStartPayload() ?? capturedPayload;

    // If the app was LAUNCHED from a reminder action button, apply it now.
    final coldAction = NotificationService().consumeColdStartAction();
    if (coldAction != null) {
      await handleReminderNotificationAction(
        isar,
        coldAction.actionId,
        coldAction.payload,
      );
    }

    // Recurring must run before the first frame: its result decides whether
    // the splash routes to the recurring-loader screen.
    missedCount = await RecurringProcessor(isar).processAll();
    backupDue = await _isAutomaticBackupDue(isar);
    // First-launch Welcome story: a single pre-built Isar write (no aggregation)
    // so a fresh install shows a bubble immediately. All other stories generate
    // post-first-frame. Existing users just get the flag set, no Welcome.
    await maybeSeedWelcomeStory(isar);
    // The on-open ledger reminder pass is deferred to after the first frame
    // (see KuberApp) so it never delays cold start.
  } catch (e, stack) {
    debugPrint('Kuber: on-open processing failed (non-fatal): $e\n$stack');
  }

  runApp(
    RestartWidget(
      child: ProviderScope(
        overrides: [
          isarProvider.overrideWithValue(isar),
          recurringProcessResultProvider.overrideWith((ref) => missedCount),
          automaticBackupDueProvider.overrideWith((ref) => backupDue),
          if (coldStartPayload != null)
            pendingDeeplinkProvider.overrideWith((ref) => coldStartPayload),
        ],
        child: const KuberApp(),
      ),
    ),
  );
}

Future<bool> _isAutomaticBackupDue(Isar isar) async {
  final config = await isar.collection<BackupConfig>().where().findFirst();
  if (config == null || !config.enabled || config.folderUri == null) {
    return false;
  }
  final last = config.lastBackupAt;
  if (last == null) return true;
  final days = switch (config.frequency) {
    'daily' => 1,
    'monthly' => 30,
    _ => 7,
  };
  final lastLocal = last.toLocal();
  final lastMidnight = DateTime(lastLocal.year, lastLocal.month, lastLocal.day);
  final now = DateTime.now();
  final nowMidnight = DateTime(now.year, now.month, now.day);
  return nowMidnight.difference(lastMidnight).inDays >= days;
}

/// Shown when the database cannot be opened/migrated. Offers a retry that
/// re-runs the full startup sequence (handles transient locks), and stays on
/// the Vault theme so the failure still looks like Kuber.
class KuberStartupErrorApp extends StatelessWidget {
  final Future<void> Function() onRetry;

  const KuberStartupErrorApp({super.key, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(const Locale('en')),
      darkTheme: AppTheme.dark(const Locale('en')),
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final cs = theme.colorScheme;
          final tt = theme.textTheme;
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(KuberSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: cs.error,
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    Text(
                      "Couldn't open Kuber",
                      textAlign: TextAlign.center,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    Text(
                      'Something went wrong while loading your data. '
                      'Your data is still on this device — please try again, '
                      'or reopen the app.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.xl),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
